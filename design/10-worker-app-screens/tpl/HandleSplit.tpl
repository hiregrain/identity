<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
    /* Option C — platform chrome, Grain content. The app bar, the back
       affordance and the commit button follow the platform so navigation feels
       ordinary; everything that carries the record keeps §8's ruled input,
       Archivo, and error in ink rather than colour. */
    .m-appbar{height:64px;display:flex;align-items:center;gap:16px;padding:0 16px;
              border-bottom:1px solid var(--hairline)}
    .m-title{font:500 22px/28px system-ui,Roboto,sans-serif;color:var(--ink)}
    .m-btn{min-height:48px;padding:12px 24px;border-radius:100px;background:var(--ink);
           color:var(--paper);font:500 15px/20px system-ui,Roboto,sans-serif;width:100%}
    .m-btn[disabled]{background:var(--page);color:var(--secondary)}
    .ruled{display:flex;align-items:baseline;border-bottom:1px solid var(--rule);padding-bottom:10px}
    .ruled:focus-within{border-bottom:2px solid var(--ink)}
    .ruled.bad{border-bottom:2.5px solid var(--ink)}
    .ruled input{border:0;outline:0;background:none;font:inherit;color:var(--ink);
                 flex:1;min-width:0;padding:0;font-weight:600;font-size:16px}
    .alt{min-height:44px;padding:13px 12px;border:1px solid var(--rule);border-radius:0}
  </style>
</helmet>

<div style="width:360px;height:800px;position:relative;overflow:hidden;background:var(--paper)">
  <div class="m-appbar">
    <button aria-label="Back" style="width:44px;height:44px;display:flex;align-items:center;justify-content:center">
      <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="var(--ink)" stroke-width="1.6">
        <path d="M12 4 L6 10 L12 16"/></svg>
    </button>
    <span class="m-title">Your link</span>
  </div>

  <main style="position:absolute;top:64px;bottom:96px;left:0;right:0;overflow-y:auto;padding:24px 20px">
    <p class="t-body" style="margin:0 0 32px;color:var(--secondary);text-wrap:pretty">
      The address people open to see your record. We wrote it out from your name.</p>

    <label class="t-micro" for="h" style="display:block;color:var(--secondary);padding-bottom:8px">Address</label>
    <div class="ruled {{ cls }}">
      <span class="t-data" style="color:var(--secondary)">hiregrain.com/u/</span>
      <input id="h" value="{{ value }}" onInput="{{ onInput }}" aria-describedby="hn"
             aria-invalid="{{ invalid }}" autocapitalize="none" autocorrect="off" spellcheck="false">
    </div>
    <p id="hn" class="t-data" style="margin:12px 0 0;color:var(--ink)">{{ note }}</p>

    <sc-if value="{{ suggest }}" hint-placeholder-val="{{ true }}">
      <div style="display:flex;flex-wrap:wrap;gap:8px;padding-top:16px">
        <sc-for list="{{ alternates }}" as="a" hint-placeholder-count="3">
          <button class="alt t-data press" onClick="{{ a.pick }}">{{ a.h }}</button>
        </sc-for>
      </div>
    </sc-if>

    <div style="margin-top:40px;border-top:1px solid var(--hairline);padding-top:16px">
      <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">
        You can change this later. The old address keeps working and never goes to
        anyone else, so anyone who already has it keeps reaching you.</p>
    </div>
  </main>

  <div style="position:absolute;left:0;right:0;bottom:0;padding:20px;background:var(--paper);
              border-top:1px solid var(--hairline)">
    <button class="m-btn" disabled="{{ disabled }}">Claim this address</button>
  </div>
</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Option C — the seam. Chrome is the platform's; the record's own surfaces are
// Grain's. Identical logic to the shipped Handle.
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
