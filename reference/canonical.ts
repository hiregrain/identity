// Canonicalization, read from contract/CONTRACT.md rules 1 and 2 alone.
// This file is one half of a differential pair: the kernel is the other,
// and the harness (reference/harness/differential.ts) is what makes the
// pair mean anything. Nothing here may be written by consulting the
// kernel, because two implementations sharing an author share their
// misreadings and then agree on being wrong.

/** A value the contract's rule 1 admits. `undefined` is not JSON. */
export type JsonValue =
  null | boolean | number | string | JsonValue[] | { [key: string]: JsonValue };

/**
 * The three points where rules 1 and 2 make a choice another reading
 * could get wrong. They are named and swappable so the harness can
 * plant a bug in one of them and prove it catches the divergence
 * (reference/harness/mutant.ts, and the differential red paths in the
 * Makefile). Acceptance criterion 2 of plans/trust-kernel/06 is the
 * reason this seam exists; it is not general configurability, and
 * `CONTRACT_RULES` is the only reading of the contract.
 */
export interface CanonicalRules {
  formatNumber(value: number): string;
  compareKeys(a: string, b: string): number;
  normalizeString(value: string): string;
}

export const CONTRACT_RULES: CanonicalRules = {
  formatNumber: ecmascriptNumberToString,
  compareKeys: compareCodeUnits,
  normalizeString: (value) => value,
};

const encoder = new TextEncoder();

/** Rule 1: JCS, output as UTF-8 bytes. */
export function canonicalize(value: JsonValue): Uint8Array {
  return encoder.encode(canonicalizeToString(value));
}

/** The same result as text, for error messages and tests. */
export function canonicalizeToString(
  value: JsonValue,
  rules: CanonicalRules = CONTRACT_RULES,
): string {
  return serialize(value, rules);
}

/** Rule 1 under a deliberately altered reading. Only the harness calls this. */
export function canonicalizeWith(
  value: JsonValue,
  rules: CanonicalRules,
): Uint8Array {
  return encoder.encode(serialize(value, rules));
}

function serialize(value: JsonValue, rules: CanonicalRules): string {
  if (value === null) return "null";
  switch (typeof value) {
    case "boolean":
      return value ? "true" : "false";
    case "number":
      if (!Number.isFinite(value)) {
        throw new RangeError(`not a JSON number: ${String(value)}`);
      }
      return rules.formatNumber(value);
    case "string":
      return quote(rules.normalizeString(value));
    case "object":
      break;
    default:
      throw new TypeError(`not a JSON value: ${typeof value}`);
  }
  if (Array.isArray(value)) {
    return `[${value.map((item) => serialize(assertDefined(item), rules)).join(",")}]`;
  }
  const keys = Object.keys(value).sort(rules.compareKeys);
  const members = keys.map(
    (key) =>
      `${quote(rules.normalizeString(key))}:${serialize(assertDefined(value[key]), rules)}`,
  );
  return `{${members.join(",")}}`;
}

function assertDefined(value: JsonValue | undefined): JsonValue {
  if (value === undefined) throw new TypeError("undefined is not a JSON value");
  return value;
}

/**
 * Rule 2: keys sort by UTF-16 code units, not UTF-8 bytes. The two
 * orders disagree on supplementary-plane characters, so the sort may not
 * be delegated to a byte comparison. JavaScript's relational operators
 * on strings are a UTF-16 code-unit comparison, which is the ordering
 * rule 2 names. Not `localeCompare`, which is locale-dependent.
 * Enforced against the kernel by reference/corpus/unicode.json.
 */
export function compareCodeUnits(a: string, b: string): number {
  if (a < b) return -1;
  if (a > b) return 1;
  return 0;
}

/**
 * Rule 2: ECMAScript `Number::toString` exactly. In TypeScript that
 * operation is `String(n)` by definition, so the reference states the
 * rule by invoking it rather than reimplementing the ECMA-262
 * §6.1.6.1.20 placement rules over shortest-round-trip digits. The
 * reimplementation is what a non-JS kernel has to do, and reading the
 * rule off the language it was specified in is what makes this side of
 * the pair worth comparing against. `String(-0)` is "0", rule 2's first
 * named case.
 */
export function ecmascriptNumberToString(value: number): string {
  return String(value);
}

// Rule 1 defers string escaping to JCS, which is the ECMAScript
// `QuoteJSONString` operation: short forms for backspace, tab, newline,
// form feed, carriage return, quote and backslash, `\u00xx` with
// lowercase hex for the rest of C0, every other code point literal, and
// no escaping of `/`, DEL, U+2028 or U+2029. `JSON.stringify` of a lone
// string is that operation, so the reference invokes it for the same
// reason it invokes `String` for numbers. Well-formed `JSON.stringify`
// escapes a lone surrogate as `\udXXX`; the contract does not rule on
// lone surrogates (ambiguity A3 in reference/README.md), and this is the
// behaviour taken pending a normative addition.
function quote(value: string): string {
  return JSON.stringify(value);
}
