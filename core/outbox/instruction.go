package outbox

import (
	"encoding/json"
	"fmt"
	"regexp"
	"sort"
	"strings"

	"github.com/hiregrain/identity/core/transport"
)

// Instruction is the payload-apply instruction an outbox entry carries:
// one row for one payload table. The worker adds the idempotency key.
// Every outbox-written payload table carries an
// `outbox_entry_id spine_object_id` column with a UNIQUE constraint,
// and the default apply is INSERT ... ON CONFLICT (outbox_entry_id) DO
// NOTHING, so idempotency is the database's unique index, not worker
// memory.
//
// ConflictConstraint is the one documented escape hatch from that
// default, for a table that also needs idempotency on its OWN logical
// key: a re-drained entry always retries with a fresh outbox_entry_id
// (person-identity/04, core/person.WriteIndex generates a new one per
// call), so outbox_entry_id alone cannot dedupe a second call's rows
// against the first's. When set, ApplySQL renders ON CONFLICT ON
// CONSTRAINT <name> DO NOTHING against that named constraint instead of
// outbox_entry_id. This still catches a genuine crash-and-retry of the
// SAME entry, as long as the caller's own logical key is itself
// deterministic from the entry's content (name_index_entry's is: a
// retry re-derives and re-seals the identical token, landing the
// identical logical key even though the ciphertext differs). A prior
// version of this package instead widened the DEFAULT to a blanket,
// unspecified ON CONFLICT DO NOTHING to get name_index_entry its
// idempotency, which caught every unique constraint on every table, not
// just the one that needed it: person_record's UNIQUE(person_id)
// (migration 0036) silently swallowed a duplicate-person_id instruction
// the same way, where it used to raise. A named, per-instruction target
// is what makes an opt-in an opt-in rather than a change to everyone's
// contract.
//
// The payload plane has no product content tables yet (foundation/05
// owns the DEK registry; later layers own content), so instruction
// consumers today are the test-scoped tables the acceptance harness
// creates plus core/person's tables. The shape is deliberately minimal;
// a layer needing more than one row per instruction extends this with
// its own decision trail.
type Instruction struct {
	Table string         `json:"table"`
	Row   map[string]any `json:"row"`
	// ConflictConstraint names a table-level UNIQUE (or exclusion)
	// constraint ON CONFLICT ON CONSTRAINT should target instead of the
	// default outbox_entry_id. Empty for every table but
	// name_index_entry (core/person); naming one is a documented,
	// per-table opt-in, never a blanket switch (see the type comment).
	ConflictConstraint string `json:"conflict_constraint,omitempty"`
}

// identifier is the only shape accepted for table names, column names,
// and constraint names. Instructions are data from the outbox, and
// interpolating anything fancier into SQL is an injection surface.
var identifier = regexp.MustCompile(`^[a-z_][a-z0-9_]*$`)

var uuidShape = regexp.MustCompile(
	`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)

// reservedColumns are the columns an instruction may never carry,
// because something other than the instruction owns their value:
//
//   - outbox_entry_id is the worker's idempotency key, written by
//     ApplySQL itself (migration 0020).
//   - residency_region is the database's own declaration. 0004 makes
//     the DATABASE authoritative and the payload tables take the value
//     from a column default that reads database_residency. A default
//     is only a default, so an instruction naming the column would
//     override it and choose its own region; refusing the name here is
//     what makes the stamp binding rather than customary.
var reservedColumns = map[string]string{
	"outbox_entry_id": "the worker's column, not the instruction's",
	"residency_region": "the database's own declaration, taken from a column default; " +
		"an instruction may not choose a region",
}

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
		if why, reserved := reservedColumns[column]; reserved {
			return fmt.Errorf("instruction: %s is %s", column, why)
		}
	}
	if in.ConflictConstraint != "" && !identifier.MatchString(in.ConflictConstraint) {
		return fmt.Errorf("instruction: conflict_constraint %q is not a valid identifier", in.ConflictConstraint)
	}
	return nil
}

// ApplySQL renders the idempotent INSERT for one entry. Columns are
// emitted in sorted order so the same instruction always renders the
// same statement. Values are rendered through core/transport's typed
// Arg literals (trust-kernel/08, decision 065): this is the one
// legitimate caller that must pre-render a full statement, because an
// instruction's row shape is arbitrary and external, not a fixed
// $n-placeholder query.
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
		arg, err := argFor(in.Row[column])
		if err != nil {
			return "", fmt.Errorf("instruction: column %q: %w", column, err)
		}
		literal, err := transport.Literal(arg)
		if err != nil {
			return "", fmt.Errorf("instruction: column %q: %w", column, err)
		}
		values = append(values, literal)
	}
	entryLiteral, err := transport.Literal(transport.String(entryID))
	if err != nil {
		return "", err
	}
	conflict := "ON CONFLICT (outbox_entry_id) DO NOTHING"
	if in.ConflictConstraint != "" {
		conflict = "ON CONFLICT ON CONSTRAINT " + in.ConflictConstraint + " DO NOTHING"
	}
	return fmt.Sprintf(
		"INSERT INTO %s (outbox_entry_id, %s)\nVALUES (%s, %s)\n%s;",
		in.Table, strings.Join(columns, ", "), entryLiteral, strings.Join(values, ", "), conflict,
	), nil
}

// argFor maps one JSON value to a transport.Arg. Nested objects and
// arrays are rejected: an instruction is one flat row.
func argFor(value any) (transport.Arg, error) {
	switch v := value.(type) {
	case nil:
		return transport.Null, nil
	case string:
		return transport.String(v), nil
	case bool:
		return transport.Bool(v), nil
	case float64:
		return transport.Float(v), nil
	default:
		return nil, fmt.Errorf("unsupported value type %T", value)
	}
}

// validUUID gates every entry id interpolated into SQL.
func validUUID(id string) error {
	if !uuidShape.MatchString(id) {
		return fmt.Errorf("entry id %q is not a lowercase UUID", id)
	}
	return nil
}
