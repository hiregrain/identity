<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .ruled{display:flex;align-items:center;border-bottom:1px solid var(--rule)}
    .ruled:focus-within{border-bottom:2px solid var(--ink)}
    .ruled input{border:0;outline:0;background:none;font:inherit;color:var(--ink);
                 flex:1;min-width:0;padding:12px 0;font-weight:600;font-size:16px;
                 min-height:44px;box-sizing:border-box}
  </style>
</helmet>

<!-- What the party is actually ASKED is not described on any of these
     screens. Decision 054 renders nothing derived from the seven measures,
     and what consent says about collecting them is an open gate in
     plans/ORDER.md. These screens describe who can attest and what it
     costs, which is settled, and say nothing that the gate would make a
     promise. -->
<!-- D4. The path that carries dissolved employers, informal work and
     cross-border history, which is the population the record layer exists for.
     Decision 055 stopped the copy calling it lesser; this screen states what
     it is worth plainly instead. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your record">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Ask a coworker</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <h2 class="t-sec" style="margin:0 0 8px;font-size:19px;line-height:1.3">Someone who was there</h2>
      <p class="t-body" style="margin:0 0 22px;color:var(--secondary);text-wrap:pretty">
        A person who worked alongside you can attest this chapter. If the business
        has closed, or nobody there answers, this is the witness that exists.</p>

      <label class="t-micro" for="cw" style="display:block;color:var(--secondary);padding-bottom:8px">Their phone or email</label>
      <div class="ruled">
        <input id="cw" value="{{ v }}" onInput="{{ onV }}" autocapitalize="none"
               autocorrect="off" spellcheck="false">
      </div>

      <div style="margin-top:26px">
        <span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:8px">
          What a reader is told</span>
        <div style="display:flex;gap:14px;align-items:center;border-block:1px solid var(--hairline);padding:14px 0">
          <span class="prov" tabindex="0">
            <svg viewBox="0 0 34 16" width="34" height="16" fill="none" aria-hidden="true"
                 stroke="var(--ink)" stroke-width="1"><use href="#sw-peer"></use></svg>
            <span class="tip t-meta">Attested by a coworker who was there. The business is not registered with Grain.</span>
          </span>
          <span class="t-body" style="flex:1;min-width:0;text-wrap:pretty">
            Attested by a coworker who was there, and the business named as not
            registered. The mark says which, and does not say less of you for it.</span>
        </div>
      </div>

      <p class="t-meta" style="margin:18px 0 0;color:var(--secondary);text-wrap:pretty">
        A business that later registers can attest the same chapter alongside
        them. Two parties who agree independently is the strongest a chapter gets.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press" disabled="{{ disabled }}">Send the request</button>
    <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-align:center;text-wrap:pretty">
      Asking cannot be undone.</p>
  </div>

</div>
@@ICONS@@
@@SWATCHES@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {v:''}; }
  renderVals(){
    const v = this.state.v.trim();
    return { v: this.state.v, onV: (e) => this.setState({v:e.target.value}),
             disabled: v.length > 4 ? null : 'disabled' };
  }
}
</script>
</body>
</html>
