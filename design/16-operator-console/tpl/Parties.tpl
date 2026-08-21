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
    .prow2{display:flex;gap:var(--sp7);align-items:center;padding:13px 0;
           border-bottom:1px solid var(--hairline);width:100%;min-height:44px;text-align:left}
    .prow2::after{content:'';flex:0 0 7px;height:7px;align-self:center;
      border-right:1.5px solid var(--rule);border-top:1.5px solid var(--rule);
      transform:rotate(45deg);margin-left:var(--sp2)}
    .prow2:hover{background:rgba(27,42,68,.04)}
    .asks{flex:0 0 250px}
    .waited{flex:0 0 96px}
  </style>
</helmet>

<div style="width:1120px;height:600px;background:var(--paper);position:relative;
            display:flex;overflow:hidden">

@@NAV@@

  <div class="pane">

  <div class="body">

    <div class="sechead">
      <span class="t-sec">Parties waiting on a decision</span>
      <span class="t-meta" style="color:var(--secondary)">Oldest first</span>
    </div>

    <button type="button" class="prow2 press">
      <span class="gutter">
        <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)"></rect></svg>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Northgate Learning Institute</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">Writes frozen. No finding has been made</span>
      </span>
      <span class="t-data col-r asks" style="color:var(--secondary)">Accreditation not on the list</span>
      <span class="t-data col-r waited" style="color:var(--secondary)">6 days</span>
    </button>

    <button type="button" class="prow2 press">
      <span class="gutter">
        <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)" stroke-dasharray="2.4 2.2"></rect></svg>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Iloilo BPO Holdings</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">Probationary, ninety days elapsed</span>
      </span>
      <span class="t-data col-r asks" style="color:var(--secondary)">Probation review due</span>
      <span class="t-data col-r waited" style="color:var(--secondary)">3 days</span>
    </button>

    <button type="button" class="prow2 press">
      <span class="gutter">
        <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)" stroke-dasharray="2.4 2.2"></rect></svg>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Davao Contact Solutions</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">Probationary, asking for room to write more</span>
      </span>
      <span class="t-data col-r asks" style="color:var(--secondary)">Cap increase requested</span>
      <span class="t-data col-r waited" style="color:var(--secondary)">2 days</span>
    </button>

    <button type="button" class="prow2 press">
      <span class="gutter">
        <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)"></rect></svg>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Cebu Pacific Air Services</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">New registration, diligence filed</span>
      </span>
      <span class="t-data col-r asks" style="color:var(--secondary)">First review, tier not set</span>
      <span class="t-data col-r waited" style="color:var(--secondary)">1 day</span>
    </button>

    <div class="skel" style="border-bottom:0;padding-top:18px">
      <span style="width:34%"></span>
      <span style="width:22%"></span>
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
