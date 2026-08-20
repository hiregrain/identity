<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .erow{display:flex;gap:14px;align-items:flex-start;padding:12px 0;
          border-bottom:1px solid var(--hairline)}
    .when{flex:0 0 62px;padding-top:2px}
  </style>
</helmet>

<!-- Decision 059. Settings stated "47 entries, and none removed" and showed
     none of them, which reads as surveillance rather than as the check it was
     put there to be: five jobs, forty-seven entries, all written by somebody
     else. Append-only is only checkable if the append is legible. This is also
     where the consent flags 058 records become visible to the person who gave
     them. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 20px;border-bottom:1px solid var(--ink);position:relative;z-index:3;
                 background:var(--paper)">
    <h1 class="t-serial" style="margin:0">Your record, in order</h1>
    <button class="press" aria-label="Back to your account" style="width:44px;height:44px;display:flex;
            align-items:center;justify-content:flex-end">
      <svg width="18" height="18" viewBox="0 0 18 18" class="icon"><path d="M3 3 L15 15"/><path d="M15 3 L3 15"/></svg>
    </button>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 40px">

    <div style="padding:24px 0 16px;border-bottom:1px solid var(--ink)">
      <p class="t-lead" style="margin:0;line-height:1.35;text-wrap:pretty">
        Every entry ever written to your record, newest last.</p>
      <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
        Nothing is ever removed or rewritten. A correction is a new entry that
        cites the one it corrects, which is why the count only goes up.</p>
    </div>

    <sc-for list="{{ groups }}" as="g" hint-placeholder-count="3">
      <div class="grp">
        <div class="sechead"><h2 class="t-sec" style="margin:0">{{ g.month }}</h2>
          <span class="t-data" style="color:var(--secondary)">{{ g.count }}</span></div>
          <sc-for list="{{ g.rows }}" as="e" hint-placeholder-count="5">
          <div class="erow">
            <span class="when t-data" style="color:var(--secondary)">{{ e.day }}</span>
            <span style="flex:1;min-width:0">
              <span class="t-rec" style="display:block;text-wrap:pretty">{{ e.what }}</span>
              <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">{{ e.who }}</span>
            </span>
          </div>
        </sc-for>
      </div>
    </sc-for>

    <p class="t-meta" style="margin:16px 0 0;color:var(--secondary);text-wrap:pretty">
      Ask us to send you everything and this is what arrives, with the signatures
      attached.</p>
  </main>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Drawn but inert. Entry kinds are the ones the record actually produces: a
// chapter written, an attestation received, a grant issued or ended, a consent
// flag recorded at the moment it bound (058), and the account facts.
class Component extends DCLogic {
  renderVals(){
    const GROUPS = [
      {month:'June 2026', rows:[
        {day:'28 Jun', what:'You agreed to how the record works',
         who:'Four terms, at signup'},
        {day:'28 Jun', what:'Identity document checked',
         who:'Grain holds the result, never the document'},
        {day:'28 Jun', what:'You claimed hiregrain.com/u/liezel-mendoza',
         who:'The address stays yours and never goes to anyone else'},
        {day:'28 Jun', what:'You added five chapters from a résumé',
         who:'Yours to correct until a party attests one'}
      ]},
      {month:'July 2026', rows:[
        {day:'2 Jul',  what:'You asked Cebu Pacific Cargo Services to attest a chapter',
         who:'You agreed there that asking cannot be undone'},
        {day:'2 Jul',  what:'Cebu Pacific Cargo Services attested your dates and employment',
         who:'Registered business, signed from the domain Grain checked'},
        {day:'19 Jul', what:'You granted Teleperformance Philippines your whole record',
         who:'Sent to recruiting@teleperformance.ph, confirmed 20 Jul 2026'}
      ]},
      // No read events here either. Decision 035 B4 governs every worker-facing
      // surface. Sharing is one of them, and this screen was added in the same
      // pass that took the read log off Sharing. What the ledger carries is what the ledger
      // is for: entries written to the record. A grant issued is an entry; a
      // grant expiring is an entry; somebody opening it is not.
      {month:'August 2026', rows:[
        {day:'4 Aug',  what:'You agreed that a grant cannot be recalled once read',
         who:'Recorded when you sent the grant'},
        {day:'4 Aug',  what:'You granted Alorica Philippines your whole record',
         who:'Sent to ramil.antonio@alorica.com, ends 2 Sep 2026'},
        {day:'17 Aug', what:'The grant to Teleperformance Philippines ended on its own date',
         who:'Granted 19 Jul 2026. They can no longer open your record'}
      ]}
    ];
    return { groups: GROUPS.map(g => ({...g, count: g.rows.length})) };
  }
}
</script>
</body>
</html>
