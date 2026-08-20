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

<!-- H7, and 038 is precise: this FILES the request, it never executes it.
     Numbers paraphrase copy/deletion.md, which is canonical and which
     checks/deletion-copy.mjs holds against db/deletion-policy.json. No
     surface states its own numbers. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your account">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Delete everything</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <h2 class="t-title" style="margin:0 0 14px;font-size:25px;line-height:1.2;text-wrap:pretty">
        This ends your record</h2>
      <p class="t-body" style="margin:0 0 22px;color:var(--secondary);text-wrap:pretty">
        You do not have to give a reason, and nobody will ask you for one.</p>

      <sc-for list="{{ steps }}" as="s" hint-placeholder-count="4">
        <div style="padding:15px 0;border-bottom:1px solid var(--hairline)">
          <span class="t-rec" style="display:block;text-wrap:pretty">{{ s.head }}</span>
          <span class="t-body" style="display:block;color:var(--secondary);padding-top:5px;text-wrap:pretty">{{ s.body }}</span>
        </div>
      </sc-for>

      <div style="margin-top:22px" class="warn">
        <p class="t-rec" style="margin:0;color:var(--paper);text-wrap:pretty">
          What deletion cannot do</p>
        <p class="t-data" style="margin:8px 0 0;text-wrap:pretty">
          A record someone already received while you permitted it is in their
          hands, under the terms they accepted. Deleting stops every future read.
          It cannot recall a past one.</p>
      </div>
    </div>
  </main>
  <div class="actions">
    <button class="btn-secondary press">File the request</button>
    <div style="padding-top:12px;text-align:center">
      <button class="btn-tertiary press">Keep my record</button>
    </div>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { steps: [
      {head:'The moment you file it',
       body:'Access stops. Every grant you have made is revoked and your page goes dark, so nothing about you can be read from Grain by anyone.'},
      {head:'For 72 hours',
       body:'You can cancel, in the app or through support. The window exists so nobody can be made to destroy their record on the spot.'},
      {head:'After that',
       body:'The key that makes your record readable is destroyed. It is not held anywhere else, including by us.'},
      {head:'Within 30 days',
       body:'What is left is physically removed, and every backup that predates your deletion expires. A backup cannot bring you back.'}
    ]};
  }
}
</script>
</body>
</html>
