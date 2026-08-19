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
    .sel0 .ch,.sel1 .ch,.sel2 .ch,.sel3 .ch,.sel4 .ch{opacity:.55}
    .sel0 .ch0,.sel1 .ch1,.sel2 .ch2,.sel3 .ch3,.sel4 .ch4{opacity:1}
    .pick{display:flex;gap:8px;overflow-x:auto;padding:0 20px;scrollbar-width:none}
    .pick::-webkit-scrollbar{height:0}
    .pick button{min-height:44px;padding:12px 12px;white-space:nowrap;
                 border-bottom:2px solid transparent}
    .pick button[aria-pressed="true"]{border-bottom-color:var(--ink)}
    .zoom{display:flex;height:44px;align-items:flex-end}
    .zoom button{flex:1;height:44px;display:flex;align-items:flex-end;justify-content:center}
    .zoom i{display:block;width:1px;background:var(--rule)}
    .rung{display:inline-flex;align-items:flex-end;gap:2px;height:14px;flex:none}
    .rung i{display:block;width:3px}
    .lrow{display:flex;gap:12px;align-items:flex-start;padding:8px 0}
    .lmark{flex:0 0 20px;margin-top:8px}
  </style>
</helmet>

<!-- The reveal class lives on the stage, never on the root: a template hole in the
     ROOT element's class attribute stops the artboard mounting at all, which is
     why this screen rendered blank in the canvas from the day it was drawn. -->
<div style="width:360px;height:800px;position:relative;overflow:hidden;background:var(--paper)">
  <header style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 20px;border-bottom:1px solid var(--hairline);position:relative;z-index:3;
                 background:var(--paper)">
    <h1 class="t-serial" style="margin:0">Liezel Mendoza · Imprint</h1>
    <button class="press" aria-label="Close" style="width:44px;height:44px;display:flex;
            align-items:center;justify-content:flex-end">
      <svg width="18" height="18" viewBox="0 0 18 18" class="icon"><path d="M3 3 L15 15"/><path d="M15 3 L3 15"/></svg>
    </button>
  </header>

  <div class="stage {{ phase }}" style="position:absolute;top:52px;left:0;right:0;height:298px"
       onPointerDown="{{ down }}" onPointerMove="{{ move }}" onPointerUp="{{ up }}">
    <svg viewBox="0 0 600 600" width="100%" height="100%" role="img" aria-label="{{ figureAlt }}">
      <g class="{{ selCls }}" transform="{{ view }}">
        <g fill="none" stroke="var(--ink)" stroke-width="1"
           transform="translate(42 42) scale(0.86)">@@CHAPTERS@@</g>
        <!-- The chapter's band, then every measure's axis and the depth attested
             on it. All seven are named permanently: this is what closes
             imprint/README.md 7.1, and it is why no selector is needed. -->
        <g fill="none" stroke="var(--ink)">
          <circle cx="300" cy="300" r="{{ selR0 }}" stroke-width="1.1"></circle>
          <circle cx="300" cy="300" r="{{ selR1 }}" stroke-width="1.1"></circle>
          <sc-for list="{{ axes }}" as="ax" hint-placeholder-count="7">
            <path d="{{ ax.axis }}" stroke-width="1.4" opacity=".4"></path>
            <path d="{{ ax.notch }}" stroke-width="4"></path>
          </sc-for>
        </g>

      </g>
    </svg>
  </div>

  <!-- The chapter. Touching its ring selects it, but a ring is 10-25px of stroke
       and that is not a touch target, so the name is also a control. -->
  <div style="position:absolute;top:350px;left:0;right:0;height:56px;display:flex;
              align-items:center;border-bottom:1px solid var(--ink)">
    <button class="press" aria-label="Previous chapter" onClick="{{ prevCh }}"
            style="width:44px;height:44px;display:flex;align-items:center;justify-content:center">
      <svg width="16" height="16" viewBox="0 0 16 16" class="icon"><path d="M10 3 L5 8 L10 13"/></svg>
    </button>
    <span style="flex:1;min-width:0;text-align:center">
      <span class="t-rec" style="display:block">{{ party }}</span>
      <span class="t-meta" style="display:block;color:var(--secondary)">{{ span }}</span>
    </span>
    <button class="press" aria-label="Next chapter" onClick="{{ nextCh }}"
            style="width:44px;height:44px;display:flex;align-items:center;justify-content:center">
      <svg width="16" height="16" viewBox="0 0 16 16" class="icon"><path d="M6 3 L11 8 L6 13"/></svg>
    </button>
  </div>

  <!-- Reading matter, not a control. Every measure says what it means, what was
       attested, and where that sits on its scale — drawn, because design/07 2.2
       records four reviewers reading an ordinal as a rating of a person. -->
  <div style="position:absolute;top:406px;left:0;right:0;bottom:26px;overflow-y:auto">
    <div style="padding:14px 20px 10px">
      <span class="t-micro" style="display:block;color:var(--secondary)">{{ attestHead }}</span>
      <p class="t-meta" style="margin:6px 0 0;color:var(--secondary);text-wrap:pretty">
        The seven spokes on the figure run clockwise from the right, in the order
        below. The mark on each spoke is the depth attested on that measure.</p>
    </div>
    <sc-for list="{{ measures }}" as="mm" hint-placeholder-count="7">
      <div style="padding:12px 20px 14px;border-bottom:1px solid var(--hairline)">
        <div style="display:flex;align-items:baseline;justify-content:space-between;gap:12px">
          <span style="font-weight:600;font-size:15px;line-height:1.3">{{ mm.name }}</span>
          <span class="rung" aria-hidden="true">
            <sc-for list="{{ mm.scale }}" as="st" hint-placeholder-count="7">
              <i style="height:{{ st.h }};background:{{ st.c }}"></i>
            </sc-for>
          </span>
        </div>
        <p class="t-meta" style="margin:3px 0 0;color:var(--secondary);text-wrap:pretty">{{ mm.definition }}</p>
        <p class="t-body" style="margin:7px 0 0;color:{{ mm.valueColor }};text-wrap:pretty">{{ mm.value }}</p>
      </div>
    </sc-for>
    <div style="padding:16px 20px 0">
      <span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:6px">How this was set</span>
      <p class="t-body" style="margin:0 0 8px;text-wrap:pretty">{{ setBy }}</p>
      <p class="t-meta" style="margin:0;color:var(--secondary);text-wrap:pretty">{{ caveat }}</p>
    </div>
    <div style="height:24px"></div>
  </div>

  <footer style="position:absolute;left:0;right:0;bottom:0;height:26px;display:flex;
                 align-items:center;justify-content:space-between;padding:0 20px;
                 border-top:1px solid var(--hairline);background:var(--paper);z-index:2">
    <span class="t-micro" style="color:var(--secondary)">Grain</span>
    <span class="t-micro" style="color:var(--secondary)">Seven measures, always in the same place</span>
  </footer>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// The expanded imprint. Closes imprint/README.md §7.1 — nothing marked which
// lobe was which measure. Labels are revealed by touch, never printed on the
// figure. Definitions are verbatim from imprint/README.md §3.
// No ordinal is shown: design/07 §2.2 records four independent reviewers reading
// "Step N of 6" as a rating of a person. The anchor sentence is the level.
const TAU = Math.PI*2, LOBES = 7, S = 0.86;
// Axis labels and attained notches, generated rather than computed here. This
// file used to carry its own profile() and a hardcoded viewbox stroke that no
// longer matched imprint.py, so the annotation sat off the band it annotated.
// One copy of the geometry now, in imprint.py (decision 044).
const AXES = @@AXES@@;
const DIMS = [
 {n:'Discretion', s:'Discretion', d:'How much of the what-and-how you decided, rather than received.',
  a:['Not part of this work','Followed instructions for each task','Chose the order of the work',
     'Chose how, within a set what','Chose how, and part of the what','Set what the work was, within a remit',
     'Set the remit']},
 {n:'Direction of Others', s:'Directing others', d:'How many people’s work you were answerable for.',
  a:['Not part of this work','Answerable for your own work only','Showed new people the work',
     'Answerable for a small group','Answerable for a shift or a crew','Answerable for a standing team',
     'Answerable for people who direct others']},
 {n:'Consequence Held', s:'Consequence', d:'What happens if you get it wrong, and who catches it.',
  a:['Not part of this work','Mistakes were caught before they mattered','Mistakes cost rework',
     'Mistakes cost time or schedule','Mistakes cost money or stock','Mistakes reached the customer',
     'Last check before something irreversible']},
 {n:'Counterparty Exposure', s:'Outside dealings',
  d:'Direct dealings with people outside your own team: customers, suppliers, inspectors, other firms.',
  a:['Not part of this work','No dealings outside the team','Occasional contact, to a script',
     'Regular contact, on your own judgement','Handled disputes and exceptions','Held the relationship',
     'Committed the business to it']},
 {n:'Method Authority', s:'Method', d:'Who decides how the work is correctly done, and who signs off.',
  a:['Not part of this work','Followed the method given','Raised problems with the method',
     'Adapted the method in practice','Decided how the work was done correctly','Set the method for others',
     'Signed off on how others worked']},
 {n:'Resource and Financial', s:'Resource', d:'What resource was committed, and who answered for it.',
  a:['Not part of this work','Committed no resource','Accountable for tools in hand',
     'Accountable for materials and stock','Accountable for a budget line','Answered for the spend',
     'Decided what was spent']},
 {n:'Systems and Tooling', s:'Systems', d:'Responsibility for the systems the work runs on.',
  a:['Not part of this work','Used the systems as given','Kept a system running day to day',
     'Fixed a system others depend on','Responsible for a system others depend on','Changed how the systems work',
     'Owned the systems the work runs on']},
];
const CHAPTERS = [
  {r0:58.00,  r1:95.35,  party:'Bataan Poultry Processing', short:'Bataan Poultry', span:'Sep 2017 to Mar 2019',
   levels:null, setBy:'Nobody has confirmed this chapter, so there is nothing attested about the work. It is your own account of it.'},
  {r0:95.35,  r1:145.14, party:'Sunrise Foods Manufacturing', short:'Sunrise Foods', span:'Mar 2019 to Sep 2021',
   levels:[3,3,3,1,3,2,2],
   setBy:'Sunrise Foods signed this on 14 October 2021, and a second party agreed.'},
  {r0:145.14, r1:194.93, party:'R. Santos Dry Goods', short:'R. Santos', span:'Sep 2020 to Mar 2023',
   levels:[2,0,2,4,1,1,2],
   setBy:'A coworker signed this on 2 April 2023. It stands at their reading, and nobody else has agreed.'},
  {r0:194.93, r1:240.58, party:'Metro Manila Logistics', short:'Metro Manila', span:'Mar 2023 to Jan 2025',
   levels:[4,3,4,3,3,3,4],
   setBy:'Metro Manila Logistics signed this on 20 January 2025. Nobody else has agreed yet.'},
  {r0:240.58, r1:280.00, party:'Cebu Pacific Cargo Services', short:'Cebu Pacific', span:'Jan 2025 to present',
   levels:null, setBy:'They confirmed the dates and the job, but nothing about the work, so there is nothing attested here yet.'},
];
const ZOOMS = [1, 2.5];   // double-tap the figure. The old five-tick scale rule
                         // was unlabelled, unevenly spaced and under the 44px floor
// PLACEHOLDER caveat text: imprint/README.md §7.5 records the anchor set as
// unvalidated. It is stated on the surface rather than in a document (design/07 §2.2).
const CAVEAT = 'Grain wrote these seven descriptions. They have not been tested for whether two managers reading the same work pick the same one. Where parties disagree, the ledger takes the description at least two of them chose, and never averages them.';

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
      figureAlt: `Imprint. ${c.party}, with every measure named and its attested depth marked.`,
      view: `translate(${tx.toFixed(1)} ${ty.toFixed(1)}) translate(${(300*(1-k)).toFixed(1)} ${(300*(1-k)).toFixed(1)}) scale(${k})`,
      selR0: (c.r0*S).toFixed(1), selR1: (c.r1*S).toFixed(1),
      axes: AXES[ch],
      setBy: c.setBy, caveat: c.levels ? CAVEAT : '', party: c.party, span: c.span,
      prevCh: () => this.setState({ch: (ch + CHAPTERS.length - 1) % CHAPTERS.length}),
      nextCh: () => this.setState({ch: (ch + 1) % CHAPTERS.length}),
      attestHead: c.levels
        ? 'What ' + c.short + ' attested, on the seven measures'
        : 'Nothing about the work was attested on this chapter',
      // Every measure, every time. The value is the attested anchor in the
      // worker's own words, and its position is seven drawn rungs — never an
      // ordinal, which design/07 §2.2 records four reviewers reading as a rating
      // of a person.
      measures: DIMS.map((x, i) => {
        const lv = c.levels ? c.levels[i] : null;
        return {
          name: x.n,
          definition: x.d,
          value: lv === null ? 'Nothing attested here.' : x.a[lv],
          valueColor: lv === null ? 'var(--secondary)' : 'var(--ink)',
          scale: x.a.map((_, r) => ({
            h: (4 + r*1.6).toFixed(0) + 'px',
            c: lv === null ? 'var(--hairline)'
                           : (r < lv ? 'var(--rule)' : (r === lv ? 'var(--ink)' : 'var(--hairline)'))
          }))
        };
      })
    };
  }
}
</script>
</body>
</html>
