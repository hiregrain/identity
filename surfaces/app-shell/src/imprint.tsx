// The imprint, drawn in Skia, under a scribe and a pinch.
//
// This is what `app-shell/00` puts on the hardware. Three things are load
// bearing and none of them is decoration:
//
//   - `strokeWidth={0}` is Skia hairline mode, one device pixel regardless of
//     the canvas transform. Decision 044 makes stroke a device-pixel quantity,
//     and `react-native-svg` was disqualified from source in decision 040
//     because `setupStrokePaint` returns early at `strokeWidth == 0` and so
//     cannot express this at all.
//   - `end` trims every thread on every frame, which is what makes the scribe
//     a renderer test rather than an opacity fade.
//   - the pinch scales the whole figure, and hairline is what has to survive
//     it. Decision 040 recorded the figure faceting into polygons at 4x zoom
//     against the old fixed-sample polyline; the fixture is the Bezier fit
//     that replaced it.

import {
  Canvas,
  Group,
  Path,
  Skia,
  type SkPath,
} from "@shopify/react-native-skia";
import { useMemo } from "react";
import { Gesture, GestureDetector } from "react-native-gesture-handler";
import Animated, {
  useDerivedValue,
  type SharedValue,
} from "react-native-reanimated";

import { imprintFixture } from "./imprint-fixture";

export const SCRIBE_MS = 1080;

/** Parses the fixture once. A thread the parser rejects is a defect, not a skip. */
export function useImprintPaths(): SkPath[] {
  return useMemo(
    () =>
      imprintFixture.paths.map((d, index) => {
        const path = Skia.Path.MakeFromSVGString(d);
        if (path === null) {
          throw new Error(
            `imprint fixture: thread ${index} is not a parsable path`,
          );
        }
        return path;
      }),
    [],
  );
}

type ImprintProps = {
  /** Edge of the square canvas, in CSS pixels. */
  size: number;
  /** 0 to 1 across the scribe. Drives the trim on every thread. */
  progress: SharedValue<number>;
  /** Pinch factor, 1 at rest. */
  scale: SharedValue<number>;
  pinch: ReturnType<typeof Gesture.Pinch>;
};

export function Imprint({ size, progress, scale, pinch }: ImprintProps) {
  const paths = useImprintPaths();
  const unit = size / imprintFixture.viewBox;
  const zoom = useDerivedValue(() => [{ scale: scale.value }]);

  return (
    <GestureDetector gesture={pinch}>
      <Animated.View style={{ width: size, height: size }}>
        <Canvas style={{ width: size, height: size }}>
          <Group transform={zoom} origin={{ x: size / 2, y: size / 2 }}>
            <Group transform={[{ scale: unit }]}>
              {paths.map((path, index) => (
                <Path
                  key={index}
                  path={path}
                  style="stroke"
                  strokeWidth={0}
                  color={imprintFixture.ink}
                  start={0}
                  end={progress}
                />
              ))}
            </Group>
          </Group>
        </Canvas>
      </Animated.View>
    </GestureDetector>
  );
}
