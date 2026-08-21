// react-native-worklets/plugin must be last: Reanimated 4 moved the worklet
// transform out of react-native-reanimated/plugin, and the ordering is the
// plugin's own documented requirement.
module.exports = function (api) {
  api.cache(true);
  return {
    presets: ["babel-preset-expo"],
    plugins: ["react-native-worklets/plugin"],
  };
};
