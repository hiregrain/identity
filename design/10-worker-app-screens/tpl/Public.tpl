<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    /* A page, not the app: page ground behind a cut sheet, no plate, no
       registration corners, no edge index. It is what a person sends someone. */
    .sheetpage{background:var(--paper);border:1px solid var(--rule)}
    .prow{display:flex;gap:12px;align-items:flex-start;padding:13px 0;
          border-bottom:1px solid var(--hairline)}
    main::-webkit-scrollbar{width:0}
  </style>
</helmet>

<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--page)">
  <main class="dissolve" style="position:absolute;inset:0;overflow-y:auto;padding:16px 12px">
    <div class="sheetpage" style="padding:28px 22px 22px">

      <h1 class="t-title" style="margin:0;font-size:28px">Liezel Mendoza</h1>
      <p class="t-data" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">
        Identity document checked, which says nothing about the work below</p>

      <svg class="imprint" viewBox="0 0 600 600" style="margin:18px auto 0" role="img"
           aria-label="Liezel Mendoza's imprint: five chapters, two signed by an employer, one by a coworker">@@WORKING@@</svg>

      <div style="border-top:1px solid var(--ink);padding-top:10px;margin-top:4px">
        <p class="t-data" style="margin:0;text-wrap:pretty">
          Five chapters, 2017 to now. Two attested by the business, one by a
          coworker, one dates only, one with no attesting party.</p>
        <!-- 059: a reader could not tell a chapter that was refused from one
             that was never asked from one that was never entered, and that is
             the difference they would most want. The record says what it is. -->
        <p class="t-meta" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">
          A record holds the chapters its subject entered. Grain does not know of
          any Liezel did not.</p>
      </div>

      <div style="padding-top:22px">
        <sc-for list="{{ chapters }}" as="c" hint-placeholder-count="5">
          <div class="prow">
            <span class="prov" tabindex="0">
              <svg viewBox="0 0 34 16" width="34" height="16" fill="none" aria-hidden="true"
                   stroke="var(--ink)" stroke-width="1"><use href="{{ c.sw }}"></use></svg>
              <span class="tip t-meta">{{ c.prov }}</span>
            </span>
            <span style="flex:1;min-width:0">
              <span class="t-rec" style="display:block">{{ c.party }}</span>
              <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">{{ c.kind }}</span>
            </span>
            <span class="col-r">
              <span class="t-data" style="display:block">{{ c.from }}</span>
              <span class="t-data" style="display:block;color:var(--secondary)">{{ c.to }}</span>
            </span>
          </div>
        </sc-for>
      </div>

      <p class="t-body" style="margin:18px 0 0;color:var(--secondary);text-wrap:pretty">
        This page shows who Liezel worked for, when, and which party attested
        each chapter. Grain checks that a party really signed a record. It never
        checks whether the work was done well.</p>

      <div style="padding-top:20px">
        <button class="btn-secondary press">Ask Liezel to send you her record</button>
        <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
          She sends it to you by name, it ends on a date she sets, and she can end
          it sooner. It cannot be sent in part.</p>
      </div>

      <div style="display:flex;align-items:center;gap:8px;border-top:1px solid var(--hairline);
                  margin-top:22px;padding-top:12px">
        <svg viewBox="0 0 600 600" width="20" height="20" role="img" aria-label="Grain">@@MARK_SOLID@@</svg>
        <span class="t-data" style="color:var(--secondary);flex:1;font-size:11px">
          Grain · hiregrain.com/u/liezel-mendoza · updated 14 Aug 2026</span>
      </div>
    </div>
    <p class="t-meta" style="text-align:center;color:var(--secondary);margin:14px 0 0;text-wrap:pretty">
      Every chapter names the party that attested it, or names none.</p>
  </main>
</div>

<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>
  <g id="sw-self">@@SW_SELF@@</g>
  <g id="sw-emp">@@SW_EMP@@</g>
  <g id="sw-peer">@@SW_PEER@@</g>
  <g id="sw-single">@@SW_SINGLE@@</g>
  <g id="sw-multi">@@SW_MULTI@@</g>
</defs></svg>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// The public page, signed-in view. Whole record or no record, no per-chapter
// curation anywhere (035). Registry state is carried on every party (06 §9), and
// a worker-typed title is never printed as if a business confirmed it.
class Component extends DCLogic {
  renderVals(){
    return { chapters: [
      {party:'Bataan Poultry Processing', kind:'Processing operator',
       prov:'Recorded by Liezel Mendoza. No attesting party.',
       from:'Sep 2017', to:'Mar 2019', sw:'#sw-self'},
      {party:'Sunrise Foods Manufacturing', kind:'Two positions',
       prov:'Attested by Sunrise Foods Manufacturing, and a second party agrees.',
       from:'Mar 2019', to:'Sep 2021', sw:'#sw-multi'},
      {party:'R. Santos Dry Goods', kind:'Stall assistant, Divisoria',
       prov:'Attested by a coworker who was there. The business is not registered with Grain.',
       from:'Sep 2020', to:'Mar 2023', sw:'#sw-peer'},
      {party:'Metro Manila Logistics', kind:'Warehouse coordinator',
       prov:'Attested by Metro Manila Logistics. No second party has agreed.',
       from:'Mar 2023', to:'Jan 2025', sw:'#sw-single'},
      {party:'Cebu Pacific Cargo Services', kind:'Cargo handling supervisor',
       prov:'Cebu Pacific Cargo Services attested the dates and the employment. Nothing about the work.',
       from:'Jan 2025', to:'Present', sw:'#sw-emp'}
    ]};
  }
}
</script>
</body>
</html>
