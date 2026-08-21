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

<div style="width:1120px;height:1024px;background:var(--paper);position:relative;
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
      <button type="button" aria-current="false">Capabilities</button>
      <button type="button" aria-current="page">Keys</button>
    </span>
  </div>

  <div class="body">

    <h1 class="t-head lead" style="margin:0">Whether their connection is healthy, and whether we agree about what they wrote</h1>
    <p class="t-body lead" style="margin:var(--sp4) 0 0;color:var(--secondary)">We hold their public key and never their private one, so nothing here can be repaired from this side. What you can do is see the state early enough to tell them.</p>

    <div class="sechead" style="margin-top:var(--sp10)">
      <span class="t-sec">Their key</span>
      <span class="t-meta" style="color:var(--secondary)">Public half only</span>
    </div>

    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">In use</span>
      <span class="t-data" style="flex:1;min-width:0">kid 9c41-e2, registered 22 July, valid to 20 October</span>
    </div>
    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Custody</span>
      <span class="t-data" style="flex:1;min-width:0">Theirs, generated in their own environment and proved by signature before it was registered</span>
    </div>
    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Renewal</span>
      <span style="flex:1;min-width:0">
        <span class="t-data" style="display:block">Automatic, last succeeded 22 July</span>
        <span class="t-meta lead" style="display:block;color:var(--secondary);padding-top:3px">If a renewal stops working their writes stop with it, because the halt is read off the key&#39;s own validity rather than set by anyone. Nobody has to notice, and nobody can forget to lift it either.</span>
      </span>
    </div>
    <div class="drow" style="border-bottom:0">
      <span class="dk t-data" style="color:var(--secondary)">Rotations</span>
      <span class="t-data" style="flex:1;min-width:0">Four since February, one of which failed and was retried the same day</span>
    </div>

    <div class="sechead" style="margin-top:var(--sp10)">
      <span class="t-sec">Traffic against what they declared</span>
      <span class="t-meta" style="color:var(--secondary)">This quarter</span>
    </div>

    <div class="staterow" style="display:flex;gap:var(--sp7);align-items:flex-start;padding:13px 0;border-bottom:1px solid var(--hairline)">
      <span style="flex:0 0 168px">
        <span class="t-data" style="display:block;color:var(--secondary)">1,240 of 4,000</span>
        <span class="band" style="margin-top:var(--sp3)"><i style="width:31%"></i></span>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Attestations written</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">Their cap is ten times the volume they told us to expect, and it is reviewed at ninety days</span>
      </span>
      <span class="t-data col-r" style="flex:0 0 190px;color:var(--secondary)">Well inside</span>
    </div>

    <div class="staterow" style="display:flex;gap:var(--sp7);align-items:flex-start;padding:13px 0;border-bottom:0">
      <span style="flex:0 0 168px">
        <span class="t-data" style="display:block;color:var(--secondary)">Passed 4 August</span>
        <span class="band" style="margin-top:var(--sp3)"><i style="width:100%"></i></span>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Conformance suite</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">Run against the published vectors, on the schema version they are pinned to</span>
      </span>
      <span class="t-data col-r" style="flex:0 0 190px;color:var(--secondary)">Schema 0.3</span>
    </div>

    <div class="sechead" style="margin-top:var(--sp10)">
      <span class="t-sec">Do they agree with us</span>
      <span class="t-meta" style="color:var(--secondary)">Countersigned monthly, by them</span>
    </div>

    <div class="row">
      <span class="gutter"><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1" y="1" width="12" height="12" fill="var(--ink)"></rect></svg></span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">July agreed</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">They signed the same root we hold, so their records and ours describe the same set</span>
      </span>
      <span class="t-data col-r" style="color:var(--secondary)">Signed 2 Aug</span>
    </div>
    <div class="row" style="border-bottom:0">
      <span class="gutter"><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)" stroke-dasharray="2.4 2.2"></rect></svg></span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">August is not signed yet</span>
        <span class="t-meta lead" style="display:block;color:var(--secondary);padding-top:var(--sp1)">A signature that disagrees tells them something is wrong but not what. Their own feed is where they find the entry, and only they can open it</span>
      </span>
      <span class="t-data col-r" style="color:var(--secondary)">Due 2 Sep</span>
    </div>

    <div class="internal" style="border-top:1px solid var(--rule);margin-top:var(--sp9);padding-top:var(--sp5)">
      <span class="t-micro" style="color:var(--secondary)">Not on this screen, and not anywhere in the console</span>
      <p class="t-meta lead" style="margin:var(--sp2) 0 0;color:var(--secondary)">Which people this party has written about. Records reach them under a pseudonym that is theirs alone, so two parties writing about the same person hold values that cannot be lined up, and no view here undoes that. If a dispute needs a specific entry, ask them for it from their own feed.</p>
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
