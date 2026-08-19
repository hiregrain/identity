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
    .lrow{display:flex;gap:12px;align-items:flex-start;padding:8px 0}
    .lmark{flex:0 0 20px;margin-top:8px}
  </style>
</helmet>

<div class="{{ phase }}" style="width:360px;height:800px;position:relative;overflow:hidden;background:var(--paper)">
  <header style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 20px;border-bottom:1px solid var(--hairline);position:relative;z-index:3;
                 background:var(--paper)">
    <h1 class="t-serial" style="margin:0">Liezel Mendoza · Imprint</h1>
    <button class="press" aria-label="Close" style="width:44px;height:44px;display:flex;
            align-items:center;justify-content:flex-end">
      <svg width="18" height="18" viewBox="0 0 18 18" class="icon"><path d="M3 3 L15 15"/><path d="M15 3 L3 15"/></svg>
    </button>
  </header>

  <div class="stage" style="position:absolute;top:52px;left:0;right:0;height:298px"
       onPointerDown="{{ down }}" onPointerMove="{{ move }}" onPointerUp="{{ up }}">
    <svg viewBox="0 0 600 600" width="100%" height="100%" role="img" aria-label="{{ figureAlt }}">
      <g class="{{ selCls }}" transform="{{ view }}">
        <g fill="none" stroke="var(--ink)" stroke-width="1"
           transform="translate(42 42) scale(0.86)">@@CHAPTERS@@</g>
        <g fill="none" stroke="var(--ink)">
          <path d="{{ sectorA }}" stroke-width="0.8" opacity=".7"></path>
          <path d="{{ sectorB }}" stroke-width="0.8" opacity=".7"></path>
          <circle cx="300" cy="300" r="{{ selR0 }}" stroke-width="1.1"></circle>
          <circle cx="300" cy="300" r="{{ selR1 }}" stroke-width="1.1"></circle>
          <path d="{{ spoke }}" stroke-width="0.9" opacity=".7"></path>
          <sc-if value="{{ hasLevel }}" hint-placeholder-val="{{ true }}">
            <path d="{{ lobe }}" stroke-width="3"></path>
            <sc-for list="{{ levelMarks }}" as="m" hint-placeholder-count="7">
              <path d="{{ m.d }}" stroke-width="{{ m.w }}" opacity="{{ m.o }}"></path>
            </sc-for>
          </sc-if>
        </g>
      </g>
    </svg>
  </div>

  <!-- every axis the figure carries is also a plain control: keyboard operable,
       44px, and the only path for anyone the figure does not serve -->
  <div class="pick" role="group" aria-label="Chapter"
       style="position:absolute;top:350px;left:0;right:0;border-bottom:1px solid var(--hairline)">
    <sc-for list="{{ chapterPicks }}" as="c" hint-placeholder-count="5">
      <button class="t-data press" aria-pressed="{{ c.on }}" onClick="{{ c.go }}">{{ c.label }}</button>
    </sc-for>
  </div>
  <div class="pick" role="group" aria-label="Measure"
       style="position:absolute;top:396px;left:0;right:0;border-bottom:1px solid var(--hairline)">
    <sc-for list="{{ dimPicks }}" as="d" hint-placeholder-count="7">
      <button class="t-data press" aria-pressed="{{ d.on }}" onClick="{{ d.go }}">{{ d.label }}</button>
    </sc-for>
  </div>

  <!-- §9's scale rule, doing real work as the zoom control -->
  <div style="position:absolute;top:446px;left:20px;right:20px;display:flex;align-items:flex-end;gap:12px">
    <div class="zoom" role="group" aria-label="Zoom" style="flex:1">
      <sc-for list="{{ ticks }}" as="k" hint-placeholder-count="5">
        <button aria-label="{{ k.label }}" aria-pressed="{{ k.on }}" onClick="{{ k.go }}">
          <i style="height:{{ k.h }};background:{{ k.c }}"></i>
        </button>
      </sc-for>
    </div>
    <span class="t-data" style="color:var(--secondary);padding-bottom:2px">{{ zoomLabel }}</span>
  </div>

  <div style="position:absolute;top:502px;left:0;right:0;bottom:26px;padding:0 20px;overflow-y:auto">
    <h2 class="t-sec" style="margin:0 0 8px;border-bottom:1px solid var(--ink);padding-bottom:8px">{{ dimension }}</h2>
    <p class="t-body" style="margin:0 0 6px;color:var(--secondary);text-wrap:pretty">{{ definition }}</p>

    <div style="display:flex;justify-content:space-between;align-items:baseline;
                border-bottom:1px solid var(--hairline);padding-bottom:6px;margin-top:18px;gap:12px">
      <span class="t-micro" style="color:var(--secondary)">What was attested</span>
      <span class="t-data" style="text-align:right">{{ levelLabel }}</span>
    </div>

    <div aria-live="polite">
      <sc-for list="{{ ladder }}" as="l" hint-placeholder-count="7">
        <div class="lrow" style="border-bottom:1px solid {{ l.border }}">
          <span class="lmark" style="height:{{ l.h }};background:{{ l.markColor }}"></span>
          <span style="flex:1;min-width:0;font-weight:{{ l.weight }};font-size:{{ l.size }};
                       line-height:1.35;text-wrap:pretty">{{ l.text }}</span>
        </div>
      </sc-for>
    </div>

    <div style="margin-top:20px;border-top:1px solid var(--ink);padding-top:12px">
      <span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:8px">How this was set</span>
      <p class="t-body" style="margin:0 0 10px;text-wrap:pretty">{{ setBy }}</p>
      <p class="t-meta" style="margin:0;color:var(--secondary);text-wrap:pretty">{{ caveat }}</p>
      <div style="display:flex;justify-content:space-between;align-items:baseline;
                  border-top:1px solid var(--hairline);margin-top:12px;padding-top:10px;gap:12px">
        <span class="t-rec" style="flex:1;min-width:0">{{ party }}</span>
        <span class="t-data" style="color:var(--secondary);white-space:nowrap">{{ span }}</span>
      </div>
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
// The highlighted lobe and the level ladder are generated, not computed here.
// This file used to carry its own profile() and a hardcoded viewbox stroke that
// stopped matching imprint.py, so the lobe traced a different amplitude than the
// band it annotates. One copy of the geometry now, in imprint.py (decision 044).
const LOBE_DATA = @@LOBES@@;
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
const ZOOMS = [1, 1.5, 2, 3, 4];
// PLACEHOLDER caveat text: imprint/README.md §7.5 records the anchor set as
// unvalidated. It is stated on the surface rather than in a document (design/07 §2.2).
const CAVEAT = 'Grain wrote these seven descriptions. They have not been tested for whether two managers reading the same work pick the same one. Where parties disagree, the ledger takes the description at least two of them chose, and never averages them.';

class Component extends DCLogic {
  constructor(p){ super(p); this.state = {dim:3, ch:1, z:0, tx:0, ty:0, dragging:false, moved:0, phase:'opening'}; }
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
    const {x,y} = this.toModel(e);
    const r = Math.hypot(x,y);
    let t = Math.atan2(y,x); if(t<0) t += TAU;
    const dim = Math.round(t/(TAU/LOBES)) % LOBES;
    let ch = this.state.ch, best = Infinity;
    CHAPTERS.forEach((c,i) => {                       // clamp to the nearest
      const d = r < c.r0 ? c.r0 - r : (r > c.r1 ? r - c.r1 : 0);
      if(d < best){ best = d; ch = i; }
    });
    this.setState({dim, ch});
  }
  renderVals(){
    const {dim, ch, z, tx, ty} = this.state;
    const c = CHAPTERS[ch], D = DIMS[dim], k = ZOOMS[z];
    const t0 = dim*(TAU/LOBES);
    const P = (r, ang) => [300 + r*S*Math.cos(ang), 300 + r*S*Math.sin(ang)];
    const line = (r1, r2, ang) => { const [x1,y1]=P(r1,ang), [x2,y2]=P(r2,ang);
      return `M${x1.toFixed(1)} ${y1.toFixed(1)} L${x2.toFixed(1)} ${y2.toFixed(1)}`; };
    const cell = LOBE_DATA[ch][dim];
    const level = cell.level, lobe = cell.d, marks = cell.marks;

    return {
      down:(e)=>this.down(e), move:(e)=>this.move(e), up:(e)=>this.up(e),
      phase: this.state.phase, selCls: 'sel' + ch,
      figureAlt: `Imprint. Showing ${D.n} on ${c.party}.`,
      view: `translate(${tx.toFixed(1)} ${ty.toFixed(1)}) translate(${(300*(1-k)).toFixed(1)} ${(300*(1-k)).toFixed(1)}) scale(${k})`,
      sectorA: line(44, 300, t0 - Math.PI/LOBES),
      sectorB: line(44, 300, t0 + Math.PI/LOBES),
      spoke: line(44, 300, t0),
      selR0: (c.r0*S).toFixed(1), selR1: (c.r1*S).toFixed(1),
      hasLevel: level !== null, lobe, levelMarks: marks,
      dimension: D.n, definition: D.d,
      levelLabel: level === null ? 'Nothing attested' : (level === 0 ? 'Not part of this work' : 'One of seven'),
      ladder: D.a.map((text, lv) => ({
        text,
        weight: lv === level ? '600' : '400',
        size:   lv === level ? '15px' : '13px',
        h:      lv === level ? '2px' : '1px',
        markColor: level === null ? 'var(--hairline)' : (lv === level ? 'var(--ink)' : 'var(--rule)'),
        border: lv === level ? 'var(--ink)' : 'var(--hairline)'
      })),
      setBy: c.setBy, caveat: level === null ? '' : CAVEAT, party: c.party, span: c.span,
      chapterPicks: CHAPTERS.map((x,i) => ({label:x.short, on: i===ch ? 'true':'false',
        go: () => this.setState({ch:i})})),
      dimPicks: DIMS.map((x,i) => ({label:x.s, on: i===dim ? 'true':'false',
        go: () => this.setState({dim:i})})),
      ticks: ZOOMS.map((v,i) => ({label: v + ' times', on: i===z ? 'true':'false',
        h: i===z ? '20px' : '10px', c: i<=z ? 'var(--ink)' : 'var(--rule)',
        go: () => this.setState({z:i, tx: i===0 ? 0 : this.state.tx, ty: i===0 ? 0 : this.state.ty})})),
      zoomLabel: k + '×'
    };
  }
}
</script>
</body>
</html>
