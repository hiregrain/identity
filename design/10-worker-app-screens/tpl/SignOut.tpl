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

<!-- H8. Signing out is not deleting, and on a shared or borrowed phone the
     difference is the whole question. This screen exists to make it
     impossible to confuse the two. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your account">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Sign out</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">
        Your record stays exactly as it is. Signing out only takes it off this
        phone.</p>
      <sc-for list="{{ rows }}" as="r" hint-placeholder-count="4">
        <div class="srow">
          <span class="t-body" style="flex:1;min-width:0;text-wrap:pretty">{{ r.label }}</span>
          <span class="t-data col-r" style="color:{{ r.color }}">{{ r.v }}</span>
        </div>
      </sc-for>
      <p class="t-meta" style="margin:16px 0 0;color:var(--secondary);text-wrap:pretty">
        Getting back in needs a code sent to your number, the same as the first
        time. Signing out is not deleting, and nothing here is a way to delete.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-secondary press">Sign out on this phone</button>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { rows: [
      {label:'Your record', v:'Untouched', color:'var(--ink)'},
      {label:'Grants you have made', v:'Still running', color:'var(--ink)'},
      {label:'Your public page', v:'Unchanged', color:'var(--ink)'},
      {label:'This phone', v:'Forgets you', color:'var(--secondary)'}
    ]};
  }
}
</script>
</body>
</html>
