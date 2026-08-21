import js from "@eslint/js";

export default [
  // .claude holds agent worktrees, which are gitignored and exist only on a
  // developer machine. CI checks out a tree without them, so linting them
  // reports hundreds of errors locally and none in CI, which makes `make lint`
  // useless as a pre-push check exactly when it matters.
  //
  // The surfaces TypeScript is excluded here and covered by `tsc --noEmit` in
  // the ts-check stage instead: eslint has no built-in TypeScript parser, so
  // linting .ts/.tsx means taking typescript-eslint as a dependency, which is
  // a call app-shell/00 was not authored to make.
  {
    ignores: [
      "test/fixtures/**",
      "node_modules/**",
      ".claude/**",
      "surfaces/**/*.{ts,tsx}",
      "surfaces/**/ios/**",
      "surfaces/**/android/**",
    ],
  },
  js.configs.recommended,
  {
    files: [
      "checks/**/*.mjs",
      "db/**/*.mjs",
      "test/*.mjs",
      "surfaces/**/*.mjs",
    ],
    languageOptions: {
      ecmaVersion: 2024,
      sourceType: "module",
      globals: {
        console: "readonly",
        process: "readonly",
        Buffer: "readonly",
      },
    },
  },
  // babel.config.js and metro.config.js are CommonJS by the toolchains' own
  // requirement: Babel and Metro both load their config through require.
  {
    files: ["surfaces/**/*.js"],
    languageOptions: {
      ecmaVersion: 2024,
      sourceType: "commonjs",
      globals: {
        __dirname: "readonly",
        module: "writable",
        require: "readonly",
      },
    },
  },
];
