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
<!-- D2. The registered-party path: the request goes to a verified domain and
     whoever answers signs in first. 058 puts the irreversible term here, at
     the moment it binds, rather than at signup where nobody had reached it. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your record">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Ask them to attest</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:24px 0 18px;border-bottom:1px solid var(--ink)">
      <span class="t-micro" style="display:block;color:var(--secondary)">Asking</span>
      <p class="t-rec" style="margin:6px 0 0">Cebu Pacific Cargo Services</p>
      <p class="t-meta" style="margin:4px 0 0;color:var(--secondary)">
        Registered with Grain · verified domain cebupacificcargo.com</p>
    </div>

    <div class="grp">
      <div class="sechead"><h3 class="t-sec" style="margin:0">How it reaches them</h3></div>
      <div class="sinerule">@@SINERULE@@</div>
      <sc-for list="{{ steps }}" as="s" hint-placeholder-count="3">
        <div style="padding:13px 0;border-bottom:1px solid var(--hairline)">
          <span class="t-body" style="display:block;text-wrap:pretty">{{ s }}</span>
        </div>
      </sc-for>
    </div>

    <!-- 058: the term that governs this action, at this action, with a flag
         recorded here. It was one of seven blocks at signup that nobody read. -->
    <div class="grp">
      <div class="warn">
        <p class="t-rec" style="margin:0;color:var(--paper);text-wrap:pretty">
          Asking cannot be undone.</p>
        <p class="t-data" style="margin:8px 0 0;text-wrap:pretty">
          Once you ask, what they write is permanent for as long as your record
          exists. You cannot edit it and they cannot withdraw it. You can attach
          your side to it, and Grain will not judge whether they were fair.</p>
      </div>
    </div>

    <div class="grp">
      <p class="t-meta" style="margin:0;color:var(--secondary);text-wrap:pretty">
        If you would rather not, the chapter stays on your record as your own
        account of it. That is a smaller claim, and it is still a true one.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Send the request, and agree to this</button>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { steps: [
      'The request goes to their verified domain, not to a person you name.',
      'Whoever answers it signs in first, so the record knows who attested.',
      'They answer on the web. They do not need the app, then or ever.'
    ]};
  }
}
</script>
</body>
</html>
