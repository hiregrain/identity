<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>Grain record, platform prototype</title>
<style>
@@CSS@@
@@CHROME@@
/* ===================================================================
   The worker app built as a system rather than as one screen. Surfaces
   are declared in a registry, chrome is a platform switch, and the type
   scale is a control, so the rest of the app is additions to SURFACES
   rather than new plumbing.

   Device metrics are MEASURED off a booted iPhone 17 on iOS 26.5, not
   remembered: 402 x 874 pt at 3x, Dynamic Island 125.3 x 36.7 with its
   top at 14.0 and equal 138.3 margins, safe area 59 top and 34 bottom.
   Android is the common 360 x 800 dp box, 24 dp status, 24 dp gesture.
   =================================================================== */
html,body{height:100%}
body{background:var(--page);display:flex;flex-direction:column;align-items:center;
     justify-content:flex-start;gap:16px;padding:0 12px 24px;min-height:100vh}

.stage{--w:402px;--h:874px;--top:59px;--bot:34px;--rad:55px;--bez:14px;--frame:68px}
.stage.android{--w:360px;--h:800px;--top:24px;--bot:24px;--rad:28px;--bez:12px;--frame:38px}

.dev{position:relative;width:calc(var(--w) + var(--bez)*2);height:calc(var(--h) + var(--bez)*2);
     border-radius:var(--frame);background:#0C0F14;flex:0 0 auto;
     box-shadow:0 0 0 1px #5A6474, 0 20px 44px rgba(27,42,68,.22)}
.scr{position:absolute;left:var(--bez);top:var(--bez);width:var(--w);height:var(--h);
     border-radius:var(--rad);overflow:hidden;background:var(--paper)}

/* ---------- system chrome ---------- */
.sysfont{font-family:-apple-system,'SF Pro Text','Helvetica Neue',sans-serif;
         -webkit-font-smoothing:antialiased}
.island{position:absolute;top:14px;left:50%;transform:translateX(-50%);width:125px;
        height:37px;border-radius:19px;background:#0C0F14;z-index:24}
.punch{position:absolute;top:7px;left:50%;transform:translateX(-50%);width:11px;height:11px;
       border-radius:50%;background:#0C0F14;z-index:24}
.status{position:absolute;top:0;left:0;right:0;z-index:23;pointer-events:none;
        transition:color 260ms linear}
.clock{position:absolute;left:0;width:138px;top:21px;text-align:center;font-size:16px;
       font-weight:600;letter-spacing:-0.01em}
.statr{position:absolute;right:20px;top:23px;display:flex;align-items:center;gap:6px}
.android .clock{left:14px;width:auto;top:4px;text-align:left;font-size:12px}
.android .statr{right:12px;top:5px;gap:4px}
.homebar{position:absolute;bottom:8px;left:50%;transform:translateX(-50%);width:139px;
         height:5px;border-radius:3px;background:currentColor;opacity:.85;z-index:24}
.android .homebar{bottom:7px;width:108px;height:3px;border-radius:2px}
/* iOS recedes the presenting view behind a sheet, which puts black behind the
   status bar, so the glyphs flip to light. That is the founder's rule: a dark
   surface reaching the status band flips the appearance. */
.chrome{color:var(--ink)}
.chrome.onblack{color:var(--paper)}

/* ---------- navigation layers ---------- */
.layer{position:absolute;inset:0;background:var(--paper);
       transition:transform 420ms cubic-bezier(0.32,0.72,0,1),opacity 260ms linear}
.layer.dragging{transition:none}
.layer::after{content:'';position:absolute;inset:0;background:var(--ink);opacity:0;
              pointer-events:none;z-index:5;transition:opacity 420ms cubic-bezier(0.32,0.72,0,1)}
.layer.behind::after{opacity:.12}
.base.behind{transform:translateX(-24%)}
.pushl{transform:translateX(100%);z-index:3;box-shadow:-1px 0 0 var(--hairline)}
.pushl.open{transform:translateX(0)}
/* Android is a fade-through with a short rise, not a slide. */
.android .base.behind{transform:none;opacity:.5}
.android .pushl{transform:translateY(16px);opacity:0}
.android .pushl.open{transform:translateY(0);opacity:1}
.edgegrab{position:absolute;left:0;top:0;bottom:0;width:24px;z-index:9;touch-action:none}

/* The sheet makes the presenting view recede. Nothing floats: the background
   retreats, which is what iOS actually does. */
.scr.recede{background:#0C0F14}
.scr.recede .base{transform:scale(.925) translateY(-14px);border-radius:14px;overflow:hidden}

/* ---------- the bar ---------- */
.barbg{position:absolute;top:0;left:0;right:0;height:calc(var(--top) + 44px);z-index:10;
       background:var(--page);border-bottom:1px solid var(--hairline);opacity:0;
       pointer-events:none;transition:opacity 200ms linear}
.barbg.on{opacity:1;transition:none}
.barbg.screen{background:transparent;backdrop-filter:contrast(0.34) brightness(1.07) saturate(0);
              -webkit-backdrop-filter:contrast(0.34) brightness(1.07) saturate(0);
              border-bottom:1px solid var(--rule)}
.bar{position:absolute;top:var(--top);left:0;right:0;height:44px;z-index:11;display:flex;
     align-items:center;justify-content:space-between;padding:0 7.5px;gap:6px}
.barslot{display:flex;align-items:center;min-width:0}
.backbtn{display:flex;align-items:center;gap:2px;min-height:44px;padding:0 6px 0 2px}
.android .bar{padding:0 4px}

/* ---------- documents ---------- */
.doc{position:absolute;inset:0;overflow-y:auto;overflow-x:hidden;
     padding:calc(var(--top) + 56px) 20px calc(var(--bot) + 24px);
     -webkit-overflow-scrolling:touch;scrollbar-width:none;z-index:1}
.doc::-webkit-scrollbar{width:0}
.plate{position:absolute;inset:0;pointer-events:none;z-index:12}
.grat{position:absolute;inset:0;pointer-events:none;opacity:.07;z-index:0}
.grat svg{width:100%;height:100%;display:block}

/* ---------- identity hero ---------- */
.idhero{display:flex;align-items:center;gap:16px}
.photo{flex:0 0 64px;position:relative;display:block;min-width:64px;min-height:64px}
.photoframe{position:relative;display:block;width:64px;height:64px;background:var(--page);
            box-shadow:inset 0 0 0 1px var(--hairline)}
.photograt{position:absolute;inset:0;width:100%;height:100%;opacity:.35}
.portrait{position:absolute;inset:0;width:100%;height:100%}
.preg{position:absolute;width:9px;height:9px;border:0 solid var(--rule)}

/* ---------- the figure ---------- */
.figwrap{position:relative;display:block;max-width:320px;width:100%;margin:24px auto 0;
         padding:14px 0}
.figreg{position:absolute;width:13px;height:13px;border:0 solid var(--rule);pointer-events:none}
.figground{position:absolute;inset:14px 0;display:flex;align-items:center;justify-content:center;
           pointer-events:none;opacity:.16}
.figground svg{width:100%;max-width:292px;aspect-ratio:1;height:auto;border-radius:50%;
               overflow:hidden}
.fig{display:block;width:100%;max-width:320px;margin-inline:auto}
.bigwrap{position:relative;display:block;width:100%;margin:0 auto}
.bigfig{display:block;width:100%;height:auto}
/* 047: anything tappable must read as tappable WITHOUT motion or colour. The
   registration corners are the plate's mark for a framed object, not an
   affordance, so the figure takes the same row grammar every other tappable
   thing on this surface uses. */
.figopen{display:flex;align-items:center;gap:12px;width:100%;padding:12px 0;min-height:44px;
         border-top:1px solid var(--ink);margin-top:10px}

/* ---------- imprint motion ---------- */
@keyframes scribe{to{stroke-dashoffset:0}}
.moved .ch4 path{stroke-dasharray:1;stroke-dashoffset:1;
                 animation:scribe 900ms cubic-bezier(0.2,0,0,1) 300ms forwards}
.unrolling .ch1 path{stroke-dasharray:1;stroke-dashoffset:1;animation:scribe 620ms cubic-bezier(0.2,0,0,1) 60ms forwards}
.unrolling .ch2 path{stroke-dasharray:1;stroke-dashoffset:1;animation:scribe 620ms cubic-bezier(0.2,0,0,1) 150ms forwards}
.unrolling .ch3 path{stroke-dasharray:1;stroke-dashoffset:1;animation:scribe 620ms cubic-bezier(0.2,0,0,1) 240ms forwards}
.unrolling .ch4 path{stroke-dasharray:1;stroke-dashoffset:1;animation:scribe 620ms cubic-bezier(0.2,0,0,1) 330ms forwards}
@keyframes matched{from{transform:scale(.56) translateY(46px);opacity:.55} to{transform:scale(1) translateY(0);opacity:1}}
.unrolling{animation:matched 420ms cubic-bezier(0.32,0.72,0,1) both}
.fx .ch{opacity:.18;transition:opacity 360ms linear}
.fx.f0 .ch0,.fx.f1 .ch1,.fx.f2 .ch2,.fx.f3 .ch3,.fx.f4 .ch4{opacity:1}

/* ---------- §7 depth, and §10's attestation landing ---------- */
.row.proud{transform:translateY(-2px)}
.row.proud .gutter,.row.proud .prov{box-shadow:0 2px 0 -1px var(--hairline)}
.row.seating{animation:seat 320ms cubic-bezier(0.2,0,0,1) forwards}
@keyframes seat{from{transform:translateY(-2px)} to{transform:translateY(0)}}
@keyframes inked{0%{opacity:0} 100%{opacity:1}}
.row.seating .gutter svg{animation:inked 320ms linear forwards}

/* ---------- disclosure ---------- */
.chevs{flex:0 0 auto;opacity:.55;transition:transform 200ms cubic-bezier(0.2,0,0,1)}
.disc.on .chevs{transform:rotate(90deg)}
.discbody{display:grid;grid-template-rows:0fr;transition:grid-template-rows 240ms cubic-bezier(0.2,0,0,1)}
.disc.on .discbody{grid-template-rows:1fr}
.discbody > div{overflow:hidden}
.disc.on .discbody > div{padding:4px 0 16px;border-bottom:1px solid var(--hairline)}
.attest{display:flex;gap:14px;align-items:flex-start;padding:8px 0 12px}
.attmark{flex:0 0 68px;padding-top:2px}
.attrow{display:flex;justify-content:space-between;align-items:baseline;gap:12px;
        padding:7px 0;border-top:1px solid var(--hairline)}

/* ---------- sheet ---------- */
.scrim{position:absolute;inset:0;background:rgba(12,15,20,.28);z-index:14;opacity:0;
       pointer-events:none;transition:opacity 380ms cubic-bezier(0.32,0.72,0,1)}
.scrim.on{opacity:1;pointer-events:auto}
.sheet{position:absolute;left:0;right:0;bottom:0;z-index:15;background:var(--paper);
       border-radius:12px 12px 0 0;box-shadow:0 -1px 0 var(--rule);transform:translateY(101%);
       transition:transform 420ms cubic-bezier(0.32,0.72,0,1);padding:0 20px 40px;
       touch-action:none}
.sheet.on{transform:translateY(0)}
.sheet.dragging{transition:none}
.grabber{width:36px;height:5px;border-radius:3px;background:var(--rule);opacity:.6;margin:8px auto 0}
.sheethead{padding:10px 0 0;cursor:grab;touch-action:none}
.sheetbar{display:flex;align-items:center;justify-content:space-between;gap:8px;
          padding:6px 0 10px;border-bottom:1px solid var(--hairline);margin:0 -20px;
          padding-inline:20px}
.barbtn{flex:0 0 56px;min-height:44px;font-weight:400;font-size:15px;color:var(--ink);text-align:left}
.barbtn:active{opacity:.4}
.listrow{display:flex;align-items:center;gap:12px;padding:14px 0;
         border-bottom:1px solid var(--hairline);width:100%}
/* The camera frame: the one place the plate's registration corners are not
   decoration. They frame a real document. */
.capture{position:relative;margin-top:22px;aspect-ratio:1.58;background:#0C0F14;
         border-radius:3px}
.creg{position:absolute;width:26px;height:26px;border:0 solid var(--paper);opacity:.9}
.shutter{width:66px;height:66px;border-radius:50%;border:2px solid var(--ink);
         background:none;position:relative}
.shutter::after{content:'';position:absolute;inset:5px;border-radius:50%;background:var(--ink)}
.shutter:active::after{inset:8px}
/* §12's offline band: a micro caption, never a dialog, because the record
   stays readable from cache. */
.offband{background:var(--ink);color:var(--paper);padding:8px 12px;margin:0 -20px 20px;
         display:flex;gap:8px;align-items:center}
.statewrap{padding-top:8px}
/* Icon masks. iOS is a superellipse approximated at 22.5% of the side;
   Android may mask to a square, a circle or a squircle, so all three are
   drawn rather than assumed. */
.icrow{display:flex;align-items:flex-end;gap:16px;padding:16px 0 0;flex-wrap:wrap}
.ic{position:relative;display:block;overflow:hidden;box-shadow:0 0 0 1px var(--hairline)}
.ic.ios{border-radius:22.5%}
.ic.and-sq{border-radius:12%}
.ic.and-ci{border-radius:50%}
.ic.and-sc{border-radius:32%}
.ic .safe{position:absolute;left:50%;top:50%;width:66.6%;height:66.6%;transform:translate(-50%,-50%);
          border:1px dashed var(--rule);border-radius:50%;pointer-events:none}
/* The month picker: the platform presents it, Grain fills it. Month precision
   only, because no party attests a day. */
.mgrid{display:grid;grid-template-columns:repeat(4,1fr);gap:6px;padding:4px 0 18px}
.mgrid button{min-height:44px;border:1px solid var(--hairline);border-radius:3px;
              font-weight:500;font-size:14px;text-align:center}
.mgrid button[aria-pressed="true"]{background:var(--ink);color:var(--paper);border-color:var(--ink)}
.yrow{display:flex;align-items:center;justify-content:space-between;padding:8px 0 10px;
      border-bottom:1px solid var(--hairline)}

/* Hover is a pointer-only reveal, never an affordance (047). Unguarded, iOS
   fires :hover on tap and leaves the tip stuck open. */
@media (hover:none){
  .prov:hover .tip{opacity:0;pointer-events:none}
  .prov:focus-visible .tip,.prov:focus .tip{opacity:1;pointer-events:auto}
}

/* ---------- the console, outside the phone ---------- */
.gates{display:flex;flex-wrap:wrap;gap:6px 16px;align-items:center;justify-content:center;
       max-width:560px;position:sticky;top:0;z-index:40;background:var(--page);
       padding:10px 8px;border-bottom:1px solid var(--hairline)}
.gate{display:flex;align-items:center;gap:7px}
.seg{display:flex;border:1px solid var(--rule);border-radius:3px;overflow:hidden}
.seg button{padding:6px 9px;font-weight:500;font-size:12px;min-height:34px;
            border-right:1px solid var(--rule)}
.seg button:last-child{border-right:0}
.seg button[aria-pressed="true"]{background:var(--ink);color:var(--paper)}
.gate select{min-height:34px;border:1px solid var(--rule);border-radius:3px;background:var(--paper);
             font:inherit;font-weight:500;font-size:12px;color:var(--ink);padding:4px 6px}

/* The console is never hidden. It used to vanish under 560px so the device
   could go full bleed, which meant that in any narrow panel the Screen control
   disappeared and the record was the only surface reachable at all. */
@media (max-width:640px){
  body{padding:0;gap:0;justify-content:flex-start;background:var(--paper)}
  /* .stage shrink-wraps its content, and the device's own children are
     absolutely positioned, so width:100% resolved against a zero-width parent
     and the whole screen collapsed. The stage carries the width; the device
     takes the viewport minus the console for its height. */
  .stage{width:100%}
  .dev{width:100%;height:calc(100dvh - 56px);flex:0 0 auto;border-radius:0;
       box-shadow:none;background:var(--paper)}
  .scr{left:0;top:0;width:100%;height:100%;border-radius:0}
  .island,.punch,.homebar{display:none}
  .gates{flex:0 0 auto;height:56px;max-width:none;width:100%;align-items:center;
         justify-content:flex-start;gap:6px 12px;padding:0 10px;background:var(--page);
         border-bottom:1px solid var(--rule);border-top:0;overflow-x:auto;flex-wrap:nowrap}
  .gate{flex:0 0 auto}
}
</style>
</head>
<body>

<div class="gates">
  <span class="gate"><span class="t-micro" style="color:var(--secondary)">Screen</span>
    <select id="g-screen" aria-label="Screen"></select></span>
  <span class="gate"><span class="t-micro" style="color:var(--secondary)">State</span>
    <select id="g-five" aria-label="State">
      <option value="">Normal</option>
      <option value="loading">Loading</option>
      <option value="empty">Empty</option>
      <option value="error">Error</option>
      <option value="offline">Offline</option>
      <option value="denied">Permission denied</option>
    </select></span>
  <span class="gate"><span class="t-micro" style="color:var(--secondary)">Platform</span>
    <span class="seg" id="g-platform">
      <button data-v="ios" aria-pressed="true">iOS</button>
      <button data-v="android" aria-pressed="false">Android</button>
    </span></span>
  <span class="gate"><span class="t-micro" style="color:var(--secondary)">Text</span>
    <span class="seg" id="g-scale">
      <button data-v="1" aria-pressed="true">100%</button>
      <button data-v="1.35" aria-pressed="false">135%</button>
      <button data-v="2" aria-pressed="false">200%</button>
    </span></span>
  <span class="gate"><span class="t-micro" style="color:var(--secondary)">Record</span>
    <span class="seg" id="g-state">
      <button data-v="full" aria-pressed="true">Five chapters</button>
      <button data-v="empty" aria-pressed="false">New worker</button>
    </span></span>
  <span class="gate"><span class="t-micro" style="color:var(--secondary)">Bar</span>
    <span class="seg" id="g-bar">
      <button data-v="hard" aria-pressed="true">Hard edge</button>
      <button data-v="screen" aria-pressed="false">Screened</button>
    </span></span>
  <span class="gate"><span class="t-micro" style="color:var(--secondary)">Ceremony</span>
    <span class="seg" id="g-seat"><button data-v="seat" aria-pressed="false">Attestation landing</button></span></span>
  <span class="gate"><span class="t-micro" style="color:var(--secondary)">Lockup</span>
    <span class="seg" id="g-lockup">
      <button data-v="none" aria-pressed="true">Off record</button>
      <button data-v="bar" aria-pressed="false">In bar</button>
    </span></span>
</div>

<div class="stage" id="stage">
<div class="dev">
  <div class="scr" id="scr">

    <div class="layer base" id="base">
      <span class="grat" aria-hidden="true">
        <svg viewBox="0 0 402 874" preserveAspectRatio="none" fill="none"
             stroke="var(--rule)" stroke-width="0.5">@@GRATICULE_SCREEN@@</svg>
      </span>
      <div class="doc" id="rec"></div>
    </div>

    <div class="plate" aria-hidden="true" id="plate"></div>
    <div class="barbg" id="barbg"></div>
    <div class="bar">
      <span class="barslot" id="lead"></span>
      <span class="barslot" id="trail"></span>
    </div>

    <div class="scrim" id="scrim"></div>
    <div class="sheet" id="sheet" role="dialog" aria-modal="true" aria-labelledby="sheettitle">
      <div class="sheethead" id="grab">
        <div class="grabber"></div>
        <div class="sheetbar">
          <button class="barbtn" id="sheetcancel">Cancel</button>
          <span class="t-micro" style="color:var(--secondary)" id="sheetkicker"></span>
          <span style="flex:0 0 56px"></span>
        </div>
      </div>
      <div style="padding-top:2px">
        <h3 class="t-lead" style="margin:16px 0 8px" id="sheettitle"></h3>
        <p class="t-body" style="margin:0 0 22px;color:var(--secondary);text-wrap:pretty" id="sheetbody-p"></p>
        <div id="sheetslot"></div>
        <button class="btn-primary press" id="sheetcta"></button>
      </div>
    </div>

    <div class="chrome" id="chrome">
      <div class="status sysfont">
        <div class="clock">9:41</div>
        <div class="statr">@@STATUSGLYPHS@@</div>
      </div>
      <div class="island" id="island"></div>
      <div class="punch" id="punchhole" style="display:none"></div>
      <div class="homebar"></div>
    </div>

  </div>
</div>
</div>


@@ICONS@@
@@SWATCHES@@

<template id="t-chapters">@@CHAPTERS@@</template>
<template id="t-sinerule">@@SINERULE@@</template>
<template id="t-lockup">@@LOCKUP@@</template>
<template id="t-share">@@SHAREGLYPH@@</template>
<template id="t-acc">@@ACCOUNTGLYPH@@</template>
<template id="t-chev">@@CHEV@@</template>
<template id="t-graticule">@@GRATICULE_SM@@</template>
<template id="t-portrait">@@PORTRAIT@@</template>
<template id="t-mark56">@@MARK56@@</template>
<template id="t-marksolid">@@MARK_SOLID@@</template>
<template id="t-empty">@@EMPTYFIG@@</template>

<script>
"use strict";
var T = function(id){ return document.getElementById(id).innerHTML; };
var $ = function(id){ return document.getElementById(id); };
var esc = function(s){ return String(s).replace(/[&<>"]/g, function(c){
  return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]; }); };

var SHARE, ACC, CHEV, FIGURE, RULE, LOCKUP, GRAT, PORTRAIT, MARK56, EMPTYFIG, MARKSOLID;

var CH = [
  {party:'Bataan Poultry Processing', kind:'Processing operator', sw:'#sw-self',
   label:'Recorded by', by:'Liezel Mendoza', note:'No party has attested this.',
   from:'Sep 2017', to:'Mar 2019', attested:false},
  {party:'Sunrise Foods Manufacturing', kind:'Two positions', sw:'#sw-multi',
   label:'Attested by', by:'Sunrise Foods Manufacturing', note:'A second party agrees.',
   from:'Mar 2019', to:'Sep 2021', attested:true},
  {party:'R. Santos Dry Goods', kind:'Stall assistant, Divisoria', sw:'#sw-peer',
   label:'Attested by', by:'A coworker Liezel named', note:'The business is not registered with Grain.',
   from:'Sep 2020', to:'Mar 2023', attested:true},
  {party:'Metro Manila Logistics', kind:'Warehouse coordinator', sw:'#sw-single',
   label:'Attested by', by:'Metro Manila Logistics', note:'No second party has agreed.',
   from:'Mar 2023', to:'Jan 2025', attested:true},
  {party:'Cebu Pacific Cargo Services', kind:'Cargo handling supervisor', sw:'#sw-emp',
   label:'Attested by', by:'Cebu Pacific Cargo Services', note:'The dates and the employment. Nothing about the work.',
   from:'Jan 2025', to:'Present', attested:false}
];
var OUT = [
  {i:4, kicker:'Request attestation', cta:'Send the request',
   gap:'They attested the dates and the employment, not the work.',
   body:'Cebu Pacific is registered with Grain. The request goes to the domain Grain checked, and whoever answers it signs in first. They write what you did. You cannot edit it, and you can attach your side to it.'},
  {i:2, kicker:'Ask a manager', cta:'Ask a manager',
   gap:'A coworker attested this. The business can attest it too.',
   body:'A coworker you named is a real witness. If someone confirms a work address at the business, the record shows a person at a business Grain recognises. Grain checks control of the address and records nothing about when they worked there.'}
];
var ACCOUNT = [
  ['Name and identity','What Grain checked, and when'],
  ['Phone and email','How you sign in'],
  ['Who you have disclosed to','Every grant you have ever made'],
  ['Export your record','A file you keep'],
  ['Delete everything','Files a request. Access stops the moment you file it.']
];


// A small registry so party search is real rather than mimed. Registered
// parties are ones Grain has checked a domain for; everything else stays the
// worker's own words and never auto-resolves to a party (C1's rule).
var PARTIES = [
  {name:'Cebu Pacific Cargo Services', where:'Pasay City', reg:true},
  {name:'Cebu Pacific Air', where:'Pasay City', reg:true},
  {name:'Sunrise Foods Manufacturing', where:'Bulacan', reg:true},
  {name:'Metro Manila Logistics', where:'Quezon City', reg:true},
  {name:'Bataan Poultry Processing', where:'Bataan', reg:false},
  {name:'Alorica Philippines', where:'Taguig', reg:true}
];
var draft = {party:null, typed:'', from:'', to:''};

var S = {stack:[], sheetOpen:false, platform:'ios', scale:1, state:'full',
         lockup:'none', bar:'hard', five:null};

var mark = function(sw, w, h, sweight){
  return '<svg viewBox="0 0 34 16" width="' + (w||34) + '" height="' + (h||16) + '" fill="none" ' +
    'aria-hidden="true" stroke="var(--ink)" stroke-width="' + (sweight||1) + '"><use href="' + sw + '"></use></svg>';
};
var chapters = function(){ return S.state === 'empty' ? [] : CH; };
// 044 gives the imprint two states. Past a text size where a 320px circle
// would crowd the record out, it drops to the drawn small-tier mark rather
// than scaling the figure to 640.
var figureHidden = function(){ return S.scale >= 1.8; };

function sechead(title, count){
  return '<div class="sechead"><h2 class="t-sec" style="margin:0">' + esc(title) + '</h2>' +
    (count == null ? '' : '<span class="t-data" style="color:var(--secondary)">' + count + '</span>') +
    '</div><div class="sinerule">' + RULE + '</div>';
}

function recordBody(){
  var chs = chapters(), out = '';
  out += '<div class="idhero">' +
      '<span class="photo prov" tabindex="0" aria-label="Identity photograph, from the document Grain checked">' +
        '<span class="photoframe">' +
          '<svg viewBox="0 0 64 64" aria-hidden="true" class="photograt" fill="none" stroke="var(--rule)" stroke-width="0.5">' + GRAT + '</svg>' +
          '<svg viewBox="0 0 64 64" aria-hidden="true" class="portrait">' + PORTRAIT + '</svg>' +
          '<i class="preg" style="top:0;left:0;border-top-width:1px;border-left-width:1px"></i>' +
          '<i class="preg" style="top:0;right:0;border-top-width:1px;border-right-width:1px"></i>' +
          '<i class="preg" style="bottom:0;left:0;border-bottom-width:1px;border-left-width:1px"></i>' +
          '<i class="preg" style="bottom:0;right:0;border-bottom-width:1px;border-right-width:1px"></i>' +
        '</span>' +
        '<span class="tip t-meta">From the identity document Grain checked, Jan 2025. It says nothing about the work below.</span>' +
      '</span>' +
      '<h1 class="t-title" style="margin:0;min-width:0">Liezel Mendoza</h1></div>';

  if(!chs.length){
    // The canvas is fixed, so an empty record still draws its boundary: the
    // shape does not grow with a career, which is the age-proxy refusal made
    // visible rather than merely written down.
    out += '<div style="padding-top:12px">' +
      '<div class="figwrap" style="pointer-events:none">' +
        '<svg class="fig" viewBox="0 0 600 600" role="img" aria-label="An empty record.">' + EMPTYFIG + '</svg>' +
      '</div>' +
      '<p class="t-lead" style="margin:18px 0 0;text-wrap:pretty">Nothing is on your record yet.</p>' +
      '<p class="t-body" style="margin:8px 0 22px;color:var(--secondary);text-wrap:pretty">Add where you have worked. Nobody can see it until you say so, and a party you name can confirm it.</p>' +
      '<button class="btn-primary press">Add where you worked</button></div>';
    return out;
  }

  // The figure IS the record's index and opens the full chapter list. The
  // record does not repeat that list underneath: doing so made a worker read
  // the same five employers three times on one screen.
  if(figureHidden()){
    out += '<button class="figopen press js-imprint" style="margin-top:20px">' +
      '<span style="flex:0 0 auto">' + MARK56 + '</span>' +
      '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">Your imprint</span>' +
      '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + chs.length + ' chapters. Open it full screen.</span></span>' +
      '<span class="chevs">' + CHEV + '</span></button>';
  } else {
    out += '<div class="figwrap">' +
        '<span class="figreg" style="top:0;left:0;border-top-width:1px;border-left-width:1px"></span>' +
        '<span class="figreg" style="top:0;right:0;border-top-width:1px;border-right-width:1px"></span>' +
        '<span class="figreg" style="bottom:0;left:0;border-bottom-width:1px;border-left-width:1px"></span>' +
        '<span class="figreg" style="bottom:0;right:0;border-bottom-width:1px;border-right-width:1px"></span>' +
        '<span class="figground" aria-hidden="true"><svg viewBox="0 0 296 296" preserveAspectRatio="xMidYMid slice" fill="none" stroke="var(--rule)" stroke-width="0.5">' + GRAT2 + '</svg></span>' +
        '<svg class="fig moved" viewBox="0 0 600 600" role="img" aria-label="Your imprint. Five chapters, oldest innermost.">' + FIGURE + '</svg>' +
      '</div>' +
      '<button class="figopen press js-imprint">' +
        '<span class="t-rec" style="flex:1;min-width:0">Open your imprint, chapter by chapter</span>' +
        '<span class="chevs">' + CHEV + '</span></button>';
  }

  out += '<div style="padding-top:28px">' + sechead('Who else could attest') +
    OUT.map(function(o, n){
      var c = CH[o.i];
      return '<button class="row press" data-out="' + n + '">' +
        '<span class="gutter">' + mark(c.sw) + '</span>' +
        '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(c.party) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px">' + esc(o.gap) + '</span></span>' +
        '<span class="col-r t-data" style="color:var(--secondary)">' + esc(c.from + ' to ' + c.to) + '</span></button>';
    }).join('') + '</div>';
  return out;
}

function imprintBody(p){
  var chs = chapters();
  var focus = (typeof p.n === 'number') ? ' fx f' + p.n : '';
  var out = '<div style="padding-top:4px">';
  if(!figureHidden()){
    out += '<span class="bigwrap">' +
      '<span class="figground" aria-hidden="true"><svg viewBox="0 0 296 296" preserveAspectRatio="xMidYMid slice" fill="none" stroke="var(--rule)" stroke-width="0.5">' + GRAT2 + '</svg></span>' +
      '<svg class="bigfig unrolling' + focus + '" viewBox="0 0 600 600" role="img" aria-label="Your imprint at full size.">' + FIGURE + '</svg></span>';
  }
  out += '<p class="t-body" style="margin:20px 0 0;color:var(--secondary);text-wrap:pretty">Each ring is one chapter. The earliest is innermost, and a ring is as wide as the time it covers. The weave shows who attested it.</p>' +
    '<div style="margin-top:26px">' + sechead('Ring by ring, innermost first', chs.length) + '</div>' +
    chs.map(function(c, i){
      return '<div class="disc" data-disc="' + i + '">' +
        '<button class="row press' + (c.attested ? '' : ' proud') + '" data-open="' + i + '" data-row="' + i + '">' +
          '<span class="prov ' + (c.attested ? 'rigid' : 'press') + '" tabindex="0">' + mark(c.sw) +
            '<span class="tip t-meta">' + esc(c.label + ' ' + c.by + '. ' + c.note) + '</span></span>' +
          '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(c.party) + '</span>' +
          '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(c.kind) + '</span></span>' +
          '<span class="col-r t-data" style="color:var(--secondary)">' + esc(c.from) + '</span>' +
          '<span class="chevs">' + CHEV + '</span></button>' +
        '<div class="discbody"><div>' +
          '<div class="attest"><span class="attmark">' + mark(c.sw, 68, 32, 0.5) + '</span>' +
            '<span style="flex:1;min-width:0">' +
              '<span class="t-micro" style="display:block;color:var(--secondary)">' + esc(c.label) + '</span>' +
              '<span class="t-lead" style="display:block;padding-top:3px;text-wrap:pretty">' + esc(c.by) + '</span>' +
              '<span class="t-meta" style="display:block;padding-top:5px;color:var(--secondary);text-wrap:pretty">' + esc(c.note) + '</span>' +
            '</span></div>' +
          '<div class="attrow"><span class="t-micro" style="color:var(--secondary)">Dates</span>' +
            '<span class="t-data">' + esc(c.from + ' to ' + c.to) + '</span></div>' +
          '<div class="attrow"><span class="t-micro" style="color:var(--secondary)">Standing</span>' +
            '<span class="t-data">' + (c.attested ? 'Permanent' : 'Your own account') + '</span></div>' +
        '</div></div></div>';
    }).join('') + '</div>';
  return out;
}

function sharingBody(){
  return '<div><h1 class="t-head" style="margin:0">Who can read this</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Each grant ends on its own date. A grant is to a named recipient, and it is not a link anyone can forward.</p>' +
    '<div style="margin-top:24px">' + sechead('Grants', 2) + '</div>' +
    '<div class="row"><span style="flex:1"><span class="t-rec" style="display:block">Alorica Philippines</span>' +
    '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Whole record</span></span>' +
    '<span class="col-r t-data" style="color:var(--secondary)">Ends Sep 2026</span></div>' +
    '<div class="row"><span style="flex:1"><span class="t-rec" style="display:block">Cebu Pacific Cargo Services</span>' +
    '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Whole record</span></span>' +
    '<span class="col-r t-data" style="color:var(--secondary)">Ends Nov 2026</span></div>' +
    '<div class="listrow" style="margin-top:20px"><span style="flex:1;min-width:0">' +
    '<span class="t-rec" style="display:block">Public page</span>' +
    '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Off. Nobody reaches your record by searching.</span></span>' +
    '<button class="sw press js-sw" role="switch" aria-checked="false" aria-label="Public page"><i></i></button></div>' +
    '<p class="t-meta" style="color:var(--secondary);margin:24px 0 0;text-wrap:pretty">This record is held by its worker. A grant ends when its date passes, and revoking one stops access from that moment. Neither erases that the grant existed.</p></div>';
}

function accountBody(){
  return '<div><h1 class="t-head" style="margin:0">Your account</h1><div style="margin-top:20px">' +
    ACCOUNT.map(function(a){
      return '<button class="listrow press"><span style="flex:1;min-width:0">' +
        '<span class="t-rec" style="display:block">' + esc(a[0]) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(a[1]) + '</span></span>' +
        '<span class="chevs">' + CHEV + '</span></button>';
    }).join('') + '</div></div>';
}


/* ---------------- One-time code (A4) ----------------
   The highest drop-off screen in any signup. One field, not six: both
   platforms autofill an SMS code into a SINGLE field, and six ruled boxes
   defeat that. The seam hands text entry to the system entirely. */
function codeBody(){
  return '<div>' +
    '<h1 class="t-head" style="margin:0">Enter the code</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary)">Sent to +63 917 ••• 4471.</p>' +
    '<div style="margin-top:30px">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Six digit code</span>' +
      '<span class="ruled lg"><input id="otp" inputmode="numeric" autocomplete="one-time-code" ' +
        'maxlength="6" aria-label="Six digit code" placeholder="000000" ' +
        'style="letter-spacing:0.34em;font-variant-numeric:tabular-nums"></span>' +
    '</div>' +
    '<div style="margin-top:28px">' +
      '<button class="btn-primary press" id="otpgo" disabled>Continue</button>' +
      '<div style="text-align:center;padding-top:6px">' +
        '<button class="btn-tertiary press" id="resend">Send it again</button></div>' +
    '</div>' +
    '<p class="t-meta" style="margin:26px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'Using someone else\'s phone? The code signs you in on this handset only, and you can sign out from your account.</p>' +
  '</div>';
}

/* ---------------- Add your first chapter (C1) ----------------
   The moment of value creation. Party search, a free-text fallback that never
   auto-resolves, and month precision only because no party attests a day. */
function addBody(){
  return '<div>' +
    '<h1 class="t-head" style="margin:0">Where did you work?</h1>' +
    '<div style="margin-top:26px">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Employer or business</span>' +
      '<span class="ruled lg"><input id="psearch" autocomplete="organization" ' +
        'aria-label="Employer or business" placeholder="Start typing" value="' + esc(draft.typed) + '"></span>' +
      '<div id="presults"></div>' +
    '</div>' +
    '<div class="grp">' +
      '<button class="srow press" data-month="from"><span class="t-rec" style="flex:1">Started</span>' +
        '<span class="t-data" style="color:var(--secondary)">' + (draft.from || 'Pick a month') + '</span></button>' +
      '<button class="srow press" data-month="to"><span class="t-rec" style="flex:1">Ended</span>' +
        '<span class="t-data" style="color:var(--secondary)">' + (draft.to || 'Pick a month') + '</span></button>' +
      '<p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">Month only. Grain records no day, because no party attests one.</p>' +
    '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press"' +
      (draft.party || draft.typed ? '' : ' disabled') + '>Add this chapter</button></div>' +
  '</div>';
}

function partyResults(){
  var q = draft.typed.trim().toLowerCase();
  if(!q) return '';
  var hits = PARTIES.filter(function(p){ return p.name.toLowerCase().indexOf(q) > -1; }).slice(0, 4);
  var out = hits.map(function(p){
    return '<button class="row press" data-party="' + esc(p.name) + '">' +
      '<span class="gutter">' + mark(p.reg ? '#sw-emp' : '#sw-self') + '</span>' +
      '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(p.name) + '</span>' +
      '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' +
        (p.reg ? 'Registered with Grain, ' + esc(p.where) : 'Not registered, ' + esc(p.where)) + '</span></span></button>';
  }).join('');
  // The fallback never resolves to a party. It stays the worker's own words,
  // and the mark says so before anything is committed.
  out += '<button class="row press" data-party="">' +
    '<span class="gutter">' + mark('#sw-self') + '</span>' +
    '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">Use &ldquo;' + esc(draft.typed) + '&rdquo; as you typed it</span>' +
    '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Your own words. No party is attached, and none is implied.</span></span></button>';
  return out;
}

/* ---------------- What permanence means (C4) ----------------
   The product's hardest truth, carried in the ledger's own row grammar rather
   than as a wall of legal-sounding prose. The cost IS the value, and the copy
   says so instead of apologising. */
function permanenceBody(){
  var rows = [
    ['Fix a typo', 'Any time. The correction is dated, and the version it replaced stays in the ledger.'],
    ['Add a position or a date', 'Any time, until a party attests the chapter.'],
    ['Remove a chapter nobody attested', 'Yes.'],
    ['Remove a chapter a party attested', 'No.'],
    ['Delete your whole record', 'Yes, and it is the only way out.']
  ];
  return '<div>' +
    '<h1 class="t-head" style="margin:0">What you can change</h1>' +
    '<div style="margin-top:24px">' +
      rows.map(function(r){
        return '<div class="row" style="align-items:flex-start">' +
          '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(r[0]) + '</span>' +
          '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">' + esc(r[1]) + '</span></span></div>';
      }).join('') +
    '</div>' +
    '<div class="warn" style="margin-top:26px">' +
      '<p class="t-body" style="margin:0;text-wrap:pretty">An attestation belongs to the party who made it, not to you. Once it is on your record you cannot take it off.</p>' +
      '<p class="t-data" style="margin:10px 0 0">That is exactly why it is worth something to the person reading it.</p>' +
    '</div>' +
    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">Nobody can read any of this until you grant it, and a grant ends on its own date.</p>' +
  '</div>';
}


/* ================= pass 1 components =================
   Each component is also its surface, so building one builds both. Copy is
   written against what the log already fixes; anything unresolved is marked
   rather than invented. */

var COUNTRIES = [
  {c:'Philippines', d:'+63'}, {c:'India', d:'+91'},
  {c:'Indonesia', d:'+62'}, {c:'Malaysia', d:'+60'}
];
var idf = {country:0, mode:'phone'};

/* A3. research/11 treats a Philippine RA 11934 number as higher assurance, and
   a field that hides its country cannot carry that, so the country is shown. */
function identifierBody(){
  var c = COUNTRIES[idf.country];
  return '<div><h1 class="t-head" style="margin:0">How do we reach you?</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">We send a code to check you control it. It is not shown to anyone and it is not your handle.</p>' +
    (idf.mode === 'phone'
      ? '<div class="grp"><button class="srow press" data-country="1">' +
          '<span class="t-rec" style="flex:1">Country</span>' +
          '<span class="t-data" style="color:var(--secondary)">' + esc(c.c) + ' ' + esc(c.d) + '</span></button></div>' +
        '<div style="margin-top:18px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Mobile number</span>' +
        '<span class="ruled lg"><span class="t-rec" style="padding-right:10px;color:var(--secondary)">' + esc(c.d) + '</span>' +
        '<input id="idfield" inputmode="tel" autocomplete="tel-national" aria-label="Mobile number" placeholder="917 000 0000"></span></div>'
      : '<div style="margin-top:26px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Email address</span>' +
        '<span class="ruled lg"><input id="idfield" inputmode="email" autocomplete="email" aria-label="Email address" placeholder="name@example.com"></span></div>') +
    '<div style="margin-top:28px"><button class="btn-primary press" disabled>Send the code</button>' +
    '<div style="text-align:center;padding-top:6px"><button class="btn-tertiary press" data-idmode="' +
      (idf.mode === 'phone' ? 'email' : 'phone') + '">Use ' + (idf.mode === 'phone' ? 'an email' : 'a number') + ' instead</button></div></div></div>';
}

/* A7. Any script, one field. The ledger keeps the name as written plus its
   script code; the searchable form is derived and never shown here. */
function nameBody(){
  return '<div><h1 class="t-head" style="margin:0">What is your name?</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Write it the way you write it, in any script. It goes on your record exactly as typed.</p>' +
    '<div style="margin-top:26px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Full name</span>' +
    '<span class="ruled lg"><input id="namefield" autocomplete="name" aria-label="Full name" placeholder="Liezel Mendoza"></span></div>' +
    '<div style="margin-top:28px"><button class="btn-primary press" disabled>Continue</button></div></div>';
}

/* F2. Document type and issuing country, using the state grammar for choice:
   filled is chosen, hollow is not. The product contains no checkmarks. */
var DOCS = [['Passport','Any country Grain supports'],['National ID','PhilSys, Aadhaar and equivalents'],['Driver licence','Where it carries a photograph']];
var docPick = 0;
function docTypeBody(){
  return '<div><h1 class="t-head" style="margin:0">Which document?</h1>' +
    '<div class="grp"><button class="srow press" data-country="2"><span class="t-rec" style="flex:1">Issued in</span>' +
    '<span class="t-data" style="color:var(--secondary)">' + esc(COUNTRIES[idf.country].c) + '</span></button></div>' +
    '<div style="margin-top:20px">' + DOCS.map(function(d, i){
      return '<button class="row press" data-doc="' + i + '"><span class="gutter" style="padding-top:2px">' +
        '<svg width="20" height="20" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="' +
        (docPick === i ? '#i-done' : '#i-open') + '"></use></svg></span>' +
        '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(d[0]) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(d[1]) + '</span></span></button>';
    }).join('') + '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press">Continue</button></div></div>';
}

/* F3. The registration corners get their one honest job: framing a real
   document rather than decorating a surface. Grain's chrome, vendor named. */
function captureBody(){
  return '<div><h1 class="t-head" style="margin:0">Photograph the document</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Fit the whole document inside the corners. Flat, and no glare on the photograph.</p>' +
    '<div class="capture"><span class="creg" style="top:0;left:0;border-top-width:2px;border-left-width:2px"></span>' +
    '<span class="creg" style="top:0;right:0;border-top-width:2px;border-right-width:2px"></span>' +
    '<span class="creg" style="bottom:0;left:0;border-bottom-width:2px;border-left-width:2px"></span>' +
    '<span class="creg" style="bottom:0;right:0;border-bottom-width:2px;border-right-width:2px"></span></div>' +
    '<div style="display:flex;justify-content:center;padding-top:22px">' +
    '<button class="shutter press" aria-label="Take the photograph"></button></div>' +
    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">The capture happens inside Grain. Persona checks the document and is told nothing about your work.</p></div>';
}

/* A10. §9's loading arc: one lobe period of the figure's own wave, carrying no
   percentage, because an arc that claims to know how long is a spinner lying. */
function parseBody(){
  return '<div style="padding-top:40px;text-align:center">' +
    '<svg class="arc" viewBox="0 0 120 24" width="120" height="24" fill="none" ' +
      'stroke="var(--ink)" stroke-width="1.5" aria-label="Reading your file">' +
      '<path pathLength="1" d="@@ARC@@"></path></svg>' +
    '<p class="t-lead" style="margin:24px 0 0">Reading your file</p>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Nothing is added to your record yet. You see everything we find and choose what to keep.</p></div>';
}

/* A11. Review before commit. The state grammar carries the choice, and the
   count on the action is the only number on the screen. */
var FOUND = [
  {p:'Cebu Pacific Cargo Services', k:'Cargo handling supervisor', d:'Jan 2025 to present', on:true},
  {p:'Metro Manila Logistics', k:'Warehouse coordinator', d:'Mar 2023 to Jan 2025', on:true},
  {p:'R. Santos Dry Goods', k:'Stall assistant', d:'Sep 2020 to Mar 2023', on:true},
  {p:'Sunrise Foods Mfg.', k:'Packing line operator', d:'Mar 2019 to Sep 2021', on:false}
];
function importBody(){
  var n = FOUND.filter(function(f){ return f.on; }).length;
  return '<div><h1 class="t-head" style="margin:0">What we found</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Your own account of it until a party attests. Nothing is on your record until you add it.</p>' +
    '<div style="margin-top:22px">' + FOUND.map(function(f, i){
      return '<button class="row press" data-found="' + i + '"><span class="gutter" style="padding-top:2px">' +
        '<svg width="20" height="20" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="' +
        (f.on ? '#i-done' : '#i-open') + '"></use></svg></span>' +
        '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(f.p) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(f.k) + '</span></span>' +
        '<span class="col-r t-data" style="color:var(--secondary)">' + esc(f.d) + '</span></button>';
    }).join('') + '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press"' + (n ? '' : ' disabled') + '>' +
    (n ? 'Add ' + n + ' chapter' + (n > 1 ? 's' : '') : 'Nothing selected') + '</button></div></div>';
}

/* A12. The handle, which is the only public name a record ever has. */
function handleBody(){
  return '<div><h1 class="t-head" style="margin:0">Claim your address</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Where your record lives if you ever turn the public page on. It is off by default.</p>' +
    '<div style="margin-top:26px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Address</span>' +
    '<span class="ruled lg"><span class="t-rec" style="color:var(--secondary);padding-right:2px">hiregrain.com/u/</span>' +
    '<input id="handlefield" autocomplete="off" aria-label="Address" placeholder="liezel"></span>' +
    '<div class="said" style="padding-top:10px"><svg width="16" height="16" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="#i-done"></use></svg>' +
    '<span class="t-meta" style="color:var(--secondary)">Available. You can change it once.</span></div></div>' +
    '<div style="margin-top:28px"><button class="btn-primary press">Claim it</button></div></div>';
}

/* I6, I7. Grain asks before the system does. Asking at launch is the pattern
   that gets denied, so each says what it is for at the moment it is needed. */
function permBody(kind){
  var cam = kind === 'camera';
  return '<div style="padding-top:16px"><h1 class="t-head" style="margin:0">' +
    (cam ? 'Grain needs the camera' : 'Three things worth interrupting you for') + '</h1>' +
    (cam
      ? '<p class="t-body" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">To photograph your document. Grain takes no other pictures and keeps no camera access afterwards.</p>'
      : '<div style="margin-top:20px">' + [
          ['A party attested your work','The only one that changes your record.'],
          ['A grant is about to end','Four days before, so you can send it again.'],
          ['A deadline to attach your side','Only when one is running.']
        ].map(function(r){
          return '<div class="row"><span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(r[0]) + '</span>' +
            '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(r[1]) + '</span></span></div>';
        }).join('') + '</div>') +
    '<div style="margin-top:26px"><button class="btn-primary press">' + (cam ? 'Allow the camera' : 'Turn these on') + '</button>' +
    '<div style="text-align:center;padding-top:6px"><button class="btn-tertiary press">Not now</button></div></div>' +
    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">' +
    (cam ? 'Declining means you cannot verify a document, and nothing else changes.'
         : 'Read events are never sent, here or anywhere.') + '</p></div>';
}

/* A6. BLOCKED, and drawn as blocked rather than invented: decision 054's gate
   asks what consent says about measures collected and not rendered, and it is
   unwritten. The shape is here so the flow is walkable; the words are not. */
function consentBody(){
  return '<div><h1 class="t-head" style="margin:0">What you are agreeing to</h1>' +
    '<div class="warn" style="margin-top:20px"><p class="t-body" style="margin:0;text-wrap:pretty">This surface is blocked, not undrawn. Decision 054 holds seven measures that Grain collects and does not render, and what consent must say about them is unwritten. Copy here would be invention.</p></div>' +
    '<div style="margin-top:22px">' + [
      ['Your record is permanent','An attestation cannot be withdrawn by you.'],
      ['Nobody reads it until you grant it','And a grant ends on its own date.'],
      ['You can ask for all of it','Export, any time.'],
      ['You can ask us to delete everything','It is the only way out.']
    ].map(function(r){
      return '<div class="row"><span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(r[0]) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(r[1]) + '</span></span></div>';
    }).join('') + '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press" disabled>Blocked on decision 054</button></div></div>';
}


/* ---------- the five states, as a shell control rather than per-surface
   drawings. design/08 treats these as work remaining on every surface, which
   is five times sixty. A surface declares which it has; the shell renders. */
function stateBody(kind, title){
  if(kind === 'loading'){
    return '<div class="statewrap"><h1 class="t-head" style="margin:0">' + esc(title) + '</h1>' +
      '<div style="margin-top:24px">' +
      '<div class="skel"><span></span><span></span></div>'.repeat(4) + '</div></div>';
  }
  if(kind === 'offline'){
    return '<div class="statewrap"><div class="offband">' +
      '<svg width="16" height="16" viewBox="0 0 24 24" class="icon" style="stroke:var(--paper);stroke-linecap:square"><use href="#i-alert"></use></svg>' +
      '<span class="t-meta">Offline. This is the copy on your phone.</span></div>' +
      '<h1 class="t-head" style="margin:0">' + esc(title) + '</h1>' +
      '<p class="t-body" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">Everything already on your record stays readable. Nothing new arrives until you are back.</p></div>';
  }
  if(kind === 'error'){
    return '<div class="statewrap" style="padding-top:24px">' +
      '<svg width="26" height="26" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="#i-alert"></use></svg>' +
      '<h1 class="t-head" style="margin:16px 0 0">That did not work</h1>' +
      '<p class="t-body" style="margin:10px 0 22px;color:var(--secondary);text-wrap:pretty">Nothing was changed. Your record is exactly as it was.</p>' +
      '<button class="btn-primary press">Try again</button></div>';
  }
  if(kind === 'denied'){
    return '<div class="statewrap" style="padding-top:24px">' +
      '<h1 class="t-head" style="margin:0">The camera is turned off</h1>' +
      '<p class="t-body" style="margin:10px 0 22px;color:var(--secondary);text-wrap:pretty">Grain cannot ask again from here. Turn it on in Settings, then come back.</p>' +
      '<button class="btn-primary press">Open Settings</button>' +
      '<div style="text-align:center;padding-top:6px"><button class="btn-tertiary press">Do this later</button></div></div>';
  }
  return '<div class="statewrap" style="padding-top:24px">' +
    '<h1 class="t-head" style="margin:0">Nothing here yet</h1>' +
    '<p class="t-body" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">When there is something to show, it appears here.</p></div>';
}


/* ---- two shapes cover most of what is left ----
   A statement surface (title, body, an action, a footnote) and a list of
   label-and-note rows. Hand-writing thirty copies of these is how a system
   drifts, so they are written once. */
function msg(o){
  return '<div style="padding-top:' + (o.pad == null ? 0 : o.pad) + 'px">' +
    (o.alert ? '<svg width="26" height="26" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square;margin-bottom:16px"><use href="#i-alert"></use></svg>' : '') +
    '<h1 class="t-head" style="margin:0">' + esc(o.title) + '</h1>' +
    (o.body ? '<p class="t-body" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">' + esc(o.body) + '</p>' : '') +
    (o.rows ? '<div style="margin-top:22px">' + rows(o.rows) + '</div>' : '') +
    (o.warn ? '<div class="warn" style="margin-top:22px"><p class="t-body" style="margin:0;text-wrap:pretty">' + esc(o.warn) + '</p></div>' : '') +
    (o.cta ? '<div style="margin-top:26px"><button class="btn-primary press"' + (o.ctaOff ? ' disabled' : '') + '>' + esc(o.cta) + '</button>' +
      (o.alt ? '<div style="text-align:center;padding-top:6px"><button class="btn-tertiary press">' + esc(o.alt) + '</button></div>' : '') + '</div>' : '') +
    (o.foot ? '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">' + esc(o.foot) + '</p>' : '') +
  '</div>';
}
function rows(list){
  return list.map(function(r){
    // [label, note] stacks; [label, null, value] puts the value right, which is
    // the ledger grammar: text left, tabular figures right.
    if(r.length > 2 && r[2] != null){
      return '<div class="row"><span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(r[0]) + '</span>' +
        (r[1] ? '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px;text-wrap:pretty">' + esc(r[1]) + '</span>' : '') +
        '</span><span class="col-r t-data" style="color:var(--secondary)">' + esc(r[2]) + '</span></div>';
    }
    return '<div class="row"><span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(r[0]) + '</span>' +
      (r[1] ? '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px;text-wrap:pretty">' + esc(r[1]) + '</span>' : '') +
      '</span></div>';
  }).join('');
}
function listrows(list){
  return list.map(function(r){
    return '<button class="listrow press"><span style="flex:1;min-width:0">' +
      '<span class="t-rec" style="display:block">' + esc(r[0]) + '</span>' +
      (r[1] ? '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px;text-wrap:pretty">' + esc(r[1]) + '</span>' : '') +
      '</span><span class="chevs">' + CHEV + '</span></button>';
  }).join('');
}
function arcmark(label){
  return '<div style="padding-top:44px;text-align:center">' +
    '<svg class="arc" viewBox="0 0 120 24" width="120" height="24" fill="none" ' +
    'stroke="var(--ink)" stroke-width="1.5" aria-label="' + esc(label) + '">' +
    '<path pathLength="1" d="@@ARC@@"></path></svg></div>';
}

/* ================= A, first run ================= */
function launchBody(){
  return '<div style="position:absolute;inset:0;display:flex;flex-direction:column;' +
    'align-items:center;justify-content:center;gap:26px">' +
    '<svg viewBox="0 0 160 26" width="150" height="24" role="img" aria-label="Grain">' + LOCKUP + '</svg>' +
    '<svg class="arc" viewBox="0 0 120 24" width="96" height="20" fill="none" stroke="var(--rule)" ' +
    'stroke-width="1.4" aria-label="Opening your record"><path pathLength="1" d="@@ARC@@"></path></svg></div>';
}
function landerBody(){
  return '<div style="padding-top:8px">' +
    '<svg viewBox="0 0 160 26" width="140" height="23" role="img" aria-label="Grain" style="opacity:.85">' + LOCKUP + '</svg>' +
    '<h1 class="t-title" style="margin:14px 0 0;text-wrap:balance">A record of what you have actually done</h1>' +
    '<p class="t-body" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">Kept by you, confirmed by the people who saw the work. Nobody reads it until you say so.</p>' +
    '<div style="margin-top:28px"><button class="btn-primary press">Start your record</button>' +
    '<div style="text-align:center;padding-top:6px"><button class="btn-tertiary press">I already have one</button></div></div>' +
    '<p class="t-meta" style="margin:26px 0 0;color:var(--secondary);text-wrap:pretty">Free, permanently. Grain never charges a worker for the record.</p></div>';
}
function welcomeBody(){
  return msg({title:'Welcome back', body:'Sign in to the number ending 4471.',
    cta:'Send a code', alt:'Use a different number',
    foot:'If this is not your phone, use a different number. The record stays where it is either way.'});
}

/* ================= C, chapter management ================= */
function positionBody(){
  return '<div><h1 class="t-head" style="margin:0">Add a position</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Inside Sunrise Foods Manufacturing. A change of title is a division inside one chapter, not a new one.</p>' +
    '<div style="margin-top:26px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Title</span>' +
    '<span class="ruled lg"><input aria-label="Title" placeholder="Line lead"></span></div>' +
    '<div class="grp">' +
    '<button class="srow press" data-month="from"><span class="t-rec" style="flex:1">Started</span>' +
    '<span class="t-data" style="color:var(--secondary)">' + (draft.from || 'Pick a month') + '</span></button>' +
    '<button class="srow press" data-month="to"><span class="t-rec" style="flex:1">Ended</span>' +
    '<span class="t-data" style="color:var(--secondary)">' + (draft.to || 'Still there') + '</span></button></div>' +
    '<div style="margin-top:26px"><button class="btn-primary press">Add the position</button></div></div>';
}
function minorEditBody(){
  return msg({title:'What you can still change',
    body:'This chapter is committed. Corrections are kept beside the original rather than replacing it.',
    rows:[['A spelling or a typo','Any time. The correction is dated.'],
          ['The dates','Until a party attests them.'],
          ['A position inside it','Until a party attests the chapter.'],
          ['The party it belongs to','No. That would make it a different chapter.']],
    foot:'Every correction stays in the ledger, so a reader can see what changed and when.'});
}

/* ================= I, system ================= */
function notFoundBody(){
  return msg({pad:20, alert:true, title:'No record at that address',
    body:'hiregrain.com/u/liezel does not resolve. The address may have changed, or the record may have been deleted.',
    cta:'Go to your record', foot:'Grain never says whether an address once existed.'});
}
function updateBody(){
  return msg({pad:20, title:'Update Grain to carry on',
    body:'This version can no longer read the ledger safely. Your record is untouched and waiting.',
    cta:'Update'});
}
function signedOutBody(){
  return msg({pad:20, title:'You have been signed out',
    body:'For your safety, on a device that has been idle a long time. Nothing about your record changed.',
    cta:'Sign in again'});
}
function pushBody2(){
  return '<div><h1 class="t-head" style="margin:0">What Grain sends</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Three events, and the text of each. A notification never carries who read your record, because read events are not surfaced anywhere.</p>' +
    '<div style="margin-top:24px">' +
    [['Cebu Pacific attested your work.','A party attested'],
     ['A grant to Alorica ends in four days.','A grant is ending'],
     ['You have until 12 Mar to attach your side.','A deadline is running']].map(function(n){
      return '<div class="row" style="align-items:flex-start"><span style="flex:1;min-width:0">' +
        '<span class="t-micro" style="display:block;color:var(--secondary)">' + esc(n[1]) + '</span>' +
        '<span class="t-rec" style="display:block;padding-top:5px">' + esc(n[0]) + '</span></span></div>';
    }).join('') + '</div></div>';
}
function legalBody(){
  return '<div><h1 class="t-head" style="margin:0">How this works</h1>' +
    '<div style="margin-top:22px">' + listrows([
      ['How the record works','What a chapter is, and what an attestation is'],
      ['Who can read it','Grants, the public page, and what neither does'],
      ['What Grain keeps','And for how long, and where'],
      ['Terms','The agreement between you and Grain'],
      ['Privacy','Written to be read, not to be survived']
    ]) + '</div></div>';
}


/* ================= D, getting work verified =================
   Three routes, and each says exactly what the party can and cannot write,
   because the difference between them is the whole epistemic point. */
function reqAttestBody(){
  return msg({title:'Ask Cebu Pacific to attest',
    body:'They are registered with Grain, so the request goes to the domain Grain checked. Whoever answers signs in first.',
    rows:[['They write what you did','In their words. You cannot edit it.'],
          ['You can attach your side','Kept beside theirs, never replacing it.'],
          ['They can decline','And nothing is added, including that they declined.']],
    cta:'Send the request', alt:'Not now',
    foot:'A request tells them the dates you recorded. It tells them nothing about the rest of your record.'});
}
function askManagerBody(){
  return '<div><h1 class="t-head" style="margin:0">Ask a manager</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">R. Santos Dry Goods is not registered with Grain. If someone there confirms a work address, your record shows a person at a business Grain recognises.</p>' +
    '<div style="margin-top:26px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Their work email</span>' +
    '<span class="ruled lg"><input inputmode="email" autocomplete="off" aria-label="Their work email" placeholder="name@rsantos.ph"></span></div>' +
    '<div style="margin-top:22px">' + rows([
      ['Grain checks they control the address','Nothing more. Not their role, not their dates.'],
      ['They attest what you did','And their mark says a named party at that business.']
    ]) + '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press" disabled>Send the request</button></div></div>';
}
function askCoworkerBody(){
  return msg({title:'Ask a coworker',
    body:'Someone who saw the work. A coworker is a real witness, and the record says plainly that is what they are.',
    rows:[['Their mark differs from a business mark','A reader can tell the two apart at a glance.'],
          ['They are named on your record','Not anonymous, and not a rating.'],
          ['One coworker is not two','A second party agreeing shows as a second mark.']],
    cta:'Choose a coworker', alt:'Not now',
    foot:'A coworker attestation is not a lesser answer. It is a different one, and the marks say which.'});
}
function requestSentBody(){
  return msg({pad:16, title:'Request sent',
    body:'To Cebu Pacific Cargo Services, at the address Grain checked.',
    rows:[['They have not answered yet','Nothing on your record has changed.', 'Sent 12 Mar'],
          ['You can send it again','After seven days.', 'From 19 Mar'],
          ['You can withdraw it','Until they answer.', null]],
    cta:'Back to your record',
    foot:'Grain does not tell you when they open it. Read events are not recorded anywhere.'});
}

/* ================= F, identity verification =================
   027 is the constraint that shapes every word here: nowhere may a graded
   claim collapse into a yes. The document is CHECKED. The person is not
   "verified", and a partner is never told they are. */
function idWhyBody(){
  return msg({title:'Check your identity',
    body:'Only when a party asks for it, or when you turn the public page on. It is not required to keep a record.',
    rows:[['What is taken','A photograph of your document, and a photograph of you.'],
          ['Who sees it','Persona checks it. Grain stores the result, not the images.'],
          ['What it proves','That the document is genuine and it is yours. Nothing about your work.']],
    cta:'Start', alt:'Not now',
    foot:'You can delete the result at any time, and your record stays exactly as it is.'});
}
function idCheckingBody(){
  return arcmark('Checking your document') +
    '<div style="text-align:center;padding-top:24px">' +
    '<p class="t-lead" style="margin:0">Checking the document</p>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Usually under a minute. You can leave this screen and come back.</p></div>';
}
function idResultBody(){
  return msg({title:'The document checked out',
    body:'Your record now says an identity document was checked, and the date. It says nothing more than that.',
    rows:[['What a reader sees','Identity document checked, January 2025.'],
          ['What a reader does not see','The document, the photographs, or the country.'],
          ['What it does not say','That your work is verified. Nothing here touches your work.']],
    cta:'Back to your record',
    foot:'Grain never prints that a person is verified, because a person is not a claim that can be true.'});
}
function idLivenessBody(){
  return msg({title:'One photograph of you',
    body:'To check the document belongs to you rather than to someone holding it. Separate from the document check, and you can decline.',
    rows:[['It is compared once','Against the document photograph, then discarded.'],
          ['It is not kept','Grain stores the answer, not the picture.'],
          ['Declining costs you one thing','The record says the document was checked, not that it was matched to you.']],
    cta:'Take the photograph', alt:'Skip this'});
}
function idFailedBody(){
  return msg({pad:16, alert:true, title:'That did not check out',
    body:'The document could not be read, or it did not match. Nothing has been added to your record and nothing was kept.',
    rows:[['Try a different photograph','Flat, in good light, the whole document in frame.'],
          ['Try a different document','A passport reads more reliably than a card.'],
          ['Carry on without it','Your record works. A party can still attest your work.']],
    cta:'Try again', alt:'Carry on without it'});
}


/* ================= G, sharing ================= */
function publicPageBody(){
  return '<div><h1 class="t-head" style="margin:0">Your public page</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Off by default, because a work record is not something to publish by accident.</p>' +
    '<div class="grp">' +
    '<div class="listrow"><span style="flex:1;min-width:0"><span class="t-rec" style="display:block">Public page</span>' +
    '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Off. Nobody reaches your record by searching for you.</span></span>' +
    '<button class="sw press js-sw" role="switch" aria-checked="false" aria-label="Public page"><i></i></button></div>' +
    '<div class="listrow"><span style="flex:1;min-width:0"><span class="t-rec" style="display:block">Show your imprint on it</span>' +
    '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">To people. Search engines get the words and never the figure.</span></span>' +
    '<button class="sw press js-sw" role="switch" aria-checked="true" aria-label="Show your imprint"><i></i></button></div></div>' +
    '<div style="margin-top:24px"><button class="btn-secondary press">Preview what a stranger sees</button></div>' +
    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">Turning it off removes the page. Anyone holding a grant still has one, until its date passes.</p></div>';
}
function sendRecordBody(){
  return '<div><h1 class="t-head" style="margin:0">Send your record</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">To one named person. It is not a link that can be forwarded, and it ends on a date you set.</p>' +
    '<div style="margin-top:26px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Their email</span>' +
    '<span class="ruled lg"><input inputmode="email" autocomplete="off" aria-label="Their email" placeholder="hiring@alorica.com"></span></div>' +
    '<div class="grp"><button class="srow press"><span class="t-rec" style="flex:1">Ends</span>' +
    '<span class="t-data" style="color:var(--secondary)">In 30 days</span></button></div>' +
    '<div style="margin-top:24px">' + rows([
      ['They prove the address is theirs','Before they can read anything.'],
      ['They see the whole record','Grain does not offer a partial one, because a selection is a claim.']
    ]) + '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press" disabled>Send it</button></div></div>';
}
function grantDetailBody(){
  return msg({title:'Alorica Philippines',
    body:'Holds a grant to your whole record.',
    rows:[['Granted','You sent it.','12 Feb 2026'],
          ['Ends','Unless you end it sooner.','12 Sep 2026'],
          ['Scope','The whole record. Grain has no partial grant.', null]],
    cta:'End this grant now',
    warn:'Ending it stops access from this moment. It does not erase that the grant existed, and it does not unsend what they already read.',
    foot:'Grain does not tell you whether they read it. Read events are not recorded.'});
}

/* ================= H, account ================= */
function ledgerBody(){
  return '<div><h1 class="t-head" style="margin:0">The ledger</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Every entry, in the order it happened. Your record is a reading of this, and this is the thing itself.</p>' +
    '<div style="margin-top:24px">' + rows([
      ['Cebu Pacific attested a chapter',null,'12 Mar 2026'],
      ['You corrected a spelling',null,'04 Mar 2026'],
      ['You sent a grant to Alorica',null,'12 Feb 2026'],
      ['Identity document checked',null,'22 Jan 2026'],
      ['You added a chapter',null,'19 Jan 2026'],
      ['Record opened',null,'19 Jan 2026']
    ]) + '</div>' +
    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">Nothing here can be edited or removed, including by Grain. A correction is a new entry.</p></div>';
}
function notifPrefsBody(){
  var items = [['A party attests your work','The only one that changes your record.', true],
               ['A grant is about to end','Four days before.', true],
               ['A deadline to attach your side','Only when one is running.', false]];
  return '<div><h1 class="t-head" style="margin:0">Notifications</h1>' +
    '<div class="grp">' + items.map(function(i){
      return '<div class="listrow"><span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(i[0]) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(i[1]) + '</span></span>' +
        '<button class="sw press js-sw" role="switch" aria-checked="' + i[2] + '" aria-label="' + esc(i[0]) + '"><i></i></button></div>';
    }).join('') + '</div>' +
    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">Grain never notifies you that someone read your record, because it does not record that.</p></div>';
}
function languageBody(){
  return '<div><h1 class="t-head" style="margin:0">Language</h1>' +
    '<div style="margin-top:22px">' +
    [['English','', true],['Tagalog','', false]].map(function(l){
      return '<button class="row press"><span class="gutter" style="padding-top:2px">' +
        '<svg width="20" height="20" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="' +
        (l[2] ? '#i-done' : '#i-open') + '"></use></svg></span>' +
        '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(l[0]) + '</span></span></button>';
    }).join('') +
    '<div class="row" style="opacity:.55"><span class="gutter" style="padding-top:2px">' +
    '<svg width="20" height="20" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="#i-open"></use></svg></span>' +
    '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">Hindi</span>' +
    '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Not yet. Grain does not have a typeface that carries Devanagari at the quality the rest of the app is set in.</span></span></div>' +
    '</div></div>';
}
function exportBody(){
  return msg({title:'Export your record',
    body:'A file you keep, containing everything: chapters, attestations, grants and the ledger.',
    rows:[['It arrives by email','Within 24 hours, to the address on your account.'],
          ['It is the whole thing','Not a summary, and not a selection.'],
          ['It is yours','Grain does not need to exist for the file to be readable.']],
    cta:'Ask for an export',
    foot:'Asking again before it arrives does not make it faster.'});
}
function disclosureBody(){
  return '<div><h1 class="t-head" style="margin:0">Who can read your record</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Everyone who has ever been given access, and when it ended. This is the list, not a guess.</p>' +
    '<div style="margin-top:24px">' + rows([
      ['Alorica Philippines','Whole record. Ends 12 Sep 2026.','Live'],
      ['Cebu Pacific Cargo Services','Whole record. Ends 12 Nov 2026.','Live'],
      ['Metro Manila Logistics','You ended it on 03 Jan 2026.','Ended']
    ]) + '</div>' +
    '<div class="warn" style="margin-top:22px"><p class="t-body" style="margin:0;text-wrap:pretty">This says who could read it. It does not say who did. Grain does not record that anyone opened your record, so it cannot tell you, and neither can anyone else.</p></div></div>';
}
function supportBody(){
  return msg({title:'Contact support',
    body:'Every change to your account goes through a person, on purpose. There is no button that quietly rewrites the ledger.',
    rows:[['Change your name or number','A person checks it is you.'],
          ['Dispute an attestation','You attach your side, and it stays attached.'],
          ['Delete everything','Filed here, and executed after the grace period.']],
    cta:'Write to support', foot:'Usually answered within two working days.'});
}
function deleteBody(){
  return msg({title:'Delete everything',
    body:'This files a request. It does not delete anything by itself.',
    rows:[['Your access stops now','The moment you file it, you cannot read your record.'],
          ['It is executed after 30 days','A person at Grain carries it out.'],
          ['Signing in cancels it','And you would have to file it again.']],
    cta:'File the request', alt:'Keep my record',
    warn:'Attestations other parties made about you are erased with everything else. They cannot be recovered, by you or by them.'});
}
function deletePendingBody(){
  return msg({pad:16, alert:true, title:'Deletion requested',
    body:'Filed 04 Mar 2026. Your record is closed to you and to everyone holding a grant.',
    rows:[['Executed on','Unless you sign in first.','03 Apr 2026'],
          ['Signing in cancels it','And restores every grant that has not expired.', null]],
    cta:'Cancel the request and sign in'});
}
function unlockBody(){
  return '<div style="position:absolute;inset:0;display:flex;flex-direction:column;' +
    'align-items:center;justify-content:center;padding:0 24px;text-align:center;gap:20px">' +
    '<svg viewBox="0 0 160 26" width="130" height="21" role="img" aria-label="Grain" style="opacity:.5">' + LOCKUP + '</svg>' +
    '<p class="t-lead" style="margin:0">Unlock to open your record</p>' +
    '<p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">A shared phone is a real thing, so the record does not open on its own.</p>' +
    '<button class="btn-secondary press" style="max-width:260px">Use Face ID</button>' +
    '<button class="btn-tertiary press">Use the passcode</button></div>';
}
function signOutBody(){
  return msg({title:'Sign out',
    body:'On this phone only. Your record and every grant stay exactly as they are.',
    rows:[['You will need a code to return','Sent to the number on your account.'],
          ['Nothing is deleted','Signing out is not deleting.']],
    cta:'Sign out', alt:'Stay signed in'});
}


/* ================= I9, the app icon =================
   It is the Grain mark, which was never the question. What is open is the
   mark itself: mark/README is stamped provisional, the lobe count is
   explicitly unsettled, and the break angle is "wherever the parameter put
   it". An icon is the most trademark-exposed use a mark ever gets, and §2
   opens the lobe count partly over collision with existing marks, so this is
   drawn and labelled rather than shipped. */
function iconSvg(size, ground){
  return '<svg viewBox="0 0 600 600" width="' + size + '" height="' + size + '" ' +
    'aria-hidden="true" style="display:block"><rect width="600" height="600" fill="' +
    (ground || 'var(--paper)') + '"></rect><g fill="var(--ink)" stroke="none" ' +
    'transform="translate(300 300) scale(0.78) translate(-300 -300)">' + MARKSOLID + '</g></svg>';
}
function appIconBody(){
  return '<div><h1 class="t-head" style="margin:0">The app icon</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">The mark at its solid tier, which is the reduction drawn for small sizes. No wordmark: an icon that needs its name read is not working.</p>' +

    '<div style="margin-top:26px">' + sechead('iOS') + '</div>' +
    '<div class="icrow">' +
      '<span class="ic ios" style="width:120px;height:120px">' + iconSvg(120) + '</span>' +
      '<span class="ic ios" style="width:60px;height:60px">' + iconSvg(60) + '</span>' +
      '<span class="ic ios" style="width:29px;height:29px">' + iconSvg(29) + '</span>' +
    '</div>' +
    '<p class="t-meta" style="margin:10px 0 0;color:var(--secondary)">120, 60 and 29 pt. The last is Settings, and it is the size that decides the lobe count.</p>' +

    '<div style="margin-top:26px">' + sechead('Android, adaptive') + '</div>' +
    '<div class="icrow">' +
      '<span class="ic and-sq" style="width:108px;height:108px">' + iconSvg(108) + '<i class="safe"></i></span>' +
      '<span class="ic and-ci" style="width:108px;height:108px">' + iconSvg(108) + '</span>' +
      '<span class="ic and-sc" style="width:108px;height:108px">' + iconSvg(108) + '</span>' +
    '</div>' +
    '<p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">108 dp with the 72 dp safe zone marked. A launcher may mask to any of these, so the mark has to survive a circle.</p>' +

    '<div class="warn" style="margin-top:26px"><p class="t-body" style="margin:0;text-wrap:pretty">Provisional. mark/README §6 leaves the lobe count open, and the break angle is wherever the parameter put it rather than locked to the top, so this icon has no stated orientation yet.</p></div>' +
    '<div style="margin-top:22px">' + rows([
      ['Lobe count','Open, and §2 keeps it open partly over collision with existing marks.'],
      ['Break angle','Should be locked to the top so the mark has one orientation.'],
      ['Silhouette across tiers','The solid tier reads slightly rounder than the full one. Someone seeing this icon and then the header should see one shape.']
    ]) + '</div></div>';
}

// The registry. A surface is a title and a body function; the rest of the app
// is additions here rather than new plumbing.
var SURFACES = {
  imprint: {title:'Imprint', body:imprintBody},
  code: {title:'Code', body:codeBody},
  addchapter: {title:'Add', body:addBody},
  permanence: {title:'Permanence', body:permanenceBody},
  identifier: {title:'Identifier', body:identifierBody},
  name: {title:'Name', body:nameBody},
  doctype: {title:'Document', body:docTypeBody},
  capture: {title:'Capture', body:captureBody},
  parsing: {title:'Parsing', body:parseBody},
  importreview: {title:'Import', body:importBody},
  handle: {title:'Address', body:handleBody},
  permcamera: {title:'Camera', body:function(){ return permBody('camera'); }},
  permnotify: {title:'Notifications', body:function(){ return permBody('notify'); }},
  consent: {title:'Consent', body:consentBody},
  launch: {title:'Launch', body:launchBody},
  lander: {title:'Lander', body:landerBody},
  welcome: {title:'Welcome', body:welcomeBody},
  addposition: {title:'Position', body:positionBody},
  minoredit: {title:'Edits', body:minorEditBody},
  notfound: {title:'Not found', body:notFoundBody},
  updaterequired: {title:'Update', body:updateBody},
  signedout: {title:'Signed out', body:signedOutBody},
  pushcontent: {title:'Notifications', body:pushBody2},
  legal: {title:'How this works', body:legalBody},
  reqattest: {title:'Request', body:reqAttestBody},
  askmanager: {title:'Ask a manager', body:askManagerBody},
  askcoworker: {title:'Ask a coworker', body:askCoworkerBody},
  requestsent: {title:'Sent', body:requestSentBody},
  idwhy: {title:'Identity', body:idWhyBody},
  idchecking: {title:'Checking', body:idCheckingBody},
  idresult: {title:'Result', body:idResultBody},
  idliveness: {title:'Liveness', body:idLivenessBody},
  idfailed: {title:'Not checked', body:idFailedBody},
  publicpage: {title:'Public page', body:publicPageBody},
  sendrecord: {title:'Send', body:sendRecordBody},
  grantdetail: {title:'Grant', body:grantDetailBody},
  ledger: {title:'Ledger', body:ledgerBody},
  notifprefs: {title:'Notifications', body:notifPrefsBody},
  language: {title:'Language', body:languageBody},
  exportrec: {title:'Export', body:exportBody},
  disclosure: {title:'Disclosure', body:disclosureBody},
  support: {title:'Support', body:supportBody},
  deleterec: {title:'Delete', body:deleteBody},
  deletepending: {title:'Deletion', body:deletePendingBody},
  unlock: {title:'Unlock', body:unlockBody},
  signout: {title:'Sign out', body:signOutBody},
  appicon: {title:'App icon', body:appIconBody},
  sharing: {title:'Sharing', body:sharingBody},
  account: {title:'Account', body:accountBody}
};

function paintBar(){
  var lead = '', trail = '', n = S.stack.length;
  if(n){
    var prev = n > 1 ? SURFACES[S.stack[n-2].kind].title : 'Record';
    lead = '<button class="backbtn press js-back" aria-label="Back">' +
      '<svg width="22" height="22" viewBox="0 0 24 24" class="icon"><use href="#i-back"></use></svg>' +
      (S.platform === 'ios' ? '<span class="t-rec">' + esc(prev) + '</span>' : '') + '</button>';
  } else {
    if(S.lockup === 'bar'){
      lead = '<span style="padding-left:12px"><svg viewBox="0 0 160 26" width="132" height="21" role="img" aria-label="Grain">' + LOCKUP + '</svg></span>';
    }
    lead += '<button class="iconbtn press js-acc" aria-label="Account and settings">' + ACC + '</button>';
    trail = '<button class="iconbtn press js-share" aria-label="Sharing. Two parties hold a grant, public page off">' + SHARE + '</button>';
  }
  $('lead').innerHTML = lead;
  $('trail').innerHTML = trail;
}

function paintPlate(){
  var t = S.platform === 'ios' ? 109 : 74, b = S.platform === 'ios' ? 41 : 31;
  $('plate').innerHTML =
    '<span class="reg" style="top:' + t + 'px;left:7px;border-top-width:1px;border-left-width:1px"></span>' +
    '<span class="reg" style="top:' + t + 'px;right:7px;border-top-width:1px;border-right-width:1px"></span>' +
    '<span class="reg" style="bottom:' + b + 'px;left:7px;border-bottom-width:1px;border-left-width:1px"></span>' +
    '<span class="reg" style="bottom:' + b + 'px;right:7px;border-bottom-width:1px;border-right-width:1px"></span>';
}

function render(kind, d){
  if(S.five) return stateBody(S.five, SURFACES[kind] ? SURFACES[kind].title : 'Your record');
  return kind === 'record' ? recordBody() : SURFACES[kind].body(d);
}
function paintRecord(){ $('rec').innerHTML = render('record'); }
function repaintStack(){
  S.stack.forEach(function(d){ d.el.querySelector('.doc').innerHTML = render(d.kind, d); });
}

function applyPlatform(){
  $('stage').classList.toggle('android', S.platform === 'android');
  $('island').style.display = S.platform === 'ios' ? '' : 'none';
  $('punchhole').style.display = S.platform === 'ios' ? 'none' : '';
  paintPlate(); paintBar();
}
function applyScale(){
  $('scr').style.fontSize = (S.scale * 100) + '%';
  paintRecord(); repaintStack();
}

function topLayer(){ return S.stack.length ? S.stack[S.stack.length-1].el : $('base'); }
function topDoc(){ return topLayer().querySelector('.doc') || $('rec'); }

function push(d){
  var below = topLayer();
  var el = document.createElement('div');
  el.className = 'layer pushl';
  el.innerHTML = '<div class="edgegrab"></div><div class="doc"></div>';
  el.querySelector('.doc').innerHTML = render(d.kind, d);
  $('scr').insertBefore(el, $('plate'));
  d.el = el; S.stack.push(d);
  wireEdge(el);
  el.querySelector('.doc').addEventListener('scroll', syncEdge, {passive:true});
  el.getBoundingClientRect();
  requestAnimationFrame(function(){
    el.classList.add('open'); below.classList.add('behind');
    paintBar(); syncEdge();
  });
}
function pop(){
  if(!S.stack.length) return;
  var d = S.stack.pop(), el = d.el, below = topLayer();
  el.classList.remove('open'); below.classList.remove('behind');
  paintBar(); syncEdge();
  setTimeout(function(){ if(el.parentNode) el.parentNode.removeChild(el); }, 460);
}

function openSheet(o){
  var c = CH[o.i];
  $('sheetkicker').textContent = o.kicker;
  $('sheettitle').textContent = c.party;
  $('sheetbody-p').textContent = o.body;
  $('sheetcta').textContent = o.cta;
  $('sheetslot').innerHTML = '';
  S.sheetOpen = true; S.sheetKind = 'request';
  requestAnimationFrame(function(){
    $('sheet').classList.add('on'); $('scrim').classList.add('on');
    if(S.platform === 'ios'){
      $('scr').classList.add('recede');
      $('chrome').classList.add('onblack');
    }
  });
}
var MON = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
var pick = {field:null, year:2019, month:null};
function monthSheetHTML(){
  return '<div class="yrow"><button class="barbtn press" data-yr="-1" aria-label="Previous year">&lsaquo;</button>' +
    '<span class="t-lead">' + pick.year + '</span>' +
    '<button class="barbtn press" data-yr="1" style="text-align:right" aria-label="Next year">&rsaquo;</button></div>' +
    '<div class="mgrid">' + MON.map(function(m, i){
      return '<button data-mon="' + i + '" aria-pressed="' + (pick.month === i) + '">' + m + '</button>';
    }).join('') + '</div>';
}
function openMonth(field){
  pick.field = field; pick.month = null;
  $('sheetkicker').textContent = field === 'from' ? 'Started' : 'Ended';
  $('sheettitle').textContent = 'Pick a month';
  $('sheetbody-p').textContent = '';
  $('sheetslot').innerHTML = monthSheetHTML();
  $('sheetcta').textContent = 'Set';
  S.sheetOpen = true; S.sheetKind = 'month';
  requestAnimationFrame(function(){
    $('sheet').classList.add('on'); $('scrim').classList.add('on');
    if(S.platform === 'ios'){ $('scr').classList.add('recede'); $('chrome').classList.add('onblack'); }
  });
}
function closeSheet(){
  S.sheetOpen = false;
  $('sheet').classList.remove('on'); $('scrim').classList.remove('on');
  $('scr').classList.remove('recede'); $('chrome').classList.remove('onblack');
}

function syncEdge(){ $('barbg').classList.toggle('on', topDoc().scrollTop > 2); }

function wireEdge(el){
  var g = el.querySelector('.edgegrab'), x0 = 0, dx = 0, t0 = 0, live = false;
  function move(e){ if(!live) return; dx = Math.max(0, e.clientX - x0);
    el.style.transform = 'translateX(' + dx + 'px)'; }
  function up(){
    if(!live) return; live = false;
    el.classList.remove('dragging'); el.style.transform = '';
    window.removeEventListener('pointermove', move); window.removeEventListener('pointerup', up);
    if(dx > 134 || (Date.now() - t0 < 260 && dx > 60)) pop();
  }
  g.addEventListener('pointerdown', function(e){
    if(topLayer() !== el || S.platform !== 'ios') return;
    live = true; x0 = e.clientX; dx = 0; t0 = Date.now();
    el.classList.add('dragging');
    window.addEventListener('pointermove', move); window.addEventListener('pointerup', up);
  });
}

// §10's attestation landing, one of the two ceremonies the system reserves.
function playSeat(){
  var run = function(){
    push({kind:'imprint'});
    setTimeout(function(){
      var row = topLayer().querySelector('[data-row="4"]');
      if(!row) return;
      CH[4].attested = true;
      setTimeout(function(){
        row.classList.remove('proud'); row.classList.add('seating');
        if(navigator.vibrate) navigator.vibrate(12);
        setTimeout(function(){
          row.classList.remove('seating');
          var big = topLayer().querySelector('.bigfig');
          if(big){ big.classList.remove('moved'); void big.offsetWidth; big.classList.add('moved'); }
        }, 320);
      }, 420);
    }, 80);
  };
  if(S.stack.length){ while(S.stack.length) pop(); setTimeout(run, 480); } else { run(); }
}

var GRAT2;
// The menu is generated from the registry and grouped by design/08's own
// sections, so adding a surface is one registry entry and nothing else.
var NAV = [
  ['First run', ['launch','lander','identifier','code','welcome','name','consent','handle']],
  ['The record', ['record','imprint','permanence']],
  ['Chapters', ['addchapter','parsing','importreview','addposition','minoredit']],
  ['Getting verified', ['reqattest','askmanager','askcoworker','requestsent']],
  ['Identity', ['idwhy','doctype','capture','idchecking','idresult','idliveness','idfailed','permcamera']],
  ['Sharing', ['sharing','publicpage','sendrecord','grantdetail']],
  ['Account', ['account','ledger','notifprefs','permnotify','language','exportrec','disclosure','support','deleterec','deletepending','unlock','signout']],
  ['System', ['notfound','updaterequired','signedout','pushcontent','legal','appicon']]
];
var NAVNAME = {
  record:'The record', launch:'Launch', lander:'Signed-out lander', identifier:'Identifier',
  code:'One-time code', welcome:'Welcome back', name:'Your name', consent:'Consent (blocked)',
  handle:'Claim your address', imprint:'Imprint', permanence:'What you can change',
  addchapter:'Add a chapter', parsing:'Parsing a file', importreview:'Import review',
  addposition:'Add a position', minoredit:'Minor edits', reqattest:'Request attestation',
  askmanager:'Ask a manager', askcoworker:'Ask a coworker', requestsent:'Request sent',
  idwhy:'Why check identity', doctype:'Document type', capture:'Capture the document',
  idchecking:'Checking', idresult:'Result', idliveness:'Liveness', idfailed:'Could not check',
  permcamera:'Camera permission', sharing:'Sharing', publicpage:'Public page',
  sendrecord:'Send the record', grantdetail:'Grant detail', account:'Account', ledger:'The ledger',
  notifprefs:'Notification preferences', permnotify:'Notification permission', language:'Language',
  exportrec:'Export', disclosure:'Who can read it', support:'Support', deleterec:'Delete everything',
  deletepending:'Deletion requested', unlock:'Unlock', signout:'Sign out',
  appicon:'App icon (provisional)', notfound:'Address not found', updaterequired:'Update required', signedout:'Signed out',
  pushcontent:'Notification content', legal:'How this works'
};
function buildNav(){
  var sel = $('g-screen'), html = '';
  NAV.forEach(function(g){
    html += '<optgroup label="' + esc(g[0]) + '">';
    g[1].forEach(function(k){
      if(k !== 'record' && !SURFACES[k]) return;
      html += '<option value="' + k + '">' + esc(NAVNAME[k] || k) + '</option>';
    });
    html += '</optgroup>';
  });
  sel.innerHTML = html;
}

function boot(){
  SHARE = T('t-share'); ACC = T('t-acc'); CHEV = T('t-chev');
  FIGURE = T('t-chapters'); RULE = T('t-sinerule'); LOCKUP = T('t-lockup');
  GRAT = T('t-graticule'); GRAT2 = GRAT; PORTRAIT = T('t-portrait');
  MARK56 = T('t-mark56'); EMPTYFIG = T('t-empty'); MARKSOLID = T('t-marksolid');
  buildNav();
  paintRecord(); applyPlatform();
  $('rec').addEventListener('scroll', syncEdge, {passive:true});
}
boot();

document.addEventListener('click', function(e){
  var t = e.target; if(!t || !t.closest) return;
  if(t.closest('.js-imprint')) return push({kind:'imprint'});
  var row = t.closest('[data-out]');
  if(row) return openSheet(OUT[+row.getAttribute('data-out')]);
  var disc = t.closest('[data-open]');
  if(disc){ disc.parentNode.classList.toggle('on'); return; }
  if(t.closest('.js-back')) return pop();
  if(t.closest('.js-share')) return push({kind:'sharing'});
  if(t.closest('.js-acc')) return push({kind:'account'});
  if(t.closest('#sheetcta') && S.sheetKind === 'month'){
    if(pick.month != null){
      draft[pick.field] = MON[pick.month] + ' ' + pick.year;
      repaintStack();
    }
    return closeSheet();
  }
  if(t.closest('#sheetcancel') || t.closest('#sheetcta') || t.closest('#scrim')) return closeSheet();
  var yr = t.closest('[data-yr]');
  if(yr){ pick.year += parseInt(yr.getAttribute('data-yr'), 10); $('sheetslot').innerHTML = monthSheetHTML(); return; }
  var mo = t.closest('[data-mon]');
  if(mo){ pick.month = parseInt(mo.getAttribute('data-mon'), 10); $('sheetslot').innerHTML = monthSheetHTML(); return; }
  var mf = t.closest('[data-month]');
  if(mf) return openMonth(mf.getAttribute('data-month'));
  var dc = t.closest('[data-country]');
  if(dc){
    idf.country = (idf.country + 1) % COUNTRIES.length;
    paintRecord(); repaintStack(); return;
  }
  var im = t.closest('[data-idmode]');
  if(im){ idf.mode = im.getAttribute('data-idmode'); repaintStack(); return; }
  var dd = t.closest('[data-doc]');
  if(dd){ docPick = parseInt(dd.getAttribute('data-doc'), 10); repaintStack(); return; }
  var df = t.closest('[data-found]');
  if(df){ var i = parseInt(df.getAttribute('data-found'), 10); FOUND[i].on = !FOUND[i].on; repaintStack(); return; }
  var pp = t.closest('[data-party]');
  if(pp){
    draft.party = pp.getAttribute('data-party') || null;
    if(draft.party) draft.typed = draft.party;
    repaintStack();
    return;
  }
  var sw = t.closest('.js-sw');
  if(sw) sw.setAttribute('aria-checked', sw.getAttribute('aria-checked') === 'true' ? 'false' : 'true');
});

(function(){
  var g = $('grab'), sheet = $('sheet'), y0 = 0, dy = 0, live = false;
  function move(e){ if(!live) return; dy = Math.max(0, e.clientY - y0);
    sheet.style.transform = 'translateY(' + dy + 'px)'; }
  function up(){
    if(!live) return; live = false;
    sheet.classList.remove('dragging'); sheet.style.transform = '';
    window.removeEventListener('pointermove', move); window.removeEventListener('pointerup', up);
    if(dy > 90) closeSheet();
  }
  g.addEventListener('pointerdown', function(e){
    if(!S.sheetOpen) return;
    live = true; y0 = e.clientY; dy = 0; sheet.classList.add('dragging');
    window.addEventListener('pointermove', move); window.addEventListener('pointerup', up);
  });
})();

document.addEventListener('input', function(e){
  var t = e.target;
  if(t.id === 'psearch'){
    draft.typed = t.value; draft.party = null;
    var r = document.getElementById('presults');
    if(r) r.innerHTML = partyResults();
  }
  if(t.id === 'otp'){
    t.value = t.value.replace(/[^0-9]/g, '').slice(0, 6);
    var go = document.getElementById('otpgo');
    if(go) go.disabled = t.value.length !== 6;
  }
});

document.addEventListener('change', function(e){
  if(e.target.id === 'g-screen'){
    var v = e.target.value;
    while(S.stack.length) pop();
    if(v !== 'record') setTimeout(function(){ push({kind:v}); }, 30);
    else setTimeout(paintRecord, 30);
    return;
  }
  if(e.target.id === 'g-five'){
    S.five = e.target.value || null;
    paintRecord(); repaintStack();
  }
});

document.querySelectorAll('.seg').forEach(function(seg){
  seg.addEventListener('click', function(e){
    var b = e.target.closest('button'); if(!b) return;
    var v = b.getAttribute('data-v');
    if(seg.id === 'g-seat') return playSeat();
    if(seg.id === 'g-screen'){
      while(S.stack.length) pop();
      if(v !== 'record') setTimeout(function(){ push({kind:v}); }, S.stack.length ? 460 : 20);
      return;
    }
    seg.querySelectorAll('button').forEach(function(x){
      x.setAttribute('aria-pressed', String(x === b)); });
    if(seg.id === 'g-lockup'){ S.lockup = v; paintBar(); }
    else if(seg.id === 'g-bar'){ S.bar = v; $('barbg').classList.toggle('screen', v === 'screen'); }
    else if(seg.id === 'g-platform'){ while(S.stack.length) pop(); S.platform = v; applyPlatform(); }
    else if(seg.id === 'g-scale'){ S.scale = parseFloat(v); applyScale(); }
    else if(seg.id === 'g-state'){ S.state = v; while(S.stack.length) pop(); paintRecord(); }
  });
});
</script>
</body>
</html>
