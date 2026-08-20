// The generated types are namespaced per plane (foundation/02, decision
// 017): a payload type must not satisfy a spine-typed parameter. TS
// typing is structural and both planes carry identically shaped rows
// today, so this holds only through the per-plane unique-symbol brand,
// which is exactly what this file asserts. The @ts-expect-error line is
// the test: if the brands ever collapse and the assignment starts
// compiling, tsc fails on the now-unused directive (TS2578).

import type { SchemaMigrationsRow as SpineSchemaMigrationsRow } from "./gen/spine";
import type { SchemaMigrationsRow as PayloadSchemaMigrationsRow } from "./gen/payload";

declare function recordSpineRow(row: SpineSchemaMigrationsRow): void;
declare const spineRow: SpineSchemaMigrationsRow;
declare const payloadRow: PayloadSchemaMigrationsRow;

// Positive control: a spine row satisfies a spine-typed parameter.
recordSpineRow(spineRow);

// @ts-expect-error a payload row must not satisfy a spine-typed parameter
recordSpineRow(payloadRow);
