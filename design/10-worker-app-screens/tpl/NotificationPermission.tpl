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

<!-- I7. Asked after the first attestation request is sent, not at launch,
     and framed by the event rather than by the permission. `design/08` §3:
     asking at launch is the pattern that gets denied. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Notifications</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:30px 0 18px">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--ink)"
           stroke-width="1.5" aria-hidden="true"><use href="#i-tick"></use></svg>
      <h2 class="t-title" style="margin:16px 0 12px;font-size:25px;line-height:1.2;text-wrap:pretty">Should we tell you when a party attests?</h2>
      <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">That is the one thing worth interrupting you for. A business signing your work is the moment your record changes.</p>
    </div>
    <div class="grp">
      <p class="t-meta" style="margin:0;color:var(--secondary);text-wrap:pretty">
        Three events, and no more: a party attests, a grant is about to end, a
        deadline to attach your side. Never when somebody reads your record,
        because Grain does not surface that anywhere.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Yes, tell me</button>
    <div style="padding-top:12px;text-align:center">
      <button class="btn-tertiary press">No notifications</button>
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
