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

<!-- A1. The mark alone on paper. §12 says loading is the scribing arc,
     never a spinner, so the launch state uses the same arc rather than a
     second idiom nobody else in the app speaks. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
  <main style="position:absolute;inset:0;display:flex;flex-direction:column;
               align-items:center;justify-content:center;gap:26px">
    <svg viewBox="0 0 600 600" width="72" height="72" role="img" aria-label="Grain">@@MARK56@@</svg>
    <svg class="arc" viewBox="0 0 120 24" width="120" height="24" fill="none"
         stroke="var(--rule)" stroke-width="1.4" aria-label="Opening your record">
      <path d="@@ARC@@"/>
    </svg>
  </main>
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
