// Metro has to be told about the monorepo: this package lives under
// surfaces/, and pnpm hoists shared dependencies to the repository root, so
// the default single-root config resolves neither the workspace nor the
// hoisted store. Both fields are Expo's documented monorepo setup.
const { getDefaultConfig } = require("expo/metro-config");
const path = require("node:path");

const projectRoot = __dirname;
const workspaceRoot = path.resolve(projectRoot, "..", "..");

const config = getDefaultConfig(projectRoot);
config.watchFolders = [workspaceRoot];
config.resolver.nodeModulesPaths = [
  path.resolve(projectRoot, "node_modules"),
  path.resolve(workspaceRoot, "node_modules"),
];

module.exports = config;
