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

<!-- I10. The three documents, and the fourth thing nobody links: the
     decision that a plain-language summary is not the agreement. Both are
     reachable, and the screen says which one binds. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your account">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">About</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <sc-for list="{{ docs }}" as="d" hint-placeholder-count="4">
        <button class="srow press">
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ d.name }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">{{ d.note }}</span>
          </span>
          <span class="chev" aria-hidden="true">
            <svg width="16" height="16" viewBox="0 0 20 20" fill="none" stroke="var(--rule)"
                 stroke-width="1.2" stroke-linecap="round"><path d="M8 4 L14 10 L8 16"/></svg>
          </span>
        </button>
      </sc-for>
      <p class="t-meta" style="margin:16px 0 0;color:var(--secondary);text-wrap:pretty">
        The plain-language version is written to be read. The full text is what
        binds, and where they differ the full text wins. Both are here so nobody
        has to take that on trust.</p>
    </div>
    <div class="grp">
      <span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:8px">This app</span>
      <div class="srow">
        <span class="t-body" style="flex:1;min-width:0">Version</span>
        <span class="t-data col-r" style="color:var(--secondary)">1.0.0</span>
      </div>
    </div>
  </main>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { docs: [
      {name:'How the record works', note:'The plain-language version. What you agreed to, in the words you agreed to it in.'},
      {name:'Terms', note:'The full text. This is the one that binds.'},
      {name:'Privacy', note:'What is held, for how long, and which vendors see what.'},
      {name:'How deletion works', note:'What happens, and when, and what deletion cannot undo.'}
    ]};
  }
}
</script>
</body>
</html>
