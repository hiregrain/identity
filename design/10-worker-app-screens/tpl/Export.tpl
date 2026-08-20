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

<!-- H4. 036: by email, within 24 hours. The file is the record plus the
     signatures, because an export without them is a copy rather than
     evidence, and the whole claim is that it can be checked without Grain. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your account">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Send me everything</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <h2 class="t-sec" style="margin:0 0 8px;font-size:19px;line-height:1.3">Everything Grain holds about you</h2>
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">
        Sent by email within 24 hours, as one file.</p>
      <sc-for list="{{ rows }}" as="r" hint-placeholder-count="4">
        <div class="srow">
          <span style="flex:1;min-width:0">
            <span class="t-body" style="display:block;text-wrap:pretty">{{ r.label }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">{{ r.note }}</span>
          </span>
        </div>
      </sc-for>
      <p class="t-meta" style="margin:16px 0 0;color:var(--secondary);text-wrap:pretty">
        The signatures come with it, so anyone can check the record is what Grain
        says it is without asking Grain. That is the point of it being yours.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Send it to me</button>
    <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-align:center;text-wrap:pretty">
      To the email on your account. Add one first if it says Not added.</p>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { rows: [
      {label:'Every chapter, and every position inside it', note:'Including anything corrected, with what it was before.'},
      {label:'Every attestation, with its signature', note:'Who signed, when, and the cryptographic proof of it.'},
      {label:'Every entry ever written to your record', note:'The same list the ledger screen shows, in order.'},
      {label:'Your account facts', note:'Name, identifier, address, and what the identity check returned.'}
    ]};
  }
}
</script>
</body>
</html>
