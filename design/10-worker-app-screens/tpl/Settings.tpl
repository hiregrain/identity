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
    <!-- The count is demoted and it opens (059). As a 40px instrument numeral
         with nothing behind it, forty-seven entries against five jobs read as
         surveillance, and a number nobody can open is a claim rather than the
         check it was put here to be. -->
    <div style="padding:20px 0 4px;border-bottom:1px solid var(--ink)">
      <button class="srow press" onClick="{{ noop }}" style="padding-top:0">
        <span style="flex:1;min-width:0">
          <span class="t-rec" style="display:block">Everything written to your record</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px;text-wrap:pretty">
            {{ entries }} entries, none removed. A correction is a new entry rather
            than a replacement, so it reads back in order. Last change {{ lastChange }}.</span>
        </span>
        <span class="chev" aria-hidden="true">
          <svg width="16" height="16" viewBox="0 0 20 20" fill="none" stroke="var(--rule)"
               stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 4 L14 10 L8 16"/></svg>
        </span>
      </button>
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
        <!-- Paraphrases copy/deletion.md, which is canonical, and decision 052's
             72-hour window. This screen said seven days and said a sign-in
             revived the record, and neither was true of either. No surface
             states its own numbers. -->
        <div style="background:var(--ink);color:var(--paper);padding:16px;margin-top:12px">
          <p class="t-body" style="margin:0;text-wrap:pretty">Access stops the moment you ask, and
            every grant ends. You have 72 hours to cancel, in the app or through support, so nobody
            can be made to destroy their record on the spot. After that the key is destroyed and
            nothing about you can be read by anyone, including us. What is left is removed within
            30 days.</p>
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
// change is a support request (decision 036). Deletion has no in-app control.
// It is named here and routed, because consent promises the right at signup.
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {confirming:false}; }
  renderVals(){
    const inert = (label, value) => ({label, value, inert:true});
    const entries = 47, lastChange = '12 Aug 2026';
    const act = (label, value) => ({label, value, act: () => {}});
    const noop = () => {};
    return {
      entries, lastChange, noop,
      groups: [
        {name:'Account', rows:[
          inert('Full name','Liezel Mendoza'), inert('Phone','+63 •• ••• 4471'),
          inert('Email','Not added'), inert('Address','hiregrain.com/u/liezel-mendoza')],
         note:'Support changes any of these. Message us and we will do it.'},
        {name:'Identity', rows:[
          act('Identity verification','Document'),
          act('Add a liveness check','Not added')],
         note:'A reader sees that a document was checked, which says nothing about the work. They never see the document.'},
        {name:'Notifications', rows:[
          act('A business signs your work','On'),
          act('A grant is about to end','On'),
          act('Your public page is viewed','Off')]},
        {name:'Language', rows:[ act('App language','English') ]},
        {name:'Your data', rows:[
          act('Send me everything','By email, within 24 hours'),
          act('Who can read my record','2 parties'),
          // Sharing already lists every reader with a date, two taps away. This
          // row sent the same question to a support conversation.
          act('Who has read my record','In Sharing')]},
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
