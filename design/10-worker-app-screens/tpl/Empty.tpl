<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
    .plate{position:absolute;inset:0;pointer-events:none}
    .reg{position:absolute;width:11px;height:11px;border:0 solid var(--ink);opacity:.55}
  </style>
</helmet>

<!-- Fluid in both axes: the record fills whatever safe area it is given, and
     min-height carries the standalone case where height:100% has no sized
     ancestor and would collapse to zero. 728 is the common safe box across
     iOS (778) and Android (728). Decision 046. -->
<div style="width:100%;height:100%;min-height:728px;position:relative;overflow:hidden;background:var(--paper)">
  <div class="plate">
    <div class="reg" style="top:7px;left:7px;border-top-width:1px;border-left-width:1px"></div>
    <div class="reg" style="top:7px;right:7px;border-top-width:1px;border-right-width:1px"></div>
    <div class="reg" style="bottom:7px;left:7px;border-bottom-width:1px;border-left-width:1px"></div>
    <div class="reg" style="bottom:7px;right:7px;border-bottom-width:1px;border-right-width:1px"></div>
  </div>

  <header style="height:52px;display:flex;align-items:center;gap:10px;padding:0 20px;
                 border-bottom:1px solid var(--hairline)">
    <!-- The lockup: mark plus the GRAIN wordmark (§4a), generated so the mark
         swaps to its drawn reduction rather than scaling a master. -->
    <svg viewBox="0 0 160 26" width="160" height="26" role="img" aria-label="Grain">@@LOCKUP@@</svg>
  </header>

  <main style="position:absolute;top:52px;bottom:0;left:0;right:0;padding:0 20px;
               display:flex;flex-direction:column;justify-content:center;gap:40px">
    <!-- the fixed canvas, empty. The graticule ground (§9) carries it; there is no
         identity core, and no boundary ring: absence is drawn as absence. -->
    <div style="position:relative;width:296px;height:296px;align-self:center">
      <svg viewBox="0 0 296 296" width="296" height="296" aria-label="Your record, empty">
        <defs><clipPath id="canv"><circle cx="148" cy="148" r="139"></circle></clipPath></defs>
        <g clip-path="url(#canv)" fill="none" stroke="var(--hairline)" stroke-width=".75">
          @@GRATICULE_LG@@
        </g>
      </svg>
    </div>
    <div>
      <h1 class="t-title" style="margin:0 0 12px">Nothing<br>on it yet</h1>
      <p class="t-body" style="margin:0 0 28px;color:var(--secondary);max-width:280px;text-wrap:pretty">
        Add where you have worked. Work nobody has confirmed is drawn plain. It fills in
        when someone who was there signs for it.
      </p>
      <div style="display:flex;flex-direction:column;gap:12px">
        <button class="btn-primary press">Add where you worked</button>
        <button class="btn-secondary press">Import a résumé</button>
      </div>
    </div>
  </main>

</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic { renderVals(){ return {}; } }
</script>
</body>
</html>
