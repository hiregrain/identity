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

<!-- A10. §9's band closing, for the one case where the length IS known.
     The arc is for work of unknown duration; a file of known size gets a band.
     Using the arc here would be the same lie as a spinner. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Cancel the import">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Import a résumé</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:32px">
      <h2 class="t-lead" style="margin:0 0 8px;line-height:1.3">{{ head }}</h2>
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">
        Nothing is written to your record yet. You read it and correct it first.</p>

      <div class="band" role="progressbar" aria-valuenow="{{ pct }}" aria-valuemin="0"
           aria-valuemax="100" aria-label="Reading your résumé"><i style="width:{{ pct }}%"></i></div>
      <div style="display:flex;justify-content:space-between;align-items:baseline;padding-top:10px">
        <span class="t-meta" style="color:var(--secondary)">{{ file }}</span>
        <span class="t-data">{{ pct }}%</span>
      </div>

      <div style="padding-top:32px">
        <sc-for list="{{ steps }}" as="s" hint-placeholder-count="3">
          <div style="display:flex;gap:12px;align-items:flex-start;padding:12px 0;
                      border-bottom:1px solid var(--hairline)">
            <span style="flex:0 0 20px;padding-top:2px">
              <sc-if value="{{ s.done }}" hint-placeholder-val="{{ true }}">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--ink)"
                     stroke-width="1.5" aria-hidden="true"><use href="#i-tick"></use></svg>
              </sc-if>
            </span>
            <span class="t-body" style="flex:1;min-width:0;color:{{ s.color }}">{{ s.label }}</span>
          </div>
        </sc-for>
      </div>
    </div>
  </main>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {pct: 64}; }
  renderVals(){
    const pct = this.state.pct;
    const steps = [
      ['Reading the file', 30], ['Finding businesses and dates', 70],
      ['Matching businesses Grain already knows', 100]
    ].map(([label, at]) => ({
      label, done: pct >= at,
      color: pct >= at ? 'var(--ink)' : 'var(--secondary)'
    }));
    return { pct, file: 'liezel-cv.pdf', head: 'Reading your résumé', steps };
  }
}
</script>
</body>
</html>
