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
    /* Nothing waiting is the correct outcome of an adjudication queue, so it is
       drawn as a statement rather than as an absence. No graticule: that ground
       belongs to the record's empty states, and a chart ground under a work
       queue would be decoration. */
    .none{padding:var(--sp10) 0 var(--sp12);border-bottom:1px solid var(--hairline)}
    .none:last-child{border-bottom:0}
  </style>
</helmet>

<div style="width:1120px;height:520px;background:var(--paper);position:relative;
            display:flex;overflow:hidden">

@@NAV@@

  <div class="pane">

  <div class="body">

    <div class="sechead">
      <span class="t-sec">Candidate pairs</span>
      <span class="t-meta" style="color:var(--secondary)">Ordered by rank weight, which is not shown</span>
    </div>

    <div class="none">
      <span class="t-lead" style="display:block">Nothing is waiting.</span>
      <span class="t-body lead" style="display:block;color:var(--secondary);padding-top:var(--sp3)">The matcher runs continuously rather than on a schedule, so a pair appears here whenever new evidence makes two records look like one person. A later verification often reveals a duplicate that was invisible at signup.</span>
    </div>

    <div class="sechead" style="margin-top:var(--sp10)">
      <span class="t-sec">Re-assignments after an unmerge</span>
      <span class="t-meta" style="color:var(--secondary)">Attestations written while two records were joined</span>
    </div>

    <div class="none">
      <span class="t-lead" style="display:block">Nothing to re-assign.</span>
      <span class="t-body lead" style="display:block;color:var(--secondary);padding-top:var(--sp3)">This fills only after an unmerge, and only with attestations a party issued during the window the records were one. Everything else moves back on its own.</span>
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
             wMerges:'off', wParties:'off', wDisputes:'' };
  }
}
</script>
</body>
</html>
