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

<div style="width:1120px;height:604px;background:var(--paper);position:relative;
            display:flex;overflow:hidden">

@@NAV@@

  <div class="pane">

  <div class="casebar">
    <button type="button" class="back press">
      <svg width="18" height="18" viewBox="0 0 18 18" aria-hidden="true"><path d="M11 4 L6 9 L11 14"></path></svg>
      Merges
    </button>
    <span class="crumbsep"></span>
    <span class="t-serial" style="color:var(--secondary)">Case 0f31-88</span>
    <span class="barsp"></span>
  </div>

  <div class="body">

    <div class="said" style="padding-top:0">
      <svg width="16" height="16" viewBox="0 0 16 16" aria-hidden="true"><path d="M3 8.5 L6.5 12 L13 4"></path></svg>
      <span style="flex:1;min-width:0">
        <span class="t-sec" style="display:block">Your approval is recorded, and nothing is merged</span>
        <span class="t-body lead" style="display:block;color:var(--secondary);padding-top:var(--sp3)">The case goes back to the queue marked as needing a second operator. Any operator except you can complete it. Until one does, both records stay exactly as they are.</span>
      </span>
    </div>

    <div style="margin-top:var(--sp10)">
      <span class="t-micro" style="color:var(--secondary)">This case needs two operators</span>
      <div class="slots">
        <span class="slot">
          <span class="t-micro" style="display:block;color:var(--secondary)">First approval</span>
          <span class="t-rec" style="display:block;padding-top:var(--sp2)">D. Okafor, operator</span>
          <span class="t-meta" style="display:block;color:var(--secondary)">Today, 16:24</span>
        </span>
        <span class="slot open">
          <span class="t-micro" style="display:block;color:var(--secondary)">Second approval</span>
          <span class="t-rec" style="display:block;padding-top:var(--sp2)">Not yet given</span>
          <span class="t-meta" style="display:block;color:var(--secondary)">Someone other than you</span>
        </span>
      </div>
    </div>

    <div class="sechead" style="margin-top:var(--sp11)">
      <span class="t-sec">What you approved</span>
      <span class="t-meta" style="color:var(--secondary)">Held against your name until it executes</span>
    </div>

    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">Decision</span>
      <span class="t-data" style="flex:1;min-width:0">One person. Record 41ae is absorbed into record 8f2c</span>
    </div>
    <div class="drow">
      <span class="dk t-data" style="color:var(--secondary)">The records</span>
      <span class="t-data" style="flex:1;min-width:0">Maria Cristina Santos Reyes, and Ma. Cristina S. Reyes</span>
    </div>
    <div class="drow" style="border-bottom:0">
      <span class="dk t-data" style="color:var(--secondary)">Withdraw</span>
      <span style="flex:1;min-width:0">
        <span class="t-data" style="display:block">Open the case and choose again</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">An approval that has not executed can be taken back. The withdrawal appends too</span>
      </span>
    </div>

  </div>

  <div class="band-act">
    <div class="acts">
      <button type="button" class="btn-primary press">Back to Merges</button>
      <button type="button" class="btn-tertiary press">Withdraw my approval</button>
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
