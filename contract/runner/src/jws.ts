// The Ed25519 JWS envelope in TypeScript: contract/CONTRACT.md rules 3
// and 4, and decision 019's two shapes (no key parameter on signing, the
// key identifier inside the signed payload).
//
// Keys are built from the contract's hex encodings through JWK, because
// node:crypto has no raw Ed25519 import and JWK is the one format that
// needs no encoder of our own.

import {
  createPrivateKey,
  createPublicKey,
  sign as edSign,
  verify as edVerify,
  type KeyObject,
} from "node:crypto";
import { canonicalize } from "./jcs.ts";

export const PROTECTED_HEADER = '{"alg":"EdDSA"}';
export const KEY_ID_FIELD = "kid";

const PROTECTED_HEADER_B64 = base64url(Buffer.from(PROTECTED_HEADER, "utf8"));

export type Verdict = { valid: boolean; kid?: string; payload?: string };

// invalidVerdict is the single false verdict rule 3 fixes: exactly
// {"valid":false} and no other member. The vectors carry its serialized
// form so both languages are held to the same bytes.
export function invalidVerdict(): Verdict {
  return { valid: false };
}

// wireVerdict is the exact bytes a verdict takes on the wire: {"valid":...}
// and nothing else, which contract rule 3 requires of both verdicts
// (decision 082 fixed the true one). kid and payload stay on the Verdict for
// a caller that verified and wants them, never on the wire, mirroring the Go
// kernel's json:"-" fields. The vectors pin both serialized forms so the two
// languages are held to the same bytes.
export function wireVerdict(verdict: Verdict): string {
  return JSON.stringify({ valid: verdict.valid });
}

// Signer holds one key and reports which. Sign takes no key parameter,
// which is decision 019: the wrong key is unexpressible rather than
// rejected.
export type Signer = {
  currentKeyId: () => string;
  sign: (signingInput: Buffer) => { signature: Buffer; keyId: string };
};

export function signerFromHex(
  keyId: string,
  privateHex: string,
  publicHex: string,
): Signer {
  const key = privateKeyFromHex(privateHex, publicHex);
  return {
    currentKeyId: () => keyId,
    sign: (signingInput: Buffer) => ({
      signature: edSign(null, signingInput, key),
      keyId,
    }),
  };
}

// sign places the signer's key identifier inside the payload, canonicalizes
// the result, and returns the compact serialization.
export function sign(payload: string, signer: Signer): string {
  const keyId = signer.currentKeyId();

  // Canonicalize the RAW payload bytes first, exactly as the Go kernel's
  // withKeyID does, so this refuses every document Go refuses before it
  // inserts anything: a duplicate member name, an over-range number, an
  // unpaired surrogate. Parsing first would produce a valid signature over
  // bytes the caller never wrote, because JSON.parse silently keeps the last
  // of a duplicate key and turns an over-range number into Infinity.
  canonicalize(payload);

  const members = JSON.parse(payload) as Record<string, unknown>;
  if (
    members === null ||
    typeof members !== "object" ||
    Array.isArray(members)
  ) {
    throw new Error("payload is not a JSON object");
  }
  if (KEY_ID_FIELD in members) {
    throw new Error("payload already carries a key identifier");
  }
  members[KEY_ID_FIELD] = keyId;

  const canonical = canonicalize(JSON.stringify(members));
  const signingInput = `${PROTECTED_HEADER_B64}.${base64url(Buffer.from(canonical, "utf8"))}`;
  const { signature, keyId: usedKeyId } = signer.sign(
    Buffer.from(signingInput, "utf8"),
  );
  if (usedKeyId !== keyId) {
    throw new Error("signer used a key other than the one it reported");
  }
  return `${signingInput}.${base64url(signature)}`;
}

// verify reads the key identifier out of the signed payload, resolves it,
// and verifies. Resolving from inside the signed bytes is what makes key
// identity unforgeable.
export function verify(
  compact: string,
  resolve: (keyId: string) => KeyObject | undefined,
): Verdict {
  const parts = compact.split(".");
  if (parts.length !== 3) return invalidVerdict();

  // Rule 3: the header is compared byte for byte and never parsed.
  let header: Buffer;
  let payload: Buffer;
  let signature: Buffer;
  try {
    header = fromBase64url(parts[0]);
    payload = fromBase64url(parts[1]);
    signature = fromBase64url(parts[2]);
  } catch {
    return invalidVerdict();
  }
  if (!header.equals(Buffer.from(PROTECTED_HEADER, "utf8"))) {
    return invalidVerdict();
  }
  if (signature.length !== 64) return invalidVerdict();

  // Rule 3 again: the payload is read but never re-canonicalized, because
  // the signature covers the bytes that arrived.
  let keyId: unknown;
  try {
    keyId = (JSON.parse(payload.toString("utf8")) as Record<string, unknown>)[
      KEY_ID_FIELD
    ];
  } catch {
    return invalidVerdict();
  }
  if (typeof keyId !== "string" || keyId === "") return invalidVerdict();

  const publicKey = resolve(keyId);
  if (publicKey === undefined) return invalidVerdict();
  if (
    !edVerify(
      null,
      Buffer.from(`${parts[0]}.${parts[1]}`, "utf8"),
      publicKey,
      signature,
    )
  ) {
    return invalidVerdict();
  }
  return { valid: true, kid: keyId, payload: payload.toString("utf8") };
}

export function publicKeyFromHex(publicHex: string): KeyObject {
  return createPublicKey({
    key: {
      kty: "OKP",
      crv: "Ed25519",
      x: base64url(hexToBytes(publicHex, 32)),
    },
    format: "jwk",
  });
}

function privateKeyFromHex(privateHex: string, publicHex: string): KeyObject {
  return createPrivateKey({
    key: {
      kty: "OKP",
      crv: "Ed25519",
      d: base64url(hexToBytes(privateHex, 32)),
      x: base64url(hexToBytes(publicHex, 32)),
    },
    format: "jwk",
  });
}

// Rule 4: a private key is its 32-byte seed in hex, a public key its
// 32-byte raw value in hex.
function hexToBytes(value: string, expectedLength: number): Buffer {
  if (!/^[0-9a-f]*$/.test(value)) throw new Error("key is not lowercase hex");
  const bytes = Buffer.from(value, "hex");
  if (bytes.length !== expectedLength) {
    throw new Error(`key is ${bytes.length} bytes, want ${expectedLength}`);
  }
  return bytes;
}

function base64url(bytes: Buffer): string {
  return bytes.toString("base64url");
}

function fromBase64url(segment: string): Buffer {
  const bytes = Buffer.from(segment, "base64url");
  // Buffer.from is lenient, so a segment that does not round-trip is
  // rejected here rather than silently accepted as a shorter value.
  if (base64url(bytes) !== segment) throw new Error("segment is not base64url");
  return bytes;
}
