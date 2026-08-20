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

<!-- B2. Every raw fact, every attestation, and what a correction did to
     what it corrected. The record is append-only, so a superseded value is
     shown struck with the entry that replaced it beside it: removing it would
     make the ledger's central promise unreadable on the one screen where a
     worker would check it. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your record">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Chapter</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:24px 0 16px;border-bottom:1px solid var(--ink)">
      <h2 class="t-head" style="margin:0;text-wrap:pretty">Sunrise Foods Manufacturing</h2>
      <p class="t-data" style="margin:8px 0 0;color:var(--secondary)">Mar 2019 to Sep 2021 · Two positions</p>
      <div style="display:flex;align-items:center;gap:10px;padding-top:12px">
        <span class="prov" tabindex="0">
          <svg viewBox="0 0 34 16" width="34" height="16" fill="none" aria-hidden="true"
               stroke="var(--ink)" stroke-width="1"><use href="#sw-multi"></use></svg>
          <span class="tip t-meta">Attested by Sunrise Foods Manufacturing, and a second party agrees.</span>
        </span>
        <span class="t-meta" style="color:var(--secondary);flex:1;min-width:0;text-wrap:pretty">
          Two parties attested this independently.</span>
      </div>
    </div>

    <div class="grp">
      <div class="sechead"><h3 class="t-sec" style="margin:0">What the record holds</h3></div>
      <div class="sinerule">@@SINERULE@@</div>
      <sc-for list="{{ facts }}" as="f" hint-placeholder-count="6">
        <div class="drow">
          <span class="dk t-meta" style="color:var(--secondary)">{{ f.k }}</span>
          <span style="flex:1;min-width:0">
            <span class="t-body" style="display:block;text-wrap:pretty">{{ f.v }}</span>
            <sc-if value="{{ f.was }}" hint-placeholder-val="{{ true }}">
              <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">
                <s>{{ f.was }}</s> corrected {{ f.when }}, by a new entry</span>
            </sc-if>
          </span>
        </div>
      </sc-for>
    </div>

    <div class="grp">
      <div class="sechead"><h3 class="t-sec" style="margin:0">Who attested it</h3>
        <span class="t-data" style="color:var(--secondary)">{{ n }}</span></div>
      <div class="sinerule">@@SINERULE@@</div>
      <sc-for list="{{ atts }}" as="a" hint-placeholder-count="2">
        <div class="drow">
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ a.party }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">{{ a.kind }}</span>
          </span>
          <span class="t-data col-r" style="color:var(--secondary)">{{ a.when }}</span>
        </div>
      </sc-for>
      <p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">
        Grain checks that each party really signed. It never checks whether they
        were right, and it never averages parties who disagree.</p>
    </div>

    <div class="grp">
      <div class="sechead"><h3 class="t-sec" style="margin:0">What you can do</h3></div>
      <div class="sinerule">@@SINERULE@@</div>
      <button class="srow press">
        <span style="flex:1;min-width:0">
          <span class="t-rec" style="display:block">Attach your side of it</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">
            The record stays as the party wrote it. Your account is written beside
            it, permanently, and travels with it.</span>
        </span>
        <span class="chev" aria-hidden="true">
          <svg width="16" height="16" viewBox="0 0 20 20" fill="none" stroke="var(--rule)"
               stroke-width="1.2" stroke-linecap="round"><path d="M8 4 L14 10 L8 16"/></svg>
        </span>
      </button>
      <button class="srow press">
        <span style="flex:1;min-width:0">
          <span class="t-rec" style="display:block">Correct a date or a title</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">
            Written as a new entry that cites the old one. Both stay readable.</span>
        </span>
        <span class="chev" aria-hidden="true">
          <svg width="16" height="16" viewBox="0 0 20 20" fill="none" stroke="var(--rule)"
               stroke-width="1.2" stroke-linecap="round"><path d="M8 4 L14 10 L8 16"/></svg>
        </span>
      </button>
      <p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">
        A chapter a party has attested cannot be removed. Deleting your whole
        record is the only way any of it comes out.</p>
    </div>
  </main>

</div>
@@ICONS@@
@@SWATCHES@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    const atts = [
      {party:'Sunrise Foods Manufacturing', kind:'Registered business, signed from their verified domain', when:'14 Oct 2021'},
      {party:'A coworker who was there', kind:'Individual, confirmed a work email at this business', when:'2 Nov 2021'}
    ];
    return {
      n: atts.length, atts,
      facts: [
        {k:'Business', v:'Sunrise Foods Manufacturing'},
        {k:'Registry', v:'Registered with Grain, verified domain'},
        {k:'Dates', v:'Mar 2019 to Sep 2021'},
        {k:'Positions', v:'Packing line operator, then Line lead'},
        {k:'Title', v:'Line lead', was:'Line leader', when:'6 Nov 2021'},
        {k:'Added', v:'By you, 28 Jun 2026, from a résumé'}
      ]
    };
  }
}
</script>
</body>
</html>
