// Randomized and fuzzed input for the differential harness.
//
// Seeded, so a run that found a divergence can be replayed exactly from
// the seed the harness prints, and the input that found it can then be
// promoted into reference/corpus/ where it becomes a regression test
// forever.
//
// The generator biases hard toward the terrain the contract spends its
// words on: rule 2's number formatting and UTF-16 key order, rule 1's
// refusal to normalize, rule 3's byte-exact header and its envelope
// segments. Uniformly random JSON would spend nearly every draw on small
// integers and ASCII keys, which no implementation gets wrong.

import type { Request } from "../adapter.ts";
import type { JsonValue } from "../canonical.ts";
import { publicHexFromSeedHex, signEnvelope } from "../jws.ts";

/** Deterministic 32-bit PRNG. Reproducibility is the only requirement. */
export function prng(seed: number): () => number {
  let state = seed >>> 0;
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = state;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Rule 2 names these cases directly, or sits one digit away from them.
const EDGE_NUMBERS = [
  0,
  -0,
  1,
  -1,
  1e21,
  -1e21,
  1e-7,
  0.000001,
  1e-6,
  9.999999999999999e20,
  1e-323,
  5e-324,
  1.7976931348623157e308,
  123456789012345680000,
  0.1,
  0.3,
  1 / 3,
  2 ** 53 - 1,
  -(2 ** 53 - 1),
  2 ** 31,
  1e20,
  1e-321,
  100,
  1.5e-10,
];

// Rule 1 makes NFC and NFD distinct, and rule 2's key order diverges from
// UTF-8 byte order only above the BMP. Both live here.
//
// Written as escapes rather than literal characters. An NFC and an NFD
// spelling of one grapheme are indistinguishable in a source file, a
// reviewer has to be able to see that two such entries are two strings,
// and an editor that normalizes on save would silently collapse them
// into one and quietly delete half of what this list is for.
export const EDGE_STRINGS = [
  "",
  "a",
  "\u00e9", // NFC e-acute
  "\u0065\u0301", // NFD e-acute: a distinct string and a distinct key (rule 1)
  "\u00c5", // NFC A-ring
  "\u0041\u030a", // NFD A-ring
  "\u212b", // angstrom sign, a third spelling that NFC folds into the first
  "\u{1f600}", // above the BMP: below U+ff3a by UTF-16 code unit
  "\uff3a", // fullwidth Z: below the emoji by UTF-8 byte, above it by UTF-16
  "\u{10000}",
  "\u{10ffff}",
  " ",
  "\u00a0",
  "\u0000",
  "\u007f", // DEL, which JCS leaves literal
  "\u2028\u2029", // literal in JSON, escaped only in JavaScript source
  "\b\t\n\f\r",
  '"\\/',
  "\ud800", // lone high surrogate (ambiguity A3)
  "\u00fc\u00df",
  "0",
  "1",
  "10",
  "\u4e00",
];

/**
 * How deep and how wide one generated value may get.
 *
 * Depth and width are drawn as a pair rather than independently, because
 * the product is the size of the value: 64 deep and 64 wide is not a
 * fuzz case, it is an out-of-memory. Deep shapes are narrow and wide
 * shapes are shallow, so each cap is reachable on its own.
 *
 * Every depth here stays under the kernel's own limit, which refuses
 * past 256. Exceeding it would produce a divergence about a bound the
 * contract does not mention, which is a question for the contract and
 * not something for this generator to manufacture.
 */
const SHAPES = [
  { weight: 84, maxDepth: 4, width: 5, budget: 60 },
  { weight: 8, maxDepth: 3, width: 64, budget: 300 }, // large-object sort
  { weight: 5, maxDepth: 12, width: 3, budget: 200 },
  { weight: 2, maxDepth: 64, width: 2, budget: 200 },
  { weight: 1, maxDepth: 200, width: 1, budget: 220 }, // a near-bound spine
] as const;

type Shape = { maxDepth: number; width: number; budget: number };

function randomShape(random: () => number): Shape {
  const total = SHAPES.reduce((sum, shape) => sum + shape.weight, 0);
  let ticket = random() * total;
  for (const shape of SHAPES) {
    ticket -= shape.weight;
    if (ticket < 0) return shape;
  }
  return SHAPES[0];
}

/**
 * One generated value.
 *
 * Every decision draws its own number. Sharing one draw between the
 * container/leaf branch and the leaf's type, which this did before,
 * correlates them: the branch reserved the low end of the range for
 * leaves, so a leaf could only ever be drawn from that end, and at the
 * depth cap, where every value is forced to be a leaf, the draw was
 * unconstrained and 63% of forced leaves came out booleans. The edge
 * numbers and edge strings that the contract actually argues about were
 * the cases being crowded out.
 */
export function randomValue(
  random: () => number,
  depth = 0,
  shape: Shape = randomShape(random),
  remaining: { nodes: number } = { nodes: shape.budget },
): JsonValue {
  // The budget is what keeps depth and width from multiplying. 64 wide at
  // 3 deep is 64^3 nodes if nothing stops it, which is not a fuzz case,
  // it is a run that never finishes. Depth and width set the shape a
  // value may reach; the budget sets how much of that shape it may fill.
  if (
    depth >= shape.maxDepth ||
    remaining.nodes <= 0 ||
    random() < leafChance(depth, shape)
  ) {
    return randomLeaf(random);
  }
  // A deep shape whose container draws zero children stops there, so the
  // narrow deep shapes take at least one. A width-1 spine drawing 0 half
  // the time averages two levels, not the two hundred it was drawn for.
  const drawn = Math.floor(random() * (shape.width + 1));
  const count = Math.min(
    shape.maxDepth > 4 ? Math.max(1, drawn) : drawn,
    remaining.nodes,
  );
  remaining.nodes -= count;
  const asArray = random() < 0.5;
  if (asArray) {
    const items: JsonValue[] = [];
    for (let index = 0; index < count; index += 1) {
      items.push(randomValue(random, depth + 1, shape, remaining));
    }
    return items;
  }
  const object: { [key: string]: JsonValue } = {};
  for (let index = 0; index < count; index += 1) {
    object[randomKey(random)] = randomValue(
      random,
      depth + 1,
      shape,
      remaining,
    );
  }
  return object;
}

// A deep shape only reaches its depth if it keeps choosing to nest, so
// the ones drawn to be deep stop rolling for leaves on the way down.
// Without this, a maxDepth of 200 produces a value about two deep and
// the depth cap it was drawn for is never exercised.
function leafChance(depth: number, shape: Shape): number {
  if (shape.maxDepth <= 4) return 0.42;
  return depth < shape.maxDepth - 1 ? 0.02 : 1;
}

function randomLeaf(random: () => number): JsonValue {
  const roll = random();
  if (roll < 0.3) return pick(random, EDGE_NUMBERS);
  if (roll < 0.6) return pick(random, EDGE_STRINGS);
  if (roll < 0.75) return randomNumber(random);
  if (roll < 0.85) return null;
  return random() < 0.5;
}

function randomKey(random: () => number): string {
  if (random() < 0.65) return pick(random, EDGE_STRINGS);
  const length = 1 + Math.floor(random() * 4);
  let key = "";
  for (let index = 0; index < length; index += 1) {
    key += String.fromCodePoint(32 + Math.floor(random() * 0x2000));
  }
  return key;
}

function randomNumber(random: () => number): number {
  const roll = random();
  if (roll < 0.3) return Math.floor(random() * 2 ** 53) - 2 ** 52;
  if (roll < 0.6)
    return (random() - 0.5) * 10 ** Math.floor(random() * 40 - 20);
  return Math.floor(random() * 2000) - 1000;
}

function pick<T>(random: () => number, options: readonly T[]): T {
  return options[Math.floor(random() * options.length)] as T;
}

// RFC 8032 test seeds plus the two degenerate ones. Public, published
// values: nothing here is a key any deployment uses.
const SEEDS = [
  "0".repeat(64),
  "f".repeat(64),
  "9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60",
  "4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb",
];

/** One fresh request. Ops are drawn in roughly the mix the kernel sees. */
export function randomRequest(random: () => number): Request {
  const seedHex = pick(random, SEEDS);
  const roll = random();
  if (roll < 0.55) return { op: "canonicalize", value: randomValue(random) };
  if (roll < 0.62) return { op: "publicKey", seedHex };
  if (roll < 0.82) {
    return { op: "sign", payload: randomValue(random), seedHex };
  }
  if (roll < 0.9) {
    // A genuinely valid envelope, so the true branch of the verdict is
    // compared too. The reference builds it; if the reference's signing
    // is itself wrong, both implementations still have to agree on the
    // verdict, so this construction cannot mask a divergence.
    //
    // Signing refuses an ill-formed payload since decision 082, and this
    // draw is about the verify path rather than about rule 1, so a
    // refused draw falls through to a near miss instead of failing the
    // generator. Rule 1's refusal is exercised by the `canonicalize` and
    // `sign` draws above, where both sides must refuse alike.
    try {
      return {
        op: "verify",
        envelope: signEnvelope(randomValue(random), seedHex),
        publicKeyHex: publicHexFromSeedHex(seedHex),
      };
    } catch {
      // falls through
    }
  }
  return {
    op: "verify",
    envelope: nearMiss(random, seedHex),
    publicKeyHex: publicHexFromSeedHex(seedHex),
  };
}

// Verification is only worth fuzzing on envelopes that are nearly right.
// A random string is rejected by every implementation for the same
// uninteresting reason; a real envelope with one segment nudged is where
// rule 3's byte-exact header comparison either holds or does not.
function nearMiss(random: () => number, seedHex: string): string {
  const alphabet =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
  const base = [
    "eyJhbGciOiJFZERTQSJ9", // the 15 header bytes, base64url
    Buffer.from(JSON.stringify({ kid: seedHex.slice(0, 8) })).toString(
      "base64url",
    ),
    "A".repeat(86),
  ];
  const roll = random();
  if (roll < 0.15) return base.join(".");
  if (roll < 0.28) return base.slice(0, 2).join("."); // two segments
  if (roll < 0.4) return `${base.join(".")}.${base[0]}`; // four segments
  const segment = Math.floor(random() * 3);
  if (roll < 0.55) {
    // A trailing "=": does the segment decoder insist on canonical
    // base64url (ambiguity A2) or shrug?
    return base
      .map((part, index) => (index === segment ? `${part}=` : part))
      .join(".");
  }
  const chosen = base[segment] as string;
  const at = Math.floor(random() * chosen.length);
  const replaced =
    chosen.slice(0, at) +
    alphabet[Math.floor(random() * alphabet.length)] +
    chosen.slice(at + 1);
  return base
    .map((part, index) => (index === segment ? replaced : part))
    .join(".");
}
