<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
@@CONSOLE@@
  </style>
</helmet>

<div style="width:1120px;height:920px;background:var(--paper);position:relative;
            display:flex;overflow:hidden">

@@NAV@@

  <div class="pane">

  <div class="casebar">
    <button type="button" class="back press">
      <svg width="18" height="18" viewBox="0 0 18 18" aria-hidden="true"><path d="M11 4 L6 9 L11 14"></path></svg>
      Markers
    </button>
    <span class="crumbsep"></span>
    <span class="t-serial" style="color:var(--secondary)">Match 7c02</span>
    <span class="barsp"></span>
    <span class="tier">
      <svg width="11" height="12" viewBox="0 0 11 12" aria-hidden="true"><rect x="0.75" y="5.25" width="9.5" height="6"></rect><path d="M2.9 5.25 V3.2 A2.6 2.6 0 0 1 8.1 3.2 V5.25"></path></svg>
      <span class="t-micro">Separately granted</span>
    </span>
  </div>

  <div class="body">

    <h1 class="t-head" style="margin:0;max-width:660px;text-wrap:balance">Is the person re-registering the person this document belongs to?</h1>
    <p class="t-body lead" style="margin:var(--sp4) 0 0;color:var(--secondary)">The account is already open and already restricted. Nothing you choose closes it, and the marker expires on its own clock either way.</p>

    <div class="warn" style="margin-top:var(--sp9);max-width:760px">
      <span class="t-rec" style="display:block;color:var(--paper)">You cannot see what was found</span>
      <span class="t-body" style="display:block;color:var(--paper);padding-top:var(--sp3);text-wrap:pretty">Grain holds no account of the finding: no narrative, no cause, nothing beyond the category below. If your decision would turn on what happened, send it to Alorica Philippines. A challenge from the worker goes to them as well, not to Grain.</span>
    </div>

    <div class="sechead" style="margin-top:var(--sp11)">
      <span class="t-sec">The marker</span>
      <span class="t-meta" style="color:var(--secondary)">Everything it holds</span>
    </div>

    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Category</span>
      <span class="t-data" style="flex:1;min-width:0">Safety, most critical</span>
    </div>
    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Filed by</span>
      <span class="t-data" style="flex:1;min-width:0">Alorica Philippines, under a live filing grant</span>
    </div>
    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Filed</span>
      <span class="t-data" style="flex:1;min-width:0">12 March 2026</span>
    </div>
    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Expires</span>
      <span class="t-data" style="flex:1;min-width:0">12 March 2028. The clock cannot be extended from here or anywhere</span>
    </div>
    <div class="drow" style="border-bottom:0">
      <span class="dk t-data" style="color:var(--secondary)">Matched on</span>
      <span style="flex:1;min-width:0">
        <span class="t-data" style="display:block">The keyed hash of a document identifier, exactly</span>
        <span class="t-meta lead" style="display:block;color:var(--secondary);padding-top:3px">Two different documents do not collide, so this is the same document. The same document is not the same person: a shared, borrowed or stolen one produces this screen too, and that is what you are here to separate.</span>
      </span>
    </div>

    <div class="sechead" style="margin-top:var(--sp10)">
      <span class="t-sec">The registration in front of you</span>
      <span class="t-meta" style="color:var(--secondary)">New id, issued today</span>
    </div>

    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Name given</span>
      <span class="t-data" style="flex:1;min-width:0">Ramil A. Delos Santos</span>
    </div>
    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Document</span>
      <span class="t-data" style="flex:1;min-width:0">PhilSys national ID, Philippines, presented at signup</span>
    </div>
    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Identity check</span>
      <span style="flex:1;min-width:0">
        <span class="t-data" style="display:block">Not run</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Verification is one of the things the restriction holds, so you have the document as given and no more</span>
      </span>
    </div>
    <div class="drow" style="border-bottom:0">
      <span class="dk t-data" style="color:var(--secondary)">Account now</span>
      <span style="flex:1;min-width:0">
        <span class="t-data" style="display:block">Usable and restricted</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">No verification, no attestations, no grants. They can sign in, read and build their record</span>
      </span>
    </div>

  </div>

  <div class="band-act">
    <p class="t-meta lead" style="margin:0 0 var(--sp6);color:var(--secondary)">The first two lift or sustain the restriction until the marker expires. Neither closes the account, and no choice here can.</p>
    <div class="acts">
      <button type="button" class="btn-secondary press">The same person</button>
      <button type="button" class="btn-secondary press">Not the same person</button>
      <button type="button" class="btn-tertiary press">Cannot determine on this evidence</button>
    </div>
  </div>

  </div>

</div>
</x-dc>

<script data-dc-script data-props='{}'>
class Component extends DCLogic {
  renderVals(){
    return { tab:'markers', acMerges:'false', acParties:'false',
             acMarkers:'page', acDisputes:'false', acDeletions:'false',
             wMerges:'', wParties:'off', wDisputes:'' };
  }
}
</script>
</body>
</html>
