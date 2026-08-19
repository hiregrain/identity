import js from "@eslint/js";

export default [
  { ignores: ["test/fixtures/**", "node_modules/**"] },
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
