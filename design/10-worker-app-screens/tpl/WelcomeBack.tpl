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

<!-- A5. The record is recalled, the identifier is masked, and one tap gets
     back in. Nothing here states the name as a greeting: 050 settled that a
     record which welcomes you is a record performing. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
  <main style="position:absolute;inset:0;display:flex;flex-direction:column;
               justify-content:center;padding:0 20px 56px">
    <svg viewBox="0 0 160 26" width="132" height="21" role="img" aria-label="Grain"
         style="margin-bottom:32px">@@LOCKUP@@</svg>
    <p class="t-data" style="margin:0 0 6px;color:var(--secondary)">This device holds a record for</p>
    <h1 class="t-title" style="margin:0">Liezel Mendoza</h1>
    <p class="t-data" style="margin:8px 0 0;color:var(--secondary)">+63 •• ••• 4471</p>
    <div style="padding-top:32px;display:flex;flex-direction:column;gap:12px">
      <button class="btn-primary press">Send a code to this number</button>
      <button class="btn-secondary press">Use a different record</button>
    </div>
    <p class="t-meta" style="margin:20px 0 0;color:var(--secondary);text-wrap:pretty">
      Only the masked number is kept on this device. The record itself is not.</p>
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
