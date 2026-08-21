package main

import (
	"bytes"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

const committed = "../../../contract/vectors"

// The kernel passes the vectors that are actually committed, not the ones
// the builders would produce right now. Those are the same thing only when
// the next test also passes.
func TestKernelPassesTheCommittedVectors(t *testing.T) {
	if err := check(committed); err != nil {
		t.Fatal(err)
	}
}

// Regeneration is byte-identical, which is what makes the committed files
// reviewable: a reviewer regenerates and diffs rather than reading base64.
func TestRegenerationIsByteIdentical(t *testing.T) {
	fresh := t.TempDir()
	if err := generate(fresh); err != nil {
		t.Fatal(err)
	}
	for _, name := range []string{canonicalizationFile, signVerifyFile} {
		want, err := os.ReadFile(filepath.Join(committed, name))
		if err != nil {
			t.Fatal(err)
		}
		got, err := os.ReadFile(filepath.Join(fresh, name))
		if err != nil {
			t.Fatal(err)
		}
		if !bytes.Equal(want, got) {
			t.Fatalf("%s differs from a fresh generation; run `make vectors` and commit the result", name)
		}
	}
}

// A mutated vector must fail rather than being tolerated. This is the Go
// half of the acceptance; the Makefile red path runs the same mutation
// through both language runners.
func TestAMutatedVectorFails(t *testing.T) {
	mutated := t.TempDir()
	if err := generate(mutated); err != nil {
		t.Fatal(err)
	}

	path := filepath.Join(mutated, canonicalizationFile)
	var vectors CanonicalizationVectors
	if err := readJSON(path, &vectors); err != nil {
		t.Fatal(err)
	}
	for i := range vectors.Cases {
		if vectors.Cases[i].Canonical != "" {
			vectors.Cases[i].Canonical += " "
			break
		}
	}
	encoded, err := json.MarshalIndent(vectors, "", "  ")
	if err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, append(encoded, '\n'), 0o644); err != nil {
		t.Fatal(err)
	}

	if err := check(mutated); err == nil {
		t.Fatal("a mutated canonicalization vector was accepted")
	}
}
