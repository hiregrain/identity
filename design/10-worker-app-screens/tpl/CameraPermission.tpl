<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
  </style>
</helmet>

<!-- I6. Asked in context, immediately before the camera screen, never at
     launch. Asking at launch is the pattern that gets denied, and a denied
     camera permission is a dead identity check. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Camera</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:30px 0 18px">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--ink)"
           stroke-width="1.5" aria-hidden="true"><use href="#i-camera"></use></svg>
      <h2 class="t-title" style="margin:16px 0 12px;font-size:25px;line-height:1.2;text-wrap:pretty">Grain needs the camera for this</h2>
      <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">Only to photograph your document, only while you are on that screen, and never in the background.</p>
    </div>
    <div class="grp">
      <p class="t-meta" style="margin:0;color:var(--secondary);text-wrap:pretty">
        If you say no, the identity check is the only thing that stops working.
        Everything else on your record is unaffected, and you can allow it later.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Allow the camera</button>
    <div style="padding-top:12px;text-align:center">
      <button class="btn-tertiary press">Not now</button>
    </div>
  </div>

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
