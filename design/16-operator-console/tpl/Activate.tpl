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

<div style="width:1120px;height:948px;background:var(--paper);position:relative;
            display:flex;overflow:hidden">

@@NAV@@

  <div class="pane">

  <div class="casebar">
    <button type="button" class="back press">
      <svg width="18" height="18" viewBox="0 0 18 18" aria-hidden="true"><path d="M11 4 L6 9 L11 14"></path></svg>
      Parties
    </button>
    <span class="crumbsep"></span>
    <span class="t-serial" style="color:var(--secondary)">Cebu Pacific Air Services</span>
    <span class="barsp"></span>
    <span class="views" role="group" aria-label="Views">
      <button type="button" aria-current="page">Overview</button>
      <button type="button" aria-current="false">Capabilities</button>
      <button type="button" aria-current="false">Keys</button>
    </span>
  </div>

  <div class="body">

    <h1 class="t-head lead" style="margin:0">Two things have to be true before this party can write anything</h1>
    <p class="t-body lead" style="margin:var(--sp4) 0 0;color:var(--secondary)">Neither is a box anyone can tick. Both are asked again every time this screen loads, and both are re-asked afterwards, so a party activated correctly under conditions that later lapsed shows up here rather than staying quietly live.</p>

    <div class="sechead" style="margin-top:var(--sp10)">
      <span class="t-sec">The two gates</span>
      <span class="t-meta" style="color:var(--secondary)">Asked at 16:41, just now</span>
    </div>

    <div class="limb">
      <span class="limbmark">
        <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)" stroke-dasharray="2.4 2.2"></rect></svg>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">No witnessed transparency log is accepting entries</span>
        <span class="t-body lead" style="display:block;color:var(--secondary);padding-top:3px">Asked of the kernel directly, every time. Nothing stores the answer, because a stored answer is one write away from being changed by whoever is under the most pressure to change it.</span>
      </span>
      <span class="t-data col-r" style="flex:0 0 150px;color:var(--secondary)">Not satisfied</span>
    </div>

    <div class="limb" style="border-bottom:0">
      <span class="limbmark">
        <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1" y="1" width="12" height="12" fill="var(--ink)"></rect></svg>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">The liability instrument is executed and applies to them</span>
        <span class="t-body lead" style="display:block;color:var(--secondary);padding-top:3px">Checked field by field rather than pointed at: their legal identity, instrument version 2.1, executed 11 August, effective 1 September, Philippines, and a scope that covers attesting about their own workers.</span>
      </span>
      <span class="t-data col-r" style="flex:0 0 150px;color:var(--secondary)">Satisfied</span>
    </div>

    <div class="sechead" style="margin-top:var(--sp10)">
      <span class="t-sec">The clock</span>
      <span class="t-meta" style="color:var(--secondary)">Started when they reached pending</span>
    </div>

    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Pending since</span>
      <span class="t-data" style="flex:1;min-width:0">4 August 2026, seventeen days</span>
    </div>
    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">First external</span>
      <span class="t-data" style="flex:1;min-width:0">They are it. The log was owed before anyone reached this screen</span>
    </div>
    <div class="drow" style="border-bottom:0">
      <span class="dk t-data" style="color:var(--secondary)">Record limb</span>
      <span class="t-data" style="flex:1;min-width:0">418,000 of a million, on the current rate about eleven weeks out</span>
    </div>

    <div class="warn" style="margin-top:var(--sp10);max-width:760px">
      <span class="t-rec" style="display:block;color:var(--paper)">Going ahead anyway is possible, and it is signed</span>
      <span class="t-body" style="display:block;color:var(--paper);padding-top:var(--sp3);text-wrap:pretty">Activating without the log takes a governance event carrying your name and your reason, appended where it cannot be removed. It exists so the decision can be made under real pressure and still be found afterwards. Leaving them in pending is not a way around it: the clock keeps running and this screen keeps saying so.</span>
    </div>

  </div>

  <div class="band-act">
    <p class="t-meta lead" style="margin:0 0 var(--sp6);color:var(--secondary)">Activation stays closed while a gate is unmet. Nothing on this screen forces one open.</p>
    <div class="acts">
      <button type="button" class="btn-primary" disabled>Activate</button>
      <button type="button" class="btn-secondary press">Record a signed slip</button>
      <button type="button" class="btn-tertiary press">Leave them pending</button>
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
