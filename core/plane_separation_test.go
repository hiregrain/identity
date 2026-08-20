package core

import (
	"reflect"
	"testing"

	"github.com/hiregrain/identity/core/gen/payload"
	"github.com/hiregrain/identity/core/gen/spine"
)

// The generated types are namespaced per plane (foundation/02, decision
// 017): a payload type must not satisfy a spine-typed parameter, even
// when the row shapes coincide, as they do today, with both planes
// carrying only schema_migrations. Go assignability is what parameter passing
// uses, so AssignableTo false in both directions is the claim, asserted
// against the identically shaped pair so the test cannot pass by shape
// divergence alone.
func TestPayloadTypeCannotSatisfySpineParameter(t *testing.T) {
	spineRow := reflect.TypeOf(spine.SchemaMigrationsRow{})
	payloadRow := reflect.TypeOf(payload.SchemaMigrationsRow{})

	if payloadRow.AssignableTo(spineRow) {
		t.Fatal("payload.SchemaMigrationsRow satisfies a spine-typed parameter; the plane namespaces have collapsed")
	}
	if spineRow.AssignableTo(payloadRow) {
		t.Fatal("spine.SchemaMigrationsRow satisfies a payload-typed parameter; the plane namespaces have collapsed")
	}
	if !spineRow.AssignableTo(spineRow) {
		t.Fatal("positive control failed: a spine row must satisfy a spine-typed parameter")
	}
}
