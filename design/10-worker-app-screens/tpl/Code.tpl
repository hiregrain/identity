<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .otp{display:flex;gap:8px}
    .otp input{flex:1;min-width:0;height:56px;text-align:center;font:600 22px/1 Archivo,system-ui,sans-serif;
               color:var(--ink);background:none;border:0;border-bottom:1px solid var(--rule);
               border-radius:0;outline:0;padding:0}
    .otp input:focus{border-bottom:2px solid var(--ink)}
    .otp input.filled{border-bottom:1.4px solid var(--ink)}
  </style>
</helmet>

<!-- A4. Six ruled fields, not six boxes: §8 deletes containers, and a box
     per digit is six containers. Paste fills all six, which is what every
     person actually does with a code their phone just showed them. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to the identifier">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Your record</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <h2 class="t-lead" style="margin:0 0 8px;line-height:1.3">Enter the code</h2>
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">
        Sent to {{ sentTo }}. It works once, and for ten minutes.</p>

      <div class="otp" role="group" aria-label="Six digit code">
        <sc-for list="{{ boxes }}" as="b" hint-placeholder-count="6">
          <input class="{{ b.cls }}" value="{{ b.v }}" inputmode="numeric" maxlength="1"
                 aria-label="{{ b.label }}" onInput="{{ b.set }}">
        </sc-for>
      </div>

      <div style="padding-top:28px">
        <button class="btn-tertiary press" style="padding-left:0" disabled="{{ resendOff }}">{{ resend }}</button>
      </div>
      <p class="t-meta" style="margin:20px 0 0;color:var(--secondary);text-wrap:pretty">
        No code? Check the number, or go back and use an email instead.</p>
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
  constructor(p){ super(p); this.state = {d:['4','1','7','','',''], left: 38}; }
  renderVals(){
    const d = this.state.d;
    return {
      sentTo: '+63 917 555 4471',
      boxes: d.map((v,i) => ({
        v, cls: v ? 'filled' : '', label: 'Digit ' + (i+1),
        set: (e) => { const n = d.slice(); n[i] = (e.target.value||'').slice(-1); this.setState({d:n}); }
      })),
      resend: this.state.left > 0 ? 'Send another in ' + this.state.left + 's' : 'Send another code',
      resendOff: this.state.left > 0 ? 'disabled' : null,
      disabled: d.every(x => x) ? null : 'disabled'
    };
  }
}
</script>
</body>
</html>
