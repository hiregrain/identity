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

<!-- A2. What a person arriving cold is told, before any field. One claim,
     one refusal, two doors. The refusal is on the lander deliberately: a
     record that says what it will not do reads differently from one that
     opens with what it promises. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
  <main class="dissolve" style="position:absolute;top:0;bottom:150px;left:0;right:0;
               overflow-y:auto;padding:44px 20px 24px">
    <svg viewBox="0 0 160 26" width="148" height="24" role="img" aria-label="Grain">@@LOCKUP@@</svg>
    <h1 class="t-title" style="margin:34px 0 0;font-size:29px;line-height:1.15;text-wrap:pretty">
      A record of the work you have actually done.</h1>
    <p class="t-body" style="margin:16px 0 0;color:var(--secondary);text-wrap:pretty">
      The businesses you worked for sign what you did there. You choose who reads
      it. It is yours, it is free, and it stays free.</p>
    <div style="margin-top:30px;border-top:1px solid var(--ink);padding-top:14px">
      <p class="t-body" style="margin:0;text-wrap:pretty">
        Grain never says whether you are any good. It says what happened and who
        confirmed it, and the person reading decides what that is worth.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Start a record</button>
    <div style="padding-top:12px;text-align:center">
      <button class="btn-tertiary press">I already have one</button>
    </div>
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
