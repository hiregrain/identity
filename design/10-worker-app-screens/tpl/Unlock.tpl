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

<!-- H7b. 038: biometrics or the device passcode, declinable, default on.
     It guards the app, never the record: the record's security is the key,
     and a screen that implied a thumbprint was protecting it would be
     overselling a convenience. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
  <main style="position:absolute;inset:0;display:flex;flex-direction:column;
               justify-content:center;padding:0 20px 70px">
    <svg viewBox="0 0 600 600" width="56" height="56" role="img" aria-label="Grain"
         style="margin-bottom:28px">@@MARK56@@</svg>
    <h1 class="t-title" style="margin:0 0 10px;font-size:25px;line-height:1.2;text-wrap:pretty">
      Unlock your record</h1>
    <p class="t-body" style="margin:0 0 26px;color:var(--secondary);text-wrap:pretty">
      This device is set to ask before opening the app.</p>
    <div style="display:flex;flex-direction:column;gap:12px">
      <button class="btn-primary press">Use Face ID</button>
      <button class="btn-secondary press">Use the device passcode</button>
    </div>
    <p class="t-meta" style="margin:20px 0 0;color:var(--secondary);text-wrap:pretty">
      This locks the app on this phone. It is not what keeps your record private
      from Grain or from anyone else; that is the key, and no thumbprint stands
      in for it.</p>
  </main>
  </main>

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
