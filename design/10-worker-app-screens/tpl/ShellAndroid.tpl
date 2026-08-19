<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
    .zone{position:absolute;left:0;right:0;background:repeating-linear-gradient(
          -45deg, var(--page) 0 6px, var(--paper) 6px 12px);
          border-block:1px solid var(--rule);display:flex;align-items:center;
          justify-content:center}
  </style>
</helmet>

<div style="width:360px;height:800px;position:relative;overflow:hidden;background:var(--page)">

  <!-- A common cheap-Android logical viewport, which is the population this
       product is for. Status bar 24dp; gesture navigation 24dp, but three-button
       navigation is 48dp and is still shipped and still chosen by users. The
       larger figure is the one to design against. -->
  <div class="zone" style="top:0;height:24px">
    <span class="t-micro" style="color:var(--secondary)">Status bar · 24 dp</span>
  </div>

  <div style="position:absolute;top:24px;bottom:48px;left:0;right:0;overflow:hidden;
              display:flex;align-items:flex-start;justify-content:center">
    <dc-import name="Main" hint-size="360px,800px"></dc-import>
  </div>

  <div class="zone" style="bottom:0;height:48px">
    <span class="t-micro" style="color:var(--secondary)">Navigation · 24 dp gesture, 48 dp three-button</span>
  </div>

  <div style="position:absolute;right:6px;top:29px;width:130px;text-align:right;z-index:5">
    <span class="t-micro" style="color:var(--ink);background:var(--paper);padding:2px 4px">
      {{ verdict }}</span>
  </div>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Android shell. Back is a system gesture from BOTH edges, which is the
// constraint design/08 §3 records and no screen has been drawn against.
const DEVICE = {w:360, h:800, top:24, bottom:48};
const DRAWN = {w:360, h:800};
class Component extends DCLogic {
  renderVals(){
    const usable = DEVICE.h - DEVICE.top - DEVICE.bottom;
    const over = DRAWN.h - usable;
    return {
      verdict: over > 0
        ? over + 'dp taller than Android leaves'
        : Math.abs(over) + 'dp of room to spare'
    };
  }
}
</script>
</body>
</html>
