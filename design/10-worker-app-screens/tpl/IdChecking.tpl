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

<!-- F4. Unknown duration, so the arc rather than the band. A percentage
     here would be invented, and §12 is explicit that loading is the scribing
     arc and never a spinner. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Cancel">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Checking</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:56px;text-align:center">
      <svg class="arc" viewBox="0 0 120 24" width="120" height="24" fill="none"
           stroke="var(--rule)" stroke-width="1.4" aria-label="Checking your document">
        <path d="@@ARC@@"/>
      </svg>
      <h2 class="t-lead" style="margin:24px 0 8px;">Checking the document</h2>
      <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">
        Usually under a minute. You can close the app; we will tell you when it
        is done.</p>
    </div>
    <div style="margin-top:40px;border-top:1px solid var(--hairline);padding-top:16px">
      <p class="t-meta" style="margin:0;color:var(--secondary);text-wrap:pretty">
        The photo goes to Persona and not to Grain. When they answer, we keep
        that a document was checked and the date, and nothing else.</p>
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
