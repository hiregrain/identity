<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .cell{padding:16px 0;border-bottom:1px solid var(--hairline)}
    .cell > .t-micro{display:block;color:var(--secondary);padding-bottom:10px}
    .ico{display:flex;flex-wrap:wrap;gap:14px}
    .ico span{width:52px;text-align:center}
    .ico svg{stroke:var(--ink);stroke-width:1.5;fill:none;stroke-linecap:butt}
  </style>
</helmet>

<!-- The pieces, drawn once, so a screen never invents a second version of
     something the system already has. Everything here is in _chrome.part or
     _icons.part; nothing on this board is defined locally, which is the point:
     if it renders here it renders everywhere. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Components</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:20px">
      <p class="t-body" style="margin:0 0 18px;color:var(--secondary);text-wrap:pretty">
        Every piece below comes from the shared chassis. Nothing is defined on
        this board, so what renders here renders on every screen.</p>

      <div class="cell">
        <span class="t-micro">Provenance marks, the five states</span>
        <sc-for list="{{ marks }}" as="m" hint-placeholder-count="5">
          <div style="display:flex;gap:16px;align-items:center;padding:7px 0">
            <span class="prov" tabindex="0">
              <svg viewBox="0 0 34 16" width="34" height="16" fill="none" aria-hidden="true"
                   stroke="var(--ink)" stroke-width="1"><use href="{{ m.sw }}"></use></svg>
              <span class="tip t-meta">{{ m.tip }}</span>
            </span>
            <span class="t-meta" style="flex:1;min-width:0;text-wrap:pretty">{{ m.label }}</span>
          </div>
        </sc-for>
        <p class="t-meta" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">
          The baseline is the business, an arch is an attestation of the work,
          and the number of arches is the number of parties. They differ by shape
          rather than by density, because count is invisible at this size.</p>
      </div>

      <div class="cell">
        <span class="t-micro">Loading, and progress</span>
        <svg class="arc" viewBox="0 0 120 24" width="120" height="24" fill="none"
             stroke="var(--rule)" stroke-width="1.4" aria-label="Loading"><path d="@@ARC@@"/></svg>
        <p class="t-meta" style="margin:10px 0 16px;color:var(--secondary);text-wrap:pretty">
          One lobe period of the figure's own wave. Carries no percentage, because
          an arc that claims to know how long tells the lie a spinner tells.</p>
        <div class="band"><i style="width:64%"></i></div>
        <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
          The band is for the one case where the length is genuinely known.</p>
      </div>

      <div class="cell">
        <span class="t-micro">The state grammar as a control</span>
        <div style="display:flex;gap:18px;align-items:center">
          <button class="sw press" role="switch" aria-checked="true" aria-label="On"><i></i></button>
          <button class="sw press" role="switch" aria-checked="false" aria-label="Off"><i></i></button>
          <span class="t-meta" style="flex:1;min-width:0;color:var(--secondary);text-wrap:pretty">
            Ink filled to the right, or the rule alone. Not a platform switch (047).</span>
        </div>
      </div>

      <div class="cell">
        <span class="t-micro">Saying something happened</span>
        <div class="said">
          <svg width="16" height="16" viewBox="0 0 24 24" aria-hidden="true"><use href="#i-tick"></use></svg>
          <span class="t-body" style="flex:1;min-width:0;text-wrap:pretty">Sent to Cebu Pacific Cargo Services</span>
        </div>
        <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
          Inline, under the thing that changed. Never a floating toast, which
          steals focus and leaves before a slow reader has finished.</p>
      </div>

      <div class="cell">
        <span class="t-micro">A list that has not arrived</span>
        <sc-for list="{{ skels }}" as="s" hint-placeholder-count="3">
          <div class="skel"><span></span><span></span></div>
        </sc-for>
        <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
          Rules at the row rhythm, no shimmer. §5 forbids a moving gradient and
          the rhythm alone already reads as structure.</p>
      </div>

      <div class="cell">
        <span class="t-micro">Icons, §8's whole set</span>
        <div class="ico">
          <sc-for list="{{ icons }}" as="i" hint-placeholder-count="6">
            <span>
              <svg width="24" height="24" viewBox="0 0 24 24" aria-hidden="true"><use href="{{ i.id }}"></use></svg>
              <span class="t-meta" style="display:block;color:var(--secondary);font-size:10px;padding-top:4px">{{ i.name }}</span>
            </span>
          </sc-for>
        </div>
        <p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">
          24px grid, 1.5px hairline, square terminals, never filled. Close and the
          chevron live in the chassis as inline paths.</p>
      </div>

      <div class="cell" style="border-bottom:0">
        <span class="t-micro">Buttons, and the block that raises its voice</span>
        <div style="display:flex;flex-direction:column;gap:10px;padding-bottom:14px">
          <button class="btn-primary press">Primary</button>
          <button class="btn-secondary press">Secondary</button>
          <div style="text-align:center"><button class="btn-tertiary press">Tertiary</button></div>
        </div>
        <div class="warn">
          <p class="t-rec" style="margin:0;color:var(--paper)">Used sparingly</p>
          <p class="t-data" style="margin:6px 0 0;text-wrap:pretty">
            Ink inversion is for a consequence that cannot be undone, and for
            nothing else. Three screens carry it.</p>
        </div>
      </div>
    </div>
  </main>

</div>
@@ICONS@@
@@SWATCHES@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return {
      marks: [
        {sw:'#sw-self',   label:'Dotted rule: the worker recorded it, no attesting party',
         tip:'Recorded by the worker. No attesting party.'},
        {sw:'#sw-emp',    label:'Solid rule: a business confirmed dates and employment, nothing about the work',
         tip:'The business attested the dates and the employment. Nothing about the work.'},
        {sw:'#sw-peer',   label:'Arch, no rule: a person who was there, at a business Grain does not know',
         tip:'Attested by a coworker who was there. The business is not registered with Grain.'},
        {sw:'#sw-single', label:'Arch on a rule: one business',
         tip:'Attested by the business. No second party has agreed.'},
        {sw:'#sw-multi',  label:'Two arches on a rule: a business, and a second party agreeing',
         tip:'Attested by the business, and a second party agrees.'}
      ],
      skels: [1,2,3],
      icons: [['#i-back','back'],['#i-add','add'],['#i-camera','camera'],
              ['#i-link','link'],['#i-tick','tick'],['#i-alert','alert']]
              .map(([id,name]) => ({id, name}))
    };
  }
}
</script>
</body>
</html>
