<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
    /* Option B — Material 3 component grammar, Android. Palette held at Grain's
       ink and paper on purpose: vary one thing. What is being judged here is
       component FORM, not colour, and M3's own baseline palette would decide
       the comparison before anyone looked at the components. */
    .m-body{font-family:system-ui,Roboto,-apple-system,sans-serif}
    .m-appbar{height:64px;display:flex;align-items:center;gap:16px;padding:0 16px;
              background:var(--paper)}
    .m-title{font:500 22px/28px system-ui,Roboto,sans-serif;color:var(--ink)}
    /* Filled text field: 56dp, 4px top radius, filled container, floating label,
       an active indicator that thickens on focus. */
    .m-field{background:var(--page);border-radius:4px 4px 0 0;padding:8px 16px 6px;
             border-bottom:1px solid var(--secondary);min-height:56px;display:flex;
             flex-direction:column;justify-content:center}
    .m-field:focus-within{border-bottom:2px solid var(--ink);padding-bottom:5px}
    .m-field.bad{border-bottom:2px solid var(--ink)}
    .m-label{font:400 12px/16px system-ui,Roboto,sans-serif;color:var(--secondary)}
    .m-input{display:flex;align-items:baseline;gap:2px}
    .m-input input{border:0;outline:0;background:none;flex:1;min-width:0;
                   font:400 16px/24px system-ui,Roboto,sans-serif;color:var(--ink)}
    .m-support{font:400 12px/16px system-ui,Roboto,sans-serif;color:var(--secondary);
               padding:4px 16px 0}
    .m-chip{min-height:44px;padding:6px 16px;border:1px solid var(--secondary);
            border-radius:8px;font:500 14px/20px system-ui,Roboto,sans-serif;
            background:none;color:var(--ink)}
    .m-btn{min-height:44px;padding:10px 24px;border-radius:100px;background:var(--ink);
           color:var(--paper);font:500 14px/20px system-ui,Roboto,sans-serif;width:100%}
    .m-btn[disabled]{background:var(--page);color:var(--secondary)}
  </style>
</helmet>

<div class="m-body" style="width:360px;height:800px;position:relative;overflow:hidden;background:var(--paper)">
  <div class="m-appbar">
    <button aria-label="Back" style="width:44px;height:44px;display:flex;align-items:center;justify-content:center">
      <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="var(--ink)" stroke-width="1.6">
        <path d="M12 4 L6 10 L12 16"/></svg>
    </button>
    <span class="m-title">Your link</span>
  </div>

  <main style="position:absolute;top:64px;bottom:88px;left:0;right:0;overflow-y:auto;padding:8px 0 24px">
    <p style="margin:0 16px 24px;font:400 14px/20px system-ui,Roboto,sans-serif;color:var(--secondary)">
      The address people open to see your record. We wrote it out from your name.</p>

    <div style="padding:0 16px">
      <div class="m-field {{ cls }}">
        <span class="m-label">Address</span>
        <span class="m-input">
          <span style="color:var(--secondary);font:400 16px/24px system-ui,Roboto,sans-serif">hiregrain.com/u/</span>
          <input id="h" value="{{ value }}" onInput="{{ onInput }}" aria-describedby="hn"
                 aria-invalid="{{ invalid }}" autocapitalize="none" autocorrect="off" spellcheck="false">
        </span>
      </div>
    </div>
    <p id="hn" class="m-support">{{ note }}</p>

    <sc-if value="{{ suggest }}" hint-placeholder-val="{{ true }}">
      <div style="display:flex;flex-wrap:wrap;gap:8px;padding:16px 16px 0">
        <sc-for list="{{ alternates }}" as="a" hint-placeholder-count="3">
          <button class="m-chip" onClick="{{ a.pick }}">{{ a.h }}</button>
        </sc-for>
      </div>
    </sc-if>

    <p style="margin:32px 16px 0;font:400 14px/20px system-ui,Roboto,sans-serif;color:var(--secondary)">
      You can change this later. The old address keeps working and never goes to
      anyone else, so anyone who already has it keeps reaching you.</p>
  </main>

  <div style="position:absolute;left:0;right:0;bottom:0;padding:16px;background:var(--paper)">
    <button class="m-btn" disabled="{{ disabled }}">Claim this address</button>
  </div>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Option B — Material 3 grammar on Grain's palette. Identical logic to the
// shipped Handle; only the components differ.
//
// What this option costs, stated where it is made: the filled field is a
// CONTAINER (§8 deletes containers and says boxed fields do not exist), the
// button is a 100px pill (§7 fixes control radius at 3px), the type is the
// system face (§6 admits one family), and M3 carries error state in colour,
// which §5 forbids and which is faked here with weight instead.
const MAP = {
  // Devanagari, Bengali, Arabic, Cyrillic, Greek, Han, Kana — enough to show the
  // mechanism. Production uses ICU; this is the mockup's stand-in.
  'ল':'l','ি':'i','য':'y','া':'a','জ':'j','ে':'e','ল':'l','ম':'m','ন':'n','্':'','দ':'d','ো':'o','স':'s',
  'л':'l','и':'i','з':'z','е':'e','м':'m','н':'n','д':'d','о':'o','с':'s','а':'a','р':'r','в':'v','к':'k',
  'α':'a','β':'b','γ':'g','δ':'d','ε':'e','λ':'l','μ':'m','ν':'n','ο':'o','σ':'s','τ':'t','ρ':'r','ι':'i'
};
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {value:'liezel-mendoza'}; }
  translit(v){
    return Array.from(v || '').map(ch => MAP[ch] !== undefined ? MAP[ch] : ch).join('');
  }
  normalize(v){
    return this.translit(v).normalize('NFD').replace(/[̀-ͯ]/g,'')
      .toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-+|-+$/g,'');
  }
  renderVals(){
    const raw = this.state.value, h = this.normalize(raw);
    const taken = h === 'liezel' || h === 'mendoza';
    const short = h.length > 0 && h.length < 3, empty = h.length === 0;
    const ok = !taken && !short && !empty;
    return {
      value: raw,
      onInput: (e) => this.setState({value: e.target.value}),
      cls: ok ? '' : 'bad',
      invalid: ok ? 'false' : 'true',
      note: empty ? 'Type an address, or take one of these.'
          : short ? 'Make it a little longer.'
          : taken ? 'Someone already has that one. These are free.'
          : 'hiregrain.com/u/' + h + ' is free.',
      suggest: !ok,
      alternates: ['liezel-mendoza','mendoza-liezel','liezelm'].map(x => ({h:x, pick: () => this.setState({value:x})})),
      disabled: ok ? null : 'disabled'
    };
  }
}
</script>
</body>
</html>
