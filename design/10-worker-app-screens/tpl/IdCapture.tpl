<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .vf{position:absolute;inset:0}
    .vfreg{position:absolute;width:26px;height:26px;border:0 solid var(--paper)}
  </style>
</helmet>

<!-- F3. In Grain's own chrome, vendor named. The plate's registration
     corners have their one honest job here: they are not decoration on a
     camera frame, they are the frame. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--ink)">

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
  <header style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 8px 0 4px;position:relative;z-index:3">
    <button class="iconbtn press" aria-label="Back">
      <svg width="22" height="22" viewBox="0 0 24 24" style="stroke:var(--paper)"><use href="#i-back"></use></svg>
    </button>
    <span class="t-micro" style="color:var(--paper);opacity:.75;padding-right:12px">Checked by Persona</span>
  </header>

  <div style="position:absolute;top:52px;bottom:150px;left:0;right:0">
    <div class="vf">
      <div class="vfreg" style="top:26px;left:22px;border-top-width:1.5px;border-left-width:1.5px"></div>
      <div class="vfreg" style="top:26px;right:22px;border-top-width:1.5px;border-right-width:1.5px"></div>
      <div class="vfreg" style="bottom:26px;left:22px;border-bottom-width:1.5px;border-left-width:1.5px"></div>
      <div class="vfreg" style="bottom:26px;right:22px;border-bottom-width:1.5px;border-right-width:1.5px"></div>
    </div>
  </div>

  <div style="position:absolute;left:0;right:0;bottom:0;padding:20px 20px 28px;text-align:center">
    <p class="t-body" style="margin:0 0 6px;color:var(--paper);text-wrap:pretty">
      Fill the frame with the photo page</p>
    <p class="t-meta" style="margin:0 0 20px;color:var(--paper);opacity:.7;text-wrap:pretty">
      Flat, in good light, no flash on the plastic</p>
    <button class="press" aria-label="Take the photo"
            style="width:66px;height:66px;border:1.5px solid var(--paper);border-radius:50%;
                   margin-inline:auto;display:flex;align-items:center;justify-content:center">
      <svg width="26" height="26" viewBox="0 0 24 24" style="stroke:var(--paper);stroke-width:1.5;fill:none">
        <use href="#i-camera"></use></svg>
    </button>
  </div>
  </main>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){ return {}; }
}
</script>
</body>
</html>
