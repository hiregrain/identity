<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
    /* A verification frame, not a design. Nothing here paints fake chrome —
       no clock, no battery, no home bar glyph. The insets are drawn as empty
       reserved bands with their measurements, because on a real device the
       system draws its own chrome into exactly that space and a painted
       imitation renders doubled. */
    .zone{position:absolute;left:0;right:0;background:repeating-linear-gradient(
          -45deg, var(--page) 0 6px, var(--paper) 6px 12px);
          border-block:1px solid var(--rule);display:flex;align-items:center;
          justify-content:center}
    .caliper{position:absolute;display:flex;align-items:center;gap:6px}
  </style>
</helmet>

<div style="width:393px;height:852px;position:relative;overflow:hidden;background:var(--page)">

  <!-- iPhone 15/16 logical points. Safe-area insets from the platform, not
       invented: 59pt top with the Dynamic Island, 34pt bottom home indicator. -->
  <div class="zone" style="top:0;height:59px">
    <span class="t-micro" style="color:var(--secondary)">Status bar and Dynamic Island · 59 pt reserved</span>
  </div>

  <div style="position:absolute;top:59px;bottom:34px;left:0;right:0;overflow:hidden;
              display:flex;align-items:flex-start;justify-content:center">
    <!-- The record screen at its drawn size, inside what iOS actually leaves. -->
    <dc-import name="Main" hint-size="360px,800px"></dc-import>
  </div>

  <div class="zone" style="bottom:0;height:34px">
    <span class="t-micro" style="color:var(--secondary)">Home indicator · 34 pt reserved</span>
  </div>

  <!-- The measurement that matters, stated on the artboard rather than in a doc -->
  <div style="position:absolute;right:6px;top:64px;width:120px;text-align:right;z-index:5">
    <span class="t-micro" style="color:var(--ink);background:var(--paper);padding:2px 4px">
      {{ verdict }}</span>
  </div>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":393,"height":852}}'>
// iOS shell. The screens are drawn 360x800; this frame says what iOS leaves.
const DEVICE = {w:393, h:852, top:59, bottom:34};
const DRAWN = {w:360, h:800};
class Component extends DCLogic {
  renderVals(){
    const usable = DEVICE.h - DEVICE.top - DEVICE.bottom;
    const over = DRAWN.h - usable;
    return {
      verdict: over > 0
        ? over + 'pt taller than iOS leaves'
        : Math.abs(over) + 'pt of room to spare'
    };
  }
}
</script>
</body>
</html>
