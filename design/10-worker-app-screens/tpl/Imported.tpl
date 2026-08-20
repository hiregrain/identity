<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .plate{position:absolute;inset:0;pointer-events:none}
    .reg{position:absolute;width:11px;height:11px;border:0 solid var(--ink);opacity:.55}
    .row{display:flex;gap:12px;align-items:flex-start;padding:12px 0;
         border-bottom:1px solid var(--hairline);width:100%}
    .gutter{flex:0 0 26px;padding-top:3px}
    .proud{transform:translateY(-2px)}
    main::-webkit-scrollbar{width:0}
  </style>
</helmet>

<!-- Fluid in both axes: the record fills whatever safe area it is given, and
     min-height carries the standalone case where height:100% has no sized
     ancestor and would collapse to zero. 728 is the common safe box across
     iOS (778) and Android (728). Decision 046. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">

  <header style="height:52px;display:flex;align-items:center;gap:10px;padding:0 20px;
                 border-bottom:1px solid var(--hairline);position:relative;z-index:2;background:var(--paper)">
    <!-- The lockup: mark plus the GRAIN wordmark (§4a), generated so the mark
         swaps to its drawn reduction rather than scaling a master. -->
    <svg viewBox="0 0 160 26" width="160" height="26" role="img" aria-label="Grain">@@LOCKUP@@</svg>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:196px;left:0;right:0;overflow-y:auto;padding:0 20px 24px">
    <section style="padding-top:20px">
      <svg class="imprint" viewBox="0 0 600 600" role="img"
           aria-label="Five chapters, none confirmed">@@IMPORTED@@</svg>
      <div style="display:flex;justify-content:space-between;align-items:baseline;padding:12px 0 0">
        <span class="t-micro" style="color:var(--secondary)">Liezel Mendoza</span>
        <span class="t-micro">5 chapters · none attested yet</span>
      </div>
    </section>

    <section style="padding-top:32px">
      <!-- The reading is how much of this nobody has confirmed, set in §6's
           instrument register, defined across ten screens and used by none. -->
      <div class="reading" style="padding-bottom:20px">
        <span class="t-inst">5</span>
        <span style="flex:1;min-width:0">
          <span class="t-rec" style="display:block;text-wrap:pretty">chapters, none of them confirmed</span>
          <span class="t-data" style="display:block;color:var(--secondary);padding-top:3px;text-wrap:pretty">
            Yours so far. Ask a party who was there to attest one.</span>
        </span>
      </div>

      <div style="display:flex;justify-content:space-between;align-items:baseline;
                  border-bottom:1px solid var(--ink);padding-bottom:8px">
        <h2 class="t-sec" style="margin:0">Outstanding verification</h2>
        <span class="t-data" style="color:var(--secondary)">5</span>
      </div>
      <div class="sinerule">@@SINERULE@@</div>
      <sc-for list="{{ rows }}" as="r" hint-placeholder-count="5">
        <button class="row proud press">
          <span class="gutter">
            <svg viewBox="0 0 34 16" width="34" height="16" fill="none" aria-hidden="true"
                 stroke="var(--ink)" stroke-width="1"><use href="#sw-self"></use></svg>
          </span>
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ r.party }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px">{{ r.kind }}</span>
          </span>
          <span class="t-micro" style="text-align:right;white-space:nowrap;padding-top:2px">{{ r.span }}</span>
        </button>
      </sc-for>
    </section>
  </main>

  <!-- résumé-parsed chapters need the worker's confirmation before commit (schema §2) -->
  <div style="position:absolute;left:0;right:0;bottom:0;padding:16px 20px;background:var(--paper);
              border-top:1px solid var(--ink);z-index:2">
    <!-- Not "commit". The word read as the irreversible step, and the
         irreversible step is asking a party to attest, which happens later and
         says so there (058). Adding your own account of where you worked is
         reversible until someone signs it. -->
    <p class="t-body" style="margin:0 0 12px;text-wrap:pretty">
      Read from your résumé. Yours to correct until a party attests one.</p>
    <button class="btn-primary press">Add these 5 chapters</button>
  </div>

</div>

@@SWATCHES@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { rows: [
      {party:'Bataan Poultry Processing', kind:'Employment · processing operator', span:'Sep 2017 – Mar 2019'},
      {party:'Sunrise Foods Manufacturing', kind:'Employment · line lead', span:'Mar 2019 – Sep 2021'},
      {party:'R. Santos Dry Goods', kind:'Engagement · stall assistant', span:'Sep 2020 – Mar 2023'},
      {party:'Metro Manila Logistics', kind:'Employment · warehouse coordinator', span:'Mar 2023 – Jan 2025'},
      {party:'Cebu Pacific Cargo Services', kind:'Employment · cargo handling supervisor', span:'Jan 2025 – present'}
    ]};
  }
}
</script>
</body>
</html>
