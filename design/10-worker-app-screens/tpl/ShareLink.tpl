<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .srow{display:flex;gap:12px;align-items:baseline;padding:13px 0;
          border-bottom:1px solid var(--hairline);width:100%;min-height:44px;text-align:left}
    .grp{padding-top:26px}
    main::-webkit-scrollbar{width:0}
    /* Danger is ink inversion, explicit words and a two-step. Never red (§5). */
    .warn{background:var(--ink);color:var(--paper);padding:14px 16px}
    .warn .t-data{color:var(--paper)}
  </style>
</helmet>

<div style="width:100%;height:100%;min-height:728px;position:relative;overflow:hidden;background:var(--paper)">
  <header style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 20px;border-bottom:1px solid var(--ink);position:relative;z-index:3;
                 background:var(--paper)">
    <h1 class="t-serial" style="margin:0">Send your record</h1>
    <button class="press" aria-label="Back to sharing" style="width:44px;height:44px;display:flex;
            align-items:center;justify-content:flex-end">
      <svg width="18" height="18" viewBox="0 0 18 18" class="icon"><path d="M3 3 L15 15"/><path d="M15 3 L3 15"/></svg>
    </button>
  </header>

  <main style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 40px">

    <!-- The reading: how long it lives. The whole object is its expiry. -->
    <div style="display:flex;align-items:baseline;gap:14px;padding:24px 0 18px;
                border-bottom:1px solid var(--ink)">
      <span class="t-inst">{{ days }}</span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block;text-wrap:pretty">days, then the link stops working</span>
        <span class="t-data" style="display:block;color:var(--secondary);padding-top:3px">
          Expires {{ expiry }}</span>
      </span>
    </div>

    <div class="grp">
      <div class="sechead"><h2 class="t-sec" style="margin:0">How long</h2></div>
      <div class="sinerule">@@SINERULE@@</div>
      <div role="group" aria-label="How long the link lasts" style="display:flex;gap:8px;padding-top:14px">
        <sc-for list="{{ spans }}" as="s" hint-placeholder-count="3">
          <button class="press t-data" aria-pressed="{{ s.on }}" onClick="{{ s.go }}"
                  style="flex:1;min-height:44px;border:1px solid {{ s.border }};border-radius:3px;
                         padding:12px 6px;text-align:center;font-weight:{{ s.weight }}">{{ s.label }}</button>
        </sc-for>
      </div>
    </div>

    <div class="grp">
      <div class="sechead"><h2 class="t-sec" style="margin:0">What they will see</h2></div>
      <div class="sinerule">@@SINERULE@@</div>
      <sc-for list="{{ contents }}" as="c" hint-placeholder-count="4">
        <div class="srow">
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ c.label }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">{{ c.note }}</span>
          </span>
          <span class="t-data col-r" style="color:{{ c.color }}">{{ c.state }}</span>
        </div>
      </sc-for>
    </div>

    <!-- The thing an interface normally implies the opposite of. -->
    <div class="grp">
      <div class="warn">
        <p class="t-rec" style="margin:0;color:var(--paper);text-wrap:pretty">
          This is everything, including what each business wrote about you.</p>
        <p class="t-data" style="margin:8px 0 0;text-wrap:pretty">
          Anyone holding the link can open it until it expires. It cannot be
          un-sent, and ending it early does not recall what was already read.
          Send it to someone deciding about you, not to a job board.</p>
      </div>
    </div>

    <div class="grp">
      <button class="btn-primary press" style="width:100%">Create the link</button>
      <p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-align:center">
        You will see it here, and in Sharing, until it expires.</p>
    </div>

  </main>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Gap 13, half one: the expiring full-record link. Decision 035 made this the
// sensitive tier — the whole record including the imprint — against the public
// page's reduced view. Drawn but inert: what "create" issues is undecided.
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {span:1}; }
  renderVals(){
    const SPANS = [{label:'7 days', days:7}, {label:'30 days', days:30}, {label:'90 days', days:90}];
    const i = this.state.span, cur = SPANS[i];
    const d = new Date(2026, 7, 20); d.setDate(d.getDate() + cur.days);
    const MON = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return {
      days: cur.days,
      expiry: d.getDate() + ' ' + MON[d.getMonth()] + ' ' + d.getFullYear(),
      spans: SPANS.map((s, j) => ({
        label: s.label, on: j === i ? 'true' : 'false',
        border: j === i ? 'var(--ink)' : 'var(--rule)',
        weight: j === i ? '600' : '400',
        go: () => this.setState({span: j})
      })),
      contents: [
        {label:'Every chapter, and its dates', note:'The whole history, not a selection.',
         state:'Shown', color:'var(--ink)'},
        {label:'Who confirmed what', note:'Which business signed, which coworker, and which nobody did.',
         state:'Shown', color:'var(--ink)'},
        {label:'What each business wrote', note:'The seven measures, at the level each party attested.',
         state:'Shown', color:'var(--ink)'},
        {label:'Your imprint', note:'The figure, at full size.',
         state:'Shown', color:'var(--ink)'},
        {label:'Your phone and email', note:'Never in a link. They ask you for those.',
         state:'Private', color:'var(--secondary)'}
      ]
    };
  }
}
</script>
</body>
</html>
