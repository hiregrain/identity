// Package planted is a synthetic fixture (trust-kernel/08's red path):
// hand-rolled psql invocations outside core/transport, the shapes
// checks/transport-seam.mjs must fail on, including the cancellable
// exec.CommandContext form a code-review finding proved was invisible
// to an exec.Command-only pattern.
package planted

import (
	"context"
	"os/exec"
)

func psql(sql string) error {
	cmd := exec.Command("docker", "compose", "exec", "-T", "payload", "psql", "-c", sql)
	return cmd.Run()
}

func psqlWithContext(ctx context.Context, sql string) error {
	cmd := exec.CommandContext(ctx, "docker", "compose", "exec", "-T", "payload", "psql", "-c", sql)
	return cmd.Run()
}
