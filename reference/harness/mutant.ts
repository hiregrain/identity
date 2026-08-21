// The planted-bug adapter.
//
// A harness that finds nothing proves nothing, and a differential run
// that has never been shown to fail is indistinguishable from one that
// cannot. This adapter is the reference model with exactly one rule
// misread, so `make differential-red` can demonstrate that the harness
// catches the misreading. Every bug here is a real misreading somebody
// could make from contract/CONTRACT.md, not a random corruption: the
// contract spends a paragraph warning against each one.
//
// Usage: node reference/harness/mutant.ts --bug <name>
//
// It is a first-class file rather than a test fixture because acceptance
// criterion 2 of plans/trust-kernel/06 is a standing obligation. A bug
// injector kept where lint and typecheck cannot see it rots, and the
// first time anyone notices is when the red path stops proving anything.

import { serve } from "../adapter.ts";
import {
  CONTRACT_RULES,
  compareCodeUnits,
  type CanonicalRules,
} from "../canonical.ts";

const BUGS: Record<string, () => CanonicalRules> = {
  // Rule 2: "Object keys sort by UTF-16 code units, NOT UTF-8 byte
  // order, they diverge on supplementary-plane characters." This is the
  // divergence, and nothing below the BMP reveals it.
  "key-order-utf8": () => ({
    ...CONTRACT_RULES,
    compareKeys: (a, b) => Buffer.compare(Buffer.from(a), Buffer.from(b)),
  }),

  // Rule 2: the exponent threshold. Fixed-point past the point where
  // ECMAScript switches to exponential notation, which agrees with the
  // contract on every number a casual test uses.
  "number-format-fixed": () => ({
    ...CONTRACT_RULES,
    formatNumber: (value) => {
      const canonical = String(value);
      return canonical.includes("e") ? value.toFixed(20) : canonical;
    },
  }),

  // Rule 2: "-0 goes to 0". Preserving the sign is the natural thing a
  // hand-written formatter does.
  "number-format-negative-zero": () => ({
    ...CONTRACT_RULES,
    formatNumber: (value) =>
      Object.is(value, -0) ? "-0" : CONTRACT_RULES.formatNumber(value),
  }),

  // Rule 1: "Unicode normalization: NONE, NFC and NFD are distinct
  // strings and distinct object keys." Normalizing is what a library
  // that means well does on your behalf.
  "normalize-nfc": () => ({
    ...CONTRACT_RULES,
    normalizeString: (value) => value.normalize("NFC"),
  }),

  // Rule 1: "a document containing an unpaired surrogate is refused,
  // never altered and never escaped" (decision 082). This is the
  // kernel's prior behaviour, Go's silent U+FFFD substitution, which
  // returns bytes that are not the input's and calls it success.
  "surrogate-substitute": () => ({
    ...CONTRACT_RULES,
    illFormed: (value) => value.toWellFormed(),
  }),

  // Rule 1, the other historical misreading: this model's own
  // preserve-and-escape reading before decision 082 ruled against it,
  // where an ill-formed string is carried through and JSON.stringify
  // escapes the surrogate as \udXXX. It was the losing side of the 2021
  // divergences the first differential run found.
  "surrogate-escape": () => ({
    ...CONTRACT_RULES,
    illFormed: (value) => value,
  }),

  // Rule 2's sort, kept in code-unit order but applied to the wrong
  // thing: a locale collation, which agrees with the contract on ASCII.
  "key-order-locale": () => ({
    ...CONTRACT_RULES,
    compareKeys: (a, b) => {
      const collated = a.localeCompare(b);
      return collated === 0 ? compareCodeUnits(a, b) : collated;
    },
  }),
};

const index = process.argv.indexOf("--bug");
const name = index === -1 ? undefined : process.argv[index + 1];
const build = name === undefined ? undefined : BUGS[name];
if (build === undefined) {
  console.error(
    `mutant: --bug must be one of ${Object.keys(BUGS).sort().join(", ")}`,
  );
  process.exit(2);
}

await serve(build());
