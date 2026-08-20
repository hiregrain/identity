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
<!-- D5. What a request looks like afterwards, which nothing drew. The state
     matters because the worker cannot chase it inside Grain: a party is under
     no obligation, and a screen that implied otherwise would be lying about
     the one thing the worker cannot control. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your record">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Request sent</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:24px 0 16px;border-bottom:1px solid var(--ink)">
      <div class="said">
        <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><use href="#i-tick"></use></svg>
        <span style="flex:1;min-width:0">
          <span class="t-rec" style="display:block;text-wrap:pretty">Sent to Cebu Pacific Cargo Services</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px">
            Today, to their verified domain</span>
        </span>
      </div>
    </div>

    <div class="grp">
      <div class="sechead"><h3 class="t-sec" style="margin:0">What happens now</h3></div>
      <div class="sinerule">@@SINERULE@@</div>
      <sc-for list="{{ states }}" as="s" hint-placeholder-count="3">
        <div style="display:flex;gap:12px;align-items:flex-start;padding:12px 0;
                    border-bottom:1px solid var(--hairline)">
          <span style="flex:0 0 20px;padding-top:2px">
            <sc-if value="{{ s.done }}" hint-placeholder-val="{{ true }}">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--ink)"
                   stroke-width="1.5" aria-hidden="true"><use href="#i-tick"></use></svg>
            </sc-if>
          </span>
          <span style="flex:1;min-width:0">
            <span class="t-body" style="display:block;color:{{ s.color }};text-wrap:pretty">{{ s.label }}</span>
            <sc-if value="{{ s.note }}" hint-placeholder-val="{{ true }}">
              <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">{{ s.note }}</span>
            </sc-if>
          </span>
        </div>
      </sc-for>
    </div>

    <div class="grp">
      <p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">
        Grain will not chase them and cannot make them answer. A party is free to
        ignore a request, and a record that pretended otherwise would be
        promising you something it does not control.</p>
      <p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">
        You will be told if they attest. Until then the chapter stays as your own
        account of it, which is what it already was.</p>
    </div>
  </main>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { states: [
      {label:'The request reached their verified domain', done:true, color:'var(--ink)',
       note:'Whoever answers it signs in first, so Grain knows who attested.'},
      {label:'Waiting for someone there to answer', done:false, color:'var(--ink)',
       note:'No deadline. There is no way for Grain to impose one on a party that owes you nothing.'},
      {label:'If they attest, the chapter fills in on your record', done:false, color:'var(--secondary)'}
    ]};
  }
}
</script>
</body>
</html>
