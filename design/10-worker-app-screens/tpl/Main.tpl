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
    /* the figure spans the plate's full width so its centre is the screen's
       centre; the text column keeps its asymmetric margin, which is fine for
       ragged text and wrong for a circle */
    /* No bleed. `main` reserves a 40px right gutter for the section index; the
       figure used to take 20px of it back, so the index's rotated labels and
       ticks were drawn on top of the imprint. */
    /* Fluid, but capped: the root is fluid now, and an uncapped figure grows
       with the display until it swallows the screen. 320 is the size it was
       drawn and budgeted at. */
    .fig{display:block;width:100%;max-width:320px;margin-inline:auto}
    .idx-tick{height:1px;background:var(--rule);transition:width 180ms cubic-bezier(0.2,0,0,1)}
    .sheet{position:absolute;left:0;right:0;bottom:0;background:var(--paper);
           border-top:1px solid var(--ink);padding:20px 20px 24px}
    .scrim{position:absolute;inset:0;background:rgba(230,230,228,.86)}
    /* Disclosure is a line quality on the plate's own header band (law 4).
       Grants are whole-record, so this is a property of the record and never of
       a chapter — a per-chapter mark would be identical on every row. */
    .disclosed{border-bottom-width:1px}
    .disclosed::after{content:'';position:absolute;left:0;right:0;bottom:-4px;
                      height:1px;background:var(--rule)}
  </style>
</helmet>

<!-- Fluid in both axes: the record fills whatever safe area it is given. A fixed
     728 left the plate's bottom registration corners hanging 50pt above the
     screen on iOS, which reads as a stray corner rather than the plate's edge.
     min-height carries the standalone case, where height:100% has no sized
     ancestor to resolve against and would collapse to zero. -->
<div style="width:100%;height:100%;min-height:728px;position:relative;overflow:hidden;
            background:var(--paper)">
  <!-- §9 the plate. It marks the record; no other surface carries it. -->
  <div class="plate">
    <div class="reg" style="top:7px;left:7px;border-top-width:1px;border-left-width:1px"></div>
    <div class="reg" style="top:7px;right:7px;border-top-width:1px;border-right-width:1px"></div>
    <div class="reg" style="bottom:7px;left:7px;border-bottom-width:1px;border-left-width:1px"></div>
    <div class="reg" style="bottom:7px;right:7px;border-bottom-width:1px;border-right-width:1px"></div>
  </div>

  <header class="{{ headerCls }}"
          style="height:52px;display:flex;align-items:center;justify-content:space-between;
                 padding:0 20px;border-bottom:1px solid var(--ink);position:relative;z-index:3;
                 background:var(--paper)">
    <!-- The lockup: mark plus the GRAIN wordmark (§4a), generated so the mark
         swaps to its drawn reduction rather than scaling a master. -->
    <svg viewBox="0 0 160 26" width="160" height="26" role="img" aria-label="Grain">@@LOCKUP@@</svg>
    <span style="display:flex;align-items:center">
      <!-- Sharing is a destination now, not a section buried under the record
           (decision 045). This is its entry point. -->
      <!-- Sharing is where custody is exercised, so it carries more than the menu
           does — but by ink and by saying a number out loud, not by a box. §8
           deletes containers; a border here would be the one thing the system
           forbids, put in to buy prominence it can get honestly. -->
      <button class="press" aria-label="{{ shareLabel }}" onClick="{{ openSharing }}"
              style="min-height:44px;display:flex;align-items:center;gap:7px;
                     padding:0 10px;margin-right:2px">
        <svg width="19" height="19" viewBox="0 0 20 20" fill="none" stroke="var(--ink)"
             stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M10 13 L10 3"/><path d="M6.5 6.5 L10 3 L13.5 6.5"/>
          <path d="M4 11 L4 17 L16 17 L16 11"/>
        </svg>
        <span class="t-data" style="font-size:13px">{{ shareCount }}</span>
      </button>
      <!-- An account glyph, not a hamburger. The hamburger is the universal sign
           for a menu of places to go, and this opens one screen — a bar carrying
           no navigation read as a navigation bar that did nothing (048). -->
      <button class="press" aria-label="Account and settings" onClick="{{ openSettings }}"
              style="width:44px;height:44px;display:flex;align-items:center;justify-content:flex-end">
        <svg width="19" height="19" viewBox="0 0 20 20" fill="none" stroke="var(--ink)"
             stroke-width="1.2" stroke-linecap="round">
          <circle cx="10" cy="7" r="3.1"/>
          <path d="M3.8 17 C3.8 13.4 6.6 11.6 10 11.6 C13.4 11.6 16.2 13.4 16.2 17"/>
        </svg>
      </button>
    </span>
  </header>

  <main id="scroll" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;
                           padding:0 20px 56px 20px;scroll-behavior:smooth">

    <!-- ===== identity and imprint, composed as one hero (029 §B1) ========= -->
    <section id="sec-0" style="padding-top:20px">
      <div style="display:flex;gap:12px;align-items:flex-start;padding-bottom:20px">
        <div style="flex:0 0 60px;height:76px;border:1px solid var(--rule);position:relative;overflow:hidden">
          <svg viewBox="0 0 76 96" width="60" height="76" preserveAspectRatio="none" fill="none"
               stroke="var(--hairline)" stroke-width=".6" role="img" aria-label="Portrait placeholder">@@GRATICULE_SM@@</svg>
        </div>
        <div style="flex:1;min-width:0">
          <h1 class="t-title" style="margin:0">Liezel Mendoza</h1>
          <p class="t-data" style="margin:6px 0 0;color:var(--secondary)">Philippines · Identity verified</p>
        </div>
      </div>

      <!-- The figure says it opens by carrying a corner affordance, not by a
           sentence underneath it. 44px target, offset so it never sits on the
           drawing. -->
      <div style="position:relative;max-width:320px;margin-inline:auto">
      <button class="press" aria-label="Open your imprint at full size"
              onClick="{{ openImprint }}"
              style="position:absolute;top:0;right:0;width:44px;height:44px;display:flex;
                     align-items:center;justify-content:center;z-index:2">
        <svg width="17" height="17" viewBox="0 0 20 20" fill="none" stroke="var(--ink)"
             stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 3 L17 3 L17 8"/><path d="M8 17 L3 17 L3 12"/>
          <path d="M17 3 L11.5 8.5"/><path d="M3 17 L8.5 11.5"/>
        </svg>
      </button>
      <svg class="fig" viewBox="0 0 600 600" role="img" aria-label="{{ figureAlt }}">
        @@WORKING@@
        <g fill="none" stroke="var(--ink)">
          <sc-if value="{{ selBand }}" hint-placeholder-val="{{ true }}">
            <circle cx="300" cy="300" r="{{ selR0 }}" stroke-width="1.2"></circle>
            <circle cx="300" cy="300" r="{{ selR1 }}" stroke-width="1.2"></circle>
          </sc-if>
        </g>
        <g fill="none" stroke="transparent" style="pointer-events:stroke;cursor:pointer">
          <sc-for list="{{ bands }}" as="b" hint-placeholder-count="5">
            <circle cx="300" cy="300" r="{{ b.mid }}" stroke-width="{{ b.w }}" onClick="{{ b.pick }}"></circle>
          </sc-for>
        </g>
      </svg>
      </div>

      <div style="display:flex;justify-content:space-between;align-items:baseline;gap:12px;
                  min-height:22px;padding-top:8px">
        <span class="t-data" aria-live="polite" style="flex:1;min-width:0">{{ readout }}</span>
      </div>
    </section>

    <!-- ===== outstanding verification ===================================== -->
    <section id="sec-1" style="padding-top:32px">
      <div class="sechead">
        <h2 class="t-sec" style="margin:0">Outstanding verification</h2>
        <span class="t-data" style="color:var(--secondary)">3</span>
      </div>
      <sc-for list="{{ outstanding }}" as="o" hint-placeholder-count="3">
        <button class="row press" onClick="{{ o.open }}">
          <span class="gutter">
            <svg viewBox="0 0 34 16" width="34" height="16" fill="none"
                 stroke="var(--ink)" stroke-width="1"><use href="{{ o.sw }}"></use></svg>
          </span>
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ o.party }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">{{ o.gap }}</span>
          </span>
          <span class="col-r t-data" style="color:var(--secondary)">{{ o.span }}</span>
        </button>
      </sc-for>
    </section>

    <!-- ===== work history ================================================ -->
    <section id="sec-2" style="padding-top:32px">
      <div class="sechead">
        <h2 class="t-sec" style="margin:0">Work history</h2>
        <span class="t-data" style="color:var(--secondary)">5</span>
      </div>
      <sc-for list="{{ chapters }}" as="c" hint-placeholder-count="5">
        <button class="row {{ c.cls }} {{ c.give }}" aria-pressed="{{ c.sel }}" onClick="{{ c.pick }}">
          <span class="gutter">
            <svg viewBox="0 0 34 16" width="34" height="16" fill="none"
                 stroke="var(--ink)" stroke-width="1"><use href="{{ c.sw }}"></use></svg>
          </span>
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">{{ c.party }}</span>
            <!-- provenance in words, on the worker's own record, not only on the
                 page employers read (design/07 §4) -->
            <span class="t-data" style="display:block;padding-top:3px">{{ c.state }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px">{{ c.kind }}</span>
            <sc-for list="{{ c.positions }}" as="p" hint-placeholder-count="2">
              <span style="display:flex;justify-content:space-between;gap:8px;
                           border-top:1px solid var(--hairline);margin-top:6px;padding-top:5px">
                <span class="t-meta">{{ p.title }}</span>
                <span class="t-meta" style="color:var(--secondary);white-space:nowrap">{{ p.span }}</span>
              </span>
            </sc-for>
          </span>
          <span class="col-r">
            <span class="t-data" style="display:block">{{ c.from }}</span>
            <span class="t-data" style="display:block;color:var(--secondary)">{{ c.to }}</span>
          </span>
        </button>
      </sc-for>
      <p class="t-meta" style="color:var(--secondary);margin:12px 0 0;text-wrap:pretty">
        A chapter cannot be removed once a party has signed it. Deleting your whole record is the only way out.
      </p>
    </section>

    <!-- No sharing section. Decision 045 made it a destination reached from the
         header: on the record it sat below identity, outstanding verification
         and work history, which is where a product puts what does not matter. -->
  </main>

  <!-- No section index. It sat at right:0, 32px wide — entirely inside the
       ~24dp strip Android gives the back gesture from both edges, so dragging it
       navigated back. 037 had already demoted it to an accelerator; an
       accelerator that fights the platform is worse than none. -->

  <!-- No plate footer. DESIGN.md §9 gave it append-only status; decision 045
       moves that to the account surface and frees the band for navigation. -->

  <sc-if value="{{ sheet }}" hint-placeholder-val="{{ true }}">
    <div class="scrim" onClick="{{ close }}"></div>
    <div class="sheet" role="dialog" aria-modal="true" aria-label="{{ sheet.title }}">
      <div style="display:flex;justify-content:space-between;align-items:baseline;padding-bottom:12px">
        <span class="t-micro" style="color:var(--secondary)">{{ sheet.kicker }}</span>
        <button class="press" onClick="{{ close }}" aria-label="Close"
                style="width:44px;height:44px;display:flex;align-items:center;justify-content:flex-end">
          <svg width="16" height="16" viewBox="0 0 16 16" class="icon"><path d="M3 3 L13 13"/><path d="M13 3 L3 13"/></svg>
        </button>
      </div>
      <h3 class="t-sec" style="margin:0 0 8px">{{ sheet.title }}</h3>
      <p class="t-body" style="margin:0 0 20px;color:var(--secondary);text-wrap:pretty">{{ sheet.body }}</p>
      <sc-if value="{{ sheet.danger }}" hint-placeholder-val="{{ true }}">
        <div style="background:var(--ink);color:var(--paper);padding:16px;margin-bottom:16px">
          <p class="t-body" style="margin:0">{{ sheet.dangerLine }}</p>
        </div>
      </sc-if>
      <div style="display:flex;flex-direction:column;gap:12px;align-items:center">
        <button class="btn-primary press" onClick="{{ close }}">{{ sheet.cta }}</button>
        <button class="btn-tertiary press" onClick="{{ close }}">{{ sheet.dismiss }}</button>
      </div>
    </div>
  </sc-if>
</div>

<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>
  <g id="sw-self">@@SW_SELF@@</g>
  <g id="sw-emp">@@SW_EMP@@</g>
  <g id="sw-peer">@@SW_PEER@@</g>
  <g id="sw-single">@@SW_SINGLE@@</g>
  <g id="sw-multi">@@SW_MULTI@@</g>
</defs></svg>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Order per decision 029 (amending 028): identity + imprint composed, then
// outstanding verification, work history, sharing. Grants carry state only, no
// read events (029 §B4). Revised against design/07.
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {sel:null, active:0, sheet:null, touched:false}; }

  componentDidMount(){
    const el = document.getElementById('scroll');
    if(!el) return;
    this._on = () => {
      let a = 0;
      for(let i=0;i<4;i++){
        const s = document.getElementById('sec-'+i);
        if(s && s.offsetTop - el.scrollTop <= 130) a = i;
      }
      if(a !== this.state.active) this.setState({active:a});
    };
    el.addEventListener('scroll', this._on, {passive:true});
  }
  componentWillUnmount(){
    const el = document.getElementById('scroll');
    if(el && this._on) el.removeEventListener('scroll', this._on);
  }

  chapters(){
    return [
      {party:'Bataan Poultry Processing', kind:'Processing operator',
       state:'You added this. Nobody has confirmed it.',
       from:'Sep 2017', to:'Mar 2019', sw:'#sw-self', positions:[], attested:false},
      {party:'Sunrise Foods Manufacturing', kind:'Two positions',
       state:'Sunrise Foods signed this, and a second party agrees.',
       from:'Mar 2019', to:'Sep 2021', sw:'#sw-multi', attested:true,
       positions:[{title:'Packing line operator', span:'Mar 2019 – Jun 2020'},
                  {title:'Line lead', span:'Jun 2020 – Sep 2021'}]},
      {party:'R. Santos Dry Goods', kind:'Stall assistant, Divisoria',
       state:'A coworker signed this. The business is not registered with Grain.',
       from:'Sep 2020', to:'Mar 2023', sw:'#sw-peer', positions:[], attested:true},
      {party:'Metro Manila Logistics', kind:'Warehouse coordinator',
       state:'Metro Manila Logistics signed this. Nobody else has agreed yet.',
       from:'Mar 2023', to:'Jan 2025', sw:'#sw-single', positions:[], attested:true},
      {party:'Cebu Pacific Cargo Services', kind:'Cargo handling supervisor, as you gave it',
       state:'They confirmed the dates and the job. Not the work.',
       from:'Jan 2025', to:'Present', sw:'#sw-emp', positions:[], attested:false}
    ];
  }
  // hit zones run to the midpoint between chapter centres, so every tap lands on
  // the nearest chapter. Five concentric zones across 320px cannot each reach
  // 44px; the work-history rows are the equal path, and the accessible one.
  zones(){ return [
    {ch:0, mid:78.25,  w:40.5, r0:58.00,  r1:95.35},
    {ch:1, mid:121.8,  w:46.6, r0:95.35,  r1:145.14},
    {ch:2, mid:169.5,  w:48.8, r0:145.14, r1:194.93},
    {ch:3, mid:216.45, w:45.1, r0:194.93, r1:240.58},
    {ch:4, mid:259.5,  w:41.0, r0:240.58, r1:280.00} ]; }

  renderVals(){
    const st = this.state, chs = this.chapters(), sel = st.sel;
    const open = (s) => this.setState({sheet:s});
    const z = this.zones();
    const pick = (i) => this.setState({sel: sel === i ? null : i, touched:true});

    const outstanding = [
      {i:4, gap:'They confirmed the dates. Ask them to say what you did.', sw:'#sw-emp',
       kicker:'Request attestation', cta:'Send the request',
       body:'Cebu Pacific is registered with Grain. The request goes to their verified domain, and whoever answers it signs in first. They write what you did. You cannot edit it, and you can attach your side to it.'},
      {i:2, gap:'Only a coworker has signed this.', sw:'#sw-peer',
       kicker:'Ask a manager', cta:'Ask a manager',
       body:'A manager who confirms their work email at this business can sign for you more strongly than a coworker can. Confirming that email also confirms their own time there.'},
      {i:0, gap:'Nobody has confirmed these dates.', sw:'#sw-self',
       kicker:'Confirm dates', cta:'Ask the employer',
       body:'Ask the employer to confirm when you worked there, or leave the chapter as your own account of it.'}
    ].map(o => ({
      party: chs[o.i].party, gap:o.gap, sw:o.sw,
      span: chs[o.i].from + ' to ' + chs[o.i].to,
      open: () => open({kicker:o.kicker, title:chs[o.i].party, body:o.body, cta:o.cta, dismiss:'Not now'})
    }));


    return {
      headerCls: 'disclosed',
      figureAlt: 'Your imprint. Five chapters: two signed by the employer, one by a coworker, one dates only, one you added yourself.',
      bands: z.map(g => ({mid:g.mid, w:g.w, pick: () => pick(g.ch)})),
      selBand: sel !== null,
      selR0: sel === null ? 0 : z[sel].r0,
      selR1: sel === null ? 0 : z[sel].r1,
      // Nothing when nothing is selected. The masthead carries disclosure now
      // (045/048), and repeating it here turned the record's readout into chrome.
      readout: sel === null ? '' : chs[sel].party + '. ' + chs[sel].state,
      outstanding,
      chapters: chs.map((c,i) => ({...c,
        cls: i === sel ? 'row-sel' : '',
        give: c.attested ? 'rigid' : 'press',   // §7 rigidity is permanence
        sel: i === sel ? 'true' : 'false',
        pick: () => pick(i)})),
      openImprint: () => open({kicker:'Imprint', title:'Your imprint, full size',
        body:'Every ring is one chapter. The weave shows who confirmed it. Open it to walk one measure of the work outward across your whole record.',
        cta:'Open it', dismiss:'Close'}),
      openSettings: () => open({kicker:'Account', title:'Your account',
        body:'Your name, phone, email, identity and address. Ask for an export, see who you have disclosed to, or ask us to delete everything.',
        cta:'Open account', dismiss:'Close'}),
      // The label states exposure rather than naming an action, so the control
      // never reads as "share" when the honest state is "already shared".
      shareLabel: 'Sharing. Public page on, 2 parties hold a grant',
      shareCount: '3',
      openSharing: () => open({kicker:'Who can read this', title:'Two parties, and the public page',
        body:'Alorica Philippines and Sunrise Foods Manufacturing each hold a grant to your whole record. Your public page is live and anyone with a Grain account can open it.',
        cta:'Go to sharing', dismiss:'Close'}),
      sheet: st.sheet,
      close: () => this.setState({sheet:null})
    };
  }
}
</script>
</body>
</html>
