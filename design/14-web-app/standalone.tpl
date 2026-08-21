<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Grain, the web app</title>
<style>
@@CSS@@
@@CHROME@@
@@CONTENTCSS@@

/* ================= the browser, which is not a device =================

   design/13 drew the record inside two operating systems that hand over a
   toolbar, a back gesture, a sheet, an alert and a month picker. A browser
   hands over none of them, so every one is drawn here. The only thing the
   browser adds that a device did not is the origin, and the origin is the
   one piece of chrome in this product that carries a trust claim, so it is
   drawn rather than cropped away. */
.stagewrap{display:flex;justify-content:center;padding:0 16px 40px}
.stage{transform-origin:top center}
.browser{background:#DCD8D1;border:1px solid var(--rule);border-radius:10px 10px 0 0;
         overflow:hidden;box-shadow:0 1px 0 var(--rule)}
.mobile .browser{border-radius:26px;padding:0;border-width:1px}

/* The origin bar. On desktop it is a window chrome; on mobile it is the one
   piece of screen the browser keeps and the app never gets, and it collapses
   on scroll, which is why the masthead may not assume a fixed offset. */
.urlbar{display:flex;align-items:center;gap:10px;padding:0 12px;height:42px;
        background:#DCD8D1;border-bottom:1px solid var(--rule)}
.mobile .urlbar{height:44px;transition:height 180ms cubic-bezier(0.2,0,0,1)}
.mobile.scrolled .urlbar{height:30px}
.navbtns{display:flex;gap:2px;flex:0 0 auto}
.navbtn{width:28px;height:28px;display:flex;align-items:center;justify-content:center;
        border-radius:3px}
.navbtn svg{stroke:var(--ink);stroke-width:1.5;fill:none}
.navbtn[disabled]{opacity:.3;cursor:default}
.navbtn:not([disabled]):hover{background:rgba(27,42,68,.08)}
.origin{flex:1;min-width:0;display:flex;align-items:center;gap:7px;height:28px;
        background:var(--paper);border:1px solid var(--hairline);border-radius:4px;
        padding:0 10px;overflow:hidden}
.origin .t-data{white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.lockicon{flex:0 0 11px}

/* The page itself. Fixed height because the frame is a viewport, not a window;
   the real app scrolls the document. */
/* The page ground. DESIGN.md 9 already defines a chart ground and the record
   column already sits on one; this is that same primitive at the page's own
   scale, so the width carries the instrument's paper rather than a colour
   field. No new object, no new colour, and the record stays marked by the
   plate, which is what 9 says marks it. Desktop only: a phone has no margin
   to give it. */
.pageground{display:none}
.desktop .pageground{display:block;position:absolute;inset:0;z-index:0;
                     pointer-events:none;opacity:.05}
.desktop .pageground svg{width:100%;height:100%;display:block}
.app{position:relative;z-index:1}
.desktop .app,.desktop .mast,.desktop .col{background:transparent}
.desktop .installbar{background:var(--ink)}

/* One ground on every platform and every viewport: paper. The desk was a
   --page field either side of the record column, and it only ever meant
   anything on the record home, where the plate marked the record off against
   it. Everywhere else it was a margin with a metaphor attached, and a screen
   with a third of its width greyed out for no stated reason reads as unfinished
   rather than composed. What marks the record is the plate (DESIGN.md 9), which
   is what 9 says marks it. Nothing else needs to. */
.vp{position:relative;overflow:hidden;background:var(--paper)}

/* ================= the app inside it ================= */
.app{position:absolute;inset:0;display:flex;flex-direction:column;background:var(--paper)}

/* The masthead. design/12 argued at length that iOS does not want a toolbar
   background, and that argument was about Liquid Glass floating over a
   scrolling record. There is no glass here and no system bar underneath, so
   the masthead is paper, and the hairline arrives on scroll: the hard scroll
   edge effect, drawn by hand because nothing else will draw it. */
.mast{flex:0 0 auto;position:relative;z-index:12;background:var(--paper);
      display:flex;align-items:center;gap:8px;height:56px;padding:0 20px;
      border-bottom:1px solid transparent}
.mast.edged{border-bottom-color:var(--hairline)}
.desktop .mast{height:60px;padding:0 32px}
.mastslot{display:flex;align-items:center;gap:4px;min-width:0}
.mastslot.grow{flex:1;min-width:0}
.backbtn{display:flex;align-items:center;gap:4px;min-height:44px;padding:0 8px 0 4px}
.homebtn{display:flex;align-items:center;min-height:44px;padding:0 8px 0 2px;border-radius:3px}
.homebtn:hover{background:rgba(27,42,68,.06)}
.bardiv{flex:0 0 1px;height:18px;background:var(--hairline)}
.wordbtn{display:flex;align-items:center;gap:8px;min-height:44px;padding:0 10px;
         border-radius:3px}
.wordbtn:hover{background:rgba(27,42,68,.06)}
.iconbtn:hover{background:rgba(27,42,68,.06);border-radius:3px}

/* ================= desk, rail and column =================

   The record keeps one measure at every width. What the desktop earns with its
   extra room is not a second column of record, which would be the one place
   the web and the native app visibly disagreed; it is the desk the record sits
   on, and the index that on Android had to be a 40px gesture strip inside a
   200dp budget (037) and here can simply be visible. */
/* Two columns on a desk, and the width is spent rather than left as margin.
   The figure leaves the scroll because it is the record's index rather than an
   illustration above it (design/12), and an index that scrolls away stops
   being one the moment you are reading the rows it indexes. The record column
   then carries the chapter list, which on a phone lives one push away inside
   the imprint because 390px cannot hold both.

   DIVERGENCE, for a founder ruling rather than a quiet call: design/13 states
   that the record does not repeat the chapter list underneath the figure,
   because a worker read the same five employers three times on one screen.
   That count was a 390px count. Here the list appears once, beside a figure
   that carries no names, so the repeat the rule was written against does not
   occur. The rule itself is untouched on mobile.

   The left rail is gone with the same reasoning. A column of chapter names
   next to a column of chapter rows is the duplication the rule forbids, and
   the rows are the better index: they carry the provenance marks. */
.frame{flex:1;min-height:0;display:flex;justify-content:center;gap:40px;position:relative}
.rail{display:none}
.aside{display:none}
/* Only the record home has a second column. Every pushed screen empties the
   aside, and an empty flex item still holds its 360px, which pushed those
   screens 180px off centre with dead ground beside them. :empty collapses it,
   so the record home is two columns and everything else is one, centred. */
.desktop .aside:not(:empty){display:block;flex:0 0 360px;padding:26px 0 0;
                            align-self:flex-start;position:sticky;top:0}
.aside .bigwrap{margin-top:0}
.aside::-webkit-scrollbar{width:0}
.colwrap{flex:0 1 auto;min-width:0;display:flex;justify-content:center;position:relative}
.col{position:relative;width:100%;background:var(--paper)}
.desktop .col{width:640px;flex:0 0 640px}
.mobile .colwrap{width:100%}

/* ================= layers =================
   A pushed screen replaces the column rather than sliding a whole display,
   because on the web the column IS the app and the desk around it never moves.
   The slide direction stays the platform's on mobile and becomes a short rise
   on desktop, where a horizontal push reads as a carousel. */
.layer{position:absolute;inset:0;background:var(--paper);
       transition:transform 420ms cubic-bezier(0.32,0.72,0,1),opacity 260ms linear}
.layer::after{content:'';position:absolute;inset:0;background:var(--ink);opacity:0;
              pointer-events:none;transition:opacity 420ms linear}
.layer.behind::after{opacity:.10}
.pushl{z-index:3}
.mobile .pushl{transform:translateX(100%)}
.mobile .pushl.open{transform:translateX(0)}
.mobile .base.behind{transform:translateX(-22%)}
.desktop .pushl{transform:translateY(14px);opacity:0}
.desktop .pushl.open{transform:translateY(0);opacity:1}
.doc{position:absolute;inset:0;overflow-y:auto;overflow-x:hidden;padding:20px 20px 0;
     /* Android Chrome fires its own pull to refresh on a record the seam
        already refused to make refreshable (design/12: the record is push
        updated). The browser does it anyway unless it is told not to. */
     overscroll-behavior-y:contain}
.desktop .doc{padding:26px 32px 0}
.doc::-webkit-scrollbar{width:0}
.plate{position:absolute;inset:0;pointer-events:none;z-index:11}
.grat{position:absolute;inset:0;pointer-events:none;opacity:.07;z-index:0}
.grat svg{width:100%;height:100%;display:block}

/* ================= the sheet, and what it becomes on a desk =================
   On both native platforms the sheet is the system's, with the system's
   detents and grabber. Here it is ours. On a phone it keeps the shape people
   already know. On a desktop a bottom sheet is a phone idiom stranded on a
   1280px window, so it becomes a centred dialog, and the grabber goes: nobody
   drags a dialog down with a mouse. */
.scrim{position:absolute;inset:0;background:rgba(12,15,20,.28);z-index:14;opacity:0;
       pointer-events:none;transition:opacity 260ms linear}
.scrim.on{opacity:1;pointer-events:auto}
.sheet{position:absolute;z-index:15;background:var(--paper);
       transition:transform 380ms cubic-bezier(0.32,0.72,0,1),opacity 200ms linear}
.mobile .sheet{left:0;right:0;bottom:0;border-radius:14px 14px 0 0;padding:0 20px 28px;
               transform:translateY(101%);box-shadow:0 -1px 0 var(--hairline)}
.mobile .sheet.on{transform:translateY(0)}
.mobile .sheet.dragging{transition:none}
/* The imported content CSS carries design/13's own .sheet, which pins a phone
   sheet to left:0 right:0 bottom:0. Those edges have to be released by name,
   not merely overridden where they happen to collide: left alone, the dialog
   stretched to the floor of the viewport and rendered 180px of empty paper
   under its own button. */
.desktop .sheet{left:50%;top:50%;right:auto;bottom:auto;width:520px;
                transform:translate(-50%,-46%);opacity:0;border-radius:0;
                max-height:calc(100% - 96px);overflow-y:auto;
                padding:0 28px 28px;border:1px solid var(--ink);pointer-events:none}
.desktop .sheet.on{transform:translate(-50%,-50%);opacity:1;pointer-events:auto}
.grabber{width:36px;height:5px;border-radius:3px;background:var(--rule);opacity:.6;margin:8px auto 0}
.desktop .grabber{display:none}
.sheethead{padding:10px 0 0;cursor:grab;touch-action:none}
.desktop .sheethead{cursor:default;padding:16px 0 0}
.sheetbar{display:flex;align-items:center;justify-content:space-between;gap:8px;
          padding:4px 0 2px}
.barbtn{flex:0 0 56px;min-height:44px;font-weight:400;font-size:15px;color:var(--ink);text-align:left}
.barbtn:active{opacity:.4}
.listrow{display:flex;align-items:center;gap:12px;padding:14px 0;
         border-bottom:1px solid var(--hairline);width:100%;min-height:44px;text-align:left}
/* A sheet and a dialog are not the same object wearing different geometry.
   The phone sheet cancels from a bar at the top, because the top bar is where
   a thumb is not. A dialog cancels beside the thing it is cancelling. Drawing
   the dialog with the sheet's bar was the tell that only the box had moved. */
.deskonly{display:none}
.desktop .deskonly{display:block}
.desktop .sheetbar{display:none}
.desktop .sheethead{padding:20px 0 0}
.actionrow{display:flex;align-items:center;gap:12px;margin-top:26px}
.actionrow .btn-primary{flex:1}
.desktop .actionrow{justify-content:flex-end}
.desktop .actionrow .btn-primary{flex:0 0 auto;width:auto;padding-left:26px;padding-right:26px}
.desktop .js-cancel{order:-1}

/* ================= what only the web needs ================= */
/* The install prompt. Decision 039 records that the offline promise holds only
   for an installed home-screen app, because WebKit deletes the caches after
   seven idle days and exempts installed apps: "Installation is the storage
   model, not a distribution preference." So this is not an upsell banner, it
   is the storage model asking to be turned on, and it says which. */
.installbar{display:flex;align-items:center;gap:12px;background:var(--ink);color:var(--paper);
            padding:10px 20px;flex:0 0 auto;position:relative;z-index:11}
.desktop .installbar{padding:10px 32px}
.installbar .t-data,.installbar .t-meta{color:var(--paper)}
.installbar button{flex:0 0 auto;min-height:44px;padding:0 12px;color:var(--paper);
                   text-decoration:underline;text-underline-offset:3px}
.mobile .installdetail{display:none}
.mobile .vlong{display:none}
.vshort{display:none}
.mobile .vshort{display:inline}
.copied{display:flex;align-items:center;gap:8px;padding:10px 0 0}
.copied svg{flex:0 0 16px;stroke:var(--ink);stroke-width:1.5;fill:none}

/* ================= the console ================= */
.gates{display:flex;flex-wrap:wrap;gap:6px 16px;align-items:center;justify-content:center;
       padding:12px 16px;max-width:1000px;margin:0 auto}
.gate{display:flex;align-items:center;gap:7px}
.seg{display:flex;border:1px solid var(--rule);border-radius:3px;overflow:hidden}
.seg button{padding:6px 9px;font-weight:500;font-size:12px;min-height:34px;
            border-right:1px solid var(--rule);background:var(--paper);color:var(--ink)}
.seg button:last-child{border-right:0}
.seg button[aria-pressed="true"]{background:var(--ink);color:var(--paper)}
.gate select{min-height:34px;border:1px solid var(--rule);border-radius:3px;background:var(--paper);
             color:var(--ink);font:inherit;font-size:12px;padding:0 8px}
@media (max-width:700px){
  .gates{justify-content:flex-start}
}
</style>
</head>
<body>

<div class="gates">
  <span class="gate"><span class="t-micro" style="color:var(--secondary)">Viewport</span>
    <span class="seg" id="g-vp">
      <button data-v="desktop" aria-pressed="true">Desktop 1280</button>
      <button data-v="mobile" aria-pressed="false">Mobile 390</button>
    </span></span>
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
  <span class="gate"><span class="t-micro" style="color:var(--secondary)">Storage</span>
    <span class="seg" id="g-installed">
      <button data-v="tab" aria-pressed="true">Browser tab</button>
      <button data-v="installed" aria-pressed="false">Installed</button>
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
  <span class="gate"><span class="t-micro" style="color:var(--secondary)">Ceremony</span>
    <span class="seg" id="g-seat"><button data-v="seat" aria-pressed="false">Attestation landing</button></span></span>
</div>

<div class="stagewrap">
<div class="stage desktop" id="stage">
  <div class="browser" id="browser">

    <div class="urlbar">
      <span class="navbtns">
        <button class="navbtn" id="bback" aria-label="Browser back" disabled>
          <svg width="16" height="16" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
        </button>
        <button class="navbtn" id="bfwd" aria-label="Browser forward" disabled style="transform:scaleX(-1)">
          <svg width="16" height="16" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
        </button>
      </span>
      <span class="origin">
        <svg class="lockicon" width="11" height="11" viewBox="0 0 24 24" aria-hidden="true"
             stroke="var(--secondary)" stroke-width="2" fill="none">
          <rect x="4" y="10" width="16" height="11"></rect><path d="M8 10V7a4 4 0 0 1 8 0v3"></path>
        </svg>
        <span class="t-data" style="color:var(--secondary)">app.grainidentity.com</span>
      </span>
    </div>

    <div class="vp" id="vp">
      <span class="pageground" aria-hidden="true">
        <svg viewBox="0 0 1280 820" preserveAspectRatio="none" fill="none"
             stroke="var(--rule)" stroke-width="0.6">@@GRATICULE_PAGE@@</svg>
      </span>
      <div class="app" id="app">

        <header class="mast" id="mast">
          <span class="mastslot grow" id="lead"></span>
          <span class="mastslot" id="trail"></span>
        </header>

        <div class="installbar" id="installbar">
          <span style="flex:1;min-width:0">
            <span class="t-data" style="display:block"><span class="vlong">Your record reads offline only once this is installed.</span><span class="vshort">Reads offline once installed.</span></span>
            <span class="t-meta installdetail" style="display:block;opacity:.8">In a browser tab the copy is cleared after seven days without a visit.</span>
          </span>
          <button class="press" id="installgo"><span class="vlong">Add to home screen</span><span class="vshort">Install</span></button>
        </div>

        <div class="frame">
          <nav class="rail" id="rail" aria-label="Chapters"></nav>
          <div class="colwrap">
            <div class="col" id="scr">
              <div class="layer base" id="base">
                <span class="grat" aria-hidden="true">
                  <svg viewBox="0 0 640 760" preserveAspectRatio="none" fill="none"
                       stroke="var(--rule)" stroke-width="0.5">@@GRATICULE_SCREEN@@</svg>
                </span>
                <div class="doc" id="rec"></div>
              </div>
              <div class="plate" aria-hidden="true" id="plate"></div>
            </div>
          </div>
          <aside class="aside" id="aside" aria-label="Imprint"></aside>
        </div>
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
          <span class="t-micro deskonly" style="display:block;color:var(--secondary)" id="sheetkicker2"></span>
          <h3 class="t-lead" style="margin:10px 0 8px" id="sheettitle"></h3>
          <p class="t-body" style="margin:0 0 22px;color:var(--secondary);text-wrap:pretty" id="sheetbody-p"></p>
          <div id="sheetslot"></div>
          <div class="actionrow">
            <button class="barbtn press js-cancel deskonly" style="flex:0 0 auto">Cancel</button>
            <button class="btn-primary press" id="sheetcta"></button>
          </div>
        </div>
      </div>
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
/* The record's own surfaces are imported from design/13 by build.py. They are
   not redrawn here: 047 keeps the record Grain's on every platform, so the
   record is the one thing a change of platform may not change. What follows
   the import is this directory's own, and all of it is chrome. */
@@SURFACES@@

/* ---------------- web state on top of the imported state ---------------- */
/* GRAT2 is a free reference inside the imported record body: design/13
   declares it in its own chassis and boot() aliases it to the graticule. The
   slice therefore does not stand alone, and this is where that is paid. */
var GRAT2;
S.platform = 'web';
S.vp = 'desktop';
S.installed = false;
S.hist = [];

var VPS = {desktop:{w:1280, h:800}, mobile:{w:390, h:844}};

/* ---------------- surfaces the browser makes necessary ----------------

   Four surfaces exist here that have no native counterpart, and each one is a
   place where the browser is worse than the platform rather than merely
   different, which is design/12's test for who draws a thing. */

function installBody(){
  return '<div class="statewrap">' +
    '<h1 class="t-head" style="margin:0">Keep the record when there is no signal</h1>' +
    '<p class="t-body" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'Added to your home screen, Grain keeps a copy of the record on this device and opens ' +
      'without a connection. The copy is read only. Nothing you do offline is queued to send later.</p>' +
    '<div style="margin-top:22px">' + rows([
      ['In a browser tab', 'The copy is cleared after seven days without a visit. That is the browser rule and Grain cannot change it.'],
      ['Added to the home screen', 'The copy stays until you sign out or remove it.'],
      ['Either way', 'The record is on Grain servers. Losing the copy loses nothing.']
    ]) + '</div>' +
    '<div style="margin-top:26px"><button class="btn-primary press" id="installdo">Add to home screen</button></div>' +
    '<p class="t-meta" style="margin:22px 0 0;color:var(--secondary);text-wrap:pretty">' +
      'Your browser asks first. Grain cannot add anything to your home screen on its own.</p>' +
    '</div>';
}

/* Native unlocks with the device passcode or a biometric (038). A browser has
   neither. What it has is a passkey, which is a different promise: it proves
   the account, not the person holding the phone. Saying so is the whole
   surface, because 038's reason was shared handsets. */
function unlockWebBody(){
  return msg({
    kicker:'Signing in',
    title:'Unlock with a passkey',
    body:'On the web Grain unlocks with a passkey held by this browser, or by your phone. There is no device passcode to fall back on here.',
    rows:[
      ['What a passkey proves','That this is your Grain account.'],
      ['What it does not prove','That it is you holding the device. On a shared handset, sign out rather than relying on this.'],
      ['If the passkey is gone','Signing in by phone or email still works, and takes a code.']
    ],
    cta:'Unlock', ctaId:'js-home', ctaId:'js-home'
  });
}

/* Native shows "update required" because a store version can fall behind the
   API. A web app cannot: the served version is always current. What it can do
   is hold an old copy in a service worker, so the honest surface is a reload
   offer, not a block. */
function updateWebBody(){
  return msg({
    kicker:'This tab',
    title:'A newer version is ready',
    body:'This tab has been open a while and is running an older copy. Reloading takes a second and loses nothing you have typed.',
    rows:[['Nothing is blocked','The record you are reading is current. Only the page around it is old.']],
    cta:'Reload', ctaId:'js-home'
  });
}

/* Sharing out. navigator.share exists on most phone browsers and on almost no
   desktop ones, so the fallback is not an edge case, it is the desktop path.
   Drawn rather than assumed, because an invisible fallback is how a share
   button becomes a dead button on the platform most partners read on. */
function shareOutBody(){
  return '<div class="statewrap">' +
    '<span class="t-serial" style="color:var(--secondary)">Send the record</span>' +
    '<h1 class="t-head" style="margin:10px 0 12px">A link to what you chose</h1>' +
    '<p class="t-body" style="margin:0 0 20px;color:var(--secondary);text-wrap:pretty">' +
      'This browser cannot hand the link to another app, so Grain copies it instead. ' +
      'The link is a grant to the person you named, and it expires.</p>' +
    '<div class="ruled" style="margin-bottom:6px"><input id="grantlink" value="grain.id/g/7Q2M-4KX9" readonly aria-label="Grant link"></div>' +
    '<button class="btn-primary press" id="copygo" style="margin-top:16px">Copy the link</button>' +
    '<div id="copiedslot"></div></div>';
}

SURFACES.install = {title:'Offline', body:installBody};
SURFACES.shareout = {title:'Send', body:shareOutBody};
/* Replacements, not additions. A route that reaches `unlock` from the account
   list has to land on the passkey copy in a browser, not on the device-passcode
   copy that is false there. Same for the store update, which a web app cannot
   have. Parallel surfaces would have left the native copy reachable. */
SURFACES.unlock = {title:'Unlock', body:unlockWebBody};
SURFACES.updaterequired = {title:'This tab', body:updateWebBody};

/* ---------------- painting ---------------- */

function render(kind, d){
  if(S.five) return stateBody(S.five, SURFACES[kind] ? SURFACES[kind].title : 'Your record');
  return kind === 'record' ? recordBody() : SURFACES[kind].body(d);
}
function paintRecord(){ $('rec').innerHTML = render('record'); layoutDesk(); }

/* The desk arrangement, done by moving nodes rather than drawing a second
   record. The imprint surface already holds both halves the desk wants, the
   figure at full size and the chapter list with its provenance marks, so the
   desk renders that one surface and splits it across the two columns. Nothing
   here is a copy of design/13's markup, which is what keeps the record
   single-sourced. */
function layoutDesk(){
  var aside = $('aside'), rec = $('rec');
  if(!aside || !rec) return;
  var prev = rec.querySelector('[data-desk="list"]');
  if(prev) prev.parentNode.removeChild(prev);
  aside.innerHTML = '';
  var fw = rec.querySelector('.figwrap'), fo = rec.querySelector('.figopen');
  /* An empty record draws a figure too, the fixed empty canvas that makes the
     age-proxy refusal visible. It is not an index of anything, so the desk
     leaves it in the record beside the sentence it belongs to. */
  var desk = S.vp === 'desktop' && !S.stack.length && !S.five &&
             !figureHidden() && chapters().length > 0;
  if(!desk){
    if(fw) fw.style.display = '';
    if(fo) fo.style.display = '';
    return;
  }
  if(!fw) return;                       // an empty record has no figure to move
  fw.style.display = 'none';
  if(fo) fo.style.display = 'none';

  var tmp = document.createElement('div');
  tmp.innerHTML = render('imprint', {kind:'imprint'});
  var inner = tmp.firstElementChild;
  var big = inner.querySelector('.bigwrap');
  if(big){
    var lead = big.nextElementSibling;
    aside.appendChild(big);
    // the sentence that explains the rings belongs under the rings
    if(lead && lead.tagName === 'P') aside.appendChild(lead);
  }
  var wrap = document.createElement('div');
  wrap.setAttribute('data-desk', 'list');
  while(inner.firstChild) wrap.appendChild(inner.firstChild);
  var anchor = fo || fw;
  anchor.parentNode.insertBefore(wrap, anchor.nextSibling);
}

function repaintStack(){
  S.stack.forEach(function(d){ d.el.querySelector('.doc').innerHTML = render(d.kind, d); });
}

/* The masthead. On a phone the trailing pair are the two glyphs the native bar
   carries. On a desktop, sharing becomes a word: design/12 left that open as
   option D and its stated cost was width, which is the one thing a desktop
   masthead has. Account stays a glyph, because it is the only thing in the bar
   that is a place rather than an act. */
function paintBar(){
  var lead = '', trail = '', n = S.stack.length;
  if(n){
    var prev = n > 1 ? SURFACES[S.stack[n-2].kind].title : 'Record';
    /* The wordmark is the way home from any depth. Without it the record and
       the account were only reachable by walking the whole back chain, and a
       browser gives no back gesture to walk it with. It keeps the leading slot
       it has on the record, so it never moves. */
    lead = '<button class="homebtn press js-home" aria-label="Back to your record">' +
        '<svg viewBox="0 0 160 26" width="86" height="14" aria-hidden="true">' + LOCKUP + '</svg></button>' +
      '<span class="bardiv" aria-hidden="true"></span>' +
      '<button class="backbtn press js-back" aria-label="Back to ' + esc(prev) + '">' +
      '<svg aria-hidden="true" width="22" height="22" viewBox="0 0 24 24" class="icon"><use href="#i-back"></use></svg>' +
      '<span class="t-rec">' + esc(prev) + '</span></button>';
  } else {
    lead = '<span style="display:flex;align-items:center;padding-left:2px">' +
      '<svg viewBox="0 0 160 26" width="120" height="19" role="img" aria-label="Grain">' + LOCKUP + '</svg></span>';
  }
  if(S.vp === 'desktop'){
    trail = '<button class="wordbtn press js-share" aria-label="Sharing. Two parties hold a grant, public page off">' +
        SHARE + '<span class="t-rec">Sharing</span>' +
        '<span class="t-data" style="color:var(--secondary)">2</span></button>' +
      '<button class="iconbtn press js-acc" aria-label="Account and settings">' + ACC + '</button>';
  } else {
    trail = '<button class="iconbtn press js-share" aria-label="Sharing. Two parties hold a grant, public page off">' + SHARE + '</button>' +
      '<button class="iconbtn press js-acc" aria-label="Account and settings">' + ACC + '</button>';
  }
  $('lead').innerHTML = lead;
  $('trail').innerHTML = trail;
}

/* The plate marks the record and nothing else (design/10's chassis comment).
   On a desk that is load-bearing rather than decorative: it is what says the
   640px column is the record and the ground either side of it is not. */
function paintPlate(){
  var on = S.vp === 'desktop' && !S.stack.length;
  $('plate').innerHTML = !on ? '' :
    '<span class="reg" style="top:8px;left:8px;border-top-width:1px;border-left-width:1px"></span>' +
    '<span class="reg" style="top:8px;right:8px;border-top-width:1px;border-right-width:1px"></span>' +
    '<span class="reg" style="bottom:8px;left:8px;border-bottom-width:1px;border-left-width:1px"></span>' +
    '<span class="reg" style="bottom:8px;right:8px;border-bottom-width:1px;border-right-width:1px"></span>';
}

/* The index. On Android this had to be a 40px edge strip inside a 200dp budget
   shared with every other window (037), and was demoted to an accelerator so
   that nothing depended on hitting it. Nothing depends on it here either: it
   scrolls the record it is already showing. It is visible because a desktop
   has the room, not because the record needs it. */
function paintRail(){ $('rail').innerHTML = ''; }

/* ---------------- the scroll edge, drawn by hand ---------------- */
function topLayer(){ return S.stack.length ? S.stack[S.stack.length-1].el : $('base'); }
function topDoc(){ return topLayer().querySelector('.doc') || $('rec'); }

function syncEdge(){
  var y = topDoc().scrollTop;
  $('mast').classList.toggle('edged', y > 2);
  /* The mobile browser takes back its own address bar as you scroll, and the
     masthead has to survive the viewport growing under it. Drawn so the
     reviewer can see the app move, because a fixed offset assumed here is a
     bug that only appears on a real phone. */
  $('stage').classList.toggle('scrolled', S.vp === 'mobile' && y > 8);
}

/* ---------------- navigation, and the browser's back button ----------------

   Every push is a history entry, so the browser's back does what the drawn
   back does. Without that, back leaves the app from a sheet, which is the
   single most common way a web app loses somebody. pushState throws on an
   opaque origin, so the internal stack is authoritative and the real history
   is best effort on top of it. */
function pushHist(kind){
  S.hist.push(kind);
  try{ history.pushState({k:kind}, '', '#' + kind); }catch(e){}
  paintNavBtns();
}
function popHist(){
  S.hist.pop();
  try{ history.back(); }catch(e){}
  paintNavBtns();
}
function paintNavBtns(){
  $('bback').disabled = !(S.stack.length || S.sheetOpen);
}

function push(d){
  var below = topLayer();
  var el = document.createElement('div');
  el.className = 'layer pushl';
  el.innerHTML = '<div class="doc"></div>';
  el.querySelector('.doc').innerHTML = render(d.kind, d);
  $('scr').insertBefore(el, $('plate'));
  d.el = el; S.stack.push(d);
  el.querySelector('.doc').addEventListener('scroll', syncEdge, {passive:true});
  el.getBoundingClientRect();
  pushHist(d.kind);
  requestAnimationFrame(function(){
    el.classList.add('open'); below.classList.add('behind');
    paintBar(); paintRail(); paintPlate(); layoutDesk(); syncEdge();
  });
}
function pop(silent){
  if(!S.stack.length) return;
  var d = S.stack.pop(), el = d.el, below = topLayer();
  el.classList.remove('open'); below.classList.remove('behind');
  if(!silent) popHist();
  paintBar(); paintRail(); paintPlate(); syncEdge();
  setTimeout(layoutDesk, 0);
  setTimeout(function(){ if(el.parentNode) el.parentNode.removeChild(el); }, 440);
}

/* ---------------- the sheet, ours on both viewports ---------------- */
function openSheet(o){
  var c = CH[o.i];
  $('sheetkicker').textContent = o.kicker;
  $('sheetkicker2').textContent = o.kicker;
  $('sheettitle').textContent = c.party;
  $('sheetbody-p').textContent = o.body;
  $('sheetcta').textContent = o.cta;
  $('sheetslot').innerHTML = '';
  S.sheetOpen = true; S.sheetKind = 'request';
  requestAnimationFrame(function(){
    $('sheet').classList.add('on'); $('scrim').classList.add('on'); paintNavBtns();
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
  $('sheetkicker2').textContent = field === 'from' ? 'Started' : 'Ended';
  $('sheettitle').textContent = 'Pick a month';
  $('sheetbody-p').textContent = '';
  $('sheetslot').innerHTML = monthSheetHTML();
  $('sheetcta').textContent = 'Set';
  S.sheetOpen = true; S.sheetKind = 'month';
  requestAnimationFrame(function(){
    $('sheet').classList.add('on'); $('scrim').classList.add('on'); paintNavBtns();
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
  });
}
function closeSheet(){
  $('sheetcta').style.display = '';
  if(!S.sheetOpen) return;
  S.sheetOpen = false;
  $('sheet').classList.remove('on'); $('scrim').classList.remove('on');
  paintNavBtns();
}

/* ---------------- viewport, scale, storage ---------------- */
function applyVp(){
  var v = VPS[S.vp];
  $('stage').classList.toggle('desktop', S.vp === 'desktop');
  $('stage').classList.toggle('mobile', S.vp === 'mobile');
  $('browser').style.width = v.w + 'px';
  $('vp').style.height = v.h + 'px';
  fit();
  paintBar(); paintRail(); paintPlate(); layoutDesk(); syncEdge();
}
/* The frame is a viewport at true pixel size, scaled to whatever room the
   page has. Scaling the frame rather than reflowing it is the point: a 1280
   layout has to be judged at 1280. */
function fit(){
  var avail = document.querySelector('.stagewrap').clientWidth - 32;
  var k = Math.min(1, avail / VPS[S.vp].w);
  $('stage').style.transform = 'scale(' + k + ')';
  $('stage').style.height = (VPS[S.vp].h + 43) * k + 'px';
}
function applyScale(){
  $('app').style.fontSize = (S.scale * 100) + '%';
  paintRecord(); repaintStack();
}
function applyInstalled(){
  $('installbar').style.display = S.installed ? 'none' : '';
  paintRecord(); repaintStack();
}

/* §10's attestation landing. On native this beat carried a haptic. A browser
   has none to carry it: iOS Safari has no vibration API at all. The beat is
   therefore entirely visual, and the row's seat plus the figure's re-scribe
   have to do the work the taptic engine was doing. */
function playSeat(){
  var run = function(){
    push({kind:'imprint'});
    setTimeout(function(){
      var row = topLayer().querySelector('[data-row="4"]');
      if(!row) return;
      CH[4].attested = true;
      setTimeout(function(){
        row.classList.remove('proud'); row.classList.add('seating');
        setTimeout(function(){
          row.classList.remove('seating');
          var big = topLayer().querySelector('.bigfig');
          if(big){ big.classList.remove('moved'); void big.offsetWidth; big.classList.add('moved'); }
        }, 320);
      }, 420);
    }, 80);
  };
  if(S.stack.length){ while(S.stack.length) pop(true); setTimeout(run, 460); } else { run(); }
}

/* ---------------- the menu ---------------- */
var NAV = [
  ['First run', ['launch','lander','identifier','code','welcome','name','consent','handle']],
  ['The record', ['record','imprint','permanence']],
  ['Chapters', ['addchapter','parsing','importreview','sensitive','importfail','addposition','countable','minoredit']],
  ['Education and certificates', ['education','credential']],
  ['Getting verified', ['reqattest','askmanager','askcoworker','requestsent']],
  ['Identity', ['idwhy','doctype','capture','idchecking','idresult','idliveness','idfailed','permcamera']],
  ['Sharing', ['sharing','publicpage','sendrecord','shareout','grantdetail']],
  ['Disputes and deletion', ['dispute','disputesent','gracesignin']],
  ['Account', ['account','ledger','notifprefs','permnotify','language','exportrec','disclosure','support','deleterec','deletepending','unlock','signout']],
  ['The browser', ['install','updaterequired','notfound','signedout','legal']]
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
  sendrecord:'Send the record', shareout:'Share, no share sheet', grantdetail:'Grant detail',
  account:'Account', ledger:'The ledger',
  notifprefs:'Notification preferences', permnotify:'Notification permission', language:'Language',
  exportrec:'Export', disclosure:'Who can read it', support:'Support', deleterec:'Delete everything',
  deletepending:'Deletion requested', gracesignin:'Deletion filed, the way back',
  dispute:'Dispute an attestation', disputesent:'Dispute filed', unlock:'Unlock, by passkey', signout:'Sign out',
  install:'Install, and offline', updaterequired:'A newer version',
  notfound:'Address not found', signedout:'Signed out', legal:'How this works'
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
  paintRecord(); applyVp(); applyInstalled();
  $('rec').addEventListener('scroll', syncEdge, {passive:true});
  window.addEventListener('resize', fit);
  window.addEventListener('popstate', function(){
    if(S.sheetOpen) return closeSheet();
    if(S.stack.length) pop(true);
  });
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

  if(t.closest('#bback')){
    if(S.sheetOpen) return closeSheet();
    if(S.stack.length) return pop();
    return;
  }
  if(t.closest('#installgo')) return push({kind:'install'});
  if(t.closest('#installdo')){
    S.installed = true;
    $('g-installed').querySelectorAll('button').forEach(function(x){
      x.setAttribute('aria-pressed', String(x.getAttribute('data-v') === 'installed')); });
    applyInstalled();
    return pop();
  }
  if(t.closest('#copygo')){
    var slot = document.getElementById('copiedslot');
    if(slot) slot.innerHTML = '<div class="copied"><svg width="16" height="16" viewBox="0 0 24 24">' +
      '<use href="#i-done"></use></svg><span class="t-data">Copied. It expires in 14 days.</span></div>';
    return;
  }

  var jump = t.closest('[data-jump]');
  if(jump){
    var i = +jump.getAttribute('data-jump');
    var row = $('rec').querySelector('[data-row="' + i + '"]');
    if(row) row.scrollIntoView({behavior:'smooth', block:'center'});
    $('rail').querySelectorAll('.railitem').forEach(function(x){ x.classList.remove('on'); });
    jump.classList.add('on');
    return;
  }

  if(t.closest('.js-imprint')) return push({kind:'imprint'});
  var row2 = t.closest('[data-out]');
  if(row2) return openAsk(OUT[+row2.getAttribute('data-out')].i);
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
  if(t.closest('#sheetcancel') || t.closest('.js-cancel') || t.closest('#sheetcta') || t.closest('#scrim')) return closeSheet();
  var yr = t.closest('[data-yr]');
  if(yr){ pick.year += parseInt(yr.getAttribute('data-yr'), 10); $('sheetslot').innerHTML = monthSheetHTML(); return; }
  var mo = t.closest('[data-mon]');
  if(mo){ pick.month = parseInt(mo.getAttribute('data-mon'), 10); $('sheetslot').innerHTML = monthSheetHTML(); return; }
  var mf = t.closest('[data-month]');
  if(mf) return openMonth(mf.getAttribute('data-month'));
  var dc = t.closest('[data-country]');
  if(dc){ idf.country = (idf.country + 1) % COUNTRIES.length; paintRecord(); repaintStack(); return; }
  var im = t.closest('[data-idmode]');
  if(im){ idf.mode = im.getAttribute('data-idmode'); repaintStack(); return; }
  var dd = t.closest('[data-doc]');
  if(dd){ docPick = parseInt(dd.getAttribute('data-doc'), 10); repaintStack(); return; }
  var df = t.closest('[data-found]');
  if(df){ var k = parseInt(df.getAttribute('data-found'), 10); FOUND[k].on = !FOUND[k].on; repaintStack(); return; }
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
    host.innerHTML = '<div class="said"><svg width="16" height="16" viewBox="0 0 24 24">' +
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
  /* On the web the send ends in the copy-link fallback rather than a share
     sheet, because navigator.share is absent on most desktop browsers. */
  if(t.closest('.js-sendgrant')) return push({kind:'shareout'});
  var sw = t.closest('.js-sw');
  if(sw) sw.setAttribute('aria-checked', sw.getAttribute('aria-checked') === 'true' ? 'false' : 'true');
});

/* Escape closes the dialog. On a desk that is the expected gesture and there
   is no drag to substitute for it. */
document.addEventListener('keydown', function(e){
  if(e.key === 'Escape'){
    if(S.sheetOpen) return closeSheet();
    if(S.stack.length) return pop();
  }
});

/* The grabber, mobile only. A dialog on a desk is not dragged. */
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
    if(!S.sheetOpen || S.vp !== 'mobile') return;
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
    while(S.stack.length) pop(true);
    if(v !== 'record') setTimeout(function(){ push({kind:v}); }, 30);
    else setTimeout(function(){ paintRecord(); paintRail(); paintPlate(); }, 30);
    return;
  }
  if(e.target.id === 'g-five'){
    S.five = e.target.value || null;
    paintRecord(); repaintStack(); paintRail();
  }
});

document.querySelectorAll('.seg').forEach(function(seg){
  seg.addEventListener('click', function(e){
    var b = e.target.closest('button'); if(!b) return;
    var v = b.getAttribute('data-v');
    if(seg.id === 'g-seat') return playSeat();
    seg.querySelectorAll('button').forEach(function(x){
      x.setAttribute('aria-pressed', String(x === b)); });
    if(seg.id === 'g-vp'){ closeSheet(); while(S.stack.length) pop(true); S.vp = v; applyVp(); }
    else if(seg.id === 'g-scale'){ S.scale = parseFloat(v); applyScale(); }
    else if(seg.id === 'g-installed'){ S.installed = v === 'installed'; applyInstalled(); }
    else if(seg.id === 'g-state'){ S.state = v; while(S.stack.length) pop(true);
      paintRecord(); paintRail(); paintPlate(); }
  });
});
</script>
</body>
</html>
