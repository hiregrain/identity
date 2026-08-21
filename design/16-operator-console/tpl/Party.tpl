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
    /* The freeze is a state, not a danger, so it takes a bordered block rather
       than the ink inversion. Suspension is the danger, and it is the only
       thing on this screen that gets the inverted treatment. */
    .state{border:1px solid var(--rule);border-radius:3px;padding:var(--sp7) var(--sp8);
           margin-top:var(--sp9);max-width:760px}
    .internal{border-top:1px solid var(--rule);margin-top:var(--sp9);padding-top:var(--sp5)}
  </style>
</helmet>

<div style="width:1120px;height:1000px;background:var(--paper);position:relative;
            display:flex;overflow:hidden">

@@NAV@@

  <div class="pane">

  <div class="casebar">
    <button type="button" class="back press">
      <svg width="18" height="18" viewBox="0 0 18 18" aria-hidden="true"><path d="M11 4 L6 9 L11 14"></path></svg>
      Parties
    </button>
    <span class="crumbsep"></span>
    <span class="t-serial" style="color:var(--secondary)">Northgate Learning Institute</span>
    <span class="barsp"></span>
    <span class="views" role="group" aria-label="Views">
      <button type="button" aria-current="page">Overview</button>
      <button type="button" aria-current="false">Capabilities</button>
      <button type="button" aria-current="false">Keys</button>
    </span>
  </div>

  <div class="body">

    <h1 class="t-head lead" style="margin:0">Their accreditation is no longer on the list we check</h1>
    <p class="t-body lead" style="margin:var(--sp4) 0 0;color:var(--secondary)">New writes are frozen while that is true. Deciding whether it means anything is your job, and doing nothing is a legitimate answer.</p>

    <div class="state">
      <span class="t-rec" style="display:block">Frozen, and not suspended</span>
      <span class="t-body lead" style="display:block;color:var(--secondary);padding-top:var(--sp3)">The party is still active and under no finding. Everything they issued before stays valid and carries no flag. External registries change names and lose rows often enough that an automatic suspension here would take honest parties offline, which is why the freeze happens on its own and the suspension never does.</span>
      <span class="t-body lead" style="display:block;padding-top:var(--sp5)">It lifts by itself the next time the accreditation check passes. You do not have to come back.</span>
    </div>

    <div class="sechead" style="margin-top:var(--sp11)">
      <span class="t-sec">The registry entry</span>
      <span class="t-meta" style="color:var(--secondary)">Public history, and what only we see</span>
    </div>

    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Status</span>
      <span class="t-data" style="flex:1;min-width:0">Active since 4 February 2026, never suspended</span>
    </div>
    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Keys</span>
      <span class="t-data" style="flex:1;min-width:0">Held by the party, rotated 11 August 2026</span>
    </div>
    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Checked against</span>
      <span style="flex:1;min-width:0">
        <span class="t-data" style="display:block">A closed accreditation list, re-read every ninety days</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Last pass 22 May, first absence 15 August. A renamed institution and a withdrawn accreditation look identical from here</span>
      </span>
    </div>
    <div class="drow" style="border-bottom:0">
      <span class="dk t-data" style="color:var(--secondary)">Attested</span>
      <span class="t-data" style="flex:1;min-width:0">412 qualifications, across term dates from 2019 onward</span>
    </div>

    <div class="internal">
      <span class="t-micro" style="color:var(--secondary)">Internal only, and it leaves on no packet, no API and no attestation</span>
      <p class="t-meta lead" style="margin:var(--sp2) 0 var(--sp4);color:var(--secondary)">None of this composites into a score, and nothing here is shown to the party or to anyone reading a record. Do not paste it into a support thread.</p>
      <div class="drow">
        <span class="dk t-data" style="color:var(--secondary)">Tier</span>
        <span class="t-data" style="flex:1;min-width:0">External, standard</span>
      </div>
      <div class="drow">
        <span class="dk t-data" style="color:var(--secondary)">Declared cap</span>
        <span class="t-data" style="flex:1;min-width:0">4,000 writes a quarter, ten times their stated volume</span>
      </div>
      <div class="drow" style="border-bottom:0">
        <span class="dk t-data" style="color:var(--secondary)">Signals</span>
        <span style="flex:1;min-width:0">
          <span class="t-data" style="display:block">Disputes 0.4 per hundred, corrections 1.1, corroboration 78 per hundred</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Each stated separately because none of them means anything added to the others</span>
        </span>
      </div>
    </div>

    <div class="warn" style="margin-top:var(--sp11);max-width:760px">
      <span class="t-rec" style="display:block;color:var(--paper)">Suspending them is a finding, and it is permanent in the public history</span>
      <span class="t-body" style="display:block;color:var(--paper);padding-top:var(--sp3);text-wrap:pretty">It needs a reason code, it never reaches back to what they already issued, and every record carrying their attestation gains a line saying the issuer was later suspended. A missing row on someone else&#39;s list is not evidence of anything they did.</span>
    </div>

  </div>

  <div class="band-act">
    <p class="t-meta lead" style="margin:0 0 var(--sp6);color:var(--secondary)">The freeze holds either way. The first choice records that you looked and found nothing, and leaves the check to clear it.</p>
    <div class="acts">
      <button type="button" class="btn-primary press">No finding, leave it to lift</button>
      <button type="button" class="btn-secondary press">Ask them about the accreditation</button>
      <button type="button" class="btn-tertiary press">Open a suspension</button>
    </div>
  </div>

  </div>

</div>
</x-dc>

<script data-dc-script data-props='{}'>
class Component extends DCLogic {
  renderVals(){
    return { tab:'parties', acMerges:'false', acParties:'page',
             acMarkers:'false', acDisputes:'false', acDeletions:'false',
             wMerges:'', wParties:'', wDisputes:'' };
  }
}
</script>
</body>
</html>
