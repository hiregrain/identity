// Command deletion is the deletion-promise runner's CLI (foundation/08).
//
//	deletion destroy -closure <uuid>[,<uuid>...] -requester <worker|support>
//	deletion replay
//	deletion purge -initiated-by <who>
//	deletion status
//
// destroy journals every closure member on the spine, then destroys the
// payload-plane keys (core/envelope). replay re-applies the whole
// deletion journal and balances every open restore gate, the step a
// restored payload plane refuses traffic without. purge physically
// removes shredded registry rows as identity_purge, audited in the same
// transaction; run it on the schedule db/deletion-policy.json states.
// status reports the restore gate: exit 0 serving, exit 1 gated. This is
// the operational surface until real infrastructure exists, like the
// outbox reconciler's exit code.
//
// Exit codes: 0 success (status: serving); 1 failure (status: gated);
// 2 usage.
package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"strings"

	"github.com/hiregrain/identity/core/deletion"
)

func main() {
	if len(os.Args) < 2 {
		usage()
	}
	command, args := os.Args[1], os.Args[2:]
	flags := flag.NewFlagSet(command, flag.ExitOnError)
	closure := flags.String("closure", "",
		"destroy: the COMPLETE alias closure, comma-separated lowercase uuids (an unmerged person is one id)")
	requester := flags.String("requester", "",
		"destroy: requester class, one of "+strings.Join(deletion.RequesterClasses, ", "))
	initiatedBy := flags.String("initiated-by", "",
		"purge: who asked for this run (recorded in purge_audit)")
	if err := flags.Parse(args); err != nil {
		os.Exit(2)
	}

	ctx := context.Background()
	switch command {
	case "destroy":
		env, err := deletion.NewEnvelope()
		fail(err)
		ids := strings.Split(*closure, ",")
		if *closure == "" {
			ids = nil
		}
		fail(deletion.Destroy(ctx, env, ids, *requester))
		fmt.Printf("destroy: %d person id(s) journaled and destroyed\n", len(ids))
	case "replay":
		env, err := deletion.NewEnvelope()
		fail(err)
		_, err = deletion.Replay(ctx, env)
		fail(err)
	case "purge":
		_, err := deletion.Purge(*initiatedBy)
		fail(err)
	case "status":
		open, err := deletion.OpenRestores()
		fail(err)
		if len(open) > 0 {
			for _, id := range open {
				fmt.Printf("status: GATED. restore %s awaits the deletion replay\n", id)
			}
			os.Exit(1)
		}
		fmt.Println("status: serving (no restore awaits replay)")
	default:
		usage()
	}
}

func fail(err error) {
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, "usage: deletion <destroy|replay|purge|status> [flags]")
	os.Exit(2)
}
