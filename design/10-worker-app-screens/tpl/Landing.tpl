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
    /* §10, the attestation landing. One of only two heavy ceremonies.
       A state change of something already on screen: no overlay, no spawned UI. */
    .before{opacity:1}
    .after path{stroke-dasharray:1;stroke-dashoffset:1}
    .run .before{animation:fadeout 360ms cubic-bezier(0.2,0,0,1) forwards}
    .run .after path{animation:scribe 880ms cubic-bezier(0.2,0,0,1) forwards}
    .run .after path:nth-child(2){animation-delay:50ms}
    .run .after path:nth-child(3){animation-delay:100ms}
    .run .after path:nth-child(4){animation-delay:150ms}
    .run .after path:nth-child(5){animation-delay:150ms}
    .run .after path:nth-child(6){animation-delay:200ms}
    .done .before{opacity:0}
    .done .after path{stroke-dashoffset:0}
    @keyframes fadeout{to{opacity:0}}
    @keyframes scribe{to{stroke-dashoffset:0}}
    /* §7, the seat. Pending rows sit 2px proud and seat flush on verification. */
    .seat{transform:translateY(-2px)}
    .run .seat{animation:seat 320ms cubic-bezier(0.2,0,0,1) 320ms forwards}
    .done .seat{transform:translateY(0)}
    @keyframes seat{to{transform:translateY(0)}}
    .contact{opacity:0}
    .run .contact{animation:contact 240ms cubic-bezier(0.2,0,0,1) 600ms}
    @keyframes contact{0%{opacity:.5}100%{opacity:0}}
  </style>
</helmet>

<div class="{{ phase }}" style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <div class="plate">
    <div class="reg" style="top:7px;left:7px;border-top-width:1px;border-left-width:1px"></div>
    <div class="reg" style="top:7px;right:7px;border-top-width:1px;border-right-width:1px"></div>
    <div class="reg" style="bottom:7px;left:7px;border-bottom-width:1px;border-left-width:1px"></div>
    <div class="reg" style="bottom:7px;right:7px;border-bottom-width:1px;border-right-width:1px"></div>
  </div>

  <header style="height:52px;display:flex;align-items:center;gap:10px;padding:0 20px;
                 border-bottom:1px solid var(--hairline)">
    <!-- The lockup: mark plus the GRAIN wordmark (§4a), generated so the mark
         swaps to its drawn reduction rather than scaling a master. -->
    <svg viewBox="0 0 160 26" width="160" height="26" role="img" aria-label="Grain">@@LOCKUP@@</svg>
  </header>

  <main style="position:absolute;top:52px;bottom:0;left:0;right:0;padding:20px 20px 28px">
    <svg class="imprint" viewBox="0 0 600 600" role="img" aria-label="An attestation lands">
      @@CBASE@@
      <g class="before">@@CBEFORE@@</g>
      <g class="after">@@CAFTER@@</g>
    </svg>

    <div style="display:flex;justify-content:space-between;align-items:baseline;padding:12px 0 0">
      <span class="t-micro" style="color:var(--secondary)">Liezel Mendoza</span>
      <span class="t-micro">{{ readout }}</span>
    </div>

    <div style="padding-top:28px">
      <!-- The event, said once and said large. This is the heavier of the two
           ceremonies §10 permits and it carried no headline at all. -->
      <h1 class="t-title" style="margin:0 0 8px;text-wrap:pretty">{{ headline }}</h1>
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">{{ subhead }}</p>

      <div style="display:flex;justify-content:space-between;align-items:baseline;
                  border-bottom:1px solid var(--ink);padding-bottom:8px">
        <h2 class="t-sec" style="margin:0">{{ sectionLabel }}</h2>
      </div>
      <div class="sinerule">@@SINERULE@@</div>
      <div style="position:relative">
        <div class="contact" style="position:absolute;left:0;right:0;bottom:0;height:1px;background:var(--ink)"></div>
        <div class="row seat">
          <span class="gutter">
            <svg viewBox="0 0 26 14" width="26" height="14" fill="none" aria-hidden="true"
                 stroke="var(--ink)" stroke-width="0.9"><use href="{{ sw }}"></use></svg>
          </span>
          <span style="flex:1;min-width:0">
            <span class="t-rec" style="display:block">Cebu Pacific Cargo Services</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px">{{ rowState }}</span>
          </span>
          <span class="t-micro" style="text-align:right;white-space:nowrap;padding-top:2px">Jan 2025 – present</span>
        </div>
      </div>
    </div>

    <div style="padding-top:32px;text-align:center">
      <button class="btn-tertiary press" onClick="{{ replay }}">Play it again</button>
    </div>
  </main>

</div>

@@SWATCHES@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {phase:'idle'}; }
  componentDidMount(){ this._t = setTimeout(() => this.run(), 700); }
  componentWillUnmount(){ clearTimeout(this._t); clearTimeout(this._u); }
  run(){
    this.setState({phase:'run'});
    this._u = setTimeout(() => this.setState({phase:'done'}), 1080);
  }
  renderVals(){
    const done = this.state.phase === 'done';
    return {
      phase: this.state.phase,
      readout: done ? '4 chapters attested. 1 recorded by you.' : '3 chapters attested. 2 not yet.',
      headline: done ? 'Cebu Pacific attested your work.' : 'Cebu Pacific is attesting your work.',
      subhead: done
        ? 'They attested the dates and the employment. No second party has agreed, so it stands at their reading alone.'
        : 'Watch the ring for that chapter fill in.',
      sectionLabel: done ? 'Work history' : 'Outstanding verification',
      rowState: done ? 'Attested by Cebu Pacific Cargo Services. No second party has agreed.'
                     : 'They attested the dates and the employment. Nothing about the work.',
      sw: done ? '#sw-single' : '#sw-emp',
      entries: done ? '48 entries · last today' : '47 entries · last 12 Aug 2026',
      replay: () => { clearTimeout(this._u); this.setState({phase:'idle'});
                      setTimeout(() => this.run(), 60); }
    };
  }
}
</script>
</body>
</html>
