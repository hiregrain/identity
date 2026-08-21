package kernel

import (
	"errors"
	"math"
	"strconv"
)

// ErrNumberNotFinite reports a JSON number that has no IEEE 754 double
// representation JCS can serialize. RFC 8785 excludes NaN and both
// infinities, and JSON has no literal for them, so this is reachable only
// from a value that overflows on parse.
var ErrNumberNotFinite = errors.New("kernel: number is not finite")

// formatNumber renders a float64 exactly as ECMAScript Number::toString
// does, which is contract rule 2. Go's own float formatting agrees on the
// digits and disagrees on where the decimal point and the exponent go, so
// the digits come from Go and the placement is reimplemented here from
// ECMA-262 Number::toString step 5.
//
// The variables below are ECMA-262's own: k digits, the integer s they
// spell, and n such that s * 10^(n-k) is the value. Keeping the spec's
// names is what makes the five branches checkable against the spec text.
func formatNumber(f float64) (string, error) {
	if math.IsNaN(f) || math.IsInf(f, 0) {
		return "", ErrNumberNotFinite
	}
	// Negative zero renders as "0": contract rule 2, and ECMA-262's step 2.
	if f == 0 {
		return "0", nil
	}
	sign := ""
	if f < 0 {
		sign = "-"
		f = -f
	}

	// 'e' with precision -1 is the shortest digit string that round-trips,
	// which is ECMA-262's "k is as small as possible" clause, formatted as
	// d[.ddd]e±dd. The digits are s; the printed exponent is n-1.
	shortest := strconv.FormatFloat(f, 'e', -1, 64)
	mantissa, exponent, err := splitExponential(shortest)
	if err != nil {
		return "", err
	}
	digits := mantissa[:1]
	if len(mantissa) > 2 {
		digits += mantissa[2:]
	}
	k := len(digits)
	n := exponent + 1

	switch {
	case k <= n && n <= 21:
		return sign + digits + zeros(n-k), nil
	case 0 < n && n <= 21:
		return sign + digits[:n] + "." + digits[n:], nil
	case -6 < n && n <= 0:
		return sign + "0." + zeros(-n) + digits, nil
	case k == 1:
		return sign + digits + "e" + exponentSuffix(n-1), nil
	default:
		return sign + digits[:1] + "." + digits[1:] + "e" + exponentSuffix(n-1), nil
	}
}

// splitExponential takes Go's d[.ddd]e±dd form apart. It returns the
// mantissa with its decimal point still in place and the printed exponent.
func splitExponential(s string) (mantissa string, exponent int, err error) {
	for i := 0; i < len(s); i++ {
		if s[i] == 'e' {
			exponent, err = strconv.Atoi(s[i+1:])
			if err != nil {
				return "", 0, err
			}
			return s[:i], exponent, nil
		}
	}
	return "", 0, errors.New("kernel: shortest float form carries no exponent")
}

// exponentSuffix writes the exponent with an explicit sign, which is the
// half of contract rule 2 that separates 1e+21 from Go's own 1e21.
func exponentSuffix(e int) string {
	if e >= 0 {
		return "+" + strconv.Itoa(e)
	}
	return "-" + strconv.Itoa(-e)
}

func zeros(count int) string {
	out := make([]byte, count)
	for i := range out {
		out[i] = '0'
	}
	return string(out)
}
