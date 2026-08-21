// A red-path fixture, not a program: it exists to fail `go build`. It is
// its own module so the kernel's own `go vet ./...` never sees it.
module redpath/kernelsign

go 1.26.6

require github.com/hiregrain/identity/core v0.0.0

replace github.com/hiregrain/identity/core => ../../../../core
