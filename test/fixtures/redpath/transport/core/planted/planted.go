// Package planted is a synthetic fixture (trust-kernel/08's red path):
// a hand-rolled psql invocation outside core/transport, the shape
// checks/transport-seam.mjs must fail on.
package planted

import "os/exec"

func psql(sql string) error {
	cmd := exec.Command("docker", "compose", "exec", "-T", "payload", "psql", "-c", sql)
	return cmd.Run()
}
