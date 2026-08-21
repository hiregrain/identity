// JWS envelope construction and verification, read from
// contract/CONTRACT.md rules 3 and 4 alone. The other half of the
// differential pair; see reference/canonical.ts for why nothing here
// consults the kernel.

import { createPrivateKey, createPublicKey, sign, verify } from "node:crypto";
import type { KeyObject } from "node:crypto";
import {
  CONTRACT_RULES,
  canonicalize,
  canonicalizeWith,
  type CanonicalRules,
  type JsonValue,
} from "./canonical.ts";

/**
 * Rule 3: the protected header is these exact 15 bytes. Verification
 * compares them as bytes and never parses them, so no second header
 * spelling can be made to verify. Enforced by `verifyEnvelope` below
 * and by the harness's malformed-envelope corpus
 * (reference/corpus/envelopes.json).
 */
export const PROTECTED_HEADER = new TextEncoder().encode('{"alg":"EdDSA"}');

/** Rule 3's false verdict, exactly, with no extra fields. */
export type Verdict = { valid: false } | { valid: true };

const FALSE_VERDICT: Verdict = { valid: false };
// The contract does not name the true verdict's shape (ambiguity A1).
// This is the only shape that adds nothing to what rule 3 fixes, and it
// stands until a normative addition rules otherwise.
const TRUE_VERDICT: Verdict = { valid: true };

// RFC 8032 raw key material carries no algorithm identifier, and
// node:crypto takes DER. These are the fixed DER prefixes for an
// Ed25519 PKCS#8 private key and SPKI public key; the 32 bytes of rule
// 4's hex follow each one unchanged.
const PKCS8_PREFIX = Buffer.from("302e020100300506032b657004220420", "hex");
const SPKI_PREFIX = Buffer.from("302a300506032b6570032100", "hex");

/** Rule 4: 32-byte seed hex. */
export function privateKeyFromSeedHex(seedHex: string): KeyObject {
  const seed = decodeKeyHex(seedHex, "private seed");
  return createPrivateKey({
    key: Buffer.concat([PKCS8_PREFIX, seed]),
    format: "der",
    type: "pkcs8",
  });
}

/** Rule 4: 32-byte raw public hex, not PEM and not JWK. */
export function publicKeyFromHex(publicHex: string): KeyObject {
  const raw = decodeKeyHex(publicHex, "public key");
  return createPublicKey({
    key: Buffer.concat([SPKI_PREFIX, raw]),
    format: "der",
    type: "spki",
  });
}

/** The rule-4 hex form of the public key belonging to a seed. */
export function publicHexFromSeedHex(seedHex: string): string {
  const spki = createPublicKey(privateKeyFromSeedHex(seedHex)).export({
    format: "der",
    type: "spki",
  });
  return Buffer.from(spki.subarray(SPKI_PREFIX.length)).toString("hex");
}

function decodeKeyHex(value: string, what: string): Buffer {
  if (!/^[0-9a-f]{64}$/.test(value)) {
    throw new TypeError(`${what} is not 32 bytes of lowercase hex`);
  }
  return Buffer.from(value, "hex");
}

/**
 * Rule 3: compact serialization over the JCS-canonicalized payload.
 * Decision 019 puts the key identifier in the signed payload, so this
 * function takes no key identifier of its own: whatever the payload
 * claims is inside the signed bytes.
 */
export function signEnvelope(
  payload: JsonValue,
  seedHex: string,
  rules: CanonicalRules = CONTRACT_RULES,
): string {
  const signingInput = `${base64url(PROTECTED_HEADER)}.${base64url(canonicalizeWith(payload, rules))}`;
  const signature = sign(
    null,
    Buffer.from(signingInput, "ascii"),
    privateKeyFromSeedHex(seedHex),
  );
  return `${signingInput}.${base64url(signature)}`;
}

/**
 * Rule 3: compares header bytes, does not re-canonicalize the payload.
 * The payload segment is carried into the signature check exactly as it
 * arrived, so a re-serialization that differs from what was signed can
 * never be papered over here.
 */
export function verifyEnvelope(envelope: string, publicHex: string): Verdict {
  const segments = envelope.split(".");
  if (segments.length !== 3) return FALSE_VERDICT;
  const [protectedSegment, payloadSegment, signatureSegment] = segments as [
    string,
    string,
    string,
  ];

  const header = decodeBase64url(protectedSegment);
  if (header === null || !bytesEqual(header, PROTECTED_HEADER)) {
    return FALSE_VERDICT;
  }
  if (decodeBase64url(payloadSegment) === null) return FALSE_VERDICT;

  const signature = decodeBase64url(signatureSegment);
  if (signature === null || signature.length !== 64) return FALSE_VERDICT;

  let key: KeyObject;
  try {
    key = publicKeyFromHex(publicHex);
  } catch {
    return FALSE_VERDICT;
  }

  const signingInput = Buffer.from(
    `${protectedSegment}.${payloadSegment}`,
    "ascii",
  );
  return verify(null, signingInput, key, signature)
    ? TRUE_VERDICT
    : FALSE_VERDICT;
}

/**
 * The verdict as canonical bytes, which is the form the harness
 * compares. A verdict that differs between implementations has to
 * differ as bytes, so rule 3's "no extra fields" is checked by the same
 * comparison as everything else rather than by a separate assertion.
 */
export function canonicalVerdict(
  envelope: string,
  publicHex: string,
): Uint8Array {
  return canonicalize(verifyEnvelope(envelope, publicHex));
}

function base64url(bytes: Uint8Array): string {
  return Buffer.from(bytes).toString("base64url");
}

// Rule 3 does not rule on non-canonical base64url (ambiguity A2). A
// segment is rejected here unless it survives a decode/re-encode round
// trip, because rule 3's whole posture on the header is byte-exactness
// and a lenient decoder admits several spellings of one envelope.
function decodeBase64url(segment: string): Buffer | null {
  if (!/^[A-Za-z0-9_-]*$/.test(segment)) return null;
  const decoded = Buffer.from(segment, "base64url");
  if (decoded.toString("base64url") !== segment) return null;
  return decoded;
}

function bytesEqual(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  for (let index = 0; index < a.length; index += 1) {
    if (a[index] !== b[index]) return false;
  }
  return true;
}
