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

<!-- I3. A handle that does not resolve. It must not distinguish never-existed
     from deleted: 038 makes deletion total, and a page that said "deleted"
     would leak the fact a record was once there, which is the thing deletion
     is for. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Address not found</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:30px 0 18px">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--ink)"
           stroke-width="1.5" aria-hidden="true"><use href="#i-alert"></use></svg>
      <h2 class="t-title" style="margin:16px 0 12px;font-size:25px;line-height:1.2;text-wrap:pretty">No record at that address</h2>
      <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">hiregrain.com/u/that-name does not resolve. Either it was never claimed, or the person deleted their record.</p>
    </div>
    <div class="grp">
      <p class="t-meta" style="margin:0;color:var(--secondary);text-wrap:pretty">
        Grain does not say which. Distinguishing an address that was never
        claimed from one that was deleted would tell you a record used to be
        there, and somebody deleted theirs precisely so that it would not.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-secondary press">Open my record</button>
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
