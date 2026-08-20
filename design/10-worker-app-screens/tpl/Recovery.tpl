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

<!-- The hole the inventory did not have a row for. The identity anchor is a
     mobile number, and in this population a recycled or lost prepaid SIM is the
     median five-year story rather than an edge case. Every account change routes
     through a person (036), which is right for anti-takeover and useless if the
     person cannot prove who they are. This is the path back. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to the start">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Get back in</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <h2 class="t-head" style="margin:0 0 12px;text-wrap:pretty">Lost the number your record is under?</h2>
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">
        Your record is not gone and nobody else can reach it. Getting back in is
        slower than a code, on purpose: a number that changed hands must not
        become a way into somebody else's record.</p>

      <div class="sechead"><h3 class="t-sec" style="margin:0">What gets you back</h3></div>
      <sc-for list="{{ paths }}" as="p" hint-placeholder-count="3">
        <div style="padding:16px 0;border-bottom:1px solid var(--hairline)">
          <span class="t-rec" style="display:block;text-wrap:pretty">{{ p.head }}</span>
          <span class="t-body" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">{{ p.body }}</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px">{{ p.how }}</span>
        </div>
      </sc-for>

      <div class="grp">
        <div class="warn">
          <p class="t-rec" style="margin:0;color:var(--paper);text-wrap:pretty">
            While this is open, your record is sealed</p>
          <p class="t-data" style="margin:8px 0 0;text-wrap:pretty">
            Every grant is paused and your page goes dark from the moment you
            file, so nobody reads your record while we work out that it is yours.
            Nothing is deleted, and nothing you did is lost.</p>
        </div>
      </div>

      <p class="t-meta" style="margin:16px 0 0;color:var(--secondary);text-wrap:pretty">
        A person reads this, not a rule. It usually takes two working days, and
        we will tell you what is still missing rather than only that it failed.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Start getting back in</button>
    <div style="padding-top:12px;text-align:center">
      <button class="btn-tertiary press">I still have the number</button>
    </div>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { paths: [
      {head:'The identity document you already had checked',
       body:'The strongest one. If the document Grain checked is still yours, this is usually the whole answer.',
       how:'A new photograph, checked the same way as the first.'},
      {head:'A party that has attested your record',
       body:'A business that signed one of your chapters can confirm it is you asking. They confirm a person, never a new claim about the work.',
       how:'We contact them at the domain we checked. They answer yes or nothing.'},
      {head:'The device you last used',
       body:'A phone that has opened your record before can vouch for itself, even without the number.',
       how:'Open Grain on that phone and approve it there.'}
    ]};
  }
}
</script>
</body>
</html>
