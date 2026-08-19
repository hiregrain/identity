<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
    /* iPhone 17 — 402x874 pt at 3x, status bar 54, safe area top 62, bottom 34.
       The frame is drawn from those published metrics. The insets are reserved
       and measured, never simulated: no clock, no battery, no home-bar glyph,
       because a real device draws its own into exactly that space. */
    .body{position:absolute;inset:0;border-radius:66px;background:var(--ink);
          box-shadow:inset 0 0 0 2px var(--secondary)}
    .screen{position:absolute;top:12px;left:12px;width:402px;height:874px;
            border-radius:55px;overflow:hidden;background:var(--paper)}
    .island{position:absolute;top:14px;left:50%;transform:translateX(-50%);
            width:126px;height:37px;border-radius:19px;background:var(--ink);z-index:6}
    .inset{position:absolute;left:0;right:0;z-index:4;display:flex;align-items:center;
           justify-content:center;
           background:repeating-linear-gradient(-45deg,var(--page) 0 6px,var(--paper) 6px 12px)}
    .inset span{background:var(--paper);padding:1px 6px}
    .rule{position:absolute;left:0;right:0;border-top:1px solid var(--rule);z-index:5}
  </style>
</helmet>

<div style="width:426px;height:898px;position:relative;background:var(--page)">
  <div class="body"></div>

  <div class="screen">
    <!-- 62 pt of safe-area top: the status bar and the Dynamic Island live here -->
    <div class="inset" style="top:0;height:62px">
      <span class="t-micro" style="color:var(--secondary)">safe-area-inset-top · 62 pt</span>
    </div>
    <div class="rule" style="top:62px"></div>

    <!-- What iOS actually leaves a screen: 874 - 62 - 34 -->
    <div style="position:absolute;top:62px;bottom:34px;left:0;right:0;overflow:hidden;
                display:flex;align-items:flex-start;justify-content:center">
      <dc-import name="Main" hint-size="360px,800px"></dc-import>
    </div>

    <div class="rule" style="bottom:34px"></div>
    <div class="inset" style="bottom:0;height:34px">
      <span class="t-micro" style="color:var(--secondary)">home indicator · 34 pt</span>
    </div>

    <div class="island"></div>
  </div>

  <div style="position:absolute;right:20px;top:88px;width:150px;text-align:right;z-index:7">
    <span class="t-micro" style="color:var(--ink);background:var(--paper);padding:2px 5px;
                                 display:inline-block;line-height:1.5">{{ verdictH }}</span><br>
    <span class="t-micro" style="color:var(--ink);background:var(--paper);padding:2px 5px;
                                 display:inline-block;margin-top:3px;line-height:1.5">{{ verdictW }}</span>
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
