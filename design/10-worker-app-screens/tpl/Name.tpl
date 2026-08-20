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

<!-- A7. One field, any script. Not given/family: the split is a western
     assumption and the ledger stores what the person wrote. Transliteration
     happens at the handle (035 §A) and is never applied to the name itself. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to the code">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Your record</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <h2 class="t-lead" style="margin:0 0 8px;line-height:1.3">What is your name?</h2>
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">
        Write it the way you write it. Any script. This is the name at the top of
        your record and on anything you send.</p>

      <label class="t-micro" for="nm" style="display:block;color:var(--secondary);padding-bottom:8px">Full name</label>
      <div class="ruled lg">
        <input id="nm" value="{{ value }}" onInput="{{ onInput }}" aria-describedby="nn" autocapitalize="words">
      </div>
      <p id="nn" class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">
        One field, on purpose. Splitting a name into first and last assumes a
        shape most of the world does not use.</p>

      <div style="margin-top:32px;border-top:1px solid var(--hairline);padding-top:16px">
        <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">
          Changing it later is a support request, because the name on a record
          that parties have signed cannot quietly become a different name.</p>
      </div>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press" disabled="{{ disabled }}">Continue</button>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {v:'Liezel Mendoza'}; }
  renderVals(){
    return { value: this.state.v, onInput: (e) => this.setState({v:e.target.value}),
             disabled: this.state.v.trim().length > 1 ? null : 'disabled' };
  }
}
</script>
</body>
</html>
