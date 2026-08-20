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

<!-- I8. The written content of each of the three events. A notification is
     read on a lock screen by whoever is holding the phone, so it names the
     business only where the business is already public knowledge to that
     person, and never states what was attested. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">What a notification says</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <p class="t-body" style="margin:0 0 24px;color:var(--secondary);text-wrap:pretty">
        A notification is read on a lock screen, sometimes by somebody else
        holding the phone. None of these say what was attested.</p>
      <sc-for list="{{ notes }}" as="n" hint-placeholder-count="3">
        <div style="padding:16px 0;border-bottom:1px solid var(--hairline)">
          <span class="t-micro" style="display:block;color:var(--secondary)">{{ n.when }}</span>
          <div style="border:1px solid var(--rule);border-radius:3px;padding:12px 14px;margin-top:10px">
            <span class="t-rec" style="display:block">Grain</span>
            <span class="t-body" style="display:block;padding-top:4px;text-wrap:pretty">{{ n.text }}</span>
          </div>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:8px;text-wrap:pretty">{{ n.why }}</span>
        </div>
      </sc-for>
    </div>
  </main>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { notes: [
      {when:'A party attests', text:'Cebu Pacific Cargo Services attested a chapter on your record.',
       why:'Names the business, because you asked them and you are waiting on it. Says nothing about what they attested.'},
      {when:'A grant is about to end', text:'Your grant to Alorica Philippines ends in 4 days.',
       why:'Four days is enough to send it again before it lapses, and short enough not to be a second reminder.'},
      {when:'A deadline to attach your side', text:'You have 6 days left to attach your side to a chapter.',
       why:'Names no business. A lock screen is not the place to say which chapter you are disputing.'}
    ]};
  }
}
</script>
</body>
</html>
