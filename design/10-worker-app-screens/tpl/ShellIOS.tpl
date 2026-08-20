<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
    /* iPhone 17, 402x874 pt at 3x, status bar 54, safe area top 62, bottom 34.
       The frame is drawn from those published metrics. The insets are reserved
       and measured, never simulated: no clock, no battery, no home-bar glyph,
       because a real device draws its own into exactly that space. */
    .body{position:absolute;top:0;left:0;right:0;border-radius:66px;background:var(--ink);
          box-shadow:inset 0 0 0 2px var(--secondary)}
    .screen{position:absolute;top:12px;left:12px;width:402px;height:874px;
            border-radius:55px;overflow:hidden;background:var(--paper)}
    .island{position:absolute;top:14px;left:50%;transform:translateX(-50%);
            width:126px;height:37px;border-radius:19px;background:var(--ink);z-index:6}
    .inset{position:absolute;left:0;right:0;z-index:4;display:flex;align-items:center;
           justify-content:center;
           background:repeating-linear-gradient(-45deg,var(--page) 0 6px,var(--paper) 6px 12px)}
    .inset span{background:var(--paper);padding:2px 6px}
    .rule{position:absolute;left:0;right:0;border-top:1px solid var(--rule);z-index:5}
  </style>
</helmet>

<div style="width:426px;height:990px;position:relative;background:var(--page)">
  <div class="body" style="height:898px"></div>

  <div class="screen">
    <!-- 62 pt of safe-area top: the status bar and the Dynamic Island live here -->
    <div class="inset" style="top:0;height:62px">
      <span class="t-micro" style="color:var(--secondary)">safe-area-inset-top · 62 pt</span>
    </div>
    <div class="rule" style="top:62px"></div>

    <!-- No band drawn over the home indicator: that space belongs to the
         system, and hatching it reads as a boundary the app owns.
    What iOS actually leaves a screen: 874 - 62 - 34 -->
    <!-- Exactly what iOS leaves, and the app fills it. It used to be a fixed
         360px column centred in 402, which left 42 pt of the display dead. -->
    <div style="position:absolute;top:62px;bottom:34px;left:0;right:0;overflow:hidden">
        <dc-import name="Main" hint-size="100%,100%"></dc-import>
    </div>


    <div class="island"></div>
  </div>

  <!-- Measurements sit BELOW the device. They were drawn inside it, over the app. -->
  <div style="position:absolute;left:0;right:0;top:918px;display:flex;flex-direction:column;gap:3px">
    <span class="t-micro" style="color:var(--secondary)">iPhone 17 · 402 × 874 pt @3x</span>
    <span class="t-data" style="font-size:12px">{{ verdictH }}</span>
    <span class="t-data" style="font-size:12px">{{ verdictW }}</span>
  </div>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":426,"height":898}}'>
// iPhone 17, from the published metrics rather than memory: 402x874 pt at 3x,
// status bar 54 pt, portrait safe area top 62 / bottom 34 / left 0 / right 0.
const DEVICE = {w:402, h:874, top:62, bottom:34};
const DRAWN  = {w:360, h:800};
class Component extends DCLogic {
  renderVals(){
    const usableH = DEVICE.h - DEVICE.top - DEVICE.bottom;   // 778
    const overH = DRAWN.h - usableH;
    const spareW = DEVICE.w - DRAWN.w;
    return {
      verdictH: overH > 0 ? overH + ' pt too tall' : Math.abs(overH) + ' pt to spare',
      verdictW: spareW > 0 ? spareW + ' pt of width unused' : 'width fits'
    };
  }
}
</script>
</body>
</html>
