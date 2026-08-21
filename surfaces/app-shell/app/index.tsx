// The device spike screen: the figure, the 1080 ms scribe, and a pinch.
//
// What the founder is asked to do with it, and what a clean run proves, is in
// this package's README. The screen states the load it is carrying on itself
// so an attestation photograph carries the number rather than depending on
// someone remembering it.

import { useEffect } from "react";
import { Pressable, Text, View, useWindowDimensions } from "react-native";
import { Gesture } from "react-native-gesture-handler";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Easing, useSharedValue, withTiming } from "react-native-reanimated";

import { imprintFixture } from "../src/imprint-fixture";
import { Imprint, SCRIBE_MS } from "../src/imprint";

export default function DeviceSpike() {
  const { width } = useWindowDimensions();
  const insets = useSafeAreaInsets();
  const size = Math.min(width, 360);

  const progress = useSharedValue(0);
  const scale = useSharedValue(1);
  const pinchStart = useSharedValue(1);

  const scribe = () => {
    progress.value = 0;
    progress.value = withTiming(1, {
      duration: SCRIBE_MS,
      easing: Easing.linear,
    });
  };

  useEffect(scribe, []);

  const pinch = Gesture.Pinch()
    .onStart(() => {
      pinchStart.value = scale.value;
    })
    .onUpdate((event) => {
      scale.value = Math.min(8, Math.max(1, pinchStart.value * event.scale));
    });

  return (
    <View
      style={{
        flex: 1,
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: imprintFixture.paper,
        paddingTop: insets.top,
        paddingBottom: insets.bottom,
      }}
    >
      <Imprint size={size} progress={progress} scale={scale} pinch={pinch} />
      <Text style={{ color: imprintFixture.ink, fontSize: 13, marginTop: 24 }}>
        {imprintFixture.vertices} path commands, {imprintFixture.paths.length}{" "}
        threads
      </Text>
      <Text style={{ color: imprintFixture.ink, fontSize: 13, marginTop: 4 }}>
        twice the density this canvas budgets; pinch to 2x to see it as drawn
      </Text>
      <Pressable
        onPress={scribe}
        style={{
          marginTop: 20,
          paddingVertical: 12,
          paddingHorizontal: 24,
          borderWidth: 1,
          borderColor: imprintFixture.ink,
        }}
      >
        <Text style={{ color: imprintFixture.ink, fontSize: 15 }}>
          Scribe again
        </Text>
      </Pressable>
    </View>
  );
}
