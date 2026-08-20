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

<!-- F7. A failure that names a next step. Most failures here are a glare
     on a laminate, not a fraud attempt, and a screen that cannot tell the
     difference should not imply it can. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your record">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Identity</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:24px 0 16px;border-bottom:1px solid var(--ink)">
      <div class="said">
        <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><use href="#i-alert"></use></svg>
        <span style="flex:1;min-width:0">
          <span class="t-rec" style="display:block;text-wrap:pretty">The document could not be read</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">
            Nothing was written to your record, and nothing was kept.</span>
        </span>
      </div>
    </div>

    <div class="grp">
      <div class="sechead"><h3 class="t-sec" style="margin:0">What usually fixes it</h3></div>
      <sc-for list="{{ fixes }}" as="f" hint-placeholder-count="4">
        <div class="srow">
          <span class="t-body" style="flex:1;min-width:0;text-wrap:pretty">{{ f }}</span>
        </div>
      </sc-for>
    </div>

    <div class="grp">
      <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">
        This is almost always the photograph rather than the document. If it
        fails again, support can check it by hand, and a person will read it.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Try the photo again</button>
    <div style="padding-top:12px;text-align:center">
      <button class="btn-tertiary press">Ask support to check it</button>
    </div>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { fixes: [
      'Lay it flat, on something dark, and fill the frame.',
      'Turn the flash off. Glare on a laminate reads as tampering.',
      'Daylight if you can, or a bright room. Not a phone torch.',
      'Every corner inside the frame, including the bottom strip.'
    ]};
  }
}
</script>
</body>
</html>
