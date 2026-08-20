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

<!-- C4. Reached from the permanence footnote, and from the disabled remove
     control. A refusal that explains itself is a different object from a
     refusal that does not, and this is the rule workers press hardest on. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to the chapter">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Why this stays</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:26px">
      <h2 class="t-title" style="margin:0 0 14px;font-size:25px;line-height:1.2;text-wrap:pretty">
        A chapter a party signed cannot be removed</h2>
      <p class="t-body" style="margin:0 0 22px;color:var(--secondary);text-wrap:pretty">
        Not by you, and not by them. Here is the whole reason, because you should
        be able to weigh it rather than take it.</p>

      <sc-for list="{{ points }}" as="p" hint-placeholder-count="4">
        <div style="padding:15px 0;border-bottom:1px solid var(--hairline)">
          <span class="t-rec" style="display:block;text-wrap:pretty">{{ p.head }}</span>
          <span class="t-body" style="display:block;color:var(--secondary);padding-top:5px;text-wrap:pretty">{{ p.body }}</span>
        </div>
      </sc-for>

      <div style="margin-top:22px;background:var(--ink);color:var(--paper);padding:16px">
        <p class="t-body" style="margin:0;text-wrap:pretty">
          What you can always do: attach your side to anything, permanently, so
          it travels with the chapter. And you can have the whole record deleted,
          at any time, without giving a reason.</p>
      </div>
    </div>
  </main>
  <div class="actions">
    <button class="btn-secondary press">Attach your side to this chapter</button>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return { points: [
      {head:'A record you can edit is a record nobody can rely on',
       body:'If a chapter could disappear after a business signed it, a reader would have to assume every record they see is the flattering half of a larger one. The whole thing would be worth what a résumé is worth.'},
      {head:'It protects you as much as it constrains you',
       body:'The same rule stops a business withdrawing what it confirmed about you after you leave, or after a dispute. Their signature is as permanent as your chapter.'},
      {head:'Grain never judges whether a party was fair',
       body:'We check that they really signed it. We do not adjudicate, and we will not quietly remove something because one side asked. That is what attaching your side is for.'},
      {head:'The exit is total, and it is yours',
       body:'Deleting your whole record is always available and needs no reason. Nothing partial, because a partial delete is an edit wearing another name.'}
    ]};
  }
}
</script>
</body>
</html>
