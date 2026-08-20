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

<!-- I2. Every failure names what it did NOT do. A worker whose record is the
     only proof they have needs to know a failed action left it alone, and a
     generic apology does not say that. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Something went wrong</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:32px 0 16px">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--ink)"
           stroke-width="1.5" aria-hidden="true"><use href="#i-alert"></use></svg>
      <h2 class="t-head" style="margin:16px 0 12px;line-height:1.2;text-wrap:pretty">That did not go through</h2>
      <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">It is us, not you, and nothing was written to your record. The record is unchanged.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Try again</button>
    <div style="padding-top:12px;text-align:center">
      <button class="btn-tertiary press">Message support</button>
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
