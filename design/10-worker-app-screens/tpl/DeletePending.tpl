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

<!-- H7a. The grace-period state. Nothing here resets the clock except an
     explicit cancel: an earlier draft of this said signing in revived the
     record, which is not what copy/deletion.md or 052 describe, and a wrong
     promise about deletion is the worst kind to make. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Deletion requested</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div class="reading" style="padding:26px 0 18px;border-bottom:1px solid var(--ink)">
      <span class="t-inst">{{ hours }}</span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block;text-wrap:pretty">hours left to change your mind</span>
        <span class="t-data" style="display:block;color:var(--secondary);padding-top:3px">
          Filed {{ filed }}</span>
      </span>
    </div>

    <div class="grp">
      <sc-for list="{{ now }}" as="n" hint-placeholder-count="3">
        <div style="display:flex;gap:12px;align-items:flex-start;padding:13px 0;
                    border-bottom:1px solid var(--hairline)">
          <span style="flex:0 0 20px;padding-top:2px">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--ink)"
                 stroke-width="1.5" aria-hidden="true"><use href="#i-tick"></use></svg>
          </span>
          <span class="t-body" style="flex:1;min-width:0;text-wrap:pretty">{{ n }}</span>
        </div>
      </sc-for>
    </div>

    <div class="grp">
      <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">
        Only cancelling stops it. Opening the app does not, and neither does
        signing in: the record is already unreadable and the clock is running on
        the shred.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Cancel the deletion</button>
    <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-align:center;text-wrap:pretty">
      Support can cancel it for you too.</p>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return {
      hours: 61, filed: 'today, 09:14',
      now: [
        'Every grant has been revoked. Nobody can open your record.',
        'Your public page is dark, and the address no longer resolves.',
        'Nothing further is written to your record.'
      ]
    };
  }
}
</script>
</body>
</html>
