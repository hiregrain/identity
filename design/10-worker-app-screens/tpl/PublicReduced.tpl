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

<!-- Public's own chassis: --page ground, not --paper. design/07 §7 calls this the
     one place the system proves it can vary by meaning, and it must not be
     mistakable for the worker's own record. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--page)">

  <main class="dissolve" style="position:absolute;inset:0;overflow-y:auto;padding:0 20px 40px">
    <div style="background:var(--paper);margin:20px -4px 0;padding:24px 20px 20px;
                border:1px solid var(--hairline)">

      <h1 class="t-title" style="margin:0">Liezel Mendoza</h1>
      <p class="t-data" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">
        Philippines · Identity document checked, which says nothing about the work below</p>

      <!-- No imprint. Decision 035: the figure is always behind sign-in, even when
           the page is published, because an indexable imprint is the one thing
           that cannot be taken back. The graticule stands where it would be,
           §9's ground, doing the job it was defined for. -->
      <div style="position:relative;height:132px;margin:22px 0 4px;overflow:hidden;
                  border-block:1px solid var(--hairline)">
        <!-- Half-scale so the mesh reads as ground rather than as a table: the
             graticule is drawn on a 296 grid, and stretched across a wide short
             box its cells become furniture. -->
        <svg viewBox="0 0 592 264" preserveAspectRatio="xMidYMid slice" fill="none"
             stroke="var(--rule)" stroke-width="0.7" style="position:absolute;inset:0;
             width:100%;height:100%;opacity:.22">@@GRATICULE_LG@@</svg>
        <div style="position:absolute;inset:0;display:flex;flex-direction:column;
                    align-items:center;justify-content:center;gap:6px;padding:0 24px">
          <span class="t-rec" style="text-align:center;text-wrap:pretty">Her imprint is not on this page</span>
          <span class="t-meta" style="color:var(--secondary);text-align:center;text-wrap:pretty">
            Sign in with a Grain account to see it.</span>
        </div>
      </div>

      <div style="padding-top:20px">
        <div class="sechead"><h2 class="t-sec" style="margin:0">Work history</h2>
          <span class="t-data" style="color:var(--secondary)">{{ count }}</span></div>
        <div class="sinerule">@@SINERULE@@</div>
        <sc-for list="{{ chapters }}" as="c" hint-placeholder-count="5">
          <div class="prow">
            <span style="flex:1;min-width:0">
              <span class="t-rec" style="display:block">{{ c.party }}</span>
              <span class="t-data" style="display:block;padding-top:3px">{{ c.state }}</span>
            </span>
            <span class="col-r">
              <span class="t-data" style="display:block">{{ c.from }}</span>
              <span class="t-data" style="display:block;color:var(--secondary)">{{ c.to }}</span>
            </span>
          </div>
        </sc-for>
      </div>

      <p class="t-meta" style="margin:18px 0 0;color:var(--secondary);text-wrap:pretty">
        This page shows who she worked for and who confirmed it. It does not show
        what any business wrote about her work, and Grain never checks whether the
        work was done well.</p>

      <div style="margin-top:20px;border-top:1px solid var(--ink);padding-top:16px">
        <button class="btn-secondary press" style="width:100%">Sign in to see the full record</button>
      </div>
    </div>

    <p class="t-micro" style="margin:16px 4px 0;color:var(--secondary);text-wrap:pretty">
      hiregrain.com/u/liezel-mendoza · a Grain record</p>
  </main>
</div>
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
    const chapters = [
      {party:'Cebu Pacific Cargo Services', state:'Employment confirmed by the business',
       from:'Jan 2025', to:'present'},
      {party:'Metro Manila Logistics', state:'Signed by the business',
       from:'Mar 2023', to:'Jan 2025'},
      {party:'R. Santos Dry Goods', state:'Signed by a coworker, not the business',
       from:'Sep 2020', to:'Mar 2023'},
      {party:'Sunrise Foods Manufacturing', state:'Signed by the business, and a second party agreed',
       from:'Mar 2019', to:'Sep 2021'},
      {party:'Bataan Poultry Processing', state:'Liezel added this. Nobody has confirmed it.',
       from:'Sep 2017', to:'Mar 2019'}
    ];
    return {chapters, count: chapters.length};
  }
}
</script>
</body>
</html>
