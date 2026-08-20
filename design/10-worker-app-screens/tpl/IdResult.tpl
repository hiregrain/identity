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

<!-- F5. The result, and what a partner now sees, verbatim. 055's rule:
     the worker never sees a weaker qualification than the reader does, so
     this screen quotes the reader's sentence rather than paraphrasing it. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your record">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Identity checked</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:26px 0 18px;border-bottom:1px solid var(--ink)">
      <div class="said">
        <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><use href="#i-tick"></use></svg>
        <span style="flex:1;min-width:0">
          <span class="t-rec" style="display:block">A document was checked</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Today, by Persona</span>
        </span>
      </div>
    </div>

    <div class="grp">
      <span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:8px">
        What a reader sees, word for word</span>
      <div style="border-block:1px solid var(--ink);padding:16px 0">
        <p class="t-body" style="margin:0;text-wrap:pretty">
          Identity document checked, which says nothing about the work below</p>
      </div>
      <p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">
        That is the whole sentence, on every surface. Grain does not print
        "verified" anywhere, because a document check says who you are and
        nothing at all about what you did.</p>
    </div>

    <div class="grp">
      <div class="sechead"><h3 class="t-sec" style="margin:0">What Grain kept</h3></div>
      <div class="sinerule">@@SINERULE@@</div>
      <sc-for list="{{ kept }}" as="k" hint-placeholder-count="3">
        <div class="srow">
          <span class="t-body" style="flex:1;min-width:0;text-wrap:pretty">{{ k.label }}</span>
          <span class="t-data col-r" style="color:{{ k.color }}">{{ k.v }}</span>
        </div>
      </sc-for>
    </div>
  </main>
  <div class="actions">
    <button class="btn-secondary press">Add a liveness check</button>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { kept: [
      {label:'That a document was checked, and the date', v:'Kept', color:'var(--ink)'},
      {label:'The photograph', v:'Not kept', color:'var(--secondary)'},
      {label:'The document number', v:'Not kept', color:'var(--secondary)'}
    ]};
  }
}
</script>
</body>
</html>
