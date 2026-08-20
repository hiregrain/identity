# Red-path fixture: every unslop.mjs pattern planted once

This line has an em dash — used as a separator, which the check must flag.

This line has a spaced en dash – used as a separator, which the check must flag.

This line has curly quotes: “quoted” and ‘quoted’, which the check must flag.

This paragraph will delve into why utilize is banned, both tell words on one line.

## A heading with an emoji 🎉

This line has a JSON-escaped em dash \u2014 too, which the check must also flag.

`make check-red` asserts checks/unslop.mjs flags all six: the em dash, the
spaced en dash, the curly quotes, both tell words, the heading emoji, and
the escaped em dash a JSON string value would carry.
