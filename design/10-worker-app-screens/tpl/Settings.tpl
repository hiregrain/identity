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
          border-bottom:1px solid var(--hairline);width:100%;min-height:44px}
    .grp{padding-top:24px}
    main::-webkit-scrollbar{width:0}
  </style>
</helmet>

<!-- Fluid in both axes: the record fills whatever safe area it is given, and
     min-height carries the standalone case where height:100% has no sized
     ancestor and would collapse to zero. 728 is the common safe box across
     iOS (778) and Android (728). Decision 046. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 20px;border-bottom:1px solid var(--hairline);position:relative;z-index:3;
                 background:var(--paper)">
    <h1 class="t-serial" style="margin:0">Account</h1>
    <button class="press" aria-label="Close" style="width:44px;height:44px;display:flex;
            align-items:center;justify-content:flex-end">
      <svg width="18" height="18" viewBox="0 0 18 18" class="icon"><path d="M3 3 L15 15"/><path d="M15 3 L3 15"/></svg>
    </button>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 40px">

    <!-- Append-only status, relocated here by decision 045 when the plate footer
         left the record. It is the only surface that makes "nothing can be
         deleted" checkable rather than a claim, and it is set in the instrument
         register, and §6 defines instrument numerals and nothing used them. -->
    <div style="padding:26px 0 20px;border-bottom:1px solid var(--ink)">
      <div class="reading">
        <span class="t-inst">{{ entries }}</span>
        <span style="flex:1;min-width:0">
          <span class="t-rec" style="display:block">entries, and none removed</span>
          <span class="t-data" style="display:block;color:var(--secondary);padding-top:3px">
            Last change {{ lastChange }}</span>
        </span>
      </div>
      <p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">
        Every entry is kept. A correction is written as a new entry rather than
        replacing the old one, so the record can be read back in order.</p>
    </div>

    <sc-for list="{{ groups }}" as="g" hint-placeholder-count="5">
      <div class="grp">
        <h2 class="t-micro" style="display:block;color:var(--secondary);padding-bottom:6px;
                                   border-bottom:1px solid var(--ink);margin:0">{{ g.name }}</h2>
        <div class="sinerule">@@SINERULE@@</div>
        <sc-for list="{{ g.rows }}" as="r" hint-placeholder-count="5">
          <sc-if value="{{ r.act }}" hint-placeholder-val="{{ true }}">
            <button class="srow press" onClick="{{ r.act }}">
              <span class="t-body" style="flex:1;min-width:0">{{ r.label }}</span>
              <span class="t-data" style="text-align:right;color:var(--secondary)">{{ r.value }}</span>
            </button>
          </sc-if>
          <sc-if value="{{ r.inert }}" hint-placeholder-val="{{ true }}">
            <div class="srow">
              <span class="t-body" style="flex:1;min-width:0;color:var(--secondary)">{{ r.label }}</span>
              <span class="t-data" style="text-align:right">{{ r.value }}</span>
            </div>
          </sc-if>
        </sc-for>
        <sc-if value="{{ g.note }}" hint-placeholder-val="{{ true }}">
          <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">{{ g.note }}</p>
        </sc-if>
      </div>
    </sc-for>

    <div style="padding-top:28px">
      <button class="btn-secondary press" onClick="{{ toggle }}">Ask us to delete everything</button>
      <sc-if value="{{ confirming }}" hint-placeholder-val="{{ true }}">
        <div style="background:var(--ink);color:var(--paper);padding:16px;margin-top:12px">
          <p class="t-body" style="margin:0;text-wrap:pretty">Support handles this. Nobody can read
            your record from the moment you ask. Everything is erased seven days later. If you sign in
            before then it all comes back, and you would have to ask again.</p>
        </div>
        <div style="padding-top:12px;text-align:center">
          <button class="btn-tertiary press" onClick="{{ toggle }}">Keep my record</button>
        </div>
      </sc-if>
    </div>
  </main>

</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// A sheet from the Record header, not a destination. Read-only: every account
// change is a support request (decision 030). Deletion has no in-app control.
// It is named here and routed, because consent promises the right at signup.
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {confirming:false}; }
  renderVals(){
    const inert = (label, value) => ({label, value, inert:true});
    const entries = 47, lastChange = '12 Aug 2026';
    const act = (label, value) => ({label, value, act: () => {}});
    return {
      entries, lastChange,
      groups: [
        {name:'Account', rows:[
          inert('Full name','Liezel Mendoza'), inert('Phone','+63 •• ••• 4471'),
          inert('Email','Not added'), inert('Address','hiregrain.com/u/liezel-mendoza')],
         note:'Support changes any of these. Message us and we will do it.'},
        {name:'Identity', rows:[
          act('Identity verification','Document'),
          act('Add a liveness check','Not added')],
         note:'Employers see one thing: verified, or not. They never see the document.'},
        {name:'Notifications', rows:[
          act('A business signs your work','On'),
          act('A grant is about to end','On'),
          act('Your public page is viewed','Off')]},
        {name:'Language', rows:[ act('App language','English') ]},
        {name:'Your data', rows:[
          act('Send me everything','By email, within 24 hours'),
          act('Who can read my record','2 parties'),
          act('Who has read my record','Ask us')]},
        {name:'About', rows:[ act('How the record works',''), act('Terms',''), act('Privacy','') ]}
      ],
      confirming: this.state.confirming,
      toggle: () => this.setState({confirming: !this.state.confirming})
    };
  }
}
</script>
</body>
</html>
