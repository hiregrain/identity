// The TypeScript half of the golden-vector check (trust-kernel/01).
//
// It reads the same files core/cmd/vectors writes and the Go kernel reads,
// so the two languages exercise identical bytes. A vector the Go kernel
// passes and this runner fails is a contract divergence, which is the
// whole reason both runners exist and run in CI from the first day there
// is a kernel.
//
//   node src/check.ts <vectors-dir>
//
// The directory argument is what lets the Makefile point both runners at a
// mutated copy and require that both reject it.

import { readFileSync } from "node:fs";
import { join } from "node:path";
import { argv, exit, stderr, stdout } from "node:process";
import { canonicalize } from "./jcs.ts";
import {
  invalidVerdict,
  KEY_ID_FIELD,
  PROTECTED_HEADER,
  publicKeyFromHex,
  sign,
  signerFromHex,
  verify,
  wireVerdict,
} from "./jws.ts";

type CanonicalizationCase = {
  name: string;
  input: string;
  canonical?: string;
  rejected?: boolean;
};
type VectorKey = { id: string; privateHex: string; publicHex: string };
type SignCase = {
  name: string;
  signerKeyId: string;
  payload: string;
  rejected?: boolean;
  signedPayload?: string;
  compact?: string;
};
type VerifyCase = {
  name: string;
  compact: string;
  valid: boolean;
  keyId?: string;
};

const directory = argv[2];
if (directory === undefined) {
  stderr.write("usage: check.ts <vectors-dir>\n");
  exit(2);
}

const failures: string[] = [];

const canonicalizationVectors = readVectors<{ cases: CanonicalizationCase[] }>(
  directory,
  "canonicalization.json",
);
for (const testCase of canonicalizationVectors.cases) {
  let got: string | undefined;
  let rejected = false;
  try {
    got = canonicalize(testCase.input);
  } catch {
    rejected = true;
  }
  if (testCase.rejected) {
    if (!rejected) {
      failures.push(
        `canonicalization/${testCase.name}: accepted an input the vector rejects`,
      );
    }
  } else if (rejected) {
    failures.push(`canonicalization/${testCase.name}: rejected a valid input`);
  } else if (got !== testCase.canonical) {
    failures.push(
      `canonicalization/${testCase.name}: got ${got}, want ${testCase.canonical}`,
    );
  }
}

const signVerifyVectors = readVectors<{
  protectedHeader: string;
  keyIdField: string;
  falseVerdict: string;
  trueVerdict: string;
  keys: VectorKey[];
  sign: SignCase[];
  verify: VerifyCase[];
}>(directory, "sign-verify.json");

if (signVerifyVectors.protectedHeader !== PROTECTED_HEADER) {
  failures.push(
    `protected header: runner has ${PROTECTED_HEADER}, vector has ${signVerifyVectors.protectedHeader}`,
  );
}
if (signVerifyVectors.keyIdField !== KEY_ID_FIELD) {
  failures.push(
    `key identifier field: runner has ${KEY_ID_FIELD}, vector has ${signVerifyVectors.keyIdField}`,
  );
}
if (wireVerdict(invalidVerdict()) !== signVerifyVectors.falseVerdict) {
  failures.push(
    `false verdict: runner serializes ${wireVerdict(invalidVerdict())}, vector has ${signVerifyVectors.falseVerdict}`,
  );
}
// The true verdict is pinned from a verdict deliberately carrying kid and
// payload, so the pin proves neither reaches the wire: it must still be
// exactly {"valid":true} (decision 082).
const trueWire = wireVerdict({ valid: true, kid: "leak", payload: "leak" });
if (trueWire !== signVerifyVectors.trueVerdict) {
  failures.push(
    `true verdict: runner serializes ${trueWire}, vector has ${signVerifyVectors.trueVerdict}`,
  );
}

const keysById = new Map(signVerifyVectors.keys.map((key) => [key.id, key]));
const resolve = (keyId: string) => {
  const key = keysById.get(keyId);
  return key === undefined ? undefined : publicKeyFromHex(key.publicHex);
};

for (const testCase of signVerifyVectors.sign) {
  const key = keysById.get(testCase.signerKeyId);
  if (key === undefined) {
    failures.push(
      `sign/${testCase.name}: vector names an unknown key ${testCase.signerKeyId}`,
    );
    continue;
  }
  let compact: string;
  try {
    compact = sign(
      testCase.payload,
      signerFromHex(key.id, key.privateHex, key.publicHex),
    );
  } catch (error) {
    if (!testCase.rejected) {
      failures.push(`sign/${testCase.name}: ${String(error)}`);
    }
    continue;
  }
  if (testCase.rejected) {
    failures.push(`sign/${testCase.name}: signed a payload the vector rejects`);
    continue;
  }
  if (compact !== testCase.compact) {
    failures.push(
      `sign/${testCase.name}: got ${compact}, want ${testCase.compact}`,
    );
    continue;
  }
  const signed = Buffer.from(compact.split(".")[1], "base64url").toString(
    "utf8",
  );
  if (signed !== testCase.signedPayload) {
    failures.push(
      `sign/${testCase.name}: signed payload is ${signed}, want ${testCase.signedPayload}`,
    );
  }
}

for (const testCase of signVerifyVectors.verify) {
  const verdict = verify(testCase.compact, resolve);
  if (verdict.valid !== testCase.valid) {
    failures.push(
      `verify/${testCase.name}: got valid=${verdict.valid}, want valid=${testCase.valid}`,
    );
    continue;
  }
  if (testCase.valid && verdict.kid !== testCase.keyId) {
    failures.push(
      `verify/${testCase.name}: got key ${verdict.kid}, want ${testCase.keyId}`,
    );
  }
}

if (failures.length > 0) {
  for (const failure of failures) stderr.write(`FAIL ${failure}\n`);
  exit(1);
}
stdout.write(
  `vectors: the typescript runner passes ${canonicalizationVectors.cases.length} canonicalization and ${signVerifyVectors.sign.length + signVerifyVectors.verify.length} sign/verify case(s) in ${directory}\n`,
);

function readVectors<T>(dir: string, name: string): T {
  return JSON.parse(readFileSync(join(dir, name), "utf8")) as T;
}
