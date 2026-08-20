<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .res{display:flex;gap:12px;align-items:flex-start;width:100%;padding:12px 0;
         border-bottom:1px solid var(--hairline);text-align:left}
  </style>
</helmet>

<!-- C1, and A9 in first run. Party search over registered businesses, with
     a free-text fallback that never auto-resolves to a party_ref: a business
     Grain does not know is a real answer, and quietly binding it to the
     nearest match would forge provenance. Month precision only, per schema. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Add a chapter</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <label class="t-micro" for="q" style="display:block;color:var(--secondary);padding-bottom:8px">Where did you work?</label>
      <div class="ruled">
        <input id="q" value="{{ q }}" onInput="{{ onQ }}" autocapitalize="words" aria-describedby="qn">
      </div>
      <p id="qn" class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
        Businesses registered with Grain can attest what you did. One that is not
        registered still goes on your record; a coworker who was there can attest it.</p>

      <div style="padding-top:14px">
        <sc-for list="{{ hits }}" as="h" hint-placeholder-count="3">
          <button class="res press" onClick="{{ h.pick }}">
            <span style="flex:1;min-width:0">
              <span class="t-rec" style="display:block">{{ h.name }}</span>
              <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px">{{ h.note }}</span>
            </span>
            <sc-if value="{{ h.registered }}" hint-placeholder-val="{{ true }}">
              <span class="t-data col-r" style="color:var(--secondary)">Registered</span>
            </sc-if>
          </button>
        </sc-for>
      </div>
    </div>

    <div class="grp">
      <div class="sechead"><h3 class="t-sec" style="margin:0">When</h3></div>
      <div style="display:flex;gap:12px;padding-top:14px">
        <sc-for list="{{ months }}" as="m" hint-placeholder-count="2">
          <!-- A ruled line, not a box. §8: inputs are ruled lines and boxed
               fields do not exist, and a month picker is an input. -->
          <button class="press" style="flex:1;min-height:44px;padding:8px 0;text-align:left;
                  border-bottom:1px solid var(--rule)">
            <span class="t-micro" style="display:block;color:var(--secondary)">{{ m.label }}</span>
            <span class="t-data" style="display:block;padding-top:4px">{{ m.value }}</span>
          </button>
        </sc-for>
      </div>
      <p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">
        Month and year only. The record never holds a day, because nobody
        remembers one accurately and a false precision is still false.</p>
    </div>

    <div class="grp">
      <div class="sechead"><h3 class="t-sec" style="margin:0">What you did</h3></div>
      <label class="t-micro" for="t" style="display:block;color:var(--secondary);padding:14px 0 8px">Your title there</label>
      <div class="ruled"><input id="t" value="{{ title }}" onInput="{{ onT }}" autocapitalize="words"></div>
      <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
        Your own words until a party attests it. Nothing you write here is shown
        as though a business confirmed it.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press" disabled="{{ disabled }}">Add it to your record</button>
    <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-align:center;text-wrap:pretty">
      Yours to correct until a party attests it.</p>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {q:'Cebu Pac', title:'Cargo handling supervisor'}; }
  renderVals(){
    const q = this.state.q.trim().toLowerCase();
    const ALL = [
      {name:'Cebu Pacific Cargo Services', note:'Pasay, Philippines · air cargo', registered:true},
      {name:'Cebu Pacific Air', note:'Pasay, Philippines · airline', registered:true}
    ].filter(x => !q || x.name.toLowerCase().includes(q));
    const hits = ALL.concat(q ? [{
      name: this.state.q, note: 'Not registered with Grain. A coworker Liezel named can attest it.',
      registered: false, pick: () => {}
    }] : []).map(h => ({...h, pick: h.pick || (() => this.setState({q:h.name}))}));
    return {
      q: this.state.q, onQ: (e) => this.setState({q:e.target.value}), hits,
      months: [{label:'Started', value:'Jan 2025'}, {label:'Ended', value:'Still there'}],
      title: this.state.title, onT: (e) => this.setState({title:e.target.value}),
      disabled: this.state.q.trim() ? null : 'disabled'
    };
  }
}
</script>
</body>
</html>
