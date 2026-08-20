// Command outbox is the cross-plane write worker's CLI (foundation/07).
//
//	outbox enqueue -entry-id <uuid> [-crash-point <p>]   instruction JSON on stdin
//	outbox drain [-crash-point <p>]
//	outbox apply -entry-id <uuid>                        manual replay, ack state ignored
//	outbox reconcile -threshold <seconds>
//
// Exit codes: 0 success; 1 failure; 2 usage; 3 injected crash. reconcile
// exits 1 when any entry is past the threshold. That non-zero exit is
// the alert surface until real alerting infrastructure exists, and the
// listed lines are the queue items.
package main

import (
	"flag"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/hiregrain/identity/core/outbox"
)

func main() {
	if len(os.Args) < 2 {
		usage()
	}
	command, args := os.Args[1], os.Args[2:]
	flags := flag.NewFlagSet(command, flag.ExitOnError)
	entryID := flags.String("entry-id", "", "outbox entry id (lowercase UUID)")
	crashPoint := flags.String("crash-point", "",
		"test injection: exit mid-flight at one of "+strings.Join(outbox.CrashPoints, ", "))
	threshold := flags.Int("threshold", 60,
		"reconcile: seconds an entry may sit unacknowledged before it is a queue item")
	if err := flags.Parse(args); err != nil {
		os.Exit(2)
	}

	switch command {
	case "enqueue":
		instruction, err := io.ReadAll(os.Stdin)
		fail(err)
		fail(outbox.Enqueue(*entryID, instruction, *crashPoint))
		fmt.Printf("enqueue: entry %s recorded (spine transaction committed)\n", *entryID)
	case "drain":
		_, _, err := outbox.Drain(*crashPoint)
		fail(err)
	case "apply":
		entry, err := outbox.Get(*entryID)
		fail(err)
		fail(outbox.Apply(entry, *crashPoint))
		fmt.Printf("apply: entry %s applied (idempotent; ack state untouched)\n", *entryID)
	case "reconcile":
		stragglers, err := outbox.Reconcile(*threshold)
		fail(err)
		if stragglers > 0 {
			os.Exit(1)
		}
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
	fmt.Fprintln(os.Stderr, "usage: outbox <enqueue|drain|apply|reconcile> [flags]")
	os.Exit(2)
}
