<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .prow{display:flex;gap:12px;align-items:flex-start;padding:14px 0;
          border-bottom:1px solid var(--hairline)}
    main::-webkit-scrollbar{width:0}
  </style>
</helmet>

<!-- The employer's side, on the --page ground Public uses: whoever is reading
     this is not the subject, and the chassis says so before the copy does. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--page)">
  <header style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 20px;border-bottom:1px solid var(--ink);background:var(--page)">
    <span style="display:flex;align-items:center;gap:10px">
      <svg viewBox="0 0 160 26" width="122" height="20" role="img" aria-label="Grain">@@LOCKUP@@</svg>
    </span>
    <span class="t-micro" style="color:var(--secondary)">Granted access</span>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 40px">

    <!-- The reading an employer needs first is not a score. It is how long they
         have, and who is accountable for what they are about to read. -->
    <div class="reading" style="padding:24px 0 18px;                border-bottom:1px solid var(--ink)">
      <span class="t-inst">{{ daysLeft }}</span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block;text-wrap:pretty">days left on this grant</span>
        <span class="t-data" style="display:block;color:var(--secondary);padding-top:3px">
          Liezel Mendoza granted it on {{ granted }}. She can end it at any time.</span>
      </span>
    </div>

    <div style="padding-top:24px">
      <h1 class="t-title" style="margin:0">Liezel Mendoza</h1>
      <p class="t-data" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">
        Identity document checked, which says nothing about the work below</p>
    </div>

    <!-- What Grain is and is not saying, before any content. This is the sentence
         the whole product exists to be able to write. -->
    <div style="margin-top:18px;border-block:1px solid var(--ink);padding:14px 0">
      <p class="t-body" style="margin:0;text-wrap:pretty">
        Grain checks that a business really signed a record. It never checks
        whether the work was done well. What each party asserted is below, at
        their own reading, and the decision is yours.</p>
    </div>

    <div style="padding-top:26px">
      <div class="sechead"><h2 class="t-sec" style="margin:0">Work history</h2>
        <span class="t-data" style="color:var(--secondary)">{{ count }}</span></div>
      <div class="sinerule">@@SINERULE@@</div>
      <sc-for list="{{ chapters }}" as="c" hint-placeholder-count="5">
        <div class="prow">
          <!-- The mark carries provenance; the sentence it stands for is the
               tip's text content, which is also what a screen reader reads and
               what a crawler indexes (055). The line that stays visible is the
               attesting party's own standing and signing date, which is a fact
               about them rather than a note about her. -->
          <span class="prov" tabindex="0">
            <svg viewBox="0 0 34 16" width="34" height="16" fill="none" aria-hidden="true"
                 stroke="var(--ink)" stroke-width="1"><use href="{{ c.sw }}"></use></svg>
            <span class="tip t-meta">{{ c.prov }}</span>
          </span>
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ c.party }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">{{ c.registry }}</span>
          </span>
          <span class="col-r">
            <span class="t-data" style="display:block">{{ c.from }}</span>
            <span class="t-data" style="display:block;color:var(--secondary)">{{ c.to }}</span>
          </span>
        </div>
      </sc-for>
    </div>

    <div style="margin-top:24px;border-top:1px solid var(--ink);padding-top:14px">
      <p class="t-meta" style="margin:0;color:var(--secondary);text-wrap:pretty">
        Two of these chapters were attested by one party only, and stand at that
        party's reading alone. One has no attesting party. This record holds the
        chapters Liezel entered, and Grain does not know of any she did not.</p>
    </div>
  </main>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Gap 8: the employer's disclosure-grant view. What a business sees when a worker
// grants them the whole record.
//
// Two constraints this screen exists to obey. It never renders a composite, a
// score or a badge, CLAUDE.md's constraint that outranks convenience. Grain says
// what is known and how well, the partner decides what it means and bears the
// decision. And it states its own limits before its content, not after.
class Component extends DCLogic {
  renderVals(){
    // Oldest first, everywhere. It ran newest first here and oldest first on the
    // worker's own record, same label and same chapters in opposite order, which
    // meant a worker and a reader walking the record together were on different
    // rows. Oldest first is the direction the figure reads: the innermost band
    // is the earliest chapter.
    const chapters = [
      {party:'Bataan Poultry Processing',
       prov:'Recorded by Liezel Mendoza. No attesting party.',
       registry:'No attesting party', sw:'#sw-self_asserted',
       from:'Sep 2017', to:'Mar 2019'},
      {party:'Sunrise Foods Manufacturing',
       prov:'Attested by Sunrise Foods Manufacturing, and a second party agrees.',
       registry:'Registered business · signed 14 Oct 2021', sw:'#sw-party_multi',
       from:'Mar 2019', to:'Sep 2021'},
      {party:'R. Santos Dry Goods',
       prov:'Attested by a coworker who was there. The business is not registered with Grain.',
       registry:'Individual · signed 2 Apr 2023', sw:'#sw-peer_attested',
       from:'Sep 2020', to:'Mar 2023'},
      {party:'Metro Manila Logistics',
       prov:'Attested by Metro Manila Logistics. No second party has agreed.',
       registry:'Registered business · signed 20 Jan 2025', sw:'#sw-party_single',
       from:'Mar 2023', to:'Jan 2025'},
      {party:'Cebu Pacific Cargo Services',
       prov:'Cebu Pacific Cargo Services attested the dates and the employment. Nothing about the work.',
       registry:'Registered business · signed 20 Jan 2026', sw:'#sw-employment_verified',
       from:'Jan 2025', to:'present'}
    ];
    return {
      daysLeft: 13, granted: '4 Aug 2026',
      count: chapters.length, chapters
    };
  }
}
</script>
</body>
</html>
