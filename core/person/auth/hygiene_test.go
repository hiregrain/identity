package auth

// The standing proof that the code path stays equal.
//
// Decision 013 rules that one-time codes are an always-available equal
// path and decision 086 defers session assurance to the verification
// layer, so nothing in this package may decide anything from how a
// session was authenticated. The behavioural half of that is the
// acceptance suite, which runs every operation from both kinds of
// session. This is the structural half: a comparison against the method
// constants is a decision waiting to be made, and it fails here whether
// or not any test happens to exercise the branch it guards.
//
// It reads this package's own source, which is why it lives inside the
// package rather than beside its tests.

import (
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"strings"
	"testing"
)

func TestNothingBranchesOnHowASessionWasAuthenticated(t *testing.T) {
	entries, err := os.ReadDir(".")
	if err != nil {
		t.Fatalf("reading the package directory: %v", err)
	}
	fset := token.NewFileSet()
	for _, entry := range entries {
		name := entry.Name()
		if !strings.HasSuffix(name, ".go") || strings.HasSuffix(name, "_test.go") {
			continue
		}
		file, err := parser.ParseFile(fset, name, nil, 0)
		if err != nil {
			t.Fatalf("parsing %s: %v", name, err)
		}
		ast.Inspect(file, func(node ast.Node) bool {
			switch n := node.(type) {
			case *ast.BinaryExpr:
				if n.Op != token.EQL && n.Op != token.NEQ {
					return true
				}
				if methodConstant(n.X) || methodConstant(n.Y) {
					t.Errorf("%s: a comparison against a method constant at %s; "+
						"decision 013 forbids the code path being treated differently",
						name, fset.Position(n.Pos()))
				}
			case *ast.SwitchStmt:
				for _, stmt := range n.Body.List {
					clause, ok := stmt.(*ast.CaseClause)
					if !ok {
						continue
					}
					for _, expr := range clause.List {
						if methodConstant(expr) {
							t.Errorf("%s: a switch case on a method constant at %s; "+
								"decision 013 forbids the code path being treated differently",
								name, fset.Position(expr.Pos()))
						}
					}
				}
			}
			return true
		})
	}
}

// methodConstant reports whether an expression names MethodPasskey or
// MethodCode.
func methodConstant(expr ast.Expr) bool {
	ident, ok := expr.(*ast.Ident)
	if !ok {
		return false
	}
	return ident.Name == "MethodPasskey" || ident.Name == "MethodCode"
}

// The stated defaults hold together only as a set: five guesses against
// a six-digit code inside ten minutes is one decision, and changing any
// number alone changes what the other two mean. This states the
// relationship the comments describe, so a later edit that moves one
// number has to look at the others.
func TestTheCodeDefaultsHoldTogether(t *testing.T) {
	space := 1
	for i := 0; i < CodeDigits; i++ {
		space *= 10
	}
	guesses := MaxAttemptsPerChallenge * MaxChallengesPerWindow
	if odds := space / guesses; odds < 10000 {
		t.Fatalf("an attacker gets one chance in %d per window; the code space, "+
			"the attempt limit and the request limit have drifted apart", odds)
	}
	if CodeTTL >= ChallengeWindow {
		t.Fatalf("a code outlives the window that limits how many can be asked for "+
			"(%v against %v), so the request limit does not bound live codes",
			CodeTTL, ChallengeWindow)
	}
}
