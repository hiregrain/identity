// react-native-worklets/plugin must be last: Reanimated 4 moved the worklet
// transform out of react-native-reanimated/plugin, and the ordering is the
// plugin's own documented requirement.
//
// babel-preset-expo is a declared dependency of this package rather than an
// inherited one. Babel resolves presets relative to @babel/core, and under
// pnpm's isolated layout a transitive copy is not visible from there: the
// release bundle fails with `Cannot find module 'babel-preset-expo'` in
// gradle's createBundleReleaseJsAndAssets. The debug build does not embed a
// bundle, so it never surfaced it.
module.exports = function (api) {
  api.cache(true);
  return {
    presets: ["babel-preset-expo"],
    plugins: ["react-native-worklets/plugin"],
  };
};
