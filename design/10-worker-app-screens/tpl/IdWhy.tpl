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

<!-- F1. Why now, what is taken, what is kept, before the camera. The
     sequence matters: a document request that arrives without its reason is
     the shape of every scam a person in this population has been warned
     about. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your record">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Verify your identity</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <h2 class="t-head" style="margin:0 0 14px;line-height:1.2;text-wrap:pretty">
        One check, so a reader knows the record is yours</h2>
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">
        Without it, anyone could put your name on a page. This is the only time
        Grain asks for a document.</p>

      <sc-for list="{{ rows }}" as="r" hint-placeholder-count="4">
        <div class="drow" style="display:flex;gap:14px;align-items:flex-start;padding:14px 0;
                                 border-bottom:1px solid var(--hairline)">
          <span class="t-meta" style="flex:0 0 96px;color:var(--secondary);padding-top:2px">{{ r.k }}</span>
          <span class="t-body" style="flex:1;min-width:0;text-wrap:pretty">{{ r.v }}</span>
        </div>
      </sc-for>

      <p class="t-meta" style="margin:16px 0 0;color:var(--secondary);text-wrap:pretty">
        You can skip this and keep using your record. Some businesses will not
        read a record that has not been checked, and the page says which it is.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Start the check</button>
    <div style="padding-top:12px;text-align:center">
      <button class="btn-tertiary press">Not now</button>
    </div>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { rows: [
      {k:'What we take', v:'A photo of one government document, and nothing else.'},
      {k:'Who reads it', v:'Our verification vendor, named on the next screen, and no one at Grain.'},
      {k:'What is kept', v:'That a document was checked, and when. Never the document, and never its number.'},
      {k:'What a reader sees', v:'"Identity document checked, which says nothing about the work below." That is the whole sentence.'}
    ]};
  }
}
</script>
</body>
</html>
