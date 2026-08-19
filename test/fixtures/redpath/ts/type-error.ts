// Red-path fixture: a deliberate type error. Outside the surfaces/
// workspace so no normal build sees it; `make check-red` points tsc here
// and asserts it fails.
const n: number = "not a number";
export default n;
