# Contract — Canonicalization, Signing, Chain, and Merkle Rules (seed)

Preserved from the T1 spike harness (decision 012). These are the
normative resolutions of every ambiguity the spike surfaced; ten
independent implementations (2 languages × 3 models) passed 48 golden
vectors built on exactly these rules. `trust-kernel/01` regenerates the
vector files against this document; future implementations in any
language must match it byte-for-byte.

1. **Canonicalization is RFC 8785 (JCS).** Unicode normalization: NONE —
   NFC and NFD are distinct strings and distinct object keys.
2. **Number formatting is ECMAScript `Number::toString`** exactly:
   `-0` → `0`; `1e21` → `1e+21` (explicit sign); the `1e-7` vs
   `0.000001` exponent threshold; full-decimal integers ≤ 2^53−1.
   (Non-JS implementations must reimplement the ECMA-262 §6.1.6.1.20
   placement rules over shortest-round-trip digits; measured cost in Go
   ~60–90 lines, done correctly by every T1 Go cell.)
   Object keys sort by UTF-16 code units (JS default string order), NOT
   UTF-8 byte order — they diverge on supplementary-plane characters.
3. **JWS envelope**: compact serialization; the protected header is the
   exact 15 bytes `{"alg":"EdDSA"}`; verification compares header bytes
   and does not re-canonicalize the payload; a false verdict is exactly
   `{"valid":false}` with no extra fields.
4. **Key encodings**: Ed25519 private = 32-byte seed hex; public =
   32-byte raw hex (RFC 8032 conventions) — not PEM/JWK.
5. **Hash chain**: SHA-256; genesis prev = 32 zero bytes; records are
   JCS-canonicalized before hashing; domain tag `0x02` on chain links;
   length-mismatch verification reports `firstBadIndex = min(len)`;
   empty-chain head = 64 hex zeros.
6. **Merkle**: leaf tag `0x00`, internal-node tag `0x01`; odd node at any
   level is PROMOTED unchanged (no duplication); promoted levels
   contribute no proof entry; proof entries name the sibling's side
   (`dir`); N ≥ 1 (empty tree undefined); single-leaf proof = `[]`.
   Promotion footgun (documented from a T1 self-test error): promotion
   suppresses an entry only on the promoted node's own path, never on its
   siblings' paths.
7. **Domain separation is cross-structure**: tags 0x00/0x01/0x02 ensure
   Merkle-leaf, Merkle-internal, and chain-link preimages can never
   collide.
