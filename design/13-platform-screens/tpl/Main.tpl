<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="./support.js"></script>
</head>
<body>
<x-dc>
<!-- The seam board. Named Main because the canvas format takes Main.dc.html
     as the document's entry artboard; the record itself is not on this canvas,
     it is the working prototype. -->
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    /* Not .band: the chassis already owns that name for the progress bar,
       whose height:3px and overflow:hidden silently flattened every row here. */
    .seamrow{position:relative;display:flex;gap:16px;align-items:flex-start;
             padding:14px 0;border-bottom:1px solid var(--hairline)}
    .who{flex:0 0 20px;padding-top:3px}
    .mech{flex:0 0 168px}
    .key{display:flex;gap:20px;align-items:center;flex-wrap:wrap}
    .keyitem{display:flex;gap:7px;align-items:center}
  </style>
</helmet>

<div style="width:660px;height:1010px;position:relative;background:var(--paper);
            padding:28px 28px 0;overflow:hidden">

  <span class="t-serial" style="color:var(--secondary)">The seam, band by band</span>
  <h1 class="t-head" style="margin:8px 0 0;max-width:520px">Grain keeps a control only where the platform's version is worse, never where it is merely different</h1>
  <p class="t-body" style="margin:8px 0 0;color:var(--secondary);max-width:520px;text-wrap:pretty">Worse means a named failure against decision 046's accessibility target, not a preference. In the whole app that test is passed exactly twice: the switch, and the record itself.</p>

  <div class="key" style="margin:18px 0 4px">
    <span class="keyitem">
      <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1" y="1" width="12" height="12" fill="var(--ink)"></rect></svg>
      <span class="t-meta">Grain draws it</span>
    </span>
    <span class="keyitem">
      <svg width="14" height="14" viewBox="0 0 14 14" fill="none" stroke="var(--ink)" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11"></rect></svg>
      <span class="t-meta">The system draws it</span>
    </span>
    <span class="keyitem">
      <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true">
        <rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)"></rect>
        <path d="M2 2 H7 V12 H2 Z" fill="var(--ink)"></path>
      </svg>
      <span class="t-meta">System container, Grain contents</span>
    </span>
  </div>

  <div style="margin-top:10px;border-top:1px solid var(--ink)">

    <div class="seamrow">
      <span class="who"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" stroke="var(--ink)" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11"></rect></svg></span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Status area, 62 pt</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Paper runs underneath it. Grain sets the glyphs dark because the ground is light, and no dark surface may reach this band.</span>
      </span>
      <span class="mech t-meta" style="color:var(--secondary)">Safe area inset<br>Window insets, edge to edge</span>
    </div>

    <div class="seamrow">
      <span class="who"><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)"></rect><path d="M2 2 H7 V12 H2 Z" fill="var(--ink)"></path></svg></span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Toolbar, 44 pt</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">No background, which is what Apple asks. The separation when scrolled is the hard scroll edge effect, toned from --page. Liquid Glass is refused: the thing passing under it is a hairline drawing, and a blurred hairline is an absent one.</span>
      </span>
      <span class="mech t-meta" style="color:var(--secondary)">Toolbar, ScrollEdgeEffectStyle<br>Top app bar, fixed container</span>
    </div>

    <div class="seamrow">
      <span class="who"><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11" fill="none" stroke="var(--ink)"></rect><path d="M2 2 H7 V12 H2 Z" fill="var(--ink)"></path></svg></span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">The name, as the screen's title</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">It stops being an h1 inside the record. The platform collapses it into the bar on scroll; the type stays Grain's t-title. Fourteen characters, inside Apple's fifteen.</span>
      </span>
      <span class="mech t-meta" style="color:var(--secondary)">Large title<br>Large top app bar</span>
    </div>

    <div class="seamrow">
      <span class="who"><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1" y="1" width="12" height="12" fill="var(--ink)"></rect></svg></span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Decision 055's sentence, the imprint, the rows, the marks</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">The record. Identical on both phones, which is the whole reason decision 047 exists: a pending record must not pass as a verified one by being read on a different handset.</span>
      </span>
      <span class="mech t-meta" style="color:var(--secondary)">Drawn<br>Drawn, identically</span>
    </div>

    <div class="seamrow">
      <span class="who"><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1" y="1" width="12" height="12" fill="var(--ink)"></rect></svg></span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">The colophon</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Where the lockup goes if it leaves the bar. Open gate, and the tweak on the record artboard flips it.</span>
      </span>
      <span class="mech t-meta" style="color:var(--secondary)">Content, both platforms</span>
    </div>

    <div class="seamrow">
      <span class="who"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" stroke="var(--ink)" aria-hidden="true"><rect x="1.5" y="1.5" width="11" height="11"></rect></svg></span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Home indicator and gesture zone, 34 pt</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Back belongs to the system on both, and on Android to both edges. Nothing of Grain's may sit in it. This is what killed the section index in decision 037.</span>
      </span>
      <span class="mech t-meta" style="color:var(--secondary)">Interactive pop<br>Predictive back</span>
    </div>

    <div class="seamrow" style="border-bottom:0">
      <span class="who"><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1" y="1" width="12" height="12" fill="var(--ink)"></rect></svg></span>
      <span style="flex:1;min-width:0">
        <span class="t-rec" style="display:block">Not on this screen, decided anyway</span>
        <span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Text entry, the keyboard and the one-time code go to the system without exception. Six ruled boxes defeat the SMS autofill both platforms provide, and that is the highest-cost component in the app for this population. The switch stays Grain's: the platform's own 26 px switch fails 2.5.8.</span>
      </span>
      <span class="mech t-meta" style="color:var(--secondary)">oneTimeCode<br>SMS OTP autofill hint</span>
    </div>

  </div>
</div>
</x-dc>

<script data-dc-script data-props='{}'>
class Component extends DCLogic {
  renderVals(){ return {}; }
}
</script>
</body>
</html>
