<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .terms{list-style:none;margin:0;padding:0}
    .terms li{padding:16px 0;border-bottom:1px solid var(--hairline)}
  </style>
</helmet>

<!-- Fluid in both axes: the record fills whatever safe area it is given, and
     min-height carries the standalone case where height:100% has no sized
     ancestor and would collapse to zero. 728 is the common safe box across
     iOS (778) and Android (728). Decision 046. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header style="height:52px;display:flex;align-items:center;gap:10px;padding:0 20px;
                 border-bottom:1px solid var(--hairline)">
    <!-- The lockup: mark plus the GRAIN wordmark (§4a), generated so the mark
         swaps to its drawn reduction rather than scaling a master. -->
    <svg viewBox="0 0 160 26" width="160" height="26" role="img" aria-label="Grain">@@LOCKUP@@</svg>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:120px;left:0;right:0;overflow-y:auto;padding:24px 20px">
    <h1 class="t-title" style="margin:0 0 8px">How this record works</h1>
    <p class="t-body" style="margin:0 0 8px;color:var(--secondary);text-wrap:pretty">
      Seven things, all of them true before you add anything. A <b>chapter</b> is one job
      or engagement with one business.</p>

    <ol class="terms">
      <sc-for list="{{ terms }}" as="t" hint-placeholder-count="7">
        <li>
          <span class="t-rec" style="display:block">{{ t.head }}</span>
          <span class="t-body" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">{{ t.body }}</span>
        </li>
      </sc-for>
    </ol>

    <div style="padding-top:12px">
      <button class="btn-tertiary press" style="padding-left:0">Read the full text</button>
    </div>
  </main>

  <div style="position:absolute;left:0;right:0;bottom:0;padding:16px 20px;background:var(--paper);
              border-top:1px solid var(--ink)">
    <button class="btn-primary press">Agree and continue</button>
  </div>

</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// One instrument, the mechanics of ledger-design 0.1 §8.2, in the ledger grammar.
// Row 5 is the exit, at the same weight as the rest. Row 7 added per design/07
// §5: parties place you on seven set measures and nothing here said so.
class Component extends DCLogic {
  renderVals(){
    return { terms: [
      {head:'Businesses write about your work',
       body:'A business you worked for signs a record of what you did. It is permanent, and you cannot edit it.'},
      {head:'Asking for confirmation cannot be undone',
       body:'Once you ask a business to confirm a chapter, that record is permanent for as long as your profile exists.'},
      {head:'You choose who reads, never what they read',
       body:'Anyone you give access to reads your whole record: every chapter, everything each business wrote, and your imprint. There is no way to show them part of it. Every grant has an end date, and they can pay us to analyse what they read.'},
      {head:'Businesses describe your work on seven set measures',
       body:'They pick a description on each one, and Grain turns that into a level. It travels with your record to anyone you share it with, and onto your public page if you turn the imprint on.'},
      {head:'You can attach your side to anything',
       body:'The record stays as the business wrote it. Grain checks that they really signed it, never whether they were fair, and they can decline to change it. There is a deadline.'},
      {head:'You can have all of it deleted, at any time',
       body:'Ask us and everything goes. Single chapters never come out on their own, so deleting all of it is the only way to remove any of it.'},
      {head:'What a reader keeps, they keep',
       body:'A business that has read your record may hold on to what it read. Deleting stops future reads, not past ones.'}
    ]};
  }
}
</script>
</body>
</html>
