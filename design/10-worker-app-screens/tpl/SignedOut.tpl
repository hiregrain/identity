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

<!-- I5. Unexpected sign-out. Names the reason, because an app that logs you
     out silently and asks you to prove yourself again is the shape of a
     phishing screen. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Signed out</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:30px 0 18px">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--ink)"
           stroke-width="1.5" aria-hidden="true"><use href="#i-alert"></use></svg>
      <h2 class="t-title" style="margin:16px 0 12px;font-size:25px;line-height:1.2;text-wrap:pretty">You were signed out</h2>
      <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">For your safety, after a long time away or a change to your account. Nothing about your record changed.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Send a code to +63 •• ••• 4471</button>
    <div style="padding-top:12px;text-align:center">
      <button class="btn-tertiary press">Use a different record</button>
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
