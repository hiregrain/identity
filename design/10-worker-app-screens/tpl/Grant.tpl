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
    .mrow{display:flex;gap:12px;align-items:baseline;padding:11px 0;
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
        Philippines · Identity document checked, which says nothing about the work below</p>
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
          <span class="gutter">
            <svg viewBox="0 0 34 16" width="34" height="16" fill="none"
                 stroke="var(--ink)" stroke-width="1"><use href="{{ c.sw }}"></use></svg>
          </span>
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ c.party }}</span>
            <span class="t-data" style="display:block;padding-top:3px">{{ c.state }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px">{{ c.registry }}</span>
          </span>
          <span class="col-r">
            <span class="t-data" style="display:block">{{ c.from }}</span>
            <span class="t-data" style="display:block;color:var(--secondary)">{{ c.to }}</span>
          </span>
        </div>
      </sc-for>
    </div>

    <div style="padding-top:26px">
      <div class="sechead"><h2 class="t-sec" style="margin:0">{{ measureHead }}</h2></div>
      <div class="sinerule">@@SINERULE@@</div>
      <p class="t-meta" style="margin:10px 0 4px;color:var(--secondary);text-wrap:pretty">
        Seven measures, in the same order on every record. Each is what one
        business asserted about the work, in their words, not a rating of a person.</p>
      <sc-for list="{{ measures }}" as="m" hint-placeholder-count="7">
        <div class="mrow">
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ m.name }}</span>
            <span class="t-body" style="display:block;color:{{ m.color }};padding-top:2px;text-wrap:pretty">{{ m.value }}</span>
          </span>
          <span class="rung" aria-hidden="true">
            <sc-for list="{{ m.scale }}" as="st" hint-placeholder-count="7">
              <i style="height:{{ st.h }};background:{{ st.c }}"></i>
            </sc-for>
          </span>
        </div>
      </sc-for>
    </div>

    <div style="margin-top:24px;border-top:1px solid var(--ink);padding-top:14px">
      <p class="t-meta" style="margin:0;color:var(--secondary);text-wrap:pretty">
        Two of these chapters were signed by one party only, and stand at that
        party's reading alone. One nobody has confirmed. Grain does not average
        parties who disagree.</p>
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
    const chapters = [
      {party:'Cebu Pacific Cargo Services', state:'Dates and job confirmed. Nothing about the work.',
       registry:'Registered business · signed 20 Jan 2026', sw:'#sw-employment_verified',
       from:'Jan 2025', to:'present'},
      {party:'Metro Manila Logistics', state:'Signed by the business. Nobody else has agreed.',
       registry:'Registered business · signed 20 Jan 2025', sw:'#sw-party_single',
       from:'Mar 2023', to:'Jan 2025'},
      {party:'R. Santos Dry Goods', state:'Signed by a coworker, not the business.',
       registry:'Individual · signed 2 Apr 2023', sw:'#sw-peer_attested',
       from:'Sep 2020', to:'Mar 2023'},
      {party:'Sunrise Foods Manufacturing', state:'Signed by the business, and a second party agreed.',
       registry:'Registered business · signed 14 Oct 2021', sw:'#sw-party_multi',
       from:'Mar 2019', to:'Sep 2021'},
      {party:'Bataan Poultry Processing', state:'Liezel added this. Nobody has confirmed it.',
       registry:'No attesting party', sw:'#sw-self_asserted',
       from:'Sep 2017', to:'Mar 2019'}
    ];
    const DIMS = [
      ['Discretion','Chose how, within a set what',3],
      ['Direction of Others','Answerable for a small group',3],
      ['Consequence Held','Mistakes cost time or schedule',3],
      ['Counterparty Exposure','No dealings outside the team',1],
      ['Method Authority','Adapted the method in practice',3],
      ['Resource and Financial','Accountable for tools in hand',2],
      ['Systems and Tooling','Kept a system running day to day',2]
    ];
    return {
      daysLeft: 13, granted: '4 Aug 2026',
      count: chapters.length, chapters,
      measureHead: 'What Sunrise Foods attested',
      measures: DIMS.map(([name, value, lv]) => ({
        name, value, color: 'var(--ink)',
        scale: Array.from({length: 7}, (_, r) => ({
          h: (4 + r * 1.6).toFixed(0) + 'px',
          c: r < lv ? 'var(--rule)' : (r === lv ? 'var(--ink)' : 'var(--hairline)')
        }))
      }))
    };
  }
}
</script>
</body>
</html>
