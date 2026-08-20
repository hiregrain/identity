<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
  </style>
</helmet>

<!-- H5, and it is not optional. 035 B4 surfaces no read events anywhere and
     names the consequence in the same breath: GDPR Art. 15(1)(c) is satisfied
     by a disclosure record available ON REQUEST. Removing the live feed is
     what makes this screen mandatory rather than a nicety. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your account">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Who has read it</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <h2 class="t-sec" style="margin:0 0 8px;font-size:19px;line-height:1.3">Ask for the disclosure record</h2>
      <p class="t-body" style="margin:0 0 20px;color:var(--secondary);text-wrap:pretty">
        Every party that has read your record, and when. Sent by email, and it is
        a right rather than a favour.</p>

      <div style="border-block:1px solid var(--ink);padding:16px 0">
        <p class="t-body" style="margin:0;text-wrap:pretty">
          Grain does not show this live, and that is deliberate. A running feed of
          who opened your record during an application is an anxiety feed for you
          and surveillance of the business, and a worker who can see it can be
          asked to show it.</p>
      </div>

      <p class="t-meta" style="margin:16px 0 0;color:var(--secondary);text-wrap:pretty">
        What you can always see without asking, on Sharing: who currently holds a
        grant, what it covers, and the date it ends.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Send me the disclosure record</button>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){ return {}; }
}
</script>
</body>
</html>
