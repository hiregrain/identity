<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    main::-webkit-scrollbar{width:0}
  </style>
</helmet>

<!-- Public's own chassis: --page ground, not --paper. design/07 §7 calls this the
     one place the system proves it can vary by meaning, and it must not be
     mistakable for the worker's own record. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--page)">

  <main class="dissolve" style="position:absolute;inset:0;overflow-y:auto;padding:0 20px 40px">
    <div style="background:var(--paper);margin:20px -4px 0;padding:24px 20px 20px;
                border:1px solid var(--hairline)">

      <h1 class="t-title" style="margin:0">Liezel Mendoza</h1>
      <p class="t-data" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">
        Identity document checked, which says nothing about the work below</p>

      <!-- The imprint, to a human visitor and never to the crawler (056). 035
           gated it for two reasons and only one survives: it no longer carries a
           graded claim about the work (054), but an indexed figure is still
           permanent, and a visitor who follows a link loses nothing by the
           crawler payload omitting it. The real page renders this server-side
           for people and drops it from the crawler variant that 037's web layer
           exists to serve. -->
      <svg class="imprint" viewBox="0 0 600 600" style="margin:20px auto 4px" role="img"
           aria-label="Liezel Mendoza's imprint: five chapters, two attested by the business, one by a coworker">@@WORKING@@</svg>

      <div style="padding-top:20px">
        <div class="sechead"><h2 class="t-sec" style="margin:0">Work history</h2>
          <span class="t-data" style="color:var(--secondary)">{{ count }}</span></div>
        <div class="sinerule">@@SINERULE@@</div>
        <sc-for list="{{ chapters }}" as="c" hint-placeholder-count="5">
          <div class="prow">
            <span class="prov" tabindex="0">
              <svg viewBox="0 0 34 16" width="34" height="16" fill="none" aria-hidden="true"
                   stroke="var(--ink)" stroke-width="1"><use href="{{ c.sw }}"></use></svg>
              <span class="tip t-meta">{{ c.prov }}</span>
            </span>
            <span style="flex:1;min-width:0">
              <span class="t-rec" style="display:block">{{ c.party }}</span>
              <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px">{{ c.kind }}</span>
            </span>
            <span class="col-r">
              <span class="t-data" style="display:block">{{ c.from }}</span>
              <span class="t-data" style="display:block;color:var(--secondary)">{{ c.to }}</span>
            </span>
          </div>
        </sc-for>
      </div>

      <p class="t-meta" style="margin:16px 0 0;color:var(--secondary);text-wrap:pretty">
        This page shows who she worked for, when, and which party attested each
        chapter. Grain never checks whether the work was done well. A record holds
        the chapters its subject entered, and Grain does not know of any she did
        not.</p>

      <div style="margin-top:20px;border-top:1px solid var(--ink);padding-top:16px">
        <button class="btn-secondary press" style="width:100%">Sign in to see the full record</button>
      </div>
    </div>

    <p class="t-micro" style="margin:16px 4px 0;color:var(--secondary);text-wrap:pretty">
      hiregrain.com/u/liezel-mendoza · a Grain record</p>
  </main>
</div>
@@SWATCHES@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Gap 13, half two, and the first of Public's two NOT DRAWN surfaces: what a
// logged-out visitor or a crawler receives. Decision 037 gives this its own web
// layer because a client-painted render ranks badly and cannot serve a distinct
// crawler payload.
//
// What is deliberately absent: the imprint (035, always behind sign-in, since an
// indexable figure cannot be recalled), and anything a party wrote.
class Component extends DCLogic {
  renderVals(){
    // Oldest first, matching every other surface and the figure above, whose
    // innermost band is the earliest chapter. This page ran newest first.
    const chapters = [
      {party:'Bataan Poultry Processing', kind:'Processing operator', sw:'#sw-self',
       prov:'Recorded by Liezel Mendoza. No attesting party.',
       from:'Sep 2017', to:'Mar 2019'},
      {party:'Sunrise Foods Manufacturing', kind:'Two positions', sw:'#sw-multi',
       prov:'Attested by Sunrise Foods Manufacturing, and a second party agrees.',
       from:'Mar 2019', to:'Sep 2021'},
      {party:'R. Santos Dry Goods', kind:'Stall assistant, Divisoria', sw:'#sw-peer',
       prov:'Attested by a coworker the worker named. The business is not registered with Grain.',
       from:'Sep 2020', to:'Mar 2023'},
      {party:'Metro Manila Logistics', kind:'Warehouse coordinator', sw:'#sw-single',
       prov:'Attested by Metro Manila Logistics. No second party has agreed.',
       from:'Mar 2023', to:'Jan 2025'},
      {party:'Cebu Pacific Cargo Services', kind:'Cargo handling supervisor', sw:'#sw-emp',
       prov:'Cebu Pacific Cargo Services attested the dates and the employment. Nothing about the work.',
       from:'Jan 2025', to:'present'}
    ];
    return {chapters, count: chapters.length};
  }
}
</script>
</body>
</html>
