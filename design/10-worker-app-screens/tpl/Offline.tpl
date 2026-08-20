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

<!-- I1. §12 is specific: offline is a micro-caption band, not a takeover.
     The record is readable from cache, so taking the screen away to announce
     a network state would remove the one thing that still works. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your record">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Your record</h1>
  </header>
  <div style="background:var(--ink);color:var(--paper);padding:7px 20px">
    <span class="t-micro" style="color:var(--paper)">Offline. Showing your record as it was on 12 Aug</span>
  </div>
  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:22px">
      <p class="t-body" style="margin:0 0 22px;color:var(--secondary);text-wrap:pretty">
        Everything already on your record is here and readable. What needs the
        network is anything that changes it or sends it.</p>
      <sc-for list="{{ rows }}" as="r" hint-placeholder-count="5">
        <div class="srow">
          <span class="t-body" style="flex:1;min-width:0;color:{{ r.color }};text-wrap:pretty">{{ r.label }}</span>
          <span class="t-data col-r" style="color:{{ r.color }}">{{ r.v }}</span>
        </div>
      </sc-for>
      <p class="t-meta" style="margin:16px 0 0;color:var(--secondary);text-wrap:pretty">
        Anything you write while offline waits on this phone and is sent when
        you are back. Nothing is lost, and nothing is sent twice.</p>
    </div>
  </main>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    const y = (label) => ({label, v:'Works', color:'var(--ink)'});
    const n = (label) => ({label, v:'Needs a connection', color:'var(--secondary)'});
    return { rows: [ y('Reading your record'), y('Opening your imprint'),
                     y('Adding a chapter, saved here'), n('Asking a party to attest'),
                     n('Sending your record to someone') ] };
  }
}
</script>
</body>
</html>
