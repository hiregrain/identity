// RFC 8785 (JCS) canonicalization in TypeScript: contract/CONTRACT.md
// rules 1 and 2, the other half of trust-kernel/01's cross-language check.
//
// This implementation deliberately leans on the platform where the
// contract's rules ARE the platform's rules, and reimplements only what
// the platform does not give it:
//
//   - Numbers go through JSON.stringify, which is ECMAScript
//     Number::toString by definition. Rule 2 cites that algorithm, so
//     reimplementing it here would test a second transcription of the
//     spec against the Go one rather than testing the Go one against the
//     spec.
//   - Member names sort with the default string comparison, which is
//     UTF-16 code unit order, which is what rule 2 requires.
//   - String escaping is JSON.stringify's, which is exactly RFC 8785
//     3.2.2.2.
//   - Duplicate member names are the one thing JSON.parse hides (it keeps
//     the last), so they are scanned for separately below.
//   - No Unicode normalization happens anywhere, which is rule 1.

export function canonicalize(document: string): string {
  // Parse first: this is what rejects malformed input and trailing bytes,
  // so the duplicate scan below never sees a document it has to be
  // careful with.
  const value: unknown = JSON.parse(document);
  assertNoDuplicateNames(document);
  return write(value);
}

function write(value: unknown): string {
  if (value === null) return "null";
  switch (typeof value) {
    case "boolean":
      return value ? "true" : "false";
    case "number":
      if (!Number.isFinite(value)) throw new Error("number is not finite");
      return JSON.stringify(value);
    case "string":
      return JSON.stringify(value);
    case "object":
      break;
    default:
      throw new Error(`unexpected JSON value of type ${typeof value}`);
  }
  if (Array.isArray(value)) {
    return `[${value.map(write).join(",")}]`;
  }
  const members = Object.entries(value as Record<string, unknown>).sort(
    ([left], [right]) => (left < right ? -1 : left > right ? 1 : 0),
  );
  return `{${members
    .map(([name, member]) => `${JSON.stringify(name)}:${write(member)}`)
    .join(",")}}`;
}

// assertNoDuplicateNames walks the document's structural characters and
// its strings, and throws on a repeated member name in one object. Names
// are compared after decoding, so "a" and "a" are the same name, which
// is what RFC 8785 means by a duplicate.
function assertNoDuplicateNames(document: string): void {
  const containers: Array<Set<string> | null> = [];
  let expectName = false;

  for (let i = 0; i < document.length;) {
    const character = document[i];
    if (character === '"') {
      const [name, next] = readString(document, i);
      if (expectName) {
        const names = containers[containers.length - 1];
        if (names) {
          if (names.has(name)) {
            throw new Error(`object has a duplicate member name ${name}`);
          }
          names.add(name);
        }
        expectName = false;
      }
      i = next;
      continue;
    }
    if (character === "{") {
      containers.push(new Set());
      expectName = true;
    } else if (character === "[") {
      containers.push(null);
      expectName = false;
    } else if (character === "}" || character === "]") {
      containers.pop();
      expectName = false;
    } else if (character === ",") {
      expectName = containers[containers.length - 1] instanceof Set;
    } else if (character === ":") {
      expectName = false;
    }
    i += 1;
  }
}

// readString returns the decoded string starting at the quote at `start`,
// and the index just past its closing quote.
function readString(document: string, start: number): [string, number] {
  let i = start + 1;
  while (i < document.length) {
    if (document[i] === "\\") {
      i += 2;
      continue;
    }
    if (document[i] === '"') {
      const raw = document.slice(start, i + 1);
      return [JSON.parse(raw) as string, i + 1];
    }
    i += 1;
  }
  throw new Error("unterminated string");
}
