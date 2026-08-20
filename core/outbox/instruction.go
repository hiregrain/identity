package outbox

import (
	"encoding/json"
	"fmt"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

// Instruction is the payload-apply instruction an outbox entry carries:
// one row for one payload table. The worker adds the idempotency key.
// Every outbox-written payload table carries an
// `outbox_entry_id spine_object_id` column with a UNIQUE constraint,
// and the apply is INSERT ... ON CONFLICT (outbox_entry_id) DO NOTHING,
// so idempotency is the database's unique index, not worker memory.
//
// The payload plane has no product content tables yet (foundation/05
// owns the DEK registry; later layers own content), so instruction
// consumers today are the test-scoped tables the acceptance harness
// creates. The shape is deliberately minimal; a layer needing more than
// one row per instruction extends this with its own decision trail.
type Instruction struct {
	Table string         `json:"table"`
	Row   map[string]any `json:"row"`
}

// identifier is the only shape accepted for table and column names.
// Instructions are data from the outbox, and interpolating anything
// fancier into SQL is an injection surface.
var identifier = regexp.MustCompile(`^[a-z_][a-z0-9_]*$`)

var uuidShape = regexp.MustCompile(
	`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)

// Parse decodes and validates an instruction's raw bytes.
func Parse(raw []byte) (Instruction, error) {
	var in Instruction
	if err := json.Unmarshal(raw, &in); err != nil {
		return Instruction{}, fmt.Errorf("instruction: not valid JSON: %w", err)
	}
	if err := in.validate(); err != nil {
		return Instruction{}, err
	}
	return in, nil
}

func (in Instruction) validate() error {
	if !identifier.MatchString(in.Table) {
		return fmt.Errorf("instruction: table %q is not a valid identifier", in.Table)
	}
	if len(in.Row) == 0 {
		return fmt.Errorf("instruction: row has no columns")
	}
	for column := range in.Row {
		if !identifier.MatchString(column) {
			return fmt.Errorf("instruction: column %q is not a valid identifier", column)
		}
		if column == "outbox_entry_id" {
			return fmt.Errorf("instruction: outbox_entry_id is the worker's column, not the instruction's")
		}
	}
	return nil
}

// ApplySQL renders the idempotent INSERT for one entry. Columns are
// emitted in sorted order so the same instruction always renders the
// same statement.
func (in Instruction) ApplySQL(entryID string) (string, error) {
	if err := validUUID(entryID); err != nil {
		return "", err
	}
	if err := in.validate(); err != nil {
		return "", err
	}
	columns := make([]string, 0, len(in.Row))
	for column := range in.Row {
		columns = append(columns, column)
	}
	sort.Strings(columns)
	values := make([]string, 0, len(columns))
	for _, column := range columns {
		literal, err := sqlLiteral(in.Row[column])
		if err != nil {
			return "", fmt.Errorf("instruction: column %q: %w", column, err)
		}
		values = append(values, literal)
	}
	return fmt.Sprintf(
		"INSERT INTO %s (outbox_entry_id, %s)\nVALUES ('%s', %s)\nON CONFLICT (outbox_entry_id) DO NOTHING;",
		in.Table, strings.Join(columns, ", "), entryID, strings.Join(values, ", "),
	), nil
}

// sqlLiteral renders one JSON value as a SQL literal. Strings are
// single-quoted with quotes doubled; numbers and booleans render
// bare; null renders NULL. Nested objects and arrays are rejected.
// An instruction is one flat row.
func sqlLiteral(value any) (string, error) {
	switch v := value.(type) {
	case nil:
		return "NULL", nil
	case string:
		return "'" + quoteText(v) + "'", nil
	case bool:
		return strconv.FormatBool(v), nil
	case float64:
		return strconv.FormatFloat(v, 'g', -1, 64), nil
	default:
		return "", fmt.Errorf("unsupported value type %T", value)
	}
}

// quoteText doubles single quotes for a standard-conforming string
// literal.
func quoteText(s string) string {
	return strings.ReplaceAll(s, "'", "''")
}

// validUUID gates every entry id interpolated into SQL.
func validUUID(id string) error {
	if !uuidShape.MatchString(id) {
		return fmt.Errorf("entry id %q is not a lowercase UUID", id)
	}
	return nil
}
