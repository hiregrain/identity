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
.homebtn{display:flex;align-items:center;min-height:44px;padding:0 6px 0 2px}
.bardiv{flex:0 0 1px;height:16px;background:var(--hairline);margin:0 3px}
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
/* Selecting a chapter lights its band. The first version only dimmed the
   others, which is a subtractive signal: four hairlines going fainter reads as
   the figure losing contrast rather than as one band being chosen, especially
   at the size the figure sits beside a list. The selected band now also
   thickens, so the signal is additive and survives being glanced at. */
.fx .ch{opacity:.12;transition:opacity 300ms linear}
.fx .ch *{transition:stroke-width 240ms linear}
.fx.f0 .ch0,.fx.f1 .ch1,.fx.f2 .ch2,.fx.f3 .ch3,.fx.f4 .ch4{opacity:1}
.fx.f0 .ch0 *,.fx.f1 .ch1 *,.fx.f2 .ch2 *,.fx.f3 .ch3 *,.fx.f4 .ch4 *{stroke-width:2.6}
@media (prefers-reduced-motion:reduce){
  .fx .ch,.fx .ch *{transition:none}
}
/* And the row that caused it says so. Without this the figure changed and
   nothing on the screen connected the change to the thing that was clicked. */
.disc.on > [data-row]{box-shadow:inset 2px 0 0 var(--ink)}

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
        <svg aria-hidden="true" viewBox="0 0 402 874" preserveAspectRatio="none" fill="none"
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
/* Every row here is a destination the app already draws. They were chevroned
   buttons that went nowhere, so half the account surfaces could only be reached
   by typing their name into the console. A row that carries a chevron and does
   not move is a fact dressed as a control, which the chassis forbids in the
   other direction and should forbid in this one. */
var ACCOUNT = [
  ['Identity', [
    ['idwhy', 'Name and identity', 'What Grain checked, and when'],
    ['unlock', 'Unlock this device', 'Biometrics or your passcode']
  ]],
  ['Your record', [
    ['requests', 'Requests you have made', 'What you have asked, and whether it has been answered'],
    ['ledger', 'The ledger', 'Every entry, in the order it happened'],
    ['disclosure', 'Who has read it', 'The record of disclosures, on request'],
    ['exportrec', 'Export your record', 'A file you keep']
  ]],
  ['This app', [
    ['notifprefs', 'Notifications', 'What Grain may tell you about'],
    ['language', 'Language', 'English'],
    ['legal', 'How this works', 'Terms, privacy, and what the marks mean']
  ]],
  ['Getting help, and leaving', [
    ['support', 'Message support', 'The route for every account change'],
    ['deleterec', 'Delete everything', 'Files a request. Access stops the moment you file it.'],
    ['signout', 'Sign out', null]
  ]]
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
/* Decision 062 made education and credentials record objects and neither had
   ever been drawn, so `self-asserted-record` was ready with a third of its
   objects unreachable in the app. Schema 8 and 9 govern every field here,
   including the two "not present, deliberately" refusals: no grade, no GPA. */
var LEVELS = [['secondary','Secondary'],['diploma','Diploma'],['bachelor','Bachelor'],
              ['master','Master'],['doctorate','Doctorate'],['other','Other']];
var INSTITUTIONS = [
  {name:'Bataan Peninsula State University', where:'Philippines', reg:true},
  {name:'Polytechnic University of the Philippines', where:'Philippines', reg:true},
  {name:'TESDA Regional Training Center', where:'Philippines', reg:true}
];
var EDU = [
  {inst:'Bataan Peninsula State University', ref:true, level:'Diploma',
   field:'Food technology', from:'Jun 2014', to:'Mar 2016', completed:true}
];
var CRED = [
  {issuer:'TESDA', ref:true, name:'Food Safety NC II', from:'Aug 2017', to:'Aug 2022', doc:true}
];
var edraft = {inst:'', ref:false, country:0, level:null, field:'', completed:true};
var cdraft = {issuer:'', ref:false, country:0, name:'', doc:false};

var draft = {party:null, typed:'', from:'', to:'', reg:false,
             country:0, locality:'', kind:null,
             volUnit:'', volCount:'', firstPosition:false,
             positions:[], pos:{title:'', from:'', to:'', directed:'', team:'', same:''}};

/* model/record-schema.md 2. `relationship_kind` is an enum with no judgment in
   it, and in this population agency and platform work are common enough that
   collapsing them into "employed" loses a real distinction. */
var KINDS = [
  ['employment', 'Employed'], ['engagement', 'Engaged directly'],
  ['platform', 'Through a platform'], ['agency', 'Through an agency'],
  ['self_employed', 'Self-employed']
];

var S = {stack:[], sheetOpen:false, platform:'ios', scale:1, state:'full',
         lockup:'none', bar:'hard', five:null, ask:4};

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
        '<span class="figground" aria-hidden="true"><svg aria-hidden="true" viewBox="0 0 296 296" preserveAspectRatio="xMidYMid slice" fill="none" stroke="var(--rule)" stroke-width="0.5">' + GRAT2 + '</svg></span>' +
        '<svg class="fig moved" viewBox="0 0 600 600" role="img" aria-label="Your imprint. Five chapters, oldest innermost.">' + FIGURE + '</svg>' +
      '</div>' +
      '<button class="figopen press js-imprint">' +
        '<span class="t-rec" style="flex:1;min-width:0">Open your imprint, chapter by chapter</span>' +
        '<span class="chevs">' + CHEV + '</span></button>';
  }

  /* Education and credentials are record objects (062) and the record showed
     neither, so a third of the schema was unreachable in the app. They are not
     chapters and they draw no ring: the figure is chapters, and putting them on
     it would claim a shape the imprint does not encode. */
  if(EDU.length){
    out += '<div style="padding-top:28px">' + sechead('Education', EDU.length) +
      EDU.map(function(e){
        return '<div class="prow"><span class="gutter">' + mark(e.ref ? '#sw-emp' : '#sw-self') + '</span>' +
          '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(e.inst) + '</span>' +
          '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' +
            esc(e.level + ', ' + e.field + (e.completed ? '' : ', not completed')) + '</span></span>' +
          '<span class="col-r t-data" style="color:var(--secondary)">' + esc(e.from + ' to ' + e.to) + '</span></div>';
      }).join('') + '</div>';
  }
  if(CRED.length){
    out += '<div style="padding-top:28px">' + sechead('Certificates', CRED.length) +
      CRED.map(function(c2){
        return '<div class="prow"><span class="gutter">' + mark(c2.ref ? '#sw-emp' : '#sw-self') + '</span>' +
          '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(c2.name) + '</span>' +
          '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' +
            esc(c2.issuer + (c2.doc ? '. Document on file, which you supplied.' : '')) + '</span></span>' +
          '<span class="col-r t-data" style="color:var(--secondary)">' + esc(c2.from + ' to ' + c2.to) + '</span></div>';
      }).join('') + '</div>';
  }

  out += '<div style="padding-top:26px">' +
    goRow('addchapter', 'Add a chapter', 'Somewhere else you have worked') +
    goRow('education', 'Add a qualification', 'What you studied, and where') +
    goRow('credential', 'Add a certificate', 'A licence, a certificate, or a course') + '</div>';

  out += '<div style="padding-top:26px">' +
    goRow('requests', 'Requests you have made', REQUESTS.length + ' outstanding, none of them answered yet') +
    '</div>';

  out += '<div style="padding-top:28px">' + sechead('Who else could attest') +
    OUT.map(function(o, n){
      var c = CH[o.i];
      /* On a desk the chapter list is already on this surface, so naming the
         party again would be the second mention worker-surface criterion 01
         forbids, and it was failing that criterion. The prompt points at the
         chapter by its dates, which are unique and already the row's own
         right-hand column, rather than renaming it. On a phone the list is a
         push away, so the name is the only thing that identifies it. */
      var desk = (typeof S.vp !== 'undefined' && S.vp === 'desktop' && chapters().length);
      return '<button class="row press" data-out="' + n + '">' +
        '<span class="gutter">' + mark(c.sw) + '</span>' +
        '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' +
          (desk ? esc(o.gap) : esc(c.party)) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px">' +
          (desk ? 'The chapter above, ' + esc(c.from + ' to ' + c.to) : esc(o.gap)) + '</span></span>' +
        '<span class="col-r t-data" style="color:var(--secondary)">' + esc(c.from + ' to ' + c.to) + '</span></button>';
    }).join('') + '</div>';
  return out;
}

function imprintBody(p){
  var chs = chapters();
  var vh = 'position:absolute;width:1px;height:1px;overflow:hidden;clip-path:inset(50%);white-space:nowrap';
  var focus = (typeof p.n === 'number') ? ' fx f' + p.n : '';
  var out = '<div style="padding-top:4px">' +
    '<h1 class="t-sec" style="' + vh + '">Your imprint, chapter by chapter</h1>';
  if(!figureHidden()){
    out += '<span class="bigwrap">' +
      '<span class="figground" aria-hidden="true"><svg aria-hidden="true" viewBox="0 0 296 296" preserveAspectRatio="xMidYMid slice" fill="none" stroke="var(--rule)" stroke-width="0.5">' + GRAT2 + '</svg></span>' +
      '<svg class="bigfig unrolling' + focus + '" viewBox="0 0 600 600" role="img" aria-label="Your imprint at full size.">' + FIGURE + '</svg></span>';
  }
  out += '<p class="t-body" style="margin:20px 0 0;color:var(--secondary);text-wrap:pretty">Each ring is one chapter. The earliest is innermost, and a ring is as wide as the time it covers. The weave shows who attested it.</p>' +
    '<div style="margin-top:26px">' + sechead('Ring by ring, innermost first', chs.length) + '</div>' +
    chs.map(function(c, i){
      return '<div class="disc" data-disc="' + i + '">' +
        '<button class="row press' + (c.attested ? '' : ' proud') + '" data-open="' + i + '" data-row="' + i + '">' +
          '<span class="prov ' + (c.attested ? 'rigid' : 'press') + '" tabindex="0">' + mark(c.sw) +
            '<span class="tip t-meta">' + esc(c.label + ' ' + (c.by === c.party ? 'the business itself' : c.by) + '. ' + c.note) + '</span></span>' +
          '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(c.party) + '</span>' +
          '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(c.kind) + '</span></span>' +
          '<span class="col-r t-data" style="color:var(--secondary)">' + esc(c.from) + '</span>' +
          '<span class="chevs">' + CHEV + '</span></button>' +
        '<div class="discbody"><div>' +
          '<div class="attest"><span class="attmark">' + mark(c.sw, 68, 32, 0.5) + '</span>' +
            '<span style="flex:1;min-width:0">' +
              '<span class="t-micro" style="display:block;color:var(--secondary)">' + esc(c.label) + '</span>' +
              '<span class="t-lead" style="display:block;padding-top:3px;text-wrap:pretty">' +
                esc(c.by === c.party ? 'The business itself' : c.by) + '</span>' +
              '<span class="t-meta" style="display:block;padding-top:5px;color:var(--secondary);text-wrap:pretty">' + esc(c.note) + '</span>' +
            '</span></div>' +
          '<div class="attrow"><span class="t-micro" style="color:var(--secondary)">Dates</span>' +
            '<span class="t-data">' + esc(c.from + ' to ' + c.to) + '</span></div>' +
          '<div class="attrow"><span class="t-micro" style="color:var(--secondary)">Standing</span>' +
            '<span class="t-data">' + (c.attested ? 'Permanent' : 'Your own account') + '</span></div>' +
          /* What a worker can do about this chapter, next to the chapter. The
             record named two chapters worth chasing on the home surface and
             offered nothing anywhere else, so every other chapter was a fact
             with no available action. */
          '<div style="padding-top:6px">' +
            '<button class="listrow press" data-ask="' + i + '"><span style="flex:1;min-width:0">' +
              '<span class="t-rec" style="display:block">Get this confirmed</span>' +
              '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' +
                (c.attested ? 'Another party agreeing shows as a second mark.' : 'Nobody has confirmed this yet.') +
              '</span></span><span class="chevs">' + CHEV + '</span></button>' +
            goRow('addposition', 'Add a position here', 'A change of title inside this chapter') +
            (c.attested ? goRow('dispute', 'Dispute this attestation', 'If it is not genuine, or to attach your side of it') : '') +
            goRow(c.attested ? 'minoredit' : 'permanence',
                  c.attested ? 'What you can still change' : 'What you can change') +
          '</div>' +
        '</div></div></div>';
    }).join('') + '</div>';
  return out;
}

function sharingBody(){
  return '<div><h1 class="t-head" style="margin:0">Who can read this</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Each grant ends on its own date. A grant is to a named recipient, and it is not a link anyone can forward.</p>' +
    '<div style="margin-top:24px">' + sechead('Grants', 2) + '</div>' +
    '<button class="row press" data-go="grantdetail"><span style="flex:1;min-width:0"><span class="t-rec" style="display:block">Alorica Philippines</span>' +
    '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Whole record</span></span>' +
    '<span class="col-r t-data" style="color:var(--secondary)">Ends Sep 2026</span>' +
    '<span class="chev">' + CHEV + '</span></button>' +
    '<button class="row press" data-go="grantdetail"><span style="flex:1;min-width:0"><span class="t-rec" style="display:block">Cebu Pacific Cargo Services</span>' +
    '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Whole record</span></span>' +
    '<span class="col-r t-data" style="color:var(--secondary)">Ends Nov 2026</span>' +
    '<span class="chev">' + CHEV + '</span></button>' +
    goRow('sendrecord', 'Send your record to someone', 'A grant to a named person, with its own end date') +
    '<div class="listrow" style="margin-top:20px"><span style="flex:1;min-width:0">' +
    '<span class="t-rec" style="display:block">Public page</span>' +
    '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Off. Nobody reaches your record by searching.</span></span>' +
    '<button class="sw press js-sw" role="switch" aria-checked="false" aria-label="Public page"><i></i></button></div>' +
    goRow('publicpage', 'Manage your public page', 'What it would carry, and a preview') +
    '<p class="t-meta" style="color:var(--secondary);margin:24px 0 0;text-wrap:pretty">This record is held by its worker. A grant ends when its date passes, and revoking one stops access from that moment. Neither erases that the grant existed.</p></div>';
}

function goRow(route, label, note){
  return '<button class="listrow press" data-go="' + route + '"><span style="flex:1;min-width:0">' +
    '<span class="t-rec" style="display:block">' + esc(label) + '</span>' +
    (note ? '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px;text-wrap:pretty">' + esc(note) + '</span>' : '') +
    '</span><span class="chevs">' + CHEV + '</span></button>';
}
function accountBody(){
  return '<div><h1 class="t-head" style="margin:0">Your account</h1>' +
    ACCOUNT.map(function(g){
      return '<div class="grp"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:2px">' +
        esc(g[0]) + '</span>' +
        g[1].map(function(a){ return goRow(a[0], a[1], a[2]); }).join('') + '</div>';
    }).join('') + '</div>';
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
        '<button class="btn-tertiary press js-said" id="resend">Send it again</button></div>' +
    '</div>' +
    '<p class="t-meta" style="margin:26px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'Using someone else\'s phone? The code signs you in on this handset only, and you can sign out from your account.</p>' +
  '</div>';
}

/* ---------------- Add your first chapter (C1) ----------------
   The moment of value creation. Party search, a free-text fallback that never
   auto-resolves, and month precision only because no party attests a day. */
/* Decision 074. This screen collected an employer and two dates, which cannot
   produce a valid chapter: `party_country` is required whenever `party_ref` is
   null, and that is the common case here because most employers in the target
   population are not registered. Country and city appear only when the party
   is unregistered, because a registered party already carries them and asking
   twice implies Grain does not know. */
function addBody(){
  var unreg = !draft.reg && (draft.party || draft.typed);
  var out = '<div>' +
    '<h1 class="t-head" style="margin:0">Where did you work?</h1>' +
    '<div style="margin-top:26px">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Employer or business</span>' +
      '<span class="ruled lg"><input id="psearch" autocomplete="organization" ' +
        'aria-label="Employer or business" placeholder="Start typing" value="' + esc(draft.typed) + '"></span>' +
      '<div id="presults"></div>' +
    '</div>';

  if(unreg){
    out += '<div class="grp">' +
      '<button class="srow press" data-chcountry="1"><span class="t-rec" style="flex:1">Country</span>' +
        '<span class="t-data" style="color:var(--secondary)">' + esc(COUNTRIES[draft.country].c) + '</span></button>' +
      '<div style="padding-top:14px">' +
        '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">City or town</span>' +
        '<span class="ruled"><input id="chcity" aria-label="City or town" placeholder="As you would say it" value="' + esc(draft.locality) + '"></span>' +
      '</div>' +
      '<p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">Grain does not know this business yet. Where it is keeps your record findable later, and it is never used to match you to a party on its own.</p>' +
    '</div>';
  }

  out += '<div style="padding-top:20px">' +
    goRow('parsing', 'Or import a resume', 'Grain reads it and you confirm every line before anything is added') +
    '</div>';

  out += '<div class="grp">' +
    '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:8px">How you worked there</span>' +
    '<div class="mgrid" style="grid-template-columns:repeat(2,1fr);padding-bottom:6px">' +
      KINDS.map(function(k){
        return '<button data-kind="' + k[0] + '" aria-pressed="' + (draft.kind === k[0]) + '">' + esc(k[1]) + '</button>';
      }).join('') +
    '</div></div>';

  out += '<div class="grp">' +
      '<button class="srow press" data-month="from"><span class="t-rec" style="flex:1">Started</span>' +
        '<span class="t-data" style="color:var(--secondary)">' + (draft.from || 'Pick a month') + '</span></button>' +
      '<button class="srow press" data-month="to"><span class="t-rec" style="flex:1">Ended</span>' +
        '<span class="t-data" style="color:var(--secondary)">' + (draft.to || 'Pick a month') + '</span></button>' +
      '<p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">Month only. Grain records no day, because no party attests one.</p>' +
    '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press" id="chapgo"' +
      ((draft.party || draft.typed) && draft.kind ? '' : ' disabled') + '>Next, what you did</button></div>' +
  '</div>';
  return out;
}

function partyResults(){
  var q = draft.typed.trim().toLowerCase();
  if(!q) return '';
  var hits = PARTIES.filter(function(p){ return p.name.toLowerCase().indexOf(q) > -1; }).slice(0, 4);
  var out = hits.map(function(p){
    return '<button class="row press" data-party="' + esc(p.name) + '" data-reg="' + (p.reg ? '1' : '') + '">' +
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
        '<input id="idinput" inputmode="tel" autocomplete="tel-national" aria-label="Mobile number" placeholder="917 000 0000"></span></div>'
      : '<div style="margin-top:26px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Email address</span>' +
        '<span class="ruled lg"><input id="idfield" inputmode="email" autocomplete="email" aria-label="Email address" placeholder="name@example.com"></span></div>') +
    '<div style="margin-top:28px"><button class="btn-primary press" id="idgo" data-go="code" disabled>Send the code</button>' +
    '<div style="text-align:center;padding-top:6px"><button class="btn-tertiary press" data-idmode="' +
      (idf.mode === 'phone' ? 'email' : 'phone') + '">Use ' + (idf.mode === 'phone' ? 'an email' : 'a number') + ' instead</button></div></div></div>';
}

/* A7. Any script, one field. The ledger keeps the name as written plus its
   script code; the searchable form is derived and never shown here. */
function nameBody(){
  return '<div><h1 class="t-head" style="margin:0">What is your name?</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Write it the way you write it, in any script. It goes on your record exactly as typed.</p>' +
    '<div style="margin-top:26px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Full name</span>' +
    '<span class="ruled lg"><input id="nameinput" autocomplete="name" aria-label="Full name" placeholder="Liezel Mendoza"></span></div>' +
    '<div style="margin-top:28px"><button class="btn-primary press" id="namego" data-go="consent" disabled>Continue</button></div></div>';
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
        '<svg aria-hidden="true" width="20" height="20" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="' +
        (docPick === i ? '#i-done' : '#i-open') + '"></use></svg></span>' +
        '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(d[0]) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(d[1]) + '</span></span></button>';
    }).join('') + '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press" data-go="capture">Continue</button></div></div>';
}

/* F3. The registration corners get their one honest job: framing a real
   document rather than decorating a surface. Grain's chrome, vendor named. */
function captureBody(){
  return '<div><h1 class="t-head" style="margin:0">Photograph the document</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">The next screen is Persona\'s, not Grain\'s. We are telling you before it opens rather than after.</p>' +
    '<div style="margin-top:24px">' + rows([
      ['Persona takes the photograph','Their camera, their screen. Grain never sees the image.'],
      ['They check the document','And send Grain the result, nothing else.'],
      ['You come straight back here','However it goes.']
    ]) + '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press" data-go="idchecking">Open Persona</button>' +
    '<div style="text-align:center;padding-top:6px"><button class="btn-tertiary press js-back">Not now</button></div></div>' +
    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">Neither vendor lets an app host their capture step, so Grain does not pretend to. Being handed to a stranger mid-flow is what the warning above is for.</p></div>';
}

/* A10. §9's loading arc: one lobe period of the figure's own wave, carrying no
   percentage, because an arc that claims to know how long is a spinner lying. */
function parseBody(){
  return '<div style="padding-top:40px;text-align:center">' +
    '<svg class="arc" viewBox="0 0 120 24" width="120" height="24" fill="none" ' +
      'stroke="var(--ink)" stroke-width="1.5" aria-label="Reading your file">' +
      '<path pathLength="1" d="@@ARC@@"></path></svg>' +
    '<p class="t-lead" style="margin:24px 0 0">Reading your file</p>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Nothing is added to your record yet. You see everything we find and choose what to keep.</p>' +
    '<div style="padding-top:28px;text-align:left">' +
      goRow('importreview', 'When it finishes', 'Every line it found, before anything is kept') +
      goRow('sensitive', 'If it holds something Grain does not keep', 'What was dropped, and why') +
      goRow('importfail', 'If it cannot be read', 'What to do next') +
    '</div></div>';
}

/* A11. Review before commit. The state grammar carries the choice, and the
   count on the action is the only number on the screen. */
/* `match` is what Grain proposes, never what it asserts. The schema rule is
   that a worker-typed name is never resolved into a `party_ref` automatically
   because a name match is not an identity, and the defect this fixes was that
   the screen performed the match silently and said nothing. */
var FOUND = [
  {p:'Cebu Pacific Cargo Services', k:'Cargo handling supervisor', d:'Jan 2025 to present', on:true,
   match:'Cebu Pacific Cargo Services', confirmed:true},
  {p:'Metro Manila Logistics', k:'Warehouse coordinator', d:'Mar 2023 to Jan 2025', on:true,
   match:'Metro Manila Logistics', confirmed:false},
  {p:'R. Santos Dry Goods', k:'Stall assistant', d:'Sep 2020 to Mar 2023', on:true,
   match:null, confirmed:false},
  {p:'Sunrise Foods Mfg.', k:'Packing line operator', d:'Mar 2019 to Sep 2021', on:false,
   match:'Sunrise Foods Manufacturing', confirmed:false}
];
function importBody(){
  var n = FOUND.filter(function(f){ return f.on; }).length;
  return '<div><h1 class="t-head" style="margin:0">What we found</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Your own account of it until a party attests. Nothing is on your record until you add it.</p>' +
    '<div style="margin-top:22px">' + FOUND.map(function(f, i){
      return '<button class="row press" data-found="' + i + '"><span class="gutter" style="padding-top:2px">' +
        '<svg aria-hidden="true" width="20" height="20" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="' +
        (f.on ? '#i-done' : '#i-open') + '"></use></svg></span>' +
        '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(f.p) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(f.k) + '</span></span>' +
        '<span class="col-r t-data" style="color:var(--secondary)">' + esc(f.d) + '</span></button>' +
        (f.on && f.match && !f.confirmed
          ? '<div style="padding:0 0 14px 38px;border-bottom:1px solid var(--hairline)">' +
              '<span class="t-meta" style="display:block;color:var(--secondary);text-wrap:pretty">' +
              'Grain thinks this is <strong>' + esc(f.match) + '</strong>, a business it has checked. ' +
              'It will not decide that for you.</span>' +
              '<div style="display:flex;gap:10px;padding-top:10px">' +
                '<button class="btn-secondary press" data-confirm-match="' + i + '" style="flex:1">Yes, that is them</button>' +
                '<button class="btn-tertiary press" data-keep-raw="' + i + '" style="flex:1">Keep my words</button>' +
              '</div></div>'
          : '') +
        (f.on && f.confirmed
          ? '<div style="padding:0 0 12px 38px;border-bottom:1px solid var(--hairline)">' +
              '<span class="t-meta" style="color:var(--secondary)">Confirmed as ' + esc(f.match) + '. You can change it before you add.</span></div>'
          : '') +
        (f.on && !f.match
          ? '<div style="padding:0 0 12px 38px;border-bottom:1px solid var(--hairline)">' +
              '<span class="t-meta" style="color:var(--secondary)">Grain does not know this business. It stays in your words.</span></div>'
          : '');
    }).join('') + '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press js-home"' + (n ? '' : ' disabled') + '>' +
    (n ? 'Add ' + n + ' chapter' + (n > 1 ? 's' : '') : 'Nothing selected') + '</button></div></div>';
}

/* A12. The handle, which is the only public name a record ever has. */
/* From `plans/self-asserted-record` 2026-08-20 defect list: there was no screen
   for a file that could not be read, and no screen for content Grain refuses to
   take. Both are ordinary outcomes in this population, not edge cases. */
function importFailBody(){
  return msg({pad:20, alert:true, title:'Grain could not read that file',
    body:'It happens with photographs of printed pages, scanned documents, and files a phone made itself. Nothing was added and nothing was kept.',
    rows:[['The file is gone','Grain does not hold a file it could not read.'],
          ['Nothing is on your record','No chapter, no qualification, nothing.'],
          ['Typing it is not slower','Most records here are three or four chapters.']],
    cta:'Type it instead', ctaGo:'addchapter', alt:'Try another file', altId:'js-back'});
}
function sensitiveBody(){
  return msg({pad:20, alert:true, title:'Some of that file is not going on your record',
    body:'Grain found things it does not keep, and it dropped them before anything was saved. You can still add the rest.',
    rows:[['A national ID number','Grain never stores one on a record, and identity checking does not use the record.'],
          ['A date of birth and a home address','Neither is a fact about your work.'],
          ['A photograph of a document','Kept only where you attach it to a certificate on purpose.']],
    cta:'Carry on with the rest', ctaGo:'importreview', alt:'Start again', altId:'js-back',
    foot:'These were dropped, not stored and hidden. Grain cannot show you what it did not keep.'});
}

function handleBody(){
  return '<div><h1 class="t-head" style="margin:0">Claim your address</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Where your record lives if you ever turn the public page on. It is off by default.</p>' +
    '<div style="margin-top:26px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Address</span>' +
    '<span class="ruled lg"><span class="t-rec" style="color:var(--secondary);padding-right:2px">hiregrain.com/u/</span>' +
    '<input id="handleinput" autocomplete="off" aria-label="Address" placeholder="liezel"></span>' +
    '<div class="said" style="padding-top:10px"><svg aria-hidden="true" width="16" height="16" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="#i-done"></use></svg>' +
    '<span class="t-meta" style="color:var(--secondary)">Available. You can change it once.</span></div></div>' +
    '<div style="margin-top:28px"><button class="btn-primary press js-home">Claim it</button></div></div>';
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
    '<div style="margin-top:26px"><button class="btn-primary press js-back">' + (cam ? 'Allow the camera' : 'Turn these on') + '</button>' +
    '<div style="text-align:center;padding-top:6px"><button class="btn-tertiary press js-back">Not now</button></div></div>' +
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
      '<svg aria-hidden="true" width="16" height="16" viewBox="0 0 24 24" class="icon" style="stroke:var(--paper);stroke-linecap:square"><use href="#i-alert"></use></svg>' +
      '<span class="t-meta">Offline. This is the copy on your phone.</span></div>' +
      '<h1 class="t-head" style="margin:0">' + esc(title) + '</h1>' +
      '<p class="t-body" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">Everything already on your record stays readable. Nothing new arrives until you are back.</p></div>';
  }
  if(kind === 'error'){
    return '<div class="statewrap" style="padding-top:24px">' +
      '<svg aria-hidden="true" width="26" height="26" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="#i-alert"></use></svg>' +
      '<h1 class="t-head" style="margin:16px 0 0">That did not work</h1>' +
      '<p class="t-body" style="margin:10px 0 22px;color:var(--secondary);text-wrap:pretty">Nothing was changed. Your record is exactly as it was.</p>' +
      '<button class="btn-primary press js-back">Try again</button></div>';
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
    (o.alert ? '<svg aria-hidden="true" width="26" height="26" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square;margin-bottom:16px"><use href="#i-alert"></use></svg>' : '') +
    '<h1 class="t-head" style="margin:0">' + esc(o.title) + '</h1>' +
    (o.body ? '<p class="t-body" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">' + esc(o.body) + '</p>' : '') +
    (o.rows ? '<div style="margin-top:22px">' + rows(o.rows) + '</div>' : '') +
    (o.warn ? '<div class="warn" style="margin-top:22px"><p class="t-body" style="margin:0;text-wrap:pretty">' + esc(o.warn) + '</p></div>' : '') +
    (o.cta ? '<div style="margin-top:26px"><button class="btn-primary press' + (o.ctaId ? ' ' + o.ctaId : '') + '"' +
      (o.ctaGo ? ' data-go="' + o.ctaGo + '"' : '') + (o.ctaOff ? ' disabled' : '') + '>' + esc(o.cta) + '</button>' +
      (o.alt ? '<div style="text-align:center;padding-top:6px"><button class="btn-tertiary press ' + (o.altId || 'js-back') + '">' + esc(o.alt) + '</button></div>' : '') + '</div>' : '') +
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
    '<div style="margin-top:28px"><button class="btn-primary press" data-go="identifier">Start your record</button>' +
    '<div style="text-align:center;padding-top:6px"><button class="btn-tertiary press" data-go="welcome">I already have one</button></div></div>' +
    '<p class="t-meta" style="margin:26px 0 0;color:var(--secondary);text-wrap:pretty">Free, permanently. Grain never charges a worker for the record.</p></div>';
}
function welcomeBody(){
  return msg({title:'Welcome back', body:'Sign in to the number ending 4471.',
    cta:'Send a code', ctaGo:'code', alt:'Use a different number', altId:'js-back',
    foot:'If this is not your phone, use a different number. The record stays where it is either way.'});
}

/* ================= C, chapter management ================= */
/* The employer was hard coded to one of the seeded chapters, so arriving here
   from the add flow showed a business the worker had not typed. It reads from
   the draft now.

   Decision 074. The title lives on `position` and never on `chapter`, so the
   add flow has to pass through here or the chapter commits with no role on it.
   The three counts are counts: a number with a unit may be collected, a
   position on a scale may not, and 054 is untouched. Two of them describe the
   operation rather than the person, which is the point. A line lead over four
   on a crew of six and a line lead over four on a crew of two hundred are not
   the same job, and no title distinguishes them.

   A chapter takes several positions, because a promotion is a division inside
   one chapter rather than a new one (schema 3, decision 028). */
function numfield(id, label, hint, val){
  return '<div style="flex:1;min-width:0">' +
    '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">' + esc(label) + '</span>' +
    '<span class="ruled"><input id="' + id + '" type="text" inputmode="numeric" pattern="[0-9]*" ' +
      'autocomplete="off" aria-label="' + esc(label) + '" placeholder="' + esc(hint) + '" value="' + esc(val) + '"></span>' +
    '</div>';
}

function positionBody(){
  var who = draft.party || draft.typed || 'Sunrise Foods Manufacturing';
  var first = !!draft.firstPosition;
  var P = draft.pos;
  var out = '<div><h1 class="t-head" style="margin:0">' +
      (first ? 'What did you do there?' : 'Add a position') + '</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">' +
      (first
        ? 'At ' + esc(who) + '. The title is yours to state. Grain records it for a reader and never compares it across parties.'
        : 'Inside ' + esc(who) + '. A change of title is a division inside one chapter, not a new one.') +
      '</p>';

  if(draft.positions.length){
    out += '<div style="margin-top:24px">' + sechead('Already on this chapter', draft.positions.length) +
      draft.positions.map(function(q){
        return '<div class="row"><span style="flex:1;min-width:0">' +
          '<span class="t-rec" style="display:block">' + esc(q.title || 'Untitled position') + '</span>' +
          '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' +
            esc([q.directed ? q.directed + ' directed' : '', q.team ? 'team of ' + q.team : ''].filter(Boolean).join(', ') || 'No counts given') +
          '</span></span>' +
          '<span class="col-r t-data" style="color:var(--secondary)">' + esc(q.from || 'No date') + '</span></div>';
      }).join('') + '</div>';
  }

  out += '<div style="margin-top:26px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Title</span>' +
    '<span class="ruled lg"><input id="postitle" aria-label="Title" placeholder="Line lead" value="' + esc(P.title) + '"></span></div>' +
    '<div class="grp">' +
    '<button class="srow press" data-month="posFrom"><span class="t-rec" style="flex:1">Started</span>' +
    '<span class="t-data" style="color:var(--secondary)">' + (P.from || 'Pick a month') + '</span></button>' +
    '<button class="srow press" data-month="posTo"><span class="t-rec" style="flex:1">Ended</span>' +
    '<span class="t-data" style="color:var(--secondary)">' + (P.to || 'Still there') + '</span></button></div>' +

    '<div class="grp">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:10px">How big the operation was</span>' +
      '<div style="display:flex;gap:14px">' +
        numfield('headcount', 'You directed', 'None', P.directed) +
        numfield('teamsize', 'On your team', 'Including you', P.team) +
      '</div>' +
      '<div style="display:flex;gap:14px;padding-top:16px">' +
        numfield('samerole', 'Doing your job', 'Of that team', P.same) +
        '<div style="flex:1;min-width:0"></div>' +
      '</div>' +
      '<p class="t-meta" style="margin:14px 0 0;color:var(--secondary);text-wrap:pretty">' +
        'Numbers, not levels. They say how big the operation was, which the business can confirm or correct. ' +
        'Nothing here asks you, or anyone else, to rate you.</p>' +
    '</div>' +

    '<div style="margin-top:26px"><button class="btn-primary press" id="posgo">' +
      (first ? 'Next, what you counted' : 'Add the position') + '</button>' +
      '<div style="text-align:center;padding-top:6px">' +
        '<button class="btn-tertiary press js-addanother">Add another position here</button></div>' +
    '</div></div>';
  return out;
}

/* Decision 074. `chapter.volume` has been a ratified field since 0.1 and no
   surface ever collected it. For the population this product is for, the title
   says least and the count says most: a warehouse coordinator who moved nine
   hundred pallets a day has a record, and the title alone does not. Optional
   and skippable, because 038's drop-off warning is about exactly these people. */
function countableBody(){
  var who = draft.party || draft.typed || 'this business';
  return '<div><h1 class="t-head" style="margin:0">Did you count anything?</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'Plenty of work is measured in something. If yours was, say what and how much. ' +
      'Skip this if nothing was counted, and you can add it later.</p>' +
    '<div class="grp">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">What you counted</span>' +
      '<span class="ruled"><input id="volunit" aria-label="What you counted" placeholder="Pallets, orders, calls, hectares" value="' + esc(draft.volUnit) + '"></span>' +
    '</div>' +
    '<div class="grp">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">How many, typically per day</span>' +
      '<span class="ruled"><input id="volcount" type="text" inputmode="numeric" pattern="[0-9]*" aria-label="How many per day" placeholder="A number" value="' + esc(draft.volCount) + '"></span>' +
    '</div>' +
    '<p class="t-meta" style="margin:20px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'This is your own account until ' + esc(who) + ' confirms it, and it carries the mark that says so. ' +
      'Nobody is asked to score you, here or anywhere.</p>' +
    '<div style="margin-top:26px"><button class="btn-primary press js-home">Add the chapter</button>' +
      '<div style="text-align:center;padding-top:6px">' +
        '<button class="btn-tertiary press js-skipvol">Nothing was counted</button></div></div>' +
  '</div>';
}

/* Moves the form's current position onto the chapter and empties the form.
   Called by both actions: adding another, and moving on. */
/* A flow starts empty. Without this, adding a second chapter opened on the
   first one's employer, its relationship kind and its positions, and asking a
   second person opened on the first person's name and address. Both are the
   same defect: in-flight state outliving the flow that owned it. */
function resetDraft(){
  draft.party = null; draft.typed = ''; draft.reg = false;
  draft.from = ''; draft.to = ''; draft.country = 0; draft.locality = '';
  draft.kind = null; draft.volUnit = ''; draft.volCount = '';
  draft.firstPosition = false; draft.positions = [];
  draft.pos = {title:'', from:'', to:'', directed:'', team:'', same:''};
}
function resetInvite(){ invite.name = ''; invite.contact = ''; invite.mode = 'email'; }

function commitPos(){
  var P = draft.pos;
  if(P.title || P.from || P.directed || P.team || P.same){
    draft.positions.push({title:P.title, from:P.from, to:P.to,
                          directed:P.directed, team:P.team, same:P.same});
  }
  draft.pos = {title:'', from:'', to:'', directed:'', team:'', same:''};
}

/* Schema 8. Institution resolution is propose-and-confirm and never automatic,
   so the list proposes and the worker confirms, and an unmatched name stays the
   worker's own words with a country beside it. */
function educationBody(){
  var q = edraft.inst.trim().toLowerCase();
  var hits = q ? INSTITUTIONS.filter(function(i){ return i.name.toLowerCase().indexOf(q) > -1; }).slice(0, 3) : [];
  var out = '<div><h1 class="t-head" style="margin:0">Add a qualification</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'What you studied and where. An enrollment you did not finish is a real record, not a gap.</p>' +
    '<div style="margin-top:26px">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Institution</span>' +
      '<span class="ruled lg"><input id="edinst" autocomplete="organization" aria-label="Institution" ' +
        'placeholder="Start typing" value="' + esc(edraft.inst) + '"></span>' +
      '<div>' + hits.map(function(i){
        return '<button class="row press" data-inst="' + esc(i.name) + '"><span class="gutter">' + mark('#sw-emp') + '</span>' +
          '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(i.name) + '</span>' +
          '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">On the accreditation list, ' + esc(i.where) + '</span></span></button>';
      }).join('') +
      (q ? '<button class="row press" data-inst=""><span class="gutter">' + mark('#sw-self') + '</span>' +
        '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">Use it as you typed it</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Your own words. Grain confirms a match, it never makes one for you.</span></span></button>' : '') +
      '</div></div>';
  if(edraft.inst && !edraft.ref){
    out += '<div class="grp"><button class="srow press" data-edcountry="1"><span class="t-rec" style="flex:1">Country</span>' +
      '<span class="t-data" style="color:var(--secondary)">' + esc(COUNTRIES[edraft.country].c) + '</span></button>' +
      '<p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">Grain does not have this institution on a list yet. Where it is keeps the record legible later.</p></div>';
  }
  out += '<div class="grp">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:8px">Level</span>' +
      '<div class="mgrid" style="grid-template-columns:repeat(2,1fr);padding-bottom:6px">' +
        LEVELS.map(function(l){
          return '<button data-level="' + l[0] + '" aria-pressed="' + (edraft.level === l[0]) + '">' + esc(l[1]) + '</button>';
        }).join('') + '</div></div>' +
    '<div class="grp">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Field of study</span>' +
      '<span class="ruled"><input id="edfield" aria-label="Field of study" placeholder="As it is written on the certificate" value="' + esc(edraft.field) + '"></span>' +
    '</div>' +
    '<div class="grp">' +
      '<button class="srow press" data-month="edFrom"><span class="t-rec" style="flex:1">Started</span>' +
        '<span class="t-data" style="color:var(--secondary)">' + (draft.edFrom || 'Pick a month') + '</span></button>' +
      '<button class="srow press" data-month="edTo"><span class="t-rec" style="flex:1">Ended</span>' +
        '<span class="t-data" style="color:var(--secondary)">' + (draft.edTo || 'Pick a month') + '</span></button>' +
      '<div class="listrow"><span style="flex:1;min-width:0"><span class="t-rec" style="display:block">You completed it</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Turn it off if you left before the end. That is a record, not a gap.</span></span>' +
        '<button class="sw press js-sw" role="switch" aria-checked="' + (edraft.completed ? 'true' : 'false') + '" aria-label="You completed it"><i></i></button></div>' +
    '</div>' +
    '<p class="t-meta" style="margin:20px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'Grain does not ask for a grade or a GPA. A score is a claim about how well you did, ' +
      'and nobody attests your own account of that.</p>' +
    '<div style="margin-top:26px"><button class="btn-primary press js-home"' +
      (edraft.inst && edraft.level ? '' : ' disabled') + '>Add it to your record</button></div></div>';
  return out;
}

/* Schema 9. No credential vocabulary exists, so the name is raw and the issuer
   is matched against the party registry propose-and-confirm like any other
   open-set population. The document is optional and lives in the payload
   plane, which is why the copy says where it goes and when it dies. */
function credentialBody(){
  var q = cdraft.issuer.trim().toLowerCase();
  var hits = q ? PARTIES.filter(function(i){ return i.name.toLowerCase().indexOf(q) > -1; }).slice(0, 3) : [];
  var out = '<div><h1 class="t-head" style="margin:0">Add a certificate</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'A licence, a certificate, or a course somebody signed off. Grain records it as your own account until an issuer confirms it.</p>' +
    '<div style="margin-top:26px">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">What it is called</span>' +
      '<span class="ruled lg"><input id="crname" aria-label="Credential name" placeholder="As it is written on the certificate" value="' + esc(cdraft.name) + '"></span></div>' +
    '<div class="grp">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Who issued it</span>' +
      '<span class="ruled"><input id="crissuer" autocomplete="organization" aria-label="Issuer" placeholder="Start typing" value="' + esc(cdraft.issuer) + '"></span>' +
      '<div>' + hits.map(function(i){
        return '<button class="row press" data-issuer="' + esc(i.name) + '"><span class="gutter">' + mark(i.reg ? '#sw-emp' : '#sw-self') + '</span>' +
          '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(i.name) + '</span>' +
          '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' +
            (i.reg ? 'Registered with Grain, ' + esc(i.where) : 'Not registered, ' + esc(i.where)) + '</span></span></button>';
      }).join('') + '</div></div>' +
    '<div class="grp">' +
      '<button class="srow press" data-month="crFrom"><span class="t-rec" style="flex:1">Issued</span>' +
        '<span class="t-data" style="color:var(--secondary)">' + (draft.crFrom || 'Pick a month') + '</span></button>' +
      '<button class="srow press" data-month="crTo"><span class="t-rec" style="flex:1">Expires</span>' +
        '<span class="t-data" style="color:var(--secondary)">' + (draft.crTo || 'Does not expire') + '</span></button>' +
      '<p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">Renewing it makes a new record. The old one stays, so a reader can see it was held continuously.</p>' +
    '</div>' +
    '<div class="grp">' +
      '<div class="listrow"><span style="flex:1;min-width:0"><span class="t-rec" style="display:block">Attach the certificate</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">Held under your own key and deleted with your record. A reader is told a document is on file and that you supplied it, never that Grain checked it.</span></span>' +
        '<button class="sw press js-sw" role="switch" aria-checked="' + (cdraft.doc ? 'true' : 'false') + '" aria-label="Attach the certificate"><i></i></button></div>' +
    '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press js-home"' +
      (cdraft.name && cdraft.issuer ? '' : ' disabled') + '>Add it to your record</button></div></div>';
  return out;
}

/* Decisions 079 and 080. The dispute flow returns, bounded by 028's line:
   Grain adjudicates authenticity and never substance, because FCRA 611's
   reasonable-reinvestigation duty is a defining CRA duty and cuts against R1.
   The screen is built around that split rather than hiding it, because a
   worker who expects Grain to rule on fairness and finds out later is worse
   off than one told at the top. */
var DISPUTE = [
  ['forged', 'They did not write this', 'You believe the party named never made this attestation.'],
  ['duplicate', 'This is a duplicate', 'The same attestation is already on the record.'],
  ['spam', 'This is spam', 'It came from someone with no connection to the work.']
];
var ddraft = {ground:null, statement:''};
function disputeBody(){
  var c = askTarget();
  return '<div><h1 class="t-head" style="margin:0">Dispute this attestation</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'From ' + esc(c.by === c.party ? 'the business itself' : c.by) + ', on ' + esc(c.party) + '.</p>' +

    '<div class="grp">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:8px">What Grain can decide</span>' +
      DISPUTE.map(function(d){
        return '<button class="row press" data-ground="' + d[0] + '"><span class="gutter" style="padding-top:2px">' +
          '<svg aria-hidden="true" width="20" height="20" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="' +
          (ddraft.ground === d[0] ? '#i-done' : '#i-open') + '"></use></svg></span>' +
          '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(d[1]) + '</span>' +
          '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px;text-wrap:pretty">' + esc(d[2]) + '</span></span></button>';
      }).join('') +
      '<p class="t-meta" style="margin:12px 0 0;color:var(--secondary);text-wrap:pretty">' +
        'These are questions about whether the attestation is genuine. Grain checks the signature, ' +
        'the party and the history, and removes it if it does not hold up.</p>' +
    '</div>' +

    '<div class="grp">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">What Grain cannot decide</span>' +
      '<p class="t-body" style="margin:6px 0 12px;color:var(--secondary);text-wrap:pretty">' +
        'Whether what they wrote is fair. Grain does not investigate that and will not rule on it. ' +
        'What you write here is attached beside their words, permanently, and never replaces them.</p>' +
      '<textarea class="ta" id="dstatement" aria-label="Your statement" ' +
        'placeholder="Your account of it, in your words">' + esc(ddraft.statement) + '</textarea>' +
    '</div>' +

    '<div class="warn" style="margin-top:24px">' +
      '<p class="t-body" style="margin:0;text-wrap:pretty">A reader sees both. Your statement does not remove theirs, and theirs does not answer yours.</p>' +
      '<p class="t-data" style="margin:10px 0 0">That is what it means for the record to belong to you and the attestation to belong to them.</p>' +
    '</div>' +

    '<div style="margin-top:26px"><button class="btn-primary press" data-go="disputesent"' +
      (ddraft.ground || ddraft.statement.trim() ? '' : ' disabled') + '>File it</button>' +
      '<div style="text-align:center;padding-top:6px">' +
        '<button class="btn-tertiary press js-back">Not now</button></div></div></div>';
}
function disputeSentBody(){
  var c = askTarget(), ground = ddraft.ground;
  return msg({pad:16, title: ground ? 'Dispute filed' : 'Your statement is on the record',
    body: ground
      ? 'Grain will check whether this attestation is genuine. It does not check whether it is fair.'
      : 'It sits beside their words on ' + c.party + ', and a reader sees both.',
    rows: ground
      ? [['Grain answers, usually within a week','It checks the signature, the party and the history.', 'Filed today'],
         ['The attestation stays visible meanwhile','Marked as disputed. It is never silently removed.', null],
         ['If it holds up, it stays','And your statement stays beside it, if you wrote one.', null]]
      : [['It is permanent','A statement is part of the record and is not edited away.', 'Added today'],
         ['It does not remove theirs','And theirs does not answer yours.', null]],
    cta:'Back to your record', ctaId:'js-home'});
}

/* Decision 080's gate: filing a deletion revokes the worker's own read access,
   so the screen that cancels it cannot sit behind the record. This is the way
   back in, and it is the only surface a filed worker can reach. */
function graceSignInBody(){
  return msg({pad:20, alert:true, title:'Your record is waiting to be deleted',
    body:'You asked Grain to delete everything. Nothing has been deleted yet, and you can stop it from here.',
    rows:[['Signing in stops it','The request is cancelled and every unexpired grant resumes.'],
          ['Doing nothing lets it run','Support carries out the erasure after the grace period.'],
          ['Starting again means asking again','Cancelling does not leave the request half-filed.']],
    cta:'Sign in and keep my record', ctaId:'js-home', alt:'Leave it', altId:'js-back',
    foot:'This is the only screen your account reaches while a deletion is filed.'});
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
    cta:'Go to your record', ctaId:'js-home', foot:'Grain never says whether an address once existed.'});
}
function updateBody(){
  return msg({pad:20, title:'Update Grain to carry on',
    body:'This version can no longer read the ledger safely. Your record is untouched and waiting.',
    cta:'Update', ctaId:'js-home'});
}
function signedOutBody(){
  return msg({pad:20, title:'You have been signed out',
    body:'For your safety, on a device that has been idle a long time. Nothing about your record changed.',
    cta:'Sign in again', ctaGo:'identifier'});
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
    '<div style="margin-top:22px">' + [
      ['How the record works','What a chapter is, and what an attestation is',
       'A chapter is one relationship with one party. An attestation is a party saying, in their words, what you did inside it. Neither can be edited once a party has attested, and every correction stays beside the original.'],
      ['Who can read it','Grants, the public page, and what neither does',
       'Nobody, until you grant it. A grant is to a named party or person and ends on its own date. The public page is off until you turn it on, and it is not a search result for your name.'],
      ['What Grain keeps','And for how long, and where',
       'The record, its attestations, and the ledger of what happened to it. Not your identity documents, and not the photographs taken to check them.'],
      ['Terms','The agreement between you and Grain',
       'You hold the record. Grain holds it for you and cannot sell it, and an attestation belongs to the party who made it.'],
      ['Privacy','Written to be read, not to be survived',
       'What is collected, why, who it reaches, and how to end it. In the same words as the rest of the app.']
    ].map(function(r, ri){
      return '<div class="disc"><button class="listrow press" data-open="' + ri + '">' +
        '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(r[0]) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(r[1]) + '</span></span>' +
        '<span class="chevs">' + CHEV + '</span></button>' +
        '<div class="discbody"><div><p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">' +
        esc(r[2]) + '</p></div></div></div>';
    }).join('') + '</div></div>';
}


/* ================= D, getting work verified =================
   Three routes, and each says exactly what the party can and cannot write,
   because the difference between them is the whole epistemic point. */
/* D1 to D5 existed as five surfaces with no route between them: the record
   named the chapters worth chasing, the sheet explained the gap, and its
   button closed the sheet. Which routes exist is a fact the record already
   holds, so the sheet asks it rather than choosing for the worker: a business
   Grain has checked can be asked directly, one it has not cannot, and a person
   who was there can always be asked. */
var EXPIRY = ['In 30 days', 'In 90 days', 'In 6 months'];

/* D5 was a single post-send state and there was no list, so a worker could
   send three requests and then have nowhere to see any of them. Outstanding
   verification on the record names chapters that COULD be attested; this names
   what has actually been asked, which is a different question and the one a
   person asks the day after. */
var REQUESTS = [
  {party:'Cebu Pacific Cargo Services', kind:'The business', state:'Waiting', when:'Sent 12 Mar'},
  {party:'R. Santos Dry Goods', kind:'A coworker', state:'Link not opened yet', when:'Made 8 Mar'}
];
function requestsBody(){
  if(!REQUESTS.length){
    return msg({title:'Nothing outstanding',
      body:'You have not asked anyone to confirm a chapter yet. The record shows which chapters a party could still attest.',
      cta:'Back to your record', ctaId:'js-home'});
  }
  return '<div><h1 class="t-head" style="margin:0">Requests you have made</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'Nothing here has changed your record. A request does that only when it is answered.</p>' +
    '<div style="margin-top:24px">' + sechead('Outstanding', REQUESTS.length) +
    REQUESTS.map(function(r, ri){
      return '<button class="row press" data-req="' + ri + '"><span style="flex:1;min-width:0">' +
        '<span class="t-rec" style="display:block">' + esc(r.party) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' +
          esc(r.kind + ', ' + r.state) + '</span></span>' +
        '<span class="col-r t-data" style="color:var(--secondary)">' + esc(r.when) + '</span>' +
        '<span class="chev">' + CHEV + '</span></button>';
    }).join('') + '</div>' +
    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'Grain does not tell you when someone opens a request. Read events are not recorded anywhere.</p></div>';
}
var SAID = {
  askcoworker:'Copied. Send it to them however you normally talk.',
  code:'Sent again. It can take a minute to arrive.',
  exportrec:'Asked. The file reaches your email within 24 hours, at the address you sign in with.',
  support:'Sent. Support answers by email, usually within two working days.'
};
var expiryPick = 0;
function confirmSheet(kind){
  if(kind === 'revoke') return {
    kicker:'End this grant', title:'Alorica Philippines',
    body:'Access stops from this moment. It does not erase that the grant existed, and it does not unsend what they have already read.',
    cta:'End the grant'};
  return {
    kicker:'Delete everything', title:'This files the request',
    body:'Access stops the moment you file it. Support carries out the erasure after the grace period, and signing in during that period cancels the request.',
    cta:'File the request'};
}
function askTarget(){ return CH[S.ask] || CH[CH.length - 1]; }
function isRegistered(name){
  for(var i = 0; i < PARTIES.length; i++){
    if(PARTIES[i].name === name) return PARTIES[i].reg;
  }
  return false;
}
function askRoutes(i){
  var c = CH[i], reg = isRegistered(c.party), r = [];
  if(reg) r.push(['reqattest', 'Ask ' + c.party,
    'The request goes to the domain Grain checked. Whoever answers it signs in first.']);
  r.push(['askmanager', 'Ask a manager there',
    reg ? 'A named person at the business, rather than the business itself.'
        : 'Grain checks they control a work address at the business, and nothing more.']);
  r.push(['askcoworker', 'Ask a coworker',
    'Someone who saw the work. Their mark says a coworker, and a reader can tell.']);
  return r;
}
function askSheet(i){
  var c = CH[i];
  return {
    kicker: 'Get this confirmed',
    title: c.party,
    body: isRegistered(c.party)
      ? 'Grain has checked this business, so you can ask the business itself or a person who was there.'
      : 'Grain has not checked this business, so the request goes to a person who was there.',
    slot: askRoutes(i).map(function(r){
      return '<button class="listrow press" data-route="' + r[0] + '">' +
        '<span style="flex:1;min-width:0">' +
        '<span class="t-rec" style="display:block">' + esc(r[1]) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px;text-wrap:pretty">' + esc(r[2]) + '</span>' +
        '</span><span class="chevs">' + CHEV + '</span></button>';
    }).join('')
  };
}

function reqAttestBody(){
  var c = askTarget();
  return msg({title:'Ask ' + c.party + ' to attest',
    body:'They are registered with Grain, so the request goes to the domain Grain checked. Whoever answers signs in first.',
    kicker:c.from + ' to ' + c.to,
    rows:[['Your own account of it freezes now','From the moment you ask, you cannot edit this chapter. It thaws if no attestation arrives.'],
          ['They write what you did','In their words. You cannot edit it.'],
          ['You can attach your side','Kept beside theirs, never replacing it.'],
          ['They can decline','And nothing is added, including that they declined.']],
    cta:'Send the request', ctaId:'js-sendreq', alt:'Not now',
    foot:'A request tells them the dates you recorded. It tells them nothing about the rest of your record.'});
}
/* D3 and D4. Both were explainers with a button and no form, so neither could
   name the person being asked. Decision 038 settles what the button does: an
   invitation link opens the web attestation flow, where the attester makes an
   account and attests. The form is Grain's and structured throughout, with no
   free-response field (025), and this screen is the part that names a person
   and a way to reach them.

   The two differ in what Grain can check. A manager gives a work address at
   the business, and Grain checks control of that address and nothing else,
   which is what lets the mark say a named party at that business. A coworker
   is a witness reachable any way at all, and their mark says coworker. */
var invite = {name:'', contact:'', mode:'email'};

function inviteName(label, hint){
  return '<div style="margin-top:24px">' +
    '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">' + esc(label) + '</span>' +
    '<span class="ruled lg"><input id="invname" autocomplete="off" aria-label="' + esc(label) + '" ' +
      'placeholder="' + esc(hint) + '" value="' + esc(invite.name) + '"></span></div>';
}
function inviteContact(label, hint, mode){
  return '<div class="grp">' +
    '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">' + esc(label) + '</span>' +
    '<span class="ruled"><input id="invcontact" ' +
      'inputmode="' + (mode === 'phone' ? 'tel' : 'email') + '" autocomplete="off" ' +
      'aria-label="' + esc(label) + '" placeholder="' + esc(hint) + '" value="' + esc(invite.contact) + '"></span></div>';
}
function inviteReady(){ return !!(invite.name.trim() && invite.contact.trim()); }
function inviteSend(label){
  return '<div style="margin-top:26px">' +
    '<button class="btn-primary press js-sendreq"' + (inviteReady() ? '' : ' disabled') + '>' + esc(label) + '</button>' +
    '<div style="text-align:center;padding-top:6px">' +
      '<button class="btn-tertiary press js-home">Not now</button></div></div>';
}

function askManagerBody(){
  var c = askTarget();
  return '<div><h1 class="t-head" style="margin:0">Ask a manager</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'Someone who managed you at ' + esc(c.party) + '. If they confirm a work address there, ' +
      'your record shows a named person at a business Grain recognises.</p>' +
    inviteName('Their name', 'As they are known at work') +
    inviteContact('Their work email', 'name@' + esc(c.party.split(' ')[0].toLowerCase()) + '.com', 'email') +
    '<p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'It has to be an address at the business. A personal address makes them a coworker, ' +
      'which is a different mark and not a lesser one.</p>' +
    '<div style="margin-top:22px">' + rows([
      ['Grain checks they control the address', 'Nothing more. Not their role, not their dates.'],
      ['They write what you did', 'In their words. You cannot edit it, and you can attach your side.'],
      ['They can decline', 'And nothing is added, including that they declined.']
    ]) + '</div>' +
    '<div class="grp"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:2px">What they receive</span>' +
      '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'A link, and the dates you recorded for this chapter. Nothing else from your record. ' +
      'They answer on the web and do not need the app.</p></div>' +
    inviteSend('Send the request') + '</div>';
}

function askCoworkerBody(){
  var c = askTarget();
  return '<div><h1 class="t-head" style="margin:0">Ask a coworker</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'Someone who saw the work at ' + esc(c.party) + '. A coworker is a real witness, ' +
      'and the record says plainly that is what they are.</p>' +

    '<div style="margin-top:26px">' +
      '<span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Their link</span>' +
      '<span class="ruled"><input id="cwlink" readonly aria-label="Link to send" ' +
        'value="grain.id/a/' + esc(c.party.split(" ")[0].toUpperCase().slice(0, 4)) + '-7Q2M"></span>' +
      '<div style="margin-top:14px"><button class="btn-primary press js-said">Copy the link</button></div>' +
    '</div>' +

    '<p class="t-meta" style="margin:14px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'Send it however you normally talk to them. Grain does not send it for you and does not ask ' +
      'for their number or their email, because there is nothing about a coworker for Grain to check. ' +
      'A manager is different: Grain checks control of a work address, which is the whole reason ' +
      'that mark can name the business.</p>' +

    '<div style="margin-top:24px">' + rows([
      ['They make an account and answer there', 'On the web. They do not need the app, and they keep a record of their own if they want one.'],
      ['Their mark differs from a business mark', 'A reader can tell the two apart at a glance.'],
      ['They are named on your record', 'Not anonymous, and not a rating.'],
      ['One coworker is not two', 'A second party agreeing shows as a second mark.']
    ]) + '</div>' +

    '<div class="warn" style="margin-top:24px">' +
      '<p class="t-body" style="margin:0;text-wrap:pretty">The first person to open this link and sign in is the one who answers it. Send it to the person you mean, and to nobody else.</p>' +
      '<p class="t-data" style="margin:10px 0 0">You can withdraw it until it is answered.</p>' +
    '</div>' +

    '<div style="margin-top:26px"><button class="btn-secondary press" data-go="requests">See it with your other requests</button>' +
      '<div style="text-align:center;padding-top:6px">' +
        '<button class="btn-tertiary press js-home">Done</button></div></div>' +

    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'A coworker attestation is not a lesser answer. It is a different one, and the marks say which.</p></div>';
}

function requestSentBody(){
  var c = askTarget(), link = S.lastAsk === 'askcoworker';
  return msg({pad:16, title:link ? 'Waiting on your link' : 'Request sent',
    body:link
      ? 'A link for ' + c.party + '. Nobody has opened it yet, and nothing on your record has changed.'
      : (invite.name
          ? 'To ' + invite.name + ', at ' + (invite.contact || 'the address you gave') + '.'
          : 'To ' + c.party + ', at the address Grain checked.'),
    rows:link
      ? [['Nobody has opened it','It does nothing until someone signs in through it.', 'Made 12 Mar'],
         ['You can send it to someone else','The link is the same one.', null],
         ['You can withdraw it','Until it is answered.', null]]
      : [['They have not answered yet','Nothing on your record has changed.', 'Sent 12 Mar'],
         ['You can send it again','After seven days.', 'From 19 Mar'],
         ['You can withdraw it','Until they answer.', null]],
    cta:'Back to your record', ctaId:'js-home',
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
    cta:'Start', ctaGo:'doctype', alt:'Not now',
    foot:'You can delete the result at any time, and your record stays exactly as it is.'});
}
function idCheckingBody(){
  /* Both outcomes are reachable. A checking screen that can only succeed is a
     screen nobody has looked at in the state that matters. */
  return arcmark('Checking your document') +
    '<div style="text-align:center;padding-top:24px">' +
    '<p class="t-lead" style="margin:0">Checking the document</p>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">Usually under a minute. You can leave this screen and come back.</p>' +
    '<div style="padding-top:28px;text-align:left">' +
      goRow('idresult', 'When it clears', 'What a reader sees afterwards') +
      goRow('idfailed', 'When it does not', 'What to do next') +
    '</div></div>';
}
function idResultBody(){
  return msg({title:'The document checked out',
    body:'You can see that a document was checked, and when. This is yours to read and it is not sent to anyone.',
    rows:[['What you can see','That a document was checked, and when.'],
          ['What a party receives','Nothing. This never appears in anything sent to an employer.'],
          ['What is kept','The result. Not the document, not the photographs.']],
    cta:'Continue to liveness', ctaGo:'idliveness', alt:'Not now',
    foot:'Grain never prints that a person is verified, because a person is not a claim that can be true, and it does not send a partner a chip that would say so.'});
}
function idLivenessBody(){
  return msg({title:'One photograph of you',
    body:'To check the document belongs to you rather than to someone holding it. Separate from the document check, and you can decline.',
    rows:[['It is compared once','Against the document photograph, then discarded.'],
          ['It is not kept','Grain stores the answer, not the picture.'],
          ['Declining costs you one thing','The record says the document was checked, not that it was matched to you.']],
    cta:'Take the photograph', ctaGo:'idresult', alt:'Skip this'});
}
function idFailedBody(){
  return msg({pad:16, alert:true, title:'That did not check out',
    body:'The document could not be read, or it did not match. Nothing has been added to your record and nothing was kept.',
    rows:[['Try a different photograph','Flat, in good light, the whole document in frame.'],
          ['Try a different document','A passport reads more reliably than a card.'],
          ['Carry on without it','Your record works. A party can still attest your work.']],
    cta:'Try again', ctaGo:'doctype', alt:'Carry on without it', altId:'js-home'});
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
    '<div style="margin-top:24px">' +
      goRow('publicpreview', 'Preview what a stranger sees', 'The page as a person loads it, imprint included') +
      goRow('publiccrawler', 'And what a search engine gets', 'The same words with the figure left out (056)') +
    '</div>' +
    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">Turning it off removes the page. Anyone holding a grant still has one, until its date passes.</p></div>';
}
/* G3 and G4. The management screen offered a preview and there was nothing to
   preview: neither view existed in this prototype, so the whole public-page
   flow stopped at a switch. Decision 056 settles what the page carries:
   employer, position and dates, provenance by mark, and the imprint to a human
   visitor but never in the crawler payload. */
function publicViewBody(crawler){
  var chs = chapters();
  var out = '<div class="statewrap">' +
    '<span class="t-serial" style="color:var(--secondary)">' +
      (crawler ? 'What a search engine receives' : 'What a stranger sees') + '</span>' +
    '<h1 class="t-title" style="margin:12px 0 0">Liezel Mendoza</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'A work record held by the person it describes, at grain.id/liezel-mendoza.</p>';

  if(!crawler){
    out += '<div class="figwrap" style="pointer-events:none;margin-top:22px">' +
      '<span class="figreg" style="top:0;left:0;border-top-width:1px;border-left-width:1px"></span>' +
      '<span class="figreg" style="top:0;right:0;border-top-width:1px;border-right-width:1px"></span>' +
      '<span class="figreg" style="bottom:0;left:0;border-bottom-width:1px;border-left-width:1px"></span>' +
      '<span class="figreg" style="bottom:0;right:0;border-bottom-width:1px;border-right-width:1px"></span>' +
      '<svg class="fig" viewBox="0 0 600 600" role="img" aria-label="Her imprint.">' + FIGURE + '</svg></div>';
  }

  out += '<div style="padding-top:26px">' + sechead('Work', chs.length) +
    chs.map(function(c){
      return '<div class="prow"><span class="gutter">' + mark(c.sw) + '</span>' +
        '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(c.party) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(c.kind) + '</span>' +
        '<span class="t-meta" style="display:block;color:var(--secondary);padding-top:3px">' + esc(c.label + ' ' + c.by) + '</span></span>' +
        '<span class="col-r t-data" style="color:var(--secondary)">' + esc(c.from + ' to ' + c.to) + '</span></div>';
    }).join('') + '</div>' +
    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">' +
      (crawler
        ? 'The figure is left out of this payload on purpose. A page a person loads is gone when they close the tab; a page in an index is permanent.'
        : 'Every line above says who attested it. A line with no attesting party says so, and Grain does not make it look like the others.') +
    '</p>' +
    '<div style="margin-top:24px"><button class="btn-secondary press js-back">Back to your settings</button></div>' +
  '</div>';
  return out;
}
function publicPreviewBody(){ return publicViewBody(false); }
function publicCrawlerBody(){ return publicViewBody(true); }

function sendRecordBody(){
  return '<div><h1 class="t-head" style="margin:0">Send your record</h1>' +
    '<p class="t-body" style="margin:8px 0 0;color:var(--secondary);text-wrap:pretty">To one named person. It is not a link that can be forwarded, and it ends on a date you set.</p>' +
    '<div style="margin-top:26px"><span class="t-micro" style="display:block;color:var(--secondary);padding-bottom:4px">Their email</span>' +
    '<span class="ruled lg"><input id="invcontact" inputmode="email" autocomplete="off" aria-label="Their email" placeholder="hiring@alorica.com" value="' + esc(invite.contact) + '"></span></div>' +
    '<div class="grp"><button class="srow press" data-expiry="1"><span class="t-rec" style="flex:1">Ends</span>' +
    '<span class="t-data" style="color:var(--secondary)">In 30 days</span></button></div>' +
    '<div style="margin-top:24px">' + rows([
      ['They prove the address is theirs','Before they can read anything.'],
      ['They see the whole record','Grain does not offer a partial one, because a selection is a claim.']
    ]) + '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press js-sendgrant">Send it</button></div></div>';
}
function grantDetailBody(){
  return msg({title:'Alorica Philippines',
    body:'Holds a grant to your whole record.',
    rows:[['Granted','You sent it.','12 Feb 2026'],
          ['Ends','Unless you end it sooner.','12 Sep 2026'],
          ['Scope','The whole record. Grain has no partial grant.', null]],
    cta:'End this grant now', ctaId:'js-confirm-revoke',
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
var langPick = 0;
function languageBody(){
  return '<div><h1 class="t-head" style="margin:0">Language</h1>' +
    '<div style="margin-top:22px">' +
    [['English','', langPick === 0],['Tagalog','', langPick === 1]].map(function(l, li){
      return '<button class="row press" data-lang="' + li + '"><span class="gutter" style="padding-top:2px">' +
        '<svg aria-hidden="true" width="20" height="20" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="' +
        (l[2] ? '#i-done' : '#i-open') + '"></use></svg></span>' +
        '<span style="flex:1;min-width:0"><span class="t-rec" style="display:block">' + esc(l[0]) + '</span></span></button>';
    }).join('') +
    '<div class="row" style="opacity:.55"><span class="gutter" style="padding-top:2px">' +
    '<svg aria-hidden="true" width="20" height="20" viewBox="0 0 24 24" class="icon" style="stroke-linecap:square"><use href="#i-open"></use></svg></span>' +
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
    cta:'Ask for an export', ctaId:'js-said',
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
    cta:'Write to support', ctaId:'js-said', foot:'Usually answered within two working days.'});
}
function deleteBody(){
  return msg({title:'Delete everything',
    body:'This files a request. It does not delete anything by itself.',
    rows:[['Your access stops now','The moment you file it, you cannot read your record.'],
          ['It is executed after 30 days','A person at Grain carries it out.'],
          ['Signing in cancels it','And you would have to file it again.']],
    cta:'File the request', ctaId:'js-confirm-delete', alt:'Keep my record',
    warn:'Attestations other parties made about you are erased with everything else. They cannot be recovered, by you or by them.'});
}
function deletePendingBody(){
  return msg({pad:16, alert:true, title:'Deletion requested',
    body:'Filed 04 Mar 2026. Your record is closed to you and to everyone holding a grant.',
    rows:[['Executed on','Unless you sign in first.','03 Apr 2026'],
          ['Signing in cancels it','And restores every grant that has not expired.', null]],
    cta:'Cancel the request and sign in', ctaGo:'gracesignin'});
}
function unlockBody(){
  return '<div style="position:absolute;inset:0;display:flex;flex-direction:column;' +
    'align-items:center;justify-content:center;padding:0 24px;text-align:center;gap:20px">' +
    '<svg viewBox="0 0 160 26" width="130" height="21" role="img" aria-label="Grain" style="opacity:.5">' + LOCKUP + '</svg>' +
    '<p class="t-lead" style="margin:0">Unlock to open your record</p>' +
    '<p class="t-body" style="margin:0;color:var(--secondary);text-wrap:pretty">A shared phone is a real thing, so the record does not open on its own.</p>' +
    '<button class="btn-secondary press js-home" style="max-width:260px">Use Face ID</button>' +
    '<button class="btn-tertiary press js-home">Use the passcode</button></div>';
}
function signOutBody(){
  return msg({title:'Sign out',
    body:'On this phone only. Your record and every grant stay exactly as they are.',
    rows:[['You will need a code to return','Sent to the number on your account.'],
          ['Nothing is deleted','Signing out is not deleting.']],
    cta:'Sign out', ctaGo:'signedout', alt:'Stay signed in'});
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
  importfail: {title:'Unreadable', body:importFailBody},
  sensitive: {title:'Dropped', body:sensitiveBody},
  handle: {title:'Address', body:handleBody},
  permcamera: {title:'Camera', body:function(){ return permBody('camera'); }},
  permnotify: {title:'Notifications', body:function(){ return permBody('notify'); }},
  consent: {title:'Consent', body:consentBody},
  launch: {title:'Launch', body:launchBody},
  lander: {title:'Lander', body:landerBody},
  welcome: {title:'Welcome', body:welcomeBody},
  addposition: {title:'Position', body:positionBody},
  countable: {title:'Counted', body:countableBody},
  education: {title:'Qualification', body:educationBody},
  credential: {title:'Certificate', body:credentialBody},
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
  requests: {title:'Requests', body:requestsBody},
  idwhy: {title:'Identity', body:idWhyBody},
  idchecking: {title:'Checking', body:idCheckingBody},
  idresult: {title:'Result', body:idResultBody},
  idliveness: {title:'Liveness', body:idLivenessBody},
  idfailed: {title:'Not checked', body:idFailedBody},
  publicpage: {title:'Public page', body:publicPageBody},
  publicpreview: {title:'Your public page', body:publicPreviewBody},
  publiccrawler: {title:'Crawler view', body:publicCrawlerBody},
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
  gracesignin: {title:'Deletion filed', body:graceSignInBody},
  dispute: {title:'Dispute', body:disputeBody},
  disputesent: {title:'Filed', body:disputeSentBody},
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
    /* Decision 075. The wordmark is the way home from any depth. It is absent
       on the record itself because that is where it would take you, and its
       standing question in design/12 (whether the lockup lives in the bar at
       all) is untouched: this is the pushed bar only. */
    lead = '<button class="homebtn press js-home" aria-label="Back to your record">' +
        '<svg viewBox="0 0 160 26" width="72" height="12" aria-hidden="true">' + LOCKUP + '</svg></button>' +
      '<span class="bardiv" aria-hidden="true"></span>' +
      '<button class="backbtn press js-back" aria-label="Back to ' + esc(prev) + '">' +
      '<svg aria-hidden="true" width="22" height="22" viewBox="0 0 24 24" class="icon"><use href="#i-back"></use></svg>' +
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
  $('sheetkicker').textContent = field.toLowerCase().indexOf('from') > -1 ? 'Started' : 'Ended';
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
function openConfirm(kind){
  var o = confirmSheet(kind);
  $('sheetkicker').textContent = o.kicker;
  if($('sheetkicker2')) $('sheetkicker2').textContent = o.kicker;
  $('sheettitle').textContent = o.title;
  $('sheetbody-p').textContent = o.body;
  $('sheetslot').innerHTML = '';
  $('sheetcta').textContent = o.cta;
  $('sheetcta').style.display = '';
  S.sheetOpen = true; S.sheetKind = 'confirm'; S.confirmKind = kind;
  requestAnimationFrame(function(){
    $('sheet').classList.add('on'); $('scrim').classList.add('on');
    if(typeof paintNavBtns === 'function') paintNavBtns();
    if(S.platform === 'ios'){ $('scr').classList.add('recede'); $('chrome').classList.add('onblack'); }
  });
}
function openAsk(i){
  S.ask = i;
  resetInvite();
  var o = askSheet(i);
  $('sheetkicker').textContent = o.kicker;
  if($('sheetkicker2')) $('sheetkicker2').textContent = o.kicker;
  $('sheettitle').textContent = o.title;
  $('sheetbody-p').textContent = o.body;
  $('sheetslot').innerHTML = o.slot;
  $('sheetcta').style.display = 'none';
  S.sheetOpen = true; S.sheetKind = 'ask';
  requestAnimationFrame(function(){
    $('sheet').classList.add('on'); $('scrim').classList.add('on');
    if(typeof paintNavBtns === 'function') paintNavBtns();
    if(S.platform === 'ios'){ $('scr').classList.add('recede'); $('chrome').classList.add('onblack'); }
  });
}
function closeSheet(){
  $('sheetcta').style.display = '';
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
  ['Chapters', ['addchapter','parsing','importreview','sensitive','importfail','addposition','countable','minoredit']],
  ['Education and certificates', ['education','credential']],
  ['Getting verified', ['reqattest','askmanager','askcoworker','requestsent']],
  ['Identity', ['idwhy','doctype','capture','idchecking','idresult','idliveness','idfailed','permcamera']],
  ['Sharing', ['sharing','publicpage','sendrecord','grantdetail']],
  ['Disputes and deletion', ['dispute','disputesent','gracesignin']],
  ['Account', ['account','ledger','notifprefs','permnotify','language','exportrec','disclosure','support','deleterec','deletepending','unlock','signout']],
  ['System', ['notfound','updaterequired','signedout','pushcontent','legal','appicon']]
];
var NAVNAME = {
  record:'The record', launch:'Launch', lander:'Signed-out lander', identifier:'Identifier',
  code:'One-time code', welcome:'Welcome back', name:'Your name', consent:'Consent (blocked)',
  handle:'Claim your address', imprint:'Imprint', permanence:'What you can change',
  addchapter:'Add a chapter', parsing:'Parsing a file', importreview:'Import review',
  addposition:'Add a position', countable:'What you counted',
  education:'Add a qualification', credential:'Add a certificate',
  importfail:'File unreadable', sensitive:'Dropped from the file', minoredit:'Minor edits', reqattest:'Request attestation',
  askmanager:'Ask a manager', askcoworker:'Ask a coworker', requestsent:'Request sent',
  idwhy:'Why check identity', doctype:'Document type', capture:'Capture the document',
  idchecking:'Checking', idresult:'Result', idliveness:'Liveness', idfailed:'Could not check',
  permcamera:'Camera permission', sharing:'Sharing', publicpage:'Public page',
  sendrecord:'Send the record', grantdetail:'Grant detail', account:'Account', ledger:'The ledger',
  notifprefs:'Notification preferences', permnotify:'Notification permission', language:'Language',
  exportrec:'Export', disclosure:'Who can read it', support:'Support', deleterec:'Delete everything',
  deletepending:'Deletion requested', gracesignin:'Deletion filed, the way back',
  dispute:'Dispute an attestation', disputesent:'Dispute filed', unlock:'Unlock', signout:'Sign out',
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

/* The shared fragments are decorative glyphs, and several of them are whole
   <svg> elements rather than path data. Unmarked, a screen reader announces
   each as an unlabelled graphic; none of them carry anything the text beside
   them does not already say. Marked once here rather than in design/10, whose
   fragments are shared with its own artboards. */
function deco(str){ return str.replace(/<svg(?![^>]*aria-)/g, '<svg aria-hidden="true"'); }

function boot(){
  SHARE = deco(T('t-share')); ACC = deco(T('t-acc')); CHEV = deco(T('t-chev'));
  FIGURE = T('t-chapters'); RULE = deco(T('t-sinerule')); LOCKUP = deco(T('t-lockup'));
  GRAT = deco(T('t-graticule')); GRAT2 = GRAT; PORTRAIT = deco(T('t-portrait'));
  MARK56 = deco(T('t-mark56')); EMPTYFIG = T('t-empty'); MARKSOLID = deco(T('t-marksolid'));
  buildNav();
  paintRecord(); applyPlatform();
  $('rec').addEventListener('scroll', syncEdge, {passive:true});
}
boot();

/* The figure's focus state has existed since it was drawn: imprintBody takes a
   ring index and the chart ground dims every other band. Nothing had ever
   passed one, so the mechanism was unreachable on every platform. Opening a
   chapter is what selects it, and the ring it names lights while the rest
   recede.

   Which figure to light depends on where it is. On a desk it is in the second
   column beside the list; everywhere else it is inside the surface the list is
   on. */
function visibleFig(){
  if(typeof S.vp !== 'undefined' && S.vp === 'desktop'){
    var a = document.querySelector('#aside .bigfig');
    if(a) return a;
  }
  var t = (typeof topLayer === 'function') ? topLayer() : null;
  return (t && t.querySelector('.bigfig')) || document.querySelector('.bigfig');
}
function syncFocus(){
  var fig = visibleFig();
  if(!fig) return;
  /* classList, not className: on an SVG element className is an
     SVGAnimatedString, so assigning a string to it silently does nothing and
     the figure never changes. */
  fig.classList.remove('fx');
  for(var i = 0; i < chapters().length + 2; i++) fig.classList.remove('f' + i);
  /* The last chapter left open is the one the figure follows. Closing it hands
     focus back to whichever is still open, rather than blanking the figure
     while a chapter is plainly still selected. */
  var open = document.querySelectorAll('.disc.on > [data-row]');
  if(open.length){
    fig.classList.add('fx');
    fig.classList.add('f' + open[open.length - 1].getAttribute('data-row'));
  }
}

document.addEventListener('click', function(e){
  var t = e.target; if(!t || !t.closest) return;
  if(t.closest('.js-imprint')) return push({kind:'imprint'});
  var row = t.closest('[data-out]');
  if(row) return openAsk(OUT[+row.getAttribute('data-out')].i);
  var disc = t.closest('[data-open]');
  if(disc){
    disc.parentNode.classList.toggle('on');
    if(disc.hasAttribute('data-row')) syncFocus();
    return;
  }
  if(t.closest('.js-back')) return pop();
  if(t.closest('.js-share')) return push({kind:'sharing'});
  if(t.closest('.js-acc')) return push({kind:'account'});
  if(t.closest('#sheetcta') && S.sheetKind === 'month'){
    if(pick.month != null){
      var val = MON[pick.month] + ' ' + pick.year;
      if(pick.field === 'posFrom') draft.pos.from = val;
      else if(pick.field === 'posTo') draft.pos.to = val;
      else draft[pick.field] = val;
      repaintStack();
    }
    return closeSheet();
  }
  if(t.closest('#sheetcta') && S.sheetKind === 'confirm'){
    var was = S.confirmKind;
    closeSheet();
    return setTimeout(function(){
      while(S.stack.length) pop(true);
      /* Filing a deletion lands on the grace-period state, which is the only
         place that says what resets it. Revoking a grant just returns. */
      if(was === 'delete') push({kind:'deletepending'});
    }, 180);
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
    draft.reg = !!pp.getAttribute('data-reg');
    if(draft.party) draft.typed = draft.party;
    repaintStack();
    return;
  }
  var kd = t.closest('[data-kind]');
  if(kd){ draft.kind = kd.getAttribute('data-kind'); repaintStack(); return; }
  var cc = t.closest('[data-chcountry]');
  if(cc){ draft.country = (draft.country + 1) % COUNTRIES.length; repaintStack(); return; }
  /* The add flow is three steps and only the first is required to be useful:
     chapter, then the position that carries the title (074), then anything
     countable, which is skippable. */
  if(t.closest('#chapgo') && !t.closest('#chapgo').disabled){
    draft.firstPosition = true; return push({kind:'addposition'});
  }
  if(t.closest('.js-addanother')){ commitPos(); repaintStack(); return; }
  if(t.closest('#posgo')){
    commitPos();
    if(draft.firstPosition) return push({kind:'countable'});
    return pop();
  }
  if(t.closest('.js-skipvol')){
    draft.volUnit = ''; draft.volCount = '';
    while(S.stack.length) pop(true);
    return;
  }
  /* Terminal actions. `js-home` returns to the record from any depth, which is
     what a screen that has finished its job should do; `js-back` is one level. */
  if(t.closest('.js-home')){ closeSheet(); while(S.stack.length) pop(true); return; }
  var sd = t.closest('.js-said');
  if(sd){
    var host = sd.parentNode, kind = S.stack.length ? S.stack[S.stack.length-1].kind : '';
    host.innerHTML = '<div class="said"><svg aria-hidden="true" width="16" height="16" viewBox="0 0 24 24">' +
      '<use href="#i-done"></use></svg><span class="t-data">' + esc(SAID[kind] || 'Done.') + '</span></div>';
    return;
  }
  /* The seam gives destructive confirmation to the system on both platforms and
     to Grain in a browser. Either way the prototype had no instance of one. */
  if(t.closest('.js-confirm-revoke')) return openConfirm('revoke');
  if(t.closest('.js-confirm-delete')) return openConfirm('delete');
  var im2 = t.closest('[data-invmode]');
  if(im2){
    var m = im2.getAttribute('data-invmode');
    if(m !== invite.mode){ invite.mode = m; invite.contact = ''; }
    repaintStack(); return;
  }
  var ei = t.closest('[data-inst]');
  if(ei){ edraft.inst = ei.getAttribute('data-inst') || edraft.inst;
          edraft.ref = !!ei.getAttribute('data-inst'); repaintStack(); return; }
  var ci = t.closest('[data-issuer]');
  if(ci){ cdraft.issuer = ci.getAttribute('data-issuer'); cdraft.ref = true; repaintStack(); return; }
  var lv = t.closest('[data-level]');
  if(lv){ edraft.level = lv.getAttribute('data-level'); repaintStack(); return; }
  var ec = t.closest('[data-edcountry]');
  if(ec){ edraft.country = (edraft.country + 1) % COUNTRIES.length; repaintStack(); return; }
  var cm = t.closest('[data-confirm-match]');
  if(cm){ FOUND[parseInt(cm.getAttribute('data-confirm-match'), 10)].confirmed = true; repaintStack(); return; }
  var kr = t.closest('[data-keep-raw]');
  if(kr){ var ki = parseInt(kr.getAttribute('data-keep-raw'), 10);
          FOUND[ki].match = null; FOUND[ki].confirmed = false; repaintStack(); return; }
  var dg = t.closest('[data-ground]');
  if(dg){ var g=dg.getAttribute('data-ground');
          ddraft.ground = (ddraft.ground === g) ? null : g; repaintStack(); return; }
  var lg = t.closest('[data-lang]');
  if(lg){ langPick = parseInt(lg.getAttribute('data-lang'), 10); repaintStack(); return; }
  var ex = t.closest('[data-expiry]');
  if(ex){ expiryPick = (expiryPick + 1) % EXPIRY.length; repaintStack(); return; }
  /* One route for every destination row in the app. */
  var go = t.closest('[data-go]');
  if(go){
    if(S.sheetOpen) closeSheet();
    var gk = go.getAttribute('data-go');
    if(gk === 'addchapter') resetDraft();
    if(gk === 'addposition') draft.firstPosition = false;
    return push({kind:go.getAttribute('data-go')});
  }
  var ask = t.closest('[data-ask]');
  if(ask) return openAsk(parseInt(ask.getAttribute('data-ask'), 10));
  var route = t.closest('[data-route]');
  if(route){
    var k = route.getAttribute('data-route');
    S.lastAsk = k;
    closeSheet();
    return setTimeout(function(){ push({kind:k}); }, 120);
  }
  if(t.closest('.js-sendreq')){
    /* A sent request joins the outstanding list, so the list is the app's
       state rather than a static illustration of one. */
    REQUESTS.unshift({
      party: askTarget().party,
      kind: S.lastAsk === 'askmanager' ? 'A manager' : (S.lastAsk === 'askcoworker' ? 'A coworker' : 'The business'),
      state: 'Waiting', when: 'Sent today'
    });
    return push({kind:'requestsent'});
  }
  var rq = t.closest('[data-req]');
  if(rq){ return push({kind:'requestsent'}); }
  if(t.closest('.js-sendgrant')) return push({kind:'requestsent'});
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
  if(t.id === 'chcity'){ draft.locality = t.value; return; }
  if(t.id === 'dstatement'){ ddraft.statement = t.value;
    var fb = document.querySelector('[data-go="disputesent"]');
    if(fb) fb.disabled = !(ddraft.ground || t.value.trim());
    return; }
  if(t.id === 'postitle'){ draft.pos.title = t.value; return; }
  if(t.id === 'edinst'){ edraft.inst = t.value; edraft.ref = false;
    var r1 = document.querySelector('.pushl:last-of-type'); repaintStack(); return; }
  if(t.id === 'edfield'){ edraft.field = t.value; return; }
  if(t.id === 'crname'){ cdraft.name = t.value;
    var b1 = document.querySelector('.js-home.btn-primary'); repaintStack(); return; }
  if(t.id === 'crissuer'){ cdraft.issuer = t.value; cdraft.ref = false; repaintStack(); return; }
  if(t.id === 'invname' || t.id === 'invcontact'){
    invite[t.id === 'invname' ? 'name' : 'contact'] = t.value;
    var send = document.querySelector('.js-sendreq');
    if(send) send.disabled = !inviteReady();
    return;
  }
  if(t.id === 'idinput'){ var g = document.getElementById('idgo'); if(g) g.disabled = t.value.trim().length < 6; return; }
  if(t.id === 'handleinput'){ return; }
  if(t.id === 'nameinput'){ var ng = document.getElementById('namego'); if(ng) ng.disabled = !t.value.trim(); return; }
  if(t.id === 'headcount' || t.id === 'teamsize' || t.id === 'samerole'){
    t.value = t.value.replace(/[^0-9]/g, '').slice(0, 5);
    draft.pos[{headcount:'directed', teamsize:'team', samerole:'same'}[t.id]] = t.value;
    return;
  }
  if(t.id === 'volunit'){ draft.volUnit = t.value; return; }
  if(t.id === 'volcount'){ t.value = t.value.replace(/[^0-9]/g, '').slice(0, 7); draft.volCount = t.value; return; }
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
