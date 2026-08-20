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

<!-- C3, under 028: only minor edits after commit. The screen's whole job is
     to show that a correction does not overwrite anything. Both values stay
     on the record, and the reader sees the correction as a correction. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to the chapter">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Correct an entry</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <h2 class="t-sec" style="margin:0 0 8px;font-size:19px;line-height:1.3">Correcting a title</h2>
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">
        Dates and titles can be corrected. What a party attested cannot, because
        it is theirs, not yours.</p>

      <label class="t-micro" for="e" style="display:block;color:var(--secondary);padding-bottom:8px">Title</label>
      <div class="ruled"><input id="e" value="{{ v }}" onInput="{{ onV }}" autocapitalize="words"></div>

      <div style="margin-top:26px;border-block:1px solid var(--ink);padding:16px 0">
        <span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:8px">What the record will show</span>
        <p class="t-body" style="margin:0;text-wrap:pretty"><s>{{ was }}</s> corrected to <b>{{ v }}</b>, today, by you.</p>
        <p class="t-meta" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">
          The old value stays readable. A correction is a new entry that cites the
          one it corrects, which is what lets the record be read back in order.</p>
      </div>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press" disabled="{{ disabled }}">Write the correction</button>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {v:'Line lead'}; }
  renderVals(){
    const was = 'Line leader';
    return { v: this.state.v, was, onV: (e) => this.setState({v:e.target.value}),
             disabled: (this.state.v.trim() && this.state.v !== was) ? null : 'disabled' };
  }
}
</script>
</body>
</html>
