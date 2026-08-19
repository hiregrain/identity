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
<div style="width:100%;height:100%;min-height:728px;position:relative;overflow:hidden;background:var(--paper)">
  <header style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 20px;border-bottom:1px solid var(--ink);position:relative;z-index:3;
                 background:var(--paper)">
    <h1 class="t-serial" style="margin:0">Sharing</h1>
    <button class="press" aria-label="Back to your record" style="width:44px;height:44px;display:flex;
            align-items:center;justify-content:flex-end">
      <svg width="18" height="18" viewBox="0 0 18 18" class="icon"><path d="M3 3 L15 15"/><path d="M15 3 L3 15"/></svg>
    </button>
  </header>

  <main style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 40px">

    <!-- Exposure first, in one sentence, before any control. A worker opening
         this screen should learn what is already true before deciding anything. -->
    <div style="padding-top:22px;border-bottom:1px solid var(--ink);padding-bottom:16px">
      <p class="t-rec" style="margin:0;text-wrap:pretty">{{ exposure }}</p>
      <p class="t-meta" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">
        A grant ends on its own date. Nobody keeps reading your record because
        you forgot about them.</p>
    </div>

    <div class="grp">
      <div class="sechead"><h2 class="t-sec" style="margin:0">Your public page</h2>
        <span class="t-data" style="color:var(--secondary)">{{ pubState }}</span></div>
      <button class="srow press" onClick="{{ noop }}">
        <span style="flex:1;min-width:0">
          <span class="t-data" style="display:block">hiregrain.com/u/liezel-mendoza</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">
            Your address never changes hands. You can turn the page off; the address stays yours.</span>
        </span>
      </button>
      <sc-for list="{{ visibility }}" as="v" hint-placeholder-count="4">
        <button class="srow press" onClick="{{ v.go }}" aria-pressed="{{ v.on }}">
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ v.label }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">{{ v.note }}</span>
          </span>
          <span class="t-data col-r" style="color:{{ v.color }}">{{ v.state }}</span>
        </button>
      </sc-for>
    </div>

    <div class="grp">
      <div class="sechead"><h2 class="t-sec" style="margin:0">Who holds a grant</h2>
        <span class="t-data" style="color:var(--secondary)">{{ grantCount }}</span></div>
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
      <p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">
        Ending a grant stops future reads. It cannot pull back what a business
        already read and kept — this screen says so rather than implying otherwise.</p>
    </div>

    <div class="grp">
      <div class="sechead"><h2 class="t-sec" style="margin:0">Send your whole record</h2></div>
      <p class="t-body" style="margin:0 0 12px;color:var(--secondary);text-wrap:pretty">
        A private link to everything, including what each business wrote. It
        expires. Send it to someone deciding about you, not to a job board.</p>
      <button class="btn-secondary press" style="width:100%">Create an expiring link</button>
    </div>

    <div class="grp">
      <div class="sechead"><h2 class="t-sec" style="margin:0">Who has read it</h2></div>
      <sc-for list="{{ reads }}" as="r" hint-placeholder-count="3">
        <div class="srow">
          <span style="flex:1;min-width:0" class="t-rec">{{ r.party }}</span>
          <span class="t-data col-r" style="color:var(--secondary)">{{ r.when }}</span>
        </div>
      </sc-for>
    </div>

  </main>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Sharing as a destination, per decision 045. It was the record's fourth
// section, which put the one surface where worker custody is actually exercised
// at the bottom of a scroll. Reached from the record header.
//
// Every control here is drawn but inert: this is a mockup, and what a revoke or
// a visibility switch actually does is not decided (DESIGN.md gaps 8 and 13).
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {}; }
  renderVals(){
    const noop = () => {};
    return {
      noop,
      exposure: 'Your public page is on, and two businesses hold a grant to your whole record.',
      pubState: 'On',
      grantCount: '2',
      visibility: [
        {label:'Chapters, parties and dates', note:'Who you worked for, and when. This is what the page is for.',
         state:'Shown', color:'var(--ink)', on:'true', go:noop},
        {label:'Who confirmed what', note:'Whether a business signed, a coworker signed, or nobody did.',
         state:'Shown', color:'var(--ink)', on:'true', go:noop},
        {label:'Your imprint', note:'The figure. It is behind sign-in even when the page is public.',
         state:'Shown', color:'var(--ink)', on:'true', go:noop},
        {label:'What each business wrote', note:'Never on the public page. Only on an expiring link you send.',
         state:'Private', color:'var(--secondary)', on:'false', go:noop}
      ],
      grants: [
        {party:'Alorica Philippines', what:'Whole record, including what businesses wrote',
         since:'Granted 4 Aug 2026', state:'Ends', until:'2 Sep', go:noop},
        {party:'Sunrise Foods Manufacturing', what:'Whole record, including what businesses wrote',
         since:'Granted 19 Jul 2026', state:'Ends', until:'17 Aug', go:noop}
      ],
      reads: [
        {party:'Alorica Philippines', when:'12 Aug'},
        {party:'Sunrise Foods Manufacturing', when:'9 Aug'},
        {party:'Public page', when:'3 this week'}
      ]
    };
  }
}
</script>
</body>
</html>
