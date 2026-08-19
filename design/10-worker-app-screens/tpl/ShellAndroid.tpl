<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
    .body{position:absolute;top:0;left:0;right:0;height:824px;border-radius:38px;
          background:var(--ink);box-shadow:inset 0 0 0 2px var(--secondary)}
    .screen{position:absolute;top:12px;left:12px;width:360px;height:800px;
            border-radius:28px;overflow:hidden;background:var(--paper)}
    .zone{position:absolute;left:0;right:0;background:repeating-linear-gradient(
          -45deg, var(--page) 0 6px, var(--paper) 6px 12px);
          border-block:1px solid var(--rule);display:flex;align-items:center;
          justify-content:center;z-index:4}
    .zone span{background:var(--paper);padding:1px 6px}
    .punch{position:absolute;top:7px;left:50%;transform:translateX(-50%);
           width:11px;height:11px;border-radius:50%;background:var(--ink);z-index:6}
  </style>
</helmet>

<div style="width:384px;height:990px;position:relative;background:var(--page)">
  <div class="body"></div>

  <div class="screen">
    <!-- 24 dp status bar; 48 dp three-button navigation, the larger of the two
         navigation modes and the one still shipped and still chosen. -->
    <div class="zone" style="top:0;height:24px">
      <span class="t-micro" style="color:var(--secondary)">status bar · 24 dp</span>
    </div>

    <div style="position:absolute;top:24px;bottom:48px;left:0;right:0;overflow:hidden">
      <dc-import name="Main" hint-size="100%,100%"></dc-import>
    </div>

    <div class="zone" style="bottom:0;height:48px">
      <span class="t-micro" style="color:var(--secondary)">navigation · 48 dp</span>
    </div>
    <div class="punch"></div>
  </div>

  <div style="position:absolute;left:0;right:0;top:918px;display:flex;flex-direction:column;gap:3px">
    <span class="t-micro" style="color:var(--secondary)">Android · 360 × 800 dp, common viewport</span>
    <span class="t-data" style="font-size:12px">{{ verdictH }}</span>
    <span class="t-data" style="font-size:12px">{{ verdictW }}</span>
  </div>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":384,"height":990}}'>
// Android shell. Back is a system gesture from BOTH edges, which is the
// constraint design/08 §3 records and no screen has been drawn against.
const DEVICE = {w:360, h:800, top:24, bottom:48};
const DRAWN = {w:360, h:800};
class Component extends DCLogic {
  renderVals(){
    const usable = DEVICE.h - DEVICE.top - DEVICE.bottom;
    const over = DRAWN.h - usable;
    return {
      verdictH: over > 0 ? over + ' dp too tall' : Math.abs(over) + ' dp to spare',
      verdictW: 'width fits'
    };
  }
}
</script>
</body>
</html>
