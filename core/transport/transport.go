// Package transport is the one seam every SQL path in this repo crosses
// (trust-kernel/08, decision 065). It owns how Go code reaches the two
// plane databases: today that is `docker compose exec psql`; the
// eventual Postgres-driver decision (plans/ORDER.md's decision gates)
// changes this file and nothing else, because every other package
// reaches a plane through Query or Tx and never through docker, psql,
// or a database/sql driver directly (checks/transport-seam.mjs
// enforces the exclusivity, with no test-file exemption).
//
// The API is driver-shaped with two verbs (decision 065): Query for a
// single statement, Tx for multi-statement transactional work, inside
// which the outbox's crash-point protocol keeps its abort-by-exit
// semantics (Tx.CrashPoint). Args are typed (Arg), never pre-rendered
// strings, so SQL safety lives in this one renderer rather than in
// call-site discipline: quotes are escaped by doubling, a NUL byte is
// always refused, nil renders the SQL keyword NULL and never the
// four-character text 'NULL', and hex bytea rendering happens only
// through the Bytea wrapper, never inferred from a string's shape.
//
// Row format is the outbox's bounded tab split: psql is asked for
// tab-separated fields, and a caller who expects more than one column
// reads a line with SplitRow(line, columns), the last field unbounded.
// An unbounded split corrupts any free-text field containing the
// separator.
package transport

import (
	"context"
	"encoding/hex"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
	"sync"
)

// Arg is a typed SQL argument the renderer turns into a literal. This
// is rendering into a `psql -c` script, not wire-protocol
// parameterization: there is no placeholder binding underneath, which
// is exactly why every case is explicit below and none infers a type
// from a string's shape.
type Arg interface {
	sqlLiteral() (string, error)
}

type stringArg string

// String is a text argument. Quotes are escaped by doubling; a NUL
// byte is always refused rather than silently dropped. A value shaped
// like hex bytea (a leading `\x`) still renders as text here: hex
// rendering happens only through Bytea, never by sniffing a string's
// shape.
func String(s string) Arg { return stringArg(s) }

func (a stringArg) sqlLiteral() (string, error) {
	s := string(a)
	if strings.IndexByte(s, 0) >= 0 {
		return "", fmt.Errorf("transport: string argument contains a NUL byte")
	}
	return "'" + strings.ReplaceAll(s, "'", "''") + "'", nil
}

type nilArg struct{}

// Null is the SQL NULL argument: it renders as the keyword NULL, never
// as the four-character text 'NULL'.
var Null Arg = nilArg{}

func (nilArg) sqlLiteral() (string, error) { return "NULL", nil }

type boolArg bool

// Bool is a boolean argument.
func Bool(b bool) Arg { return boolArg(b) }

func (a boolArg) sqlLiteral() (string, error) { return strconv.FormatBool(bool(a)), nil }

type floatArg float64

// Float is a floating-point numeric argument.
func Float(f float64) Arg { return floatArg(f) }

func (a floatArg) sqlLiteral() (string, error) {
	return strconv.FormatFloat(float64(a), 'g', -1, 64), nil
}

// Bytea is the one wrapper type that renders as a hex bytea literal.
// It is the only path to that rendering: no other Arg derives it from
// a string's shape. hex.EncodeToString never emits a quote, a
// backslash, or a NUL, so the literal needs no further escaping.
type Bytea []byte

func (b Bytea) sqlLiteral() (string, error) {
	return fmt.Sprintf(`'\x%x'`, []byte(b)), nil
}

// Literal renders one Arg as a SQL literal outside a Query or Tx call.
// The one legitimate caller is core/outbox/instruction.go, which
// assembles a full INSERT statement from an externally supplied
// instruction row rather than a fixed $n-placeholder query. Everywhere
// else, pass Args to Query or Tx and let $n substitution do this.
func Literal(a Arg) (string, error) { return a.sqlLiteral() }

// placeholderPattern finds every $n token in a statement. A single
// left-to-right scan of the ORIGINAL sql, below, is what makes
// substitution safe: repeated whole-string ReplaceAll passes (the
// prior implementation) rescan literals already inserted, so a String
// argument containing the text "$1" is reinterpreted as a placeholder
// on a later pass and replaced again, breaking the statement out from
// under its own escaping. This scan never revisits substituted text.
var placeholderPattern = regexp.MustCompile(`\$(\d+)`)

// render substitutes $n placeholders with rendered literals in one
// pass over sql, emitting each literal into its position rather than
// scanning the growing output. An argument's rendered text, including
// one that itself contains "$1", "$$", or any other $n-shaped
// substring, reaches the statement verbatim: it is written once, at
// its match position, and never looked at again for further $n
// matches.
func render(sql string, args []Arg) (string, error) {
	literals := make([]string, len(args))
	for i, a := range args {
		lit, err := a.sqlLiteral()
		if err != nil {
			return "", fmt.Errorf("transport: arg %d: %w", i+1, err)
		}
		literals[i] = lit
	}
	var out strings.Builder
	last := 0
	for _, m := range placeholderPattern.FindAllStringSubmatchIndex(sql, -1) {
		start, end := m[0], m[1]
		n, err := strconv.Atoi(sql[m[2]:m[3]])
		if err != nil {
			return "", fmt.Errorf("transport: malformed placeholder %q", sql[start:end])
		}
		if n < 1 || n > len(literals) {
			return "", fmt.Errorf("transport: placeholder $%d has no matching argument (%d given)", n, len(literals))
		}
		out.WriteString(sql[last:start])
		out.WriteString(literals[n-1])
		last = end
	}
	out.WriteString(sql[last:])
	return out.String(), nil
}

// SplitRow splits one tab-separated result line into exactly columns
// fields, the last field unbounded. This is the one row-parsing format
// the repo uses (decision 065): an unbounded split corrupts any
// free-text field containing the separator.
func SplitRow(line string, columns int) []string {
	return strings.SplitN(line, "\t", columns)
}

// standard_conforming_strings guards the one assumption String's
// escaping makes: quote-doubling alone is a correct SQL-string escape
// only if a plain quoted literal does not itself process backslash
// escapes. Off, a payload's backslash could combine with the
// following character into an escape sequence the renderer never
// intended, inside a literal the renderer believed was inert.
// Postgres has defaulted this on since 9.1 (2011) and the pinned image
// this repo runs (postgres:18) inherits that default, so the setting
// is not reachable off in this repo's own config; asserted live and
// once per plane anyway, because correctness at the one SQL chokepoint
// should not rest on an assumption nothing checks. Preferred over
// rendering every string through decode('..','hex') or dollar-quoting
// (the other option raised): those change every literal's shape for a
// setting this repo's own compose config never varies, where a single
// live assertion, cached, costs one extra query per plane for the
// process's lifetime and fails loudly the moment it would matter.
var (
	scsMu      sync.Mutex
	scsChecked = map[string]error{}
)

func assertStandardConformingStrings(plane, role string) error {
	scsMu.Lock()
	if err, checked := scsChecked[plane]; checked {
		scsMu.Unlock()
		return err
	}
	scsMu.Unlock()

	out, err := psql(plane, role, []string{"-tAq", "-c", "SHOW standard_conforming_strings"}, "")
	var result error
	if err != nil {
		result = fmt.Errorf("transport: checking standard_conforming_strings on %s: %w", plane, err)
	} else if got := strings.TrimSpace(out); got != "on" {
		result = fmt.Errorf(
			"transport: %s has standard_conforming_strings = %q, want \"on\": "+
				"String's quote-doubling escape assumes a plain quoted literal "+
				"does not process backslash escapes", plane, got)
	}

	scsMu.Lock()
	scsChecked[plane] = result
	scsMu.Unlock()
	return result
}

// Query executes one statement with $n placeholders against plane as
// role, returning tab-separated result lines. A caller expecting more
// than one column reads each line with SplitRow.
func Query(plane, role, sql string, args ...Arg) ([]string, error) {
	if err := assertStandardConformingStrings(plane, role); err != nil {
		return nil, err
	}
	rendered, err := render(sql, args)
	if err != nil {
		return nil, err
	}
	out, err := psql(plane, role, []string{"-tAq", "-F", "\t", "-c", rendered}, "")
	if err != nil {
		return nil, err
	}
	trimmed := strings.TrimSpace(out)
	if trimmed == "" {
		return nil, nil
	}
	return strings.Split(trimmed, "\n"), nil
}

// Tx is one multi-statement transactional script under construction.
type Transaction struct {
	plane, role string
	stmts       []string
}

// Exec adds one statement with $n placeholders to the transaction.
func (tx *Transaction) Exec(sql string, args ...Arg) error {
	rendered, err := render(sql, args)
	if err != nil {
		return err
	}
	tx.stmts = append(tx.stmts, rendered)
	return nil
}

// ExecLiteral adds one already-rendered statement to the transaction,
// for the one caller (core/outbox/instruction.go, via Literal) that
// must pre-render a statement from an externally supplied row rather
// than a fixed $n-placeholder query.
func (tx *Transaction) ExecLiteral(sql string) { tx.stmts = append(tx.stmts, sql) }

func (tx *Transaction) openScript() string {
	return "BEGIN;\n" + strings.Join(tx.stmts, "\n") + "\n"
}

// CrashPoint exits the process (code 3, distinguishing an injected
// crash from a real failure) mid-transaction when configured matches
// point, after flushing every statement added so far as an open,
// uncommitted transaction. The disconnect aborts it: this is the
// outbox crash-point protocol's abort-by-exit semantics
// (core/outbox's CrashBeforeSpineCommit, CrashMidPayloadApply), kept
// alive across the transport seam.
func (tx *Transaction) CrashPoint(configured, point string) {
	if configured != point {
		return
	}
	if err := script(tx.plane, tx.role, tx.openScript()); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Fprintf(os.Stderr, "crash-point %s: exiting mid-flight (test injection)\n", point)
	os.Exit(3)
}

// Tx runs fn to build a transaction's statements, then commits them in
// one script. fn may call tx.CrashPoint to abort by exit instead,
// matching the outbox's crash-injection protocol.
func Tx(plane, role string, fn func(tx *Transaction) error) error {
	if err := assertStandardConformingStrings(plane, role); err != nil {
		return err
	}
	tx := &Transaction{plane: plane, role: role}
	if err := fn(tx); err != nil {
		return err
	}
	return script(plane, role, tx.openScript()+"COMMIT;")
}

// Dump returns a full schema+data pg_dump of a plane, run as the owner
// role. Verification and test harnesses need this to prove nothing
// readable survives a destroy; it is not a query, but it is still one
// database invocation, so it lives behind the one seam rather than a
// second exec.Command scattered into test files.
func Dump(plane string) (string, error) {
	cmd := exec.Command("docker", "compose", "exec", "-T", plane,
		"pg_dump", "-U", "identity", plane)
	var out, errOut strings.Builder
	cmd.Stdout = &out
	cmd.Stderr = &errOut
	if err := cmd.Run(); err != nil {
		return "", fmt.Errorf("pg_dump(%s): %s: %w", plane, firstLine(errOut.String()), err)
	}
	return out.String(), nil
}

// EnvelopeQuerier adapts the transport to core/envelope's Querier
// interface (decision 065): that interface stays untouched and
// transport-free, and this is where the seam closes at composition,
// production and test alike (core/deletion.NewEnvelope; the envelope
// and deletion db test harnesses).
//
// Every arg envelope passes through this interface is a validated
// uuid, a hex bytea value (envelope's own hexArg), or a provider name,
// per the Querier contract documented on envelope.go: never a
// caller-controlled shape this adapter has to guess at on its own
// account. That is what makes the shape-based hex detection below
// safe, though the general Arg renderer (String, Bytea) never infers
// hex from a string's shape: this adapter is bounded to the one
// interface that already guarantees the three shapes.
type EnvelopeQuerier struct {
	Plane, Role string
}

func (q EnvelopeQuerier) Query(_ context.Context, sql string, args ...string) ([][]string, error) {
	typed := make([]Arg, len(args))
	for i, a := range args {
		if b, ok := hexShape(a); ok {
			typed[i] = Bytea(b)
			continue
		}
		typed[i] = String(a)
	}
	lines, err := Query(q.Plane, q.Role, sql, typed...)
	if err != nil {
		return nil, err
	}
	return envelopeRows(lines)
}

// envelopeRows shapes raw tab-separated result lines into the
// [][]string envelope.Querier's contract expects. Every query
// envelope.go issues selects exactly one column, per its own
// documented Querier contract; this refuses a row that carries more
// rather than silently mashing a second column into the first field,
// which wrapping each line as []string{line} without checking would
// otherwise do. A future query that grows a second column fails loudly
// here instead of corrupting activeDEK's len(rows[0]) != 1 guard,
// which counts slice length, not columns.
func envelopeRows(lines []string) ([][]string, error) {
	rows := make([][]string, len(lines))
	for i, line := range lines {
		fields := SplitRow(line, 2)
		if len(fields) != 1 {
			return nil, fmt.Errorf("transport: envelope querier: expected exactly one column, row has more: %q", line)
		}
		rows[i] = fields
	}
	return rows, nil
}

// hexShape recognizes envelope's one bytea-argument shape (a leading
// `\x` followed by valid hex), the contract envelope.go documents for
// every arg it passes here.
func hexShape(s string) ([]byte, bool) {
	if !strings.HasPrefix(s, `\x`) {
		return nil, false
	}
	b, err := hex.DecodeString(s[2:])
	if err != nil {
		return nil, false
	}
	return b, true
}

// psql runs one psql invocation inside the plane's compose container as
// role, returning stdout. ON_ERROR_STOP makes any SQL error a non-zero
// exit. This, dump, and script are the only places in the repo that
// shell out to docker or psql (checks/transport-seam.mjs enforces the
// exclusivity).
func psql(plane, role string, args []string, stdin string) (string, error) {
	base := []string{
		"compose", "exec", "-T", plane,
		"psql", "-v", "ON_ERROR_STOP=1", "-U", role, "-d", plane,
	}
	cmd := exec.Command("docker", append(base, args...)...)
	if stdin != "" {
		cmd.Stdin = strings.NewReader(stdin)
	}
	var out, errOut strings.Builder
	cmd.Stdout = &out
	cmd.Stderr = &errOut
	if err := cmd.Run(); err != nil {
		return out.String(), fmt.Errorf("psql(%s as %s): %s: %w", plane, role, firstLine(errOut.String()), err)
	}
	return out.String(), nil
}

// script feeds a multi-statement SQL script to psql on stdin as role.
func script(plane, role, sql string) error {
	_, err := psql(plane, role, []string{"-f", "-"}, sql)
	return err
}

// firstLine truncates error text to its sanitized first line. Postgres
// first lines name relations, constraints and privileges, not row
// values.
func firstLine(s string) string {
	line := strings.TrimSpace(s)
	if i := strings.IndexByte(line, '\n'); i >= 0 {
		line = line[:i]
	}
	const maxLen = 200
	if len(line) > maxLen {
		line = line[:maxLen]
	}
	return line
}
