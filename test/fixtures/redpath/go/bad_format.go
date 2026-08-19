// Red-path fixture: deliberately misformatted Go. Outside the core/
// module so no normal build sees it; `make check-red` points gofmt here
// and asserts it is flagged.
package redpath

func misformatted() int {
	x :=      1
		return x }
