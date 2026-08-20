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

<!-- F2. Country first, then type, because which documents exist depends on
     the country and offering a US driver licence to a Philippine worker is
     the tell of a product built somewhere else. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Verify your identity</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <div class="sechead"><h3 class="t-sec" style="margin:0">Issuing country</h3></div>
      <button class="srow press" style="padding-top:16px">
        <span class="t-body" style="flex:1;min-width:0">Philippines</span>
        <span class="chev" aria-hidden="true">
          <svg width="16" height="16" viewBox="0 0 20 20" fill="none" stroke="var(--rule)"
               stroke-width="1.2" stroke-linecap="round"><path d="M8 4 L14 10 L8 16"/></svg>
        </span>
      </button>
    </div>

    <div class="grp">
      <div class="sechead"><h3 class="t-sec" style="margin:0">Which document</h3></div>
      <sc-for list="{{ docs }}" as="d" hint-placeholder-count="4">
        <button class="srow press" aria-pressed="{{ d.on }}" onClick="{{ d.go }}">
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ d.name }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">{{ d.note }}</span>
          </span>
          <span class="t-data col-r" style="color:var(--secondary)">{{ d.mark }}</span>
        </button>
      </sc-for>
      <p class="t-meta" style="margin:14px 0 0;color:var(--secondary);text-wrap:pretty">
        Checked by Persona, our verification vendor. They see the document, we do
        not, and their retention schedule is in the privacy notice.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Continue</button>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {i:0}; }
  renderVals(){
    const DOCS = [
      ['Philippine passport', 'Fastest to check.'],
      ['PhilSys national ID', 'Widely held, and accepted here.'],
      ['UMID or SSS card', 'Accepted. Slower to check by hand.'],
      ['Driver licence', 'Accepted.']
    ];
    return { docs: DOCS.map(([name, note], i) => ({
      name, note, on: i === this.state.i ? 'true' : 'false',
      mark: i === this.state.i ? 'Chosen' : '',
      go: () => this.setState({i})
    }))};
  }
}
</script>
</body>
</html>
