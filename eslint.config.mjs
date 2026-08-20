import js from "@eslint/js";

export default [
  // .claude holds agent worktrees, which are gitignored and exist only on a
  // developer machine. CI checks out a tree without them, so linting them
  // reports hundreds of errors locally and none in CI, which makes `make lint`
  // useless as a pre-push check exactly when it matters.
  { ignores: ["test/fixtures/**", "node_modules/**", ".claude/**"] },
  js.configs.recommended,
  {
    files: [
      "checks/**/*.mjs",
      "db/**/*.mjs",
      "test/*.mjs",
      "surfaces/**/*.{js,mjs,ts,tsx}",
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
];
