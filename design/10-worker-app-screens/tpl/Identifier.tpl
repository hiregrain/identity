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
    .ruled.bad{border-bottom:2.5px solid var(--ink)}
    .ruled input{border:0;outline:0;background:none;font:inherit;color:var(--ink);
                 flex:1;min-width:0;padding:12px 0;font-weight:600;font-size:16px;
                 min-height:44px;box-sizing:border-box}
    .cc{min-height:44px;display:flex;align-items:center;gap:6px;padding-right:10px;
        border-right:1px solid var(--rule);margin-right:12px}
  </style>
</helmet>

<!-- A3. One identifier, and control of it proven (research/11). The country
     selector is part of the control rather than a separate screen, because
     research/11 treats a Philippine RA 11934 number as higher assurance and a
     field that hides which country it is in cannot carry that. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to the start">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Your record</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:26px">
      <h2 class="t-sec" style="margin:0 0 8px;font-size:19px;line-height:1.3">How should we reach you?</h2>
      <p class="t-body" style="margin:0 0 26px;color:var(--secondary);text-wrap:pretty">
        We send one code to check it is yours. This is how you get back in, and
        it is never shown to anyone reading your record.</p>

      <div role="group" aria-label="Phone or email" style="display:flex;gap:8px;padding-bottom:20px">
        <sc-for list="{{ tabs }}" as="t" hint-placeholder-count="2">
          <button class="press t-data" aria-pressed="{{ t.on }}" onClick="{{ t.go }}"
                  style="flex:1;min-height:44px;border:1px solid {{ t.border }};border-radius:3px;
                         padding:12px 6px;text-align:center;font-weight:{{ t.weight }}">{{ t.label }}</button>
        </sc-for>
      </div>

      <label class="t-micro" for="id" style="display:block;color:var(--secondary);padding-bottom:8px">{{ label }}</label>
      <div class="ruled">
        <sc-if value="{{ isPhone }}" hint-placeholder-val="{{ true }}">
          <button class="cc press t-data" aria-label="Country, Philippines">
            <span>+63</span>
            <svg width="12" height="12" viewBox="0 0 20 20" fill="none" stroke="var(--rule)"
                 stroke-width="1.2" stroke-linecap="round"><path d="M5 8 L10 13 L15 8"/></svg>
          </button>
        </sc-if>
        <input id="id" value="{{ value }}" onInput="{{ onInput }}" inputmode="{{ mode }}"
               autocapitalize="none" autocorrect="off" spellcheck="false" aria-describedby="idn">
      </div>
      <p id="idn" class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">{{ note }}</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press" disabled="{{ disabled }}">Send the code</button>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// A3. research/11: a Philippine mobile is registered under RA 11934, which makes
// it a stronger identifier than an email, and the control has to show which
// country it is in for that to mean anything.
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {mode:'phone', phone:'917 555 4471', email:''}; }
  renderVals(){
    const isPhone = this.state.mode === 'phone';
    const value = isPhone ? this.state.phone : this.state.email;
    const ok = isPhone ? value.replace(/\D/g,'').length >= 9 : /.+@.+\..+/.test(value);
    return {
      tabs: [['phone','Phone'],['email','Email']].map(([k,label]) => ({
        label, on: this.state.mode === k ? 'true' : 'false',
        border: this.state.mode === k ? 'var(--ink)' : 'var(--rule)',
        weight: this.state.mode === k ? '600' : '400',
        go: () => this.setState({mode:k})
      })),
      isPhone, value, mode: isPhone ? 'tel' : 'email',
      label: isPhone ? 'Mobile number' : 'Email address',
      onInput: (e) => this.setState(isPhone ? {phone:e.target.value} : {email:e.target.value}),
      note: isPhone
        ? 'A Philippine mobile is registered to a person, so it carries more weight here than an email does.'
        : 'You can add a phone later. A registered mobile carries more weight.',
      disabled: ok ? null : 'disabled'
    };
  }
}
</script>
</body>
</html>
