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

<!-- F6. Separate, declinable, and after the document passes. Bundling it
     into the document step would make a second biometric feel like part of
     the first, which it is not. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your record">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Liveness check</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <h2 class="t-head" style="margin:0 0 14px;line-height:1.2;text-wrap:pretty">
        A short video, to show the document is yours</h2>
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">
        Optional, and separate from the document check you already passed. It
        raises how strongly a reader can rely on the identity, and it changes
        nothing about the work.</p>

      <sc-for list="{{ rows }}" as="r" hint-placeholder-count="3">
        <div style="display:flex;gap:14px;align-items:flex-start;padding:14px 0;
                    border-bottom:1px solid var(--hairline)">
          <span class="t-meta" style="flex:0 0 96px;color:var(--secondary);padding-top:2px">{{ r.k }}</span>
          <span class="t-body" style="flex:1;min-width:0;text-wrap:pretty">{{ r.v }}</span>
        </div>
      </sc-for>

      <p class="t-meta" style="margin:16px 0 0;color:var(--secondary);text-wrap:pretty">
        Declining costs you nothing you already have. Your document check stands
        either way.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Record it</button>
    <div style="padding-top:12px;text-align:center">
      <button class="btn-tertiary press">No thanks</button>
    </div>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { rows: [
      {k:'What it is', v:'A few seconds of video, following a prompt on screen.'},
      {k:'Who reads it', v:'Persona, the same vendor. Not Grain.'},
      {k:'What is kept', v:'That a liveness check passed, and when. Never the video.'}
    ]};
  }
}
</script>
</body>
</html>
