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

<!-- H3. EN, then TL and HI. DESIGN.md gap 7 is launch-blocking and named
     here rather than hidden: Archivo does not cover Devanagari, and §6's
     hierarchy rests on a width axis the fallback stack does not have. A row
     that offered Hindi today would be offering a broken screen. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your account">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Language</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <sc-for list="{{ langs }}" as="l" hint-placeholder-count="3">
        <button class="srow press" aria-pressed="{{ l.on }}" disabled="{{ l.off }}" onClick="{{ l.go }}">
          <span style="flex:1;min-width:0">
            <span class="t-body" style="display:block;color:{{ l.color }}">{{ l.name }}</span>
            <sc-if value="{{ l.note }}" hint-placeholder-val="{{ true }}">
              <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">{{ l.note }}</span>
            </sc-if>
          </span>
          <span class="t-data col-r" style="color:var(--secondary)">{{ l.mark }}</span>
        </button>
      </sc-for>
    </div>
    <div class="grp">
      <p class="t-meta" style="margin:0;color:var(--secondary);text-wrap:pretty">
        Changing the language changes the app. It never changes your record: what
        a party wrote stays in the language they wrote it in, because translating
        an attestation would be Grain putting words in their mouth.</p>
    </div>
  </main>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {i:0}; }
  renderVals(){
    const L = [
      {name:'English', note:''},
      {name:'Tagalog', note:''},
      {name:'हिन्दी, Hindi', note:'Not yet. The typeface this record is set in does not cover Devanagari, and a substitute face would lose the weight distinctions the record uses to say what is attested.'}
    ];
    return { langs: L.map((l, i) => ({
      name: l.name, note: l.note,
      color: i === 2 ? 'var(--secondary)' : 'var(--ink)',
      on: i === this.state.i ? 'true' : 'false',
      off: i === 2 ? 'disabled' : null,
      mark: i === this.state.i ? 'On' : (i === 2 ? 'Not ready' : ''),
      go: () => { if (i !== 2) this.setState({i}); }
    }))};
  }
}
</script>
</body>
</html>
