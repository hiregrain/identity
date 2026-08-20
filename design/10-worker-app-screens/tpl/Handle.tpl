<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    /* §8 inputs are ruled lines: a hairline you type on, focus thickens ink-ward.
       An error thickens it further and speaks in ink — never paler (law 8). */
    .ruled{display:flex;align-items:baseline;border-bottom:1px solid var(--rule);padding-bottom:10px}
    .ruled:focus-within{border-bottom:2px solid var(--ink)}
    .ruled.bad{border-bottom:2.5px solid var(--ink)}
    /* WCAG 2.2 AA 2.5.8 and §12's stricter 44px floor: the field is the target,
       and it measured 18px tall. The rule stays a rule; the touchable area is
       padded around it. */
    .ruled input{border:0;outline:0;background:none;font:inherit;color:var(--ink);
                 flex:1;min-width:0;padding:12px 0;font-weight:600;font-size:16px;
                 min-height:44px;box-sizing:border-box}
    .ruled{align-items:center}
    .alt{min-height:44px;padding:13px 12px;border:1px solid var(--rule);border-radius:0}
  </style>
</helmet>

<!-- Fluid in both axes: the record fills whatever safe area it is given, and
     min-height carries the standalone case where height:100% has no sized
     ancestor and would collapse to zero. 728 is the common safe box across
     iOS (778) and Android (728). Decision 046. -->
<div style="width:100%;height:100%;min-height:728px;position:relative;overflow:hidden;background:var(--paper)">
  <header style="height:52px;display:flex;align-items:center;gap:10px;padding:0 20px;
                 border-bottom:1px solid var(--hairline)">
    <!-- The lockup: mark plus the GRAIN wordmark (§4a), generated so the mark
         swaps to its drawn reduction rather than scaling a master. -->
    <svg viewBox="0 0 160 26" width="160" height="26" role="img" aria-label="Grain">@@LOCKUP@@</svg>
  </header>

  <main style="position:absolute;top:52px;bottom:120px;left:0;right:0;overflow-y:auto;padding:28px 20px">
    <h1 class="t-title" style="margin:0 0 8px">Your link</h1>
    <p class="t-body" style="margin:0 0 32px;color:var(--secondary);text-wrap:pretty">
      The address people open to see your record. We wrote it out from your name.
    </p>

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
        You can change this later. The old address keeps working and never goes to anyone
        else, so anyone who already has it keeps reaching you.
      </p>
    </div>
  </main>

  <div style="position:absolute;left:0;right:0;bottom:0;padding:16px 20px;background:var(--paper);
              border-top:1px solid var(--ink)">
    <button class="btn-primary press" disabled="{{ disabled }}">Claim this address</button>
  </div>

</div>
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
// Handle claim, in onboarding, after the record exists (029). Latin-only URLs
// (029 §A), so a non-Latin name is TRANSLITERATED into a working address and
// never rejected — design/07 §5 found the first build only claimed to do this.
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
