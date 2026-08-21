// The root layout. GestureHandlerRootView has to wrap everything or a pinch
// registers nowhere on Android; it is gesture-handler's own documented
// requirement, not a precaution.
import { Stack } from "expo-router";
import { GestureHandlerRootView } from "react-native-gesture-handler";

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <Stack screenOptions={{ headerShown: false }} />
    </GestureHandlerRootView>
  );
}
