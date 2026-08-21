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

<div style="width:1120px;height:924px;background:var(--paper);position:relative;
            display:flex;overflow:hidden">

@@NAV@@

  <div class="pane">

  <div class="casebar">
    <button type="button" class="back press">
      <svg width="18" height="18" viewBox="0 0 18 18" aria-hidden="true"><path d="M11 4 L6 9 L11 14"></path></svg>
      Parties
    </button>
    <span class="crumbsep"></span>
    <span class="t-serial" style="color:var(--secondary)">Alorica Philippines</span>
    <span class="barsp"></span>
    <span class="views" role="group" aria-label="Views">
      <button type="button" aria-current="false">Overview</button>
      <button type="button" aria-current="page">Capabilities</button>
      <button type="button" aria-current="false">Keys</button>
    </span>
  </div>

  <div class="body">

    <h1 class="t-head lead" style="margin:0">What this party is allowed to do</h1>
    <p class="t-body lead" style="margin:var(--sp4) 0 0;color:var(--secondary)">Each one is granted on its own and revoked on its own. Their tier grants nothing, being active grants nothing, and they cannot give themselves any of these. Every grant and every revocation is an event with your name on it.</p>

    <div class="sechead" style="margin-top:var(--sp10)">
      <span class="t-sec">Grants</span>
      <span class="t-meta" style="color:var(--secondary)">In force now</span>
    </div>

    <div class="cap">
      <span class="capname">
        <span class="t-rec" style="display:block">Write attestations</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px">Scoped to their own workers</span>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-data" style="display:block">Granted 12 February by R. Alvarez</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Capped at 4,000 writes a quarter, which ingestion reads fresh on every request</span>
      </span>
      <button type="button" class="btn-tertiary press" style="flex:0 0 auto">Revoke</button>
    </div>

    <div class="cap">
      <span class="capname">
        <span class="t-rec" style="display:block">Read prior packets</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px">Only under a worker grant</span>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-data" style="display:block">Granted 12 February by R. Alvarez</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">This lets them ask. Whether any given record answers is the worker&#39;s decision, not this grant</span>
      </span>
      <button type="button" class="btn-tertiary press" style="flex:0 0 auto">Revoke</button>
    </div>

    <div class="cap" style="border-bottom:0">
      <span class="capname">
        <span class="t-rec" style="display:block">File a safety marker</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px">The heaviest thing a party can do</span>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-data" style="display:block">Not granted, and not grantable today</span>
        <span class="t-meta lead" style="display:block;color:var(--secondary);padding-top:3px">It needs a signed addendum on file from this party, effective and unrevoked, because filing puts them into joint controllership and routes worker challenges to them. There is no addendum here, so the control below is closed rather than merely unused.</span>
      </span>
      <button type="button" class="btn-tertiary" disabled style="flex:0 0 auto;opacity:1;color:var(--secondary);text-decoration:none">No addendum</button>
    </div>

    <div class="sechead" style="margin-top:var(--sp10)">
      <span class="t-sec">Everything that ever changed</span>
      <span class="t-meta" style="color:var(--secondary)">Appended, never edited</span>
    </div>

    <div class="row">
      <span class="gutter"><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1" y="1" width="12" height="12" fill="var(--ink)"></rect></svg></span>
      <span style="flex:1;min-width:0"><span class="t-data">Read prior packets, granted by R. Alvarez</span></span>
      <span class="t-data col-r" style="color:var(--secondary)">12 Feb 2026</span>
    </div>
    <div class="row">
      <span class="gutter"><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1" y="1" width="12" height="12" fill="var(--ink)"></rect></svg></span>
      <span style="flex:1;min-width:0"><span class="t-data">Write attestations, granted by R. Alvarez</span></span>
      <span class="t-data col-r" style="color:var(--secondary)">12 Feb 2026</span>
    </div>
    <div class="row" style="border-bottom:0">
      <span class="gutter"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" stroke="var(--ink)" stroke-width="1.5" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11"></rect><path d="M4 7 H10"></path></svg></span>
      <span style="flex:1;min-width:0">
        <span class="t-data" style="display:block">Write attestations, revoked by D. Okafor, then granted again the same day</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px">Key rotation failed and was fixed. Both events stay</span>
      </span>
      <span class="t-data col-r" style="color:var(--secondary)">3 Jun 2026</span>
    </div>

  </div>

  <div class="band-act">
    <p class="t-meta lead" style="margin:0 0 var(--sp6);color:var(--secondary)">A revocation takes effect on their next request. It does not reach back to anything they have already written.</p>
    <div class="acts">
      <button type="button" class="btn-secondary press">Add a grant</button>
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
