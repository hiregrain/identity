package keys

import (
	"crypto/hmac"
	"crypto/sha256"
)

// The MAC construction both in-repo providers share, and the shape the
// real KMS provider must reproduce to pass the conformance suite.
//
// Two layers, for one reason each:
//
//	macKey = HMAC-SHA256(scope key, macLabel)
//	code   = HMAC-SHA256(macKey, scope || 0x00 || message)
//
// The first layer separates this use from wrapping. A scope's key is
// already an AES-GCM wrapping key, and using one key as both an AES key
// and an HMAC key is the kind of reuse that has no known break and no
// reason to risk; deriving a distinct key costs one hash.
//
// The second layer binds the scope into the code, so a code computed
// under one scope is not a code under another even where a caller
// passes the same message. The NUL separator makes the concatenation
// unambiguous: without it, scope "ab" with message "c" and scope "a"
// with message "bc" would authenticate to the same value.
const macLabel = "grain/keys/mac/v1"

func scopeMac(key []byte, scope string, message []byte) []byte {
	derive := hmac.New(sha256.New, key)
	derive.Write([]byte(macLabel))
	macKey := derive.Sum(nil)

	code := hmac.New(sha256.New, macKey)
	code.Write([]byte(scope))
	code.Write([]byte{0})
	code.Write(message)
	return code.Sum(nil)
}
