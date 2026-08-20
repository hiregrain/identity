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
  </style>
</helmet>

<!-- Fluid in both axes: the record fills whatever safe area it is given, and
     min-height carries the standalone case where height:100% has no sized
     ancestor and would collapse to zero. 728 is the common safe box across
     iOS (778) and Android (728). Decision 046. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 20px;border-bottom:1px solid var(--ink);position:relative;z-index:3;
                 background:var(--paper)">
    <h1 class="t-serial" style="margin:0">Sharing</h1>
    <button class="press" aria-label="Back to your record" style="width:44px;height:44px;display:flex;
            align-items:center;justify-content:flex-end">
      <svg width="18" height="18" viewBox="0 0 18 18" class="icon"><path d="M3 3 L15 15"/><path d="M15 3 L3 15"/></svg>
    </button>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 40px">

    <!-- Exposure first, in one sentence, before any control. A worker opening
         this screen should learn what is already true before deciding anything. -->
    <!-- Exposure said as a state, because that is what it is. A bare figure here
         would read as a score, and §6's instrument register is for readings where
         the number IS the fact, such as ledger length or days left, not for a count of
         who can see you. -->
    <div style="padding:24px 0 18px;border-bottom:1px solid var(--ink)">
      <p class="t-sec" style="margin:0;font-size:19px;line-height:1.35;text-wrap:pretty">{{ exposure }}</p>
      <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
        A grant ends on its own date. Nobody keeps reading your record because
        you forgot about them.</p>
    </div>

    <div class="grp">
      <div class="sechead"><h2 class="t-sec" style="margin:0">Your public page</h2></div>
      <div class="sinerule">@@SINERULE@@</div>
      <!-- Every row leads with the record voice and carries its detail beneath,
           so the address row and the rows under it are the same object. A row
           that goes somewhere shows a chevron; a row that only states a fact
           does not, because a fact dressed as a control is a lie about what a
           worker can change. -->
      <button class="srow press" onClick="{{ noop }}">
        <span style="flex:1;min-width:0">
          <span class="t-rec" style="display:block">Your address</span>
          <span class="t-data" style="display:block;padding-top:3px">hiregrain.com/u/liezel-mendoza</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">
            It never changes hands. Turn the page off and the address stays yours.</span>
        </span>
        <span class="chev" aria-hidden="true">
          <svg width="16" height="16" viewBox="0 0 20 20" fill="none" stroke="var(--rule)"
               stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 4 L14 10 L8 16"/></svg>
        </span>
      </button>

      <!-- Decision 035: the only lever is the imprint, full or absent, nothing
           between. So this is one control, and the rest are statements. They were
           drawn as four identical toggles, which promised three settings that do
           not exist. -->
      <button class="srow press" onClick="{{ noop }}" aria-pressed="{{ pubOn }}">
        <span style="flex:1;min-width:0">
          <span class="t-rec" style="display:block">Your page</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">
            Off until you turn it on. Nobody reaches your record by searching for
            you while it is off.</span>
        </span>
        <span class="t-data col-r">{{ pubState }}</span>
      </button>

      <div class="srow">
        <span style="flex:1;min-width:0">
          <span class="t-body" style="display:block">Times your page was opened</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">
            Counted while the page is on. Never who, and never for a record you sent.</span>
        </span>
        <span class="t-data col-r">{{ pubViews }}</span>
      </div>

      <div style="padding-top:14px">
        <span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:6px">
          What the page always shows, and never shows</span>
        <sc-for list="{{ facts }}" as="v" hint-placeholder-count="3">
          <div class="srow">
            <span style="flex:1;min-width:0">
              <span class="t-body" style="display:block;text-wrap:pretty">{{ v.label }}</span>
              <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">{{ v.note }}</span>
            </span>
            <span class="t-data col-r" style="color:{{ v.color }}">{{ v.state }}</span>
          </div>
        </sc-for>
      </div>
    </div>

    <div class="grp">
      <div class="sechead"><h2 class="t-sec" style="margin:0">Who holds a grant</h2>
        <span class="t-data" style="color:var(--secondary)">{{ grantCount }}</span></div>
      <div class="sinerule">@@SINERULE@@</div>
      <sc-for list="{{ grants }}" as="g" hint-placeholder-count="2">
        <button class="srow press" onClick="{{ g.go }}">
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ g.party }}</span>
            <span class="t-data" style="display:block;padding-top:3px">{{ g.what }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px">{{ g.since }}</span>
          </span>
          <span class="col-r">
            <span class="t-data" style="display:block">{{ g.state }}</span>
            <span class="t-data" style="display:block;color:var(--secondary)">{{ g.until }}</span>
          </span>
        </button>
      </sc-for>
      <!-- The rationale clause that used to close this paragraph ("this screen
           says so rather than implying otherwise") was addressed to a reviewer,
           not to the worker. The two sentences before it already do the work. -->
      <p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">
        Ending a grant stops future reads. It cannot pull back what a business
        already read and kept.</p>
    </div>

    <div class="grp">
      <div class="sechead"><h2 class="t-sec" style="margin:0">Send your record to someone</h2></div>
      <div class="sinerule">@@SINERULE@@</div>
      <p class="t-body" style="margin:0 0 12px;color:var(--secondary);text-wrap:pretty">
        You send it to one person by name. They open it by confirming the address
        you sent it to, so you always know who read it, and it ends on a date you
        set.</p>
      <button class="btn-secondary press" style="width:100%">Send your record</button>
    </div>

    <!-- No read log. Decision 035 B4: the worker sees the grant's state and no
         read events, because a read stream during a live application is an
         anxiety feed and surveillance of the employer. 057 made a read
         attributable in the ledger, which is not the same as surfacing it, and
         057 did not supersede this. Public-profile views are counted, which is
         the one thing 035 B4 permits, and it sits with the page it counts. -->


  </main>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Sharing as a destination, per decision 045. It was the record's fourth
// section, which put the one surface where worker custody is actually exercised
// at the bottom of a scroll. Reached from the record header.
//
// Every control here is drawn but inert: this is a mockup, and what a revoke or
// the imprint lever actually does is not decided. Decision 035 fixes that the
// lever is the imprint, full or absent, and nothing between, so this screen
// carries one control and states the rest as facts rather than drawing three
// settings that do not exist.
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {}; }
  renderVals(){
    const noop = () => {};
    return {
      noop,
      exposure: 'Your public page is off. Two parties hold a grant to your record.',
      pubState: 'Off', pubOn: 'false', pubViews: 'None while off',
      grantCount: '2',
      // The measures row is gone rather than reworded. Nothing derived from them
      // renders (054) and what consent and the packet say about collecting them
      // is an open gate, so this screen says nothing about them at all.
      facts: [
        {label:'Chapters, parties and dates', note:'Who you worked for, when, and in what position.',
         state:'Always', color:'var(--ink)'},
        {label:'Which party attested each chapter', note:'The business, a coworker who was there, or none.',
         state:'Always', color:'var(--ink)'},
        {label:'Your imprint', note:'Drawn for anyone who opens the page. Never in search results.',
         state:'Visitors', color:'var(--ink)'},
        {label:'Your phone and email', note:'Never on a page and never in anything you send.',
         state:'Never', color:'var(--secondary)'}
      ],
      // Two parties deciding about her, not a former employer. A demonstration
      // showing an old employer holding a live grant to her current record
      // taught the wrong thing whatever the mechanism allows.
      grants: [
        {party:'Alorica Philippines', what:'Your whole record',
         since:'Granted 4 Aug 2026', state:'Ends', until:'2 Sep', go:noop},
        {party:'Teleperformance Philippines', what:'Your whole record',
         since:'Granted 19 Jul 2026', state:'Ends', until:'17 Aug', go:noop}
      ]
    };
  }
}
</script>
</body>
</html>
