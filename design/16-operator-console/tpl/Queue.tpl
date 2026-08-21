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
    .qrow{display:flex;gap:var(--sp7);align-items:center;padding:13px 0;
          border-bottom:1px solid var(--hairline);width:100%;min-height:44px;text-align:left}
    .qrow::after{content:'';flex:0 0 7px;height:7px;align-self:center;
      border-right:1.5px solid var(--rule);border-top:1.5px solid var(--rule);
      transform:rotate(45deg);margin-left:var(--sp2)}
    .qrow:hover{background:rgba(27,42,68,.04)}
    .pair{flex:1;min-width:0}
    .need{flex:0 0 210px}
    .waited{flex:0 0 96px}
  </style>
</helmet>

<div style="width:1120px;height:556px;background:var(--paper);position:relative;
            display:flex;overflow:hidden">

@@NAV@@

  <div class="pane">

  <div class="body">

    <div class="sechead">
      <span class="t-sec">Candidate pairs</span>
      <span class="t-meta" style="color:var(--secondary)">Ordered by rank weight, which is not shown</span>
    </div>

    <button type="button" class="qrow press">
      <span class="gutter">
        <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)"></rect><path d="M2 2 H7 V12 H2 Z" fill="var(--ink)"></path></svg>
      </span>
      <span class="pair">
        <span class="t-rec" style="display:block">Maria Cristina Santos Reyes</span>
        <span class="t-rec" style="display:block;color:var(--secondary)">Ma. Cristina S. Reyes</span>
      </span>
      <span class="t-data col-r need" style="color:var(--secondary)">Two operators, one given</span>
      <span class="t-data col-r waited" style="color:var(--secondary)">2 days</span>
    </button>

    <button type="button" class="qrow press">
      <span class="gutter">
        <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)"></rect></svg>
      </span>
      <span class="pair">
        <span class="t-rec" style="display:block">Joselito B. Cruz</span>
        <span class="t-rec" style="display:block;color:var(--secondary)">Jose Lito Cruz</span>
      </span>
      <span class="t-data col-r need" style="color:var(--secondary)">Two operators</span>
      <span class="t-data col-r waited" style="color:var(--secondary)">2 days</span>
    </button>

    <button type="button" class="qrow press">
      <span class="gutter">
        <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)"></rect></svg>
      </span>
      <span class="pair">
        <span class="t-rec" style="display:block">Nguyen Thi Mai</span>
        <span class="t-rec" style="display:block;color:var(--secondary)">Nguy&#7877;n Th&#7883; Mai</span>
      </span>
      <span class="t-data col-r need" style="color:var(--secondary)">One operator</span>
      <span class="t-data col-r waited" style="color:var(--secondary)">4 days</span>
    </button>

    <button type="button" class="qrow press">
      <span class="gutter">
        <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)"></rect></svg>
      </span>
      <span class="pair">
        <span class="t-rec" style="display:block">Rajesh Kumar Nair</span>
        <span class="t-rec" style="display:block;color:var(--secondary)">R. K. Nair</span>
      </span>
      <span class="t-data col-r need" style="color:var(--secondary)">One operator</span>
      <span class="t-data col-r waited" style="color:var(--secondary)">5 days</span>
    </button>

    <button type="button" class="qrow press">
      <span class="gutter">
        <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)"></rect></svg>
      </span>
      <span class="pair">
        <span class="t-rec" style="display:block">Aditi Sharma</span>
        <span class="t-rec" style="display:block;color:var(--secondary)">Aditi Sharma</span>
      </span>
      <span class="t-data col-r need" style="color:var(--secondary)">One operator</span>
      <span class="t-data col-r waited" style="color:var(--secondary)">6 days</span>
    </button>

    <div class="skel" style="border-bottom:0;padding-top:18px">
      <span style="width:38%"></span>
      <span style="width:26%"></span>
    </div>

  </div>

  </div>

</div>
</x-dc>

<script data-dc-script data-props='{}'>
class Component extends DCLogic {
  renderVals(){
    return { tab:'merges', acMerges:'page', acParties:'false',
             acMarkers:'false', acDisputes:'false', acDeletions:'false',
      wMerges:'', wParties:'off', wDisputes:'', };
  }
}
</script>
</body>
</html>
