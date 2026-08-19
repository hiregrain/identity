package envelope_test

// The no-plaintext-in-logs half of acceptance criterion 1 has two
// enforcement points: the db-tagged tests assert every error surfaced
// during the failure paths is marker-free, and this test asserts the
// package cannot log at all — no logging or printing import exists in
// any non-test source file, so there is no sink for plaintext to leak
// into. Pure (no database), so it runs in every `go test ./...`.

import (
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestPackageHasNoLoggingSink(t *testing.T) {
	banned := map[string]bool{"log": true, "log/slog": true, "os": true}
	entries, err := os.ReadDir(".")
	if err != nil {
		t.Fatal(err)
	}
	for _, entry := range entries {
		name := entry.Name()
		if !strings.HasSuffix(name, ".go") || strings.HasSuffix(name, "_test.go") {
			continue
		}
		file, err := parser.ParseFile(token.NewFileSet(), filepath.Join(".", name), nil, parser.ImportsOnly)
		if err != nil {
			t.Fatal(err)
		}
		for _, imp := range file.Imports {
			path := strings.Trim(imp.Path.Value, `"`)
			if banned[path] {
				t.Errorf("%s imports %q — the envelope package must have no logging or printing sink", name, path)
			}
		}
		// fmt is legitimately imported for error construction; printing
		// through it is not.
		source, err := os.ReadFile(name)
		if err != nil {
			t.Fatal(err)
		}
		if strings.Contains(string(source), "fmt.Print") {
			t.Errorf("%s calls fmt.Print* — the envelope package must have no printing sink", name)
		}
	}
}
