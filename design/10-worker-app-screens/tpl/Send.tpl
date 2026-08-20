<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    /* §8 inputs are ruled lines: a hairline you type on, focus thickens
       ink-ward. The touchable area is padded around the rule, since the rule
       itself measured 18px and §12 floors a target at 44. */
    .ruled{display:flex;align-items:center;border-bottom:1px solid var(--rule)}
    .ruled:focus-within{border-bottom:2px solid var(--ink)}
    .ruled input{border:0;outline:0;background:none;font:inherit;color:var(--ink);
                 flex:1;min-width:0;padding:12px 0;font-weight:600;font-size:16px;
                 min-height:44px;box-sizing:border-box}
    .srow{display:flex;gap:12px;align-items:baseline;padding:13px 0;
          border-bottom:1px solid var(--hairline);width:100%;min-height:44px;text-align:left}
    .grp{padding-top:26px}
    main::-webkit-scrollbar{width:0}
    /* Danger is ink inversion, explicit words and a two-step. Never red (§5). */
    .warn{background:var(--ink);color:var(--paper);padding:14px 16px}
    .warn .t-data{color:var(--paper)}
  </style>
</helmet>

<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 20px;border-bottom:1px solid var(--ink);position:relative;z-index:3;
                 background:var(--paper)">
    <h1 class="t-serial" style="margin:0">Send your record</h1>
    <button class="press" aria-label="Back to sharing" style="width:44px;height:44px;display:flex;
            align-items:center;justify-content:flex-end">
      <svg width="18" height="18" viewBox="0 0 18 18" class="icon"><path d="M3 3 L15 15"/><path d="M15 3 L3 15"/></svg>
    </button>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 40px">

    <!-- The reading: how long it lives. The whole object is its expiry. -->
    <div class="reading" style="padding:24px 0 18px;                border-bottom:1px solid var(--ink)">
      <span class="t-inst">{{ days }}</span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block;text-wrap:pretty">days, then their access ends</span>
        <span class="t-data" style="display:block;color:var(--secondary);padding-top:3px">
          Ends {{ expiry }}, and you can end it sooner</span>
      </span>
    </div>

    <div class="grp">
      <div class="sechead"><h2 class="t-sec" style="margin:0">Who you are sending it to</h2></div>
      <div class="sinerule">@@SINERULE@@</div>
      <label class="t-micro" for="to" style="display:block;color:var(--secondary);padding:14px 0 8px">
        Their email</label>
      <div class="ruled">
        <input id="to" value="{{ to }}" onInput="{{ onTo }}" aria-describedby="tn"
               autocapitalize="none" autocorrect="off" spellcheck="false" inputmode="email">
      </div>
      <p id="tn" class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
        They open it by confirming this address. No account, no password. Nobody
        else can open it, and you see when they did.</p>
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
          This is your whole record. You choose who reads it, never what they read.</p>
        <p class="t-data" style="margin:8px 0 0;text-wrap:pretty">
          Ending it early stops them reading it again. It does not recall what
          they already read.</p>
      </div>
    </div>

    <div class="grp">
      <button class="btn-primary press" style="width:100%">Send it to Ramil</button>
      <p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-align:center;text-wrap:pretty">
        It appears in Sharing under who holds a grant, with the date it ends.</p>
    </div>

  </main>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Gap 13, half one: the expiring full-record link. Decision 035 made this the
// sensitive tier, the whole record including the imprint, against the public
// page's reduced view. Drawn but inert: what "create" issues is undecided.
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {span:1, to:'ramil.antonio@alorica.com'}; }
  renderVals(){
    const SPANS = [{label:'7 days', days:7}, {label:'30 days', days:30}, {label:'90 days', days:90}];
    const i = this.state.span, cur = SPANS[i];
    const d = new Date(2026, 7, 20); d.setDate(d.getDate() + cur.days);
    const MON = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return {
      to: this.state.to,
      onTo: (e) => this.setState({to: e.target.value}),
      days: cur.days,
      expiry: d.getDate() + ' ' + MON[d.getMonth()] + ' ' + d.getFullYear(),
      spans: SPANS.map((s, j) => ({
        label: s.label, on: j === i ? 'true' : 'false',
        border: j === i ? 'var(--ink)' : 'var(--rule)',
        weight: j === i ? '600' : '400',
        go: () => this.setState({span: j})
      })),
      contents: [
        {label:'Every chapter, and its dates', note:'Everything on your record, not a selection.',
         state:'Shown', color:'var(--ink)'},
        {label:'Which party attested each chapter', note:'The business, a coworker who was there, or none.',
         state:'Shown', color:'var(--ink)'},
        {label:'Your imprint', note:'The figure, at full size.',
         state:'Shown', color:'var(--ink)'},
        {label:'Your phone and email', note:'Never in anything you send. They ask you for those.',
         state:'Private', color:'var(--secondary)'}
      ]
    };
  }
}
</script>
</body>
</html>
