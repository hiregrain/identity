package kernel

import (
	"math"
	"testing"
)

// The expectations here are written by hand from ECMA-262
// Number::toString, not captured from this implementation, which is the
// only way this test says anything the golden vectors do not already say.
// Every case names the branch of the algorithm it lands in.
func TestFormatNumberFollowsEcmaScript(t *testing.T) {
	cases := []struct {
		name  string
		value float64
		want  string
	}{
		{name: "zero", value: 0, want: "0"},
		{name: "negative zero renders as zero", value: negativeZero(), want: "0"},
		{name: "small integer, k <= n <= 21", value: 100, want: "100"},
		{name: "integer written as a decimal keeps no point", value: 1.0, want: "1"},
		{name: "largest exact integer", value: 9007199254740991, want: "9007199254740991"},
		{name: "twenty-one digits still expand", value: 1e20, want: "100000000000000000000"},
		{name: "one past the expansion limit takes an exponent", value: 1e21, want: "1e+21"},
		{name: "fraction, 0 < n <= 21", value: 1.5, want: "1.5"},
		{name: "negative fraction", value: -1.5, want: "-1.5"},
		{name: "leading zeros, -6 < n <= 0", value: 0.000001, want: "0.000001"},
		{name: "one past the leading-zero limit", value: 1e-7, want: "1e-7"},
		{name: "single digit with a negative exponent", value: 1e-9, want: "1e-9"},
		{name: "several digits with a negative exponent", value: -1.5e-9, want: "-1.5e-9"},
		{name: "rounding to the nearest double", value: 333333333333333333333, want: "333333333333333300000"},
		{name: "a third", value: 1.0 / 3.0, want: "0.3333333333333333"},
	}

	for _, testCase := range cases {
		t.Run(testCase.name, func(t *testing.T) {
			got, err := formatNumber(testCase.value)
			if err != nil {
				t.Fatalf("formatNumber(%v): %v", testCase.value, err)
			}
			if got != testCase.want {
				t.Fatalf("formatNumber(%v) = %s, want %s", testCase.value, got, testCase.want)
			}
		})
	}
}

// negativeZero produces -0 without a compile-time constant, which Go folds
// to +0.
func negativeZero() float64 {
	zero := 0.0
	return -zero
}

func TestFormatNumberRejectsNonFinite(t *testing.T) {
	for _, value := range []float64{math.Inf(1), math.Inf(-1), math.NaN()} {
		if _, err := formatNumber(value); err == nil {
			t.Fatalf("formatNumber(%v) accepted a non-finite value", value)
		}
	}
}
