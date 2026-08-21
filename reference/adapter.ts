// The differential adapter protocol, and the reference model's
// implementation of it.
//
// An implementation joins the harness as a subprocess speaking
// line-delimited JSON: one request object per line on stdin, one
// response object per line on stdout, in order, one response per
// request. The kernel joins the same way when trust-kernel/01 lands; the
// harness knows nothing about either side beyond this protocol, which is
// what keeps it from being written to one implementation's shape.
//
// Request, one of:
//   {"op":"canonicalize","value":<any JSON value>}
//   {"op":"sign","payload":<any JSON value>,"seedHex":"<64 hex>"}
//   {"op":"verify","envelope":"<compact JWS>","publicKeyHex":"<64 hex>"}
//   {"op":"publicKey","seedHex":"<64 hex>"}
//
// Response:
//   {"ok":true,"out":"<lowercase hex of the produced bytes>"}
//   {"ok":false,"error":"<free text>"}
//
// Only `ok` and `out` are compared. `error` is free text because
// implementations must agree on *whether* an input is rejected, never on
// how they word it; a harness that compared messages would report a
// divergence on every wording difference and teach its readers to ignore
// it.
//
// Every `out` is hex so that a comparison is a string comparison over
// bytes, with no encoding of the harness's own interposed. `sign` and
// `publicKey` return the hex of their ASCII output.
//
// Both directions are pure ASCII, every non-ASCII code point written as
// a `\uXXXX` escape. This is not decoration. Node's readline splits a
// stream on U+2028 and U+2029 as well as on newline, so a request
// carrying either one, and rule 1's corpus carries both, arrives as two
// requests and the run desynchronizes. Escaping also removes any
// question of what encoding a non-JS adapter reads its stdin in.
// Enforced by `encodeLine` below, which every writer on both sides uses.

import { createInterface } from "node:readline";
import {
  CONTRACT_RULES,
  canonicalizeWith,
  type CanonicalRules,
  type JsonValue,
} from "./canonical.ts";
import { canonicalVerdict, publicHexFromSeedHex, signEnvelope } from "./jws.ts";

export type Request =
  | { op: "canonicalize"; value: JsonValue }
  | { op: "sign"; payload: JsonValue; seedHex: string }
  | { op: "verify"; envelope: string; publicKeyHex: string }
  | { op: "publicKey"; seedHex: string };

export type Response = { ok: true; out: string } | { ok: false; error: string };

/**
 * JSON text for a request or a response, with one repair.
 * `JSON.stringify(-0)` is "0", so a wire format built on it silently
 * destroys negative zero, which is the first case rule 2 names. The
 * harness would then be structurally unable to test that rule, and would
 * report agreement on it forever. JSON itself has no such problem: the
 * text `-0` parses back to negative zero in every decoder, so only the
 * encoder needs replacing. Found by the `number-format-negative-zero`
 * mutant, which the harness could not catch until this was fixed; the
 * Makefile's `differential-red` keeps it that way.
 *
 * Key order here is insertion order, deliberately not sorted. Sorting is
 * the thing under test, and a harness that pre-sorted its own input
 * would hand the answer to both implementations.
 */
export function encodeJson(value: unknown): string {
  if (typeof value === "number" && Object.is(value, -0)) return "-0";
  if (Array.isArray(value)) {
    return `[${value.map((item) => encodeJson(item)).join(",")}]`;
  }
  if (value !== null && typeof value === "object") {
    const members = Object.entries(value).map(
      ([key, member]) => `${JSON.stringify(key)}:${encodeJson(member)}`,
    );
    return `{${members.join(",")}}`;
  }
  return JSON.stringify(value);
}

/** One protocol line: JSON with every non-ASCII code point escaped. */
export function encodeLine(value: unknown): string {
  const json = encodeJson(value);
  let line = "";
  for (let index = 0; index < json.length; index += 1) {
    const unit = json.charCodeAt(index);
    line +=
      unit >= 0x20 && unit < 0x7f
        ? json[index]
        : `\\u${unit.toString(16).padStart(4, "0")}`;
  }
  return `${line}\n`;
}

/** Answers one request under a given reading of the contract. */
export function respond(request: Request, rules: CanonicalRules): Response {
  try {
    switch (request.op) {
      case "canonicalize":
        return hex(canonicalizeWith(request.value, rules));
      case "sign":
        return ascii(signEnvelope(request.payload, request.seedHex, rules));
      case "verify":
        return hex(canonicalVerdict(request.envelope, request.publicKeyHex));
      case "publicKey":
        return ascii(publicHexFromSeedHex(request.seedHex));
      default:
        return { ok: false, error: `unknown op` };
    }
  } catch (cause) {
    return { ok: false, error: String(cause) };
  }
}

function hex(bytes: Uint8Array): Response {
  return { ok: true, out: Buffer.from(bytes).toString("hex") };
}

function ascii(text: string): Response {
  return { ok: true, out: Buffer.from(text, "ascii").toString("hex") };
}

/** Drives stdin to stdout. Exported so the mutant reuses it verbatim. */
export async function serve(rules: CanonicalRules): Promise<void> {
  const lines = createInterface({ input: process.stdin, crlfDelay: Infinity });
  for await (const line of lines) {
    if (line.trim() === "") continue;
    let response: Response;
    try {
      response = respond(JSON.parse(line) as Request, rules);
    } catch (cause) {
      response = { ok: false, error: `unreadable request: ${String(cause)}` };
    }
    process.stdout.write(encodeLine(response));
  }
}

if (process.argv[1] === import.meta.filename) {
  await serve(CONTRACT_RULES);
}
