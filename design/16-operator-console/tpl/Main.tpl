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

<div style="width:1120px;height:1164px;background:var(--paper);position:relative;
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

    <h1 class="t-head lead" style="margin:0">Are these two records one person?</h1>
    <p class="t-body lead" style="margin:var(--sp4) 0 0;color:var(--secondary)">You are deciding identity, not conduct. A merge rewrites no attestation: both records keep the subject id they were issued against, and reads assemble across the closure.</p>

    <div style="margin-top:var(--sp10)">
      <span class="t-micro" style="color:var(--secondary)">{{gradLabel}}</span>
      <p class="t-body lead" style="margin:5px 0 0">{{gradWhy}}</p>
      <div class="slots">
        <span class="slot {{slot1Class}}">
          <span class="t-micro" style="display:block;color:var(--secondary)">First approval</span>
          <span class="t-rec" style="display:block;padding-top:var(--sp2)">{{slot1Who}}</span>
          <span class="t-meta" style="display:block;color:var(--secondary)">{{slot1Note}}</span>
        </span>
        <sc-if value="{{twoOps}}" hint-placeholder-val="{{ true }}">
        <span class="slot open">
          <span class="t-micro" style="display:block;color:var(--secondary)">Second approval</span>
          <span class="t-rec" style="display:block;padding-top:var(--sp2)">{{slot2Who}}</span>
          <span class="t-meta" style="display:block;color:var(--secondary)">{{slot2Note}}</span>
        </span>
        </sc-if>
      </div>
    </div>

    <div class="sechead" style="margin-top:var(--sp11)">
      <span class="t-sec">What the matcher compared</span>
      <span class="t-meta" style="color:var(--secondary)">Extracts, not the records</span>
    </div>

    <div class="sig sighead">
      <span class="t-micro" style="color:var(--secondary)">Signal</span>
      <span class="t-micro" style="color:var(--secondary)">Record 8f2c</span>
      <span class="t-micro" style="color:var(--secondary)">Record 41ae</span>
      <span class="t-micro w" style="color:var(--secondary)">Weight</span>
    </div>

    <div class="sig">
      <span class="t-data" style="color:var(--secondary)">Full name</span>
      <span class="t-data">Maria Cristina Santos Reyes</span>
      <span class="t-data">Ma. Cristina S. Reyes</span>
      <span class="t-data w">+4.10</span>
    </div>
    <div class="sig">
      <span class="t-data" style="color:var(--secondary)">Mobile channel</span>
      <span class="t-data">+63 9&#8226;&#8226; &#8226;&#8226;&#8226; 4471</span>
      <span class="t-data">+63 9&#8226;&#8226; &#8226;&#8226;&#8226; 4471</span>
      <span class="t-data w">+3.05</span>
    </div>
    <div class="sig">
      <span class="t-data" style="color:var(--secondary)">Email channel</span>
      <span class="t-data">mcs.reyes@&#8226;&#8226;&#8226;&#8226;&#8226;.com</span>
      <span class="t-data" style="color:var(--secondary)">No channel on this record</span>
      <span class="t-data w">0.00</span>
    </div>
    <div class="sig">
      <span class="t-data" style="color:var(--secondary)">Document identifier</span>
      <span class="t-data" style="color:var(--secondary)">Not captured, unverified</span>
      <span class="t-data" style="color:var(--secondary)">Not captured, unverified</span>
      <span class="t-data w">0.00</span>
    </div>
    <div class="sig">
      <span class="t-data" style="color:var(--secondary)">Chapter adjacency</span>
      <span class="t-data">Alorica Philippines, ends Mar 2023</span>
      <span class="t-data">Alorica Philippines, begins Apr 2023</span>
      <span class="t-data w">+2.65</span>
    </div>

    <div class="fence">
      <span class="t-micro" style="color:var(--secondary)">Triage evidence only, never identity proof</span>
      <p class="t-meta lead" style="margin:var(--sp2) 0 var(--sp4);color:var(--secondary)">These two order the queue and prove nothing. Internet cafes, offices, shared households and VPNs all put unrelated people behind one address, and this population uses them heavily.</p>
      <div class="sig">
        <span class="t-data" style="color:var(--secondary)">Address range</span>
        <span class="t-data">112.198.x.x, Cebu</span>
        <span class="t-data">112.198.x.x, Cebu</span>
        <span class="t-data w">+0.40</span>
      </div>
      <div class="sig">
        <span class="t-data" style="color:var(--secondary)">Device family</span>
        <span class="t-data">Android 14, mid-tier</span>
        <span class="t-data">Android 14, mid-tier</span>
        <span class="t-data w">+0.20</span>
      </div>
    </div>

    <div class="sig sigtot">
      <span class="t-rec">Rank weight</span>
      <span class="t-meta" style="grid-column:2 / 4;color:var(--secondary)">Orders the queue.</span>
      <span class="t-rec w">+10.40</span>
    </div>

    <div class="sechead" style="margin-top:var(--sp10)">
      <span class="t-sec">What each record carries</span>
      <span class="t-meta" style="color:var(--secondary)">Shape and dates, not content</span>
    </div>

    <div class="row">
      <span class="marklead">
        <svg width="20" height="12" viewBox="0 0 20 12" fill="none" stroke="var(--ink)" stroke-width="1.5" aria-hidden="true"><path d="M1 10 H19" stroke-dasharray="2 2.5"></path></svg>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Alorica Philippines, Cebu</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">Record 8f2c, the worker&#39;s own account, unattested</span>
      </span>
      <span class="t-data col-r" style="color:var(--secondary)">Nov 2021 to Mar 2023</span>
    </div>
    <div class="row">
      <span class="marklead">
        <svg width="20" height="12" viewBox="0 0 20 12" fill="none" stroke="var(--ink)" stroke-width="1.5" aria-hidden="true"><path d="M1 10 H19"></path><path d="M5 10 A5 5 0 0 1 15 10"></path></svg>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Teleperformance Philippines, Cebu</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">Record 8f2c, one business attested the work</span>
      </span>
      <span class="t-data col-r" style="color:var(--secondary)">Feb 2019 to Oct 2021</span>
    </div>
    <div class="row">
      <span class="marklead">
        <svg width="20" height="12" viewBox="0 0 20 12" fill="none" stroke="var(--ink)" stroke-width="1.5" aria-hidden="true"><path d="M1 10 H19"></path><path d="M4 10 A4 4 0 0 1 12 10"></path><path d="M9 10 A4 4 0 0 1 17 10"></path></svg>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Alorica Philippines, Cebu</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">Record 41ae, a business, with a second party agreeing</span>
      </span>
      <span class="t-data col-r" style="color:var(--secondary)">Apr 2023 to present</span>
    </div>
    <div class="row" style="border-bottom:0">
      <span class="marklead">
        <svg width="20" height="12" viewBox="0 0 20 12" fill="none" stroke="var(--ink)" stroke-width="1.5" aria-hidden="true"><path d="M1 10 H19" stroke-dasharray="2 2.5"></path></svg>
      </span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Concentrix Philippines, Manila</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:var(--sp1)">Record 41ae, the worker&#39;s own account, unattested</span>
      </span>
      <span class="t-data col-r" style="color:var(--secondary)">Jun 2018 to Jan 2019</span>
    </div>

    <div class="esc">
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Open both records in full</span>
        <span class="t-meta lead" style="display:block;color:var(--secondary);padding-top:3px">Ask for this when the extract does not settle it, and say why. Opening a record is logged as a read of it, and the worker can see that read if they ask who has read their record.</span>
      </span>
      <button type="button" class="btn-secondary press" style="width:auto;padding:12px 18px;flex:0 0 auto">Ask to open</button>
    </div>

  </div>

  <div class="band-act">
    <p class="t-meta lead" style="margin:0 0 var(--sp6);color:var(--secondary)">{{actMeta}}</p>
    <div class="acts">
      <button type="button" class="btn-primary press rigid">{{primaryLabel}}</button>
      <button type="button" class="btn-secondary press">Not the same person</button>
      <button type="button" class="btn-tertiary press">Cannot determine on this evidence</button>
    </div>
  </div>

  </div>

</div>
</x-dc>

<script data-dc-script data-props='{"stage":{"editor":"enum","options":["Two operators, you are second","Two operators, you are first","One operator, neither attested"],"default":"Two operators, you are second","section":"Case"}}'>
class Component extends DCLogic {
  renderVals(){
    var stage = this.props.stage ?? 'Two operators, you are second';
    var two = stage.indexOf('Two') === 0;
    var first = stage.indexOf('you are first') > 0;
    return {
      tab:'merges', acMerges:'page', acParties:'false',
      acMarkers:'false', acDisputes:'false', acDeletions:'false',
      wMerges:'', wParties:'off', wDisputes:'',
      twoOps: two,
      gradLabel: two ? 'This case needs two operators' : 'This case needs one operator',
      gradWhy: two
        ? 'Both records carry a party attestation. One approval cannot execute this merge, and the second must come from a different person.'
        : 'Neither record carries a party attestation, so one approval executes this merge.',
      slot1Class: (two && first) ? 'open' : '',
      slot1Who:  (two && first) ? 'Not yet given' : (two ? 'R. Alvarez, operator' : 'Not yet given'),
      slot1Note: (two && first) ? 'Yours would be the first' : (two ? 'Today, 14:02' : 'Yours, and it executes'),
      slot2Who:  'Not yet given',
      slot2Note: first ? 'Someone other than you, afterwards' : 'Yours, and it executes',
      primaryLabel: (two && first) ? 'Approve as the first operator' : 'One person, merge',
      actMeta: (two && first)
        ? 'This does not merge anything. It records your approval and returns the case to the queue for a second operator, who cannot be you.'
        : (two
          ? 'R. Alvarez approved at 14:02, so yours is the second and this merges now. It appends to both subject chains under both names. An unmerge can reverse it, and leaves its own record.'
          : 'This merges now, and appends to both subject chains under your name. An unmerge can reverse it, and leaves its own record.')
    };
  }
}
</script>
</body>
</html>
