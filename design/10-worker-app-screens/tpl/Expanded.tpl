<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .stage{touch-action:none;cursor:grab;overflow:hidden}
    .stage:active{cursor:grabbing}
    /* the resting state is VISIBLE. The scribe is added on open and removed when
       it finishes, so an environment that suppresses animation still shows the
       figure (design/07 §5). */
    .opening .ch path, .opening .ch circle{stroke-dasharray:1;stroke-dashoffset:1;
      animation:scribe 760ms cubic-bezier(0.2,0,0,1) forwards}
    .opening .ch1 path,.opening .ch1 circle{animation-delay:60ms}
    .opening .ch2 path,.opening .ch2 circle{animation-delay:120ms}
    .opening .ch3 path,.opening .ch3 circle{animation-delay:180ms}
    .opening .ch4 path,.opening .ch4 circle{animation-delay:240ms}
    @keyframes scribe{to{stroke-dashoffset:0}}
    /* unselected chapters recede to 3.4:1, not to invisibility. Selection is not
       provenance, so recession here does not collide with law 8. */
    .ch{transition:opacity 220ms cubic-bezier(0.2,0,0,1)}
    .sel0 .ch,.sel1 .ch,.sel2 .ch,.sel3 .ch,.sel4 .ch{opacity:.3}
    .sel0 .ch0,.sel1 .ch1,.sel2 .ch2,.sel3 .ch3,.sel4 .ch4{opacity:1}
    /* §7 press physics, on this screen only (decision 050). The figure yields
       under the thumb where inspecting it is the task; on the record it is a
       plate you open, and a plate that squirms is a worse plate. A band whose
       chapter is attested does NOT yield: §7 makes rigidity the expression of
       permanence. */
    .stage{transition:transform 120ms cubic-bezier(0.2,0,0,1)}
    .stage.give:active{transform:scale(0.994)}
    .lrow{display:flex;gap:14px;align-items:flex-start;padding:10px 0;
          border-bottom:1px solid var(--hairline)}
    .lmark{flex:0 0 34px;margin-top:4px}
  </style>
</helmet>

<!-- The reveal class lives on the stage, never on the root: a template hole in the
     ROOT element's class attribute stops the artboard mounting at all, which is
     why this screen rendered blank in the canvas from the day it was drawn. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 20px;border-bottom:1px solid var(--hairline);position:relative;z-index:3;
                 background:var(--paper)">
    <h1 class="t-serial" style="margin:0">Liezel Mendoza · Imprint</h1>
    <button class="press" aria-label="Close" style="width:44px;height:44px;display:flex;
            align-items:center;justify-content:flex-end">
      <svg width="18" height="18" viewBox="0 0 18 18" class="icon"><path d="M3 3 L15 15"/><path d="M15 3 L3 15"/></svg>
    </button>
  </header>

  <!-- Decision 054 emptied this screen of its old subject: it existed to name
       which lobe was which measure, and no measure renders. What it does now is
       the thing every reader wanted and none could do, which is read the figure.
       Touching a ring selects its chapter. -->
  <div class="stage {{ phase }} {{ give }}" style="position:absolute;top:52px;left:0;right:0;height:282px"
       onPointerDown="{{ down }}" onPointerMove="{{ move }}" onPointerUp="{{ up }}">
    <svg viewBox="0 0 600 600" width="100%" height="100%" role="img" aria-label="{{ figureAlt }}"
         style="display:block">
      <g class="{{ selCls }}" transform="{{ view }}">
        <g transform="translate(42 42) scale(0.86)">@@CHAPTERS@@</g>
        <!-- The selected chapter's band, drawn as two boundary circles. Nothing
             else is drawn over the figure: spokes and sector lines read as
             damage across the engraving. -->
        <g fill="none" stroke="var(--ink)" stroke-width="1.2">
          <circle cx="300" cy="300" r="{{ selR0 }}"></circle>
          <circle cx="300" cy="300" r="{{ selR1 }}"></circle>
        </g>
      </g>
    </svg>
  </div>

  <p class="t-meta" style="position:absolute;top:336px;left:0;right:0;margin:0;
            text-align:center;color:var(--secondary)">Touch a ring to read that chapter</p>

  <!-- A ring is 10 to 25px of stroke, which is not a touch target, so the name
       is also a control, and it is the path a keyboard and a screen reader take. -->
  <div style="position:absolute;top:358px;left:0;right:0;min-height:60px;display:flex;
              align-items:center;border-bottom:1px solid var(--ink)">
    <button class="press" aria-label="Previous chapter" onClick="{{ prevCh }}"
            style="width:44px;height:44px;display:flex;align-items:center;justify-content:center">
      <svg width="18" height="18" viewBox="0 0 20 20" fill="none" stroke="var(--ink)"
           stroke-width="1.4" stroke-linecap="round"><path d="M12 4 L6 10 L12 16"/></svg>
    </button>
    <span style="flex:1;min-width:0;text-align:center;padding:0 4px">
      <span class="t-sec" style="display:block;text-wrap:pretty;line-height:1.2">{{ party }}</span>
      <span class="t-data" style="display:block;color:var(--secondary);padding-top:2px">{{ span }}</span>
    </span>
    <button class="press" aria-label="Next chapter" onClick="{{ nextCh }}"
            style="width:44px;height:44px;display:flex;align-items:center;justify-content:center">
      <svg width="18" height="18" viewBox="0 0 20 20" fill="none" stroke="var(--ink)"
           stroke-width="1.4" stroke-linecap="round"><path d="M8 4 L14 10 L8 16"/></svg>
    </button>
  </div>

  <div class="dissolve" style="position:absolute;top:420px;left:0;right:0;bottom:0;overflow-y:auto;padding:0 20px">
    <div style="padding:16px 0 4px">
      <span class="t-micro" style="display:block;color:var(--secondary)">This ring</span>
      <p class="t-body" style="margin:8px 0 0;text-wrap:pretty">{{ prov }}</p>
      <p class="t-meta" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">{{ standing }}</p>
    </div>

    <!-- What the figure encodes, said once, on the only screen big enough to
         say it. Every persona called the imprint the best thing in the product
         and none of them could read it. Each line is a rule the ledger applies
         the same way to every record. -->
    <div style="padding-top:24px">
      <div class="sechead"><h2 class="t-sec" style="margin:0">What the figure says</h2></div>
      <div class="sinerule">@@SINERULE@@</div>
      <sc-for list="{{ legend }}" as="l" hint-placeholder-count="5">
        <div class="lrow">
          <span class="lmark">
            <sc-if value="{{ l.sw }}" hint-placeholder-val="{{ true }}">
              <svg viewBox="0 0 34 16" width="34" height="16" fill="none" aria-hidden="true"
                   stroke="var(--ink)" stroke-width="1"><use href="{{ l.sw }}"></use></svg>
            </sc-if>
          </span>
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block;text-wrap:pretty">{{ l.head }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">{{ l.body }}</span>
          </span>
        </div>
      </sc-for>
      <p class="t-meta" style="margin:14px 0 0;color:var(--secondary);text-wrap:pretty">
        The wave itself is the same on every chapter of every record. It is how
        the figure is drawn, not something it is telling you.</p>
    </div>
    <div style="height:28px"></div>
  </div>
</div>

@@SWATCHES@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// The expanded imprint, rebuilt under decision 054. It used to name which lobe
// carried which of the seven measures; nothing derived from the measures renders
// now, so what it does is let a person read the figure they are looking at.
// Touching a ring selects its chapter and the detail below follows.
const S = 0.86;
const CHAPTERS = [
  {r0:58.00,  r1:95.35,  party:'Bataan Poultry Processing',   span:'Sep 2017 to Mar 2019', sw:'#sw-self',
   attested:false,
   prov:'Recorded by Liezel Mendoza. No attesting party.',
   standing:'Nobody who was there has attested this chapter, so it is her own account of it. Its ring is drawn dotted, which is how the figure says that.'},
  {r0:95.35,  r1:145.14, party:'Sunrise Foods Manufacturing', span:'Mar 2019 to Sep 2021', sw:'#sw-multi',
   attested:true,
   prov:'Attested by Sunrise Foods Manufacturing on 14 October 2021, and a second party agrees.',
   standing:'Two parties attested this independently, which is the densest weave the figure draws.'},
  {r0:145.14, r1:194.93, party:'R. Santos Dry Goods',         span:'Sep 2020 to Mar 2023', sw:'#sw-peer',
   attested:true,
   prov:'Attested by a coworker who was there, on 2 April 2023. The business is not registered with Grain.',
   standing:'A person who was present attested this. The business itself has not, and it can, which is what the outstanding item on the record is for.'},
  {r0:194.93, r1:240.58, party:'Metro Manila Logistics',      span:'Mar 2023 to Jan 2025', sw:'#sw-single',
   attested:true,
   prov:'Attested by Metro Manila Logistics on 20 January 2025. No second party has agreed.',
   standing:'One party attested this, so it stands at their reading. The weave is lighter than a chapter two parties agree on.'},
  {r0:240.58, r1:280.00, party:'Cebu Pacific Cargo Services', span:'Jan 2025 to present', sw:'#sw-emp',
   attested:false,
   prov:'Cebu Pacific Cargo Services attested the dates and the employment on 20 January 2026. Nothing about the work.',
   standing:'Dates and employment only, so the ring is drawn plain and solid. That plainness is the statement.'}
];
const LEGEND = [
  {head:'One ring is one chapter, and the earliest is innermost',
   body:'Reading outward from the middle is reading forward in time, which is the same order as the list on your record.'},
  {head:'A ring is as wide as the time it covers',
   body:'A long engagement takes a wide band. Two chapters that overlap share the width of the months they share.'},
  {sw:'#sw-self',   head:'Dotted: nobody has attested it',
   body:'Your own account of the work, drawn as your own account of the work.'},
  {sw:'#sw-emp',    head:'Plain and solid: dates and employment only',
   body:'A business confirmed you were there and when. It said nothing about the work.'},
  {sw:'#sw-peer',   head:'Threaded: a party attested it, and the weave says how many',
   body:'One coworker is the lightest weave, one business is heavier, and two parties who agree independently is the densest.'}
];
const ZOOMS = [1, 2.5];

class Component extends DCLogic {
  constructor(p){ super(p); this.state = {ch:1, z:0, tx:0, ty:0, dragging:false, moved:0, phase:'opening'}; }
  componentDidMount(){ this._t = setTimeout(() => this.setState({phase:''}), 1100); }
  componentWillUnmount(){ clearTimeout(this._t); }

  toModel(e){
    const box = e.currentTarget.getBoundingClientRect();
    const side = Math.min(box.width, box.height);
    const ox = box.left + (box.width-side)/2, oy = box.top + (box.height-side)/2;
    const sx = ((e.clientX-ox)/side)*600, sy = ((e.clientY-oy)/side)*600;
    const k = ZOOMS[this.state.z];
    return {x: ((sx - this.state.tx - 300*(1-k))/k - 300)/S,
            y: ((sy - this.state.ty - 300*(1-k))/k - 300)/S};
  }
  down(e){
    if(e.currentTarget.setPointerCapture) e.currentTarget.setPointerCapture(e.pointerId);
    this.setState({dragging:true, moved:0, px:e.clientX, py:e.clientY});
  }
  move(e){
    if(!this.state.dragging) return;
    const dx = e.clientX-this.state.px, dy = e.clientY-this.state.py;
    const box = e.currentTarget.getBoundingClientRect();
    const k = 600/Math.min(box.width, box.height);
    this.setState({tx:this.state.tx+dx*k, ty:this.state.ty+dy*k, px:e.clientX, py:e.clientY,
                   moved:this.state.moved+Math.abs(dx)+Math.abs(dy)});
  }
  up(e){
    const wasDrag = this.state.moved > 6;
    this.setState({dragging:false});
    if(wasDrag) return;
    const now = e.timeStamp;
    if(this._lastTap && now - this._lastTap < 320){        // double-tap zooms
      this._lastTap = 0;
      const z = this.state.z ? 0 : 1;
      this.setState({z, tx: z ? this.state.tx : 0, ty: z ? this.state.ty : 0});
      return;
    }
    this._lastTap = now;
    const {x,y} = this.toModel(e);
    const r = Math.hypot(x,y);
    let ch = this.state.ch, best = Infinity;
    CHAPTERS.forEach((c,i) => {                       // clamp to the nearest
      const d = r < c.r0 ? c.r0 - r : (r > c.r1 ? r - c.r1 : 0);
      if(d < best){ best = d; ch = i; }
    });
    this.setState({ch});
  }
  renderVals(){
    const {ch, z, tx, ty} = this.state;
    const c = CHAPTERS[ch], k = ZOOMS[z];
    return {
      down:(e)=>this.down(e), move:(e)=>this.move(e), up:(e)=>this.up(e),
      phase: this.state.phase, selCls: 'sel' + ch,
      figureAlt: `Liezel Mendoza's imprint, five rings. The ring for ${c.party} is selected.`,
      view: `translate(${tx.toFixed(1)} ${ty.toFixed(1)}) translate(${(300*(1-k)).toFixed(1)} ${(300*(1-k)).toFixed(1)}) scale(${k})`,
      selR0: (c.r0*S).toFixed(1), selR1: (c.r1*S).toFixed(1),
      // Attested chapters are rigid. Unattested ones yield, which is §7's rule:
      // the record gives where nothing holds it.
      give: c.attested ? '' : 'give',
      party: c.party, span: c.span, prov: c.prov, standing: c.standing,
      prevCh: () => this.setState({ch: (ch + CHAPTERS.length - 1) % CHAPTERS.length}),
      nextCh: () => this.setState({ch: (ch + 1) % CHAPTERS.length}),
      legend: LEGEND
    };
  }
}
</script>
</body>
</html>
