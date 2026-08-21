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
    /* A state view, not a work queue. A row here states a fact, so it carries
       no chevron and no hover: the chassis rule is that a fact dressed as a
       control lies about what can be changed. */
    .staterow{display:flex;gap:var(--sp7);align-items:flex-start;padding:13px 0;
              border-bottom:1px solid var(--hairline)}
    .clock{flex:0 0 168px}
    .clock .band{margin-top:var(--sp3)}
    .outcome{flex:0 0 200px}
    /* The exception row is the one thing here an operator acts on, so it is the
       only row that holds a control. */
    .exrow{display:flex;gap:var(--sp7);align-items:center;padding:var(--sp7) 0;
           border-bottom:1px solid var(--hairline)}
  </style>
</helmet>

<div style="width:1120px;height:620px;background:var(--paper);position:relative;
            display:flex;overflow:hidden">

@@NAV@@

  <div class="pane">

  <div class="body">

    <div class="sechead">
      <span class="t-sec">Waiting on a person</span>
      <span class="t-meta" style="color:var(--secondary)">The only part of this screen you act on</span>
    </div>

    <div class="exrow">
      <span class="gutter">
        <svg width="14" height="14" viewBox="0 0 14 14" fill="none" stroke="var(--ink)" stroke-width="1.5" aria-hidden="true"><path d="M7 2 V8.5"></path><path d="M7 11 V11.5"></path></svg>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Alorica Philippines has not answered in 27 days</span>
        <span class="t-meta lead" style="display:block;color:var(--secondary);padding-top:3px">The window closes in 3 days. After that the attestation carries an unresolved dispute with the issuer recorded as unresponsive, and that reaches their reliability signal.</span>
      </span>
      <button type="button" class="btn-secondary press" style="width:auto;padding:12px 18px;flex:0 0 auto">Open the case</button>
    </div>

    <div class="sechead" style="margin-top:var(--sp10)">
      <span class="t-sec">Running on their own</span>
      <span class="t-meta" style="color:var(--secondary)">No operator needed, nothing to remember</span>
    </div>

    <div class="staterow">
      <span class="clock">
        <span class="t-data" style="display:block;color:var(--secondary)">18 of 30 days</span>
        <span class="band"><i style="width:60%"></i></span>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Teleperformance Philippines, notified 3 August</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">Worker disputes the dates on one chapter</span>
      </span>
      <span class="t-data col-r outcome" style="color:var(--secondary)">Awaiting the party</span>
    </div>

    <div class="staterow">
      <span class="clock">
        <span class="t-data" style="display:block;color:var(--secondary)">6 of 45 days</span>
        <span class="band"><i style="width:13%"></i></span>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Concentrix Philippines, notified 15 August</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">Extended once, on new evidence from the worker</span>
      </span>
      <span class="t-data col-r outcome" style="color:var(--secondary)">Awaiting the party</span>
    </div>

    <div class="staterow">
      <span class="clock">
        <span class="t-data" style="display:block;color:var(--secondary)">Closed 12 August</span>
        <span class="band"><i style="width:100%"></i></span>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Alorica Philippines, corrected</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">The party issued a superseding attestation, and both versions stay on the record</span>
      </span>
      <span class="t-data col-r outcome" style="color:var(--secondary)">Party agreed</span>
    </div>

    <div class="staterow" style="border-bottom:0">
      <span class="clock">
        <span class="t-data" style="display:block;color:var(--secondary)">Closed 29 July</span>
        <span class="band"><i style="width:100%"></i></span>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Teleperformance Philippines, stood by their account</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">The worker&#39;s counter-statement is attached, and travels wherever the attestation does</span>
      </span>
      <span class="t-data col-r outcome" style="color:var(--secondary)">Party stood</span>
    </div>

  </div>

  </div>

</div>
</x-dc>

<script data-dc-script data-props='{}'>
class Component extends DCLogic {
  renderVals(){
    return { tab:'disputes', acMerges:'false', acParties:'false',
             acMarkers:'false', acDisputes:'page', acDeletions:'false',
             wMerges:'', wParties:'off', wDisputes:'' };
  }
}
</script>
</body>
</html>
