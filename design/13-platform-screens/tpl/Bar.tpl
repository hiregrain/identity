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
    .crop{width:402px;border-radius:26px 26px 0 0;overflow:hidden;background:var(--paper);
          position:relative;height:190px;box-shadow:0 0 0 1px var(--hairline)}
    .sysfont{font-family:-apple-system,'SF Pro Text','Helvetica Neue',sans-serif;
             -webkit-font-smoothing:antialiased}
    .island{position:absolute;top:11px;left:50%;transform:translateX(-50%);
            width:126px;height:37px;border-radius:19px;background:#0C0F14;z-index:8}
    .stat{position:absolute;top:22px;right:20px;display:flex;align-items:center;gap:6px;z-index:7}
    .clock{position:absolute;left:0;width:138px;top:20px;text-align:center;z-index:7;
           font-size:16px;font-weight:600;color:var(--ink);letter-spacing:-0.01em}
    .bar{position:absolute;top:62px;left:0;right:0;height:44px;z-index:6;
         display:flex;align-items:center;justify-content:space-between;padding:0 12px}
    .txtbtn{min-height:44px;display:flex;align-items:center;gap:6px;padding:0 8px}
    .opt{display:flex;flex-direction:column;gap:10px}
    .arg{display:flex;gap:14px}
    .arg > div{flex:1;min-width:0}
  </style>
</helmet>

<div style="width:500px;position:relative;background:var(--page);padding:28px 28px 32px">

  <span class="t-serial" style="color:var(--secondary)">The trailing cluster, four ways</span>
  <p class="t-body" style="margin:8px 0 24px;color:var(--secondary);text-wrap:pretty">Account is who you are and is visited twice a year. Sharing is the one consequential act on this screen. Drawn as two matched 19px glyphs they read as a pair of settings, which is the thing they are least alike in being.</p>

  <div style="display:flex;flex-direction:column;gap:28px">

    <!-- A -->
    <div class="opt">
      <div class="crop">
        <div class="clock sysfont">9:41</div>
        <div class="stat sysfont">@@STATUSGLYPHS@@</div>
        <div class="island"></div>
        <div class="bar">
          <button class="iconbtn press" aria-label="Account and settings">@@ACCOUNTGLYPH@@</button>
          <button class="txtbtn press" aria-label="Sharing, 2 parties hold a grant">
            @@SHAREGLYPH@@<span class="t-data" style="font-size:13px">2</span>
          </button>
        </div>
        <div style="position:absolute;top:112px;left:20px;right:20px">
          <h1 class="t-title" style="margin:0">Liezel Mendoza</h1>
        </div>
      </div>
      <div class="arg">
        <div>
          <span class="t-micro" style="color:var(--secondary)">Option A</span>
          <span class="t-rec" style="display:block;padding-top:4px">Split by edge</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">Leading is the who slot on both platforms, trailing is the what-you-can-do slot. Identity and action end up 360 points apart.</span>
        </div>
        <div>
          <span class="t-micro" style="color:var(--secondary)">Its cost</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:22px;text-wrap:pretty">The leading slot is where back lives on every pushed screen, so the account glyph appears and vanishes as you navigate. And it collides with the lockup if the lockup stays in the bar.</span>
        </div>
      </div>
    </div>

    <!-- B -->
    <div class="opt">
      <div class="crop">
        <div class="clock sysfont">9:41</div>
        <div class="stat sysfont">@@STATUSGLYPHS@@</div>
        <div class="island"></div>
        <div class="bar" style="justify-content:flex-end">
          <button class="iconbtn press" aria-label="Account and settings">@@ACCOUNTGLYPH@@</button>
        </div>
        <div style="position:absolute;top:112px;left:20px;right:20px">
          <h1 class="t-title" style="margin:0">Liezel Mendoza</h1>
        </div>
      </div>
      <div class="arg">
        <div>
          <span class="t-micro" style="color:var(--secondary)">Option B</span>
          <span class="t-rec" style="display:block;padding-top:4px">Sharing stops being a glyph</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">It becomes a ruled row at the foot of the record: "Two parties hold a grant. Your public page is off." Everything else in this product refuses to compress a graded fact into a symbol, and a 2 beside an arrow is a badge.</span>
        </div>
        <div>
          <span class="t-micro" style="color:var(--secondary)">Its cost</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:22px;text-wrap:pretty">Sharing is then a scroll away, and it touches decision 045's reasoning, which moved sharing out of the record. It would need a superseding entry rather than a quiet reinterpretation.</span>
        </div>
      </div>
    </div>

    <!-- C -->
    <div class="opt">
      <div class="crop" style="height:230px">
        <div class="clock sysfont">9:41</div>
        <div class="stat sysfont">@@STATUSGLYPHS@@</div>
        <div class="island"></div>
        <div class="bar" style="justify-content:flex-end">
          <button class="iconbtn press" aria-label="Account and settings">@@ACCOUNTGLYPH@@</button>
        </div>
        <div style="position:absolute;top:112px;left:20px;right:20px">
          <h1 class="t-title" style="margin:0">Liezel Mendoza</h1>
        </div>
        <div style="position:absolute;left:0;right:0;bottom:0;height:56px;background:var(--page);
                    border-top:1px solid var(--hairline);display:flex;align-items:center;
                    justify-content:center;gap:8px">
          @@SHAREGLYPH@@<span class="t-rec">Sharing</span>
          <span class="t-data" style="color:var(--secondary)">2 parties</span>
        </div>
      </div>
      <div class="arg">
        <div>
          <span class="t-micro" style="color:var(--secondary)">Option C</span>
          <span class="t-rec" style="display:block;padding-top:4px">Sharing to a bottom toolbar</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">Thumb reachable, and legitimate: Apple's toolbars run along the top or bottom edge, and decision 048 refused a tab bar, which is navigation between destinations, not an action bar.</span>
        </div>
        <div>
          <span class="t-micro" style="color:var(--secondary)">Its cost</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:22px;text-wrap:pretty">048's arithmetic still lands. 56 pt plus the 34 pt inset is permanent chrome for something that happens when a person outside the app asks for it, which 048 named as the trade a bottom bar is worst at.</span>
        </div>
      </div>
    </div>

    <!-- D -->
    <div class="opt">
      <div class="crop">
        <div class="clock sysfont">9:41</div>
        <div class="stat sysfont">@@STATUSGLYPHS@@</div>
        <div class="island"></div>
        <div class="bar" style="justify-content:flex-end;gap:2px">
          <button class="txtbtn press" aria-label="Sharing, 2 parties hold a grant">
            <span class="t-rec">Sharing</span>
            <span class="t-data" style="color:var(--secondary)">2</span>
          </button>
          <button class="iconbtn press" aria-label="Account and settings">@@ACCOUNTGLYPH@@</button>
        </div>
        <div style="position:absolute;top:112px;left:20px;right:20px">
          <h1 class="t-title" style="margin:0">Liezel Mendoza</h1>
        </div>
      </div>
      <div class="arg">
        <div>
          <span class="t-micro" style="color:var(--secondary)">Option D</span>
          <span class="t-rec" style="display:block;padding-top:4px">A word, not a matched glyph</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:4px;text-wrap:pretty">Both stay trailing, but they stop being a pair: one is a word with a number, one is a glyph. Text bar buttons are standard on both platforms, and the word says what the glyph could not.</span>
        </div>
        <div>
          <span class="t-micro" style="color:var(--secondary)">Its cost</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:22px;text-wrap:pretty">The cheapest change here, and the least considered. It fixes the pairing without answering whether a count belongs in chrome at all. It also does not survive translation to Hindi with the same width.</span>
        </div>
      </div>
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
