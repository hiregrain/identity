package kernel

import (
	"fmt"
	"math/rand"
	"strings"
	"testing"
	"unicode/utf16"
)

// Finding 8 replaced an O(n^2) insertion sort and an allocating comparison
// with slices.SortFunc over a non-allocating comparator. These tests hold
// the behaviour identical to the old []uint16 comparison and cover a large
// reverse-ordered object, which is what made the old cost visible.

// referenceLessUTF16 is the comparison the old sort used, kept here as the
// oracle the new comparator is checked against.
func referenceLessUTF16(a, b string) bool {
	left := utf16.Encode([]rune(a))
	right := utf16.Encode([]rune(b))
	for i := 0; i < len(left) && i < len(right); i++ {
		if left[i] != right[i] {
			return left[i] < right[i]
		}
	}
	return len(left) < len(right)
}

func TestCompareUTF16MatchesTheReferenceOrder(t *testing.T) {
	// A pool mixing ASCII, basic-multilingual, and supplementary-plane
	// code points, since the two orderings only diverge across the planes.
	pool := []string{
		"", "a", "A", "Z", "z", "aa", "ab", "é", "å", "Å",
		"￿", "", "\U00010000", "\U0001f600", "\U00010000a",
		"￿a", "a\U00010000", "middle\U0001f4a9end", "  ",
	}
	random := rand.New(rand.NewSource(11))
	for i := 0; i < 20000; i++ {
		a := pool[random.Intn(len(pool))]
		b := pool[random.Intn(len(pool))]
		got := compareUTF16(a, b)
		want := 0
		switch {
		case referenceLessUTF16(a, b):
			want = -1
		case referenceLessUTF16(b, a):
			want = 1
		}
		if signOf(got) != want {
			t.Fatalf("compareUTF16(%q, %q) = %d, reference order = %d", a, b, got, want)
		}
	}
}

func signOf(n int) int {
	switch {
	case n < 0:
		return -1
	case n > 0:
		return 1
	default:
		return 0
	}
}

// A large reverse-ordered object sorts to ascending UTF-16 order. Reverse
// input is the arrangement an insertion sort paid n^2 for.
func TestCanonicalizeSortsALargeReverseOrderedObject(t *testing.T) {
	const n = 4000
	var b strings.Builder
	b.WriteByte('{')
	for i := 0; i < n; i++ {
		if i > 0 {
			b.WriteByte(',')
		}
		// Descending keys: k03999, k03998, ... so the input is fully
		// reversed relative to the sorted output.
		fmt.Fprintf(&b, `"k%05d":%d`, n-1-i, i)
	}
	b.WriteByte('}')

	got, err := Canonicalize([]byte(b.String()))
	if err != nil {
		t.Fatal(err)
	}

	// The canonical form must open with the lowest key and its value is the
	// last one written, n-1.
	wantHead := fmt.Sprintf(`{"k%05d":%d,`, 0, n-1)
	if !strings.HasPrefix(string(got), wantHead) {
		t.Fatalf("canonical form starts %q, want prefix %q", string(got)[:len(wantHead)], wantHead)
	}
	// And the keys in the output are strictly ascending.
	keys := extractKeys(string(got))
	if len(keys) != n {
		t.Fatalf("got %d keys, want %d", len(keys), n)
	}
	for i := 1; i < len(keys); i++ {
		if keys[i-1] >= keys[i] {
			t.Fatalf("keys not ascending at %d: %q then %q", i, keys[i-1], keys[i])
		}
	}
}

// extractKeys pulls the member names out of a canonical flat object of
// string-keyed integer values.
func extractKeys(canonical string) []string {
	var keys []string
	body := strings.TrimSuffix(strings.TrimPrefix(canonical, "{"), "}")
	for _, pair := range strings.Split(body, ",") {
		colon := strings.IndexByte(pair, ':')
		keys = append(keys, strings.Trim(pair[:colon], `"`))
	}
	return keys
}
