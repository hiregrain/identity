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

<!-- What the party is actually ASKED is not described on any of these
     screens. Decision 054 renders nothing derived from the seven measures,
     and what consent says about collecting them is an open gate in
     plans/ORDER.md. These screens describe who can attest and what it
     costs, which is settled, and say nothing that the gate would make a
     promise. -->
<!-- D3. The business is not registered, so a person attests instead. A work
     email at the business is what separates a manager from a coworker, and
     Grain checks control of the address and records that, and nothing about
     when they worked there: a confirmation link cannot make a non-user the
     subject of a tenure claim they never agreed to. See the gate in
     plans/ORDER.md on third parties becoming subjects. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your record">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Ask a manager</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:24px 0 16px;border-bottom:1px solid var(--ink)">
      <span class="t-micro" style="display:block;color:var(--secondary)">For</span>
      <p class="t-rec" style="margin:6px 0 0">R. Santos Dry Goods</p>
      <p class="t-meta" style="margin:4px 0 0;color:var(--secondary)">Not registered with Grain</p>
    </div>

    <div style="padding-top:24px">
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">
        A person who was there can attest what you did. If they confirm a work
        address at the business, the record shows a person at a business Grain
        recognises rather than one it does not.</p>

      <label class="t-micro" for="em" style="display:block;color:var(--secondary);padding-bottom:8px">Their email</label>
      <div class="ruled">
        <input id="em" value="{{ email }}" onInput="{{ onE }}" inputmode="email"
               autocapitalize="none" autocorrect="off" spellcheck="false" aria-describedby="en">
      </div>
      <p id="en" class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">{{ note }}</p>

      <div style="margin-top:28px;border-top:1px solid var(--hairline);padding-top:16px">
        <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">
          They do not need the app. The link opens on the web, they confirm who
          they are, and they answer there.</p>
        <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
          A confirmed work address is a fact about the address, not about when
          they worked there. Grain records what it checked and nothing more.</p>
      </div>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press" disabled="{{ disabled }}">Send the request</button>
    <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-align:center;text-wrap:pretty">
      Asking cannot be undone.</p>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {email:'ramon@rsantosdrygoods.ph'}; }
  renderVals(){
    const v = this.state.email;
    const ok = /.+@.+\..+/.test(v);
    const free = /@(gmail|yahoo|outlook|hotmail|icloud)\./i.test(v);
    return {
      email: v, onE: (e) => this.setState({email:e.target.value}),
      note: !ok ? 'An email they can open.'
        : free ? 'A personal address attests as a person, not as the business. That is still a real witness, and the record says which it was.'
               // Not "attests as the business". ChapterDetail renders the same
               // evidence class, a confirmed work email at the business, as
               // Individual, so the same evidence produced two marks split by an
               // attribute Grain cannot check. What the check establishes is
               // control of an address at that domain, and that is what it says.
               : 'A work address at this business. Grain checks control of that address, so the record shows a person at a business it recognises.',
      disabled: ok ? null : 'disabled'
    };
  }
}
</script>
</body>
</html>
