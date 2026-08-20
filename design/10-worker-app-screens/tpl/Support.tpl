<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .ta{width:100%;min-height:132px;border:0;border-bottom:1px solid var(--rule);
        background:none;font:inherit;color:var(--ink);outline:0;padding:12px 0;resize:none}
    .ta:focus{border-bottom:2px solid var(--ink)}
  </style>
</helmet>

<!-- H6. 036 routes every account change through a person, so this is not a
     help desk bolted on, it is the mechanism. It says what it can and cannot
     do, because a support box that quietly cannot delete a chapter wastes the
     one message a worker on a prepaid plan will send. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your account">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Message support</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <p class="t-body" style="margin:0 0 20px;color:var(--secondary);text-wrap:pretty">
        Account changes go through a person, on purpose: a name or a number on a
        record that parties have signed should not change quietly.</p>

      <div class="sechead"><h3 class="t-sec" style="margin:0">What we can change</h3></div>
      <div class="sinerule">@@SINERULE@@</div>
      <sc-for list="{{ can }}" as="c" hint-placeholder-count="4">
        <div class="srow"><span class="t-body" style="flex:1;min-width:0">{{ c }}</span></div>
      </sc-for>

      <div class="grp">
        <div class="sechead"><h3 class="t-sec" style="margin:0">What nobody can change</h3></div>
        <div class="sinerule">@@SINERULE@@</div>
        <sc-for list="{{ cannot }}" as="c" hint-placeholder-count="3">
          <div class="srow">
            <span class="t-body" style="flex:1;min-width:0;color:var(--secondary);text-wrap:pretty">{{ c }}</span>
          </div>
        </sc-for>
      </div>

      <div class="grp">
        <label class="t-micro" for="msg" style="display:block;color:var(--secondary);padding-bottom:8px">Your message</label>
        <textarea class="ta" id="msg" aria-label="Your message"></textarea>
        <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
          Usually answered within a working day.</p>
      </div>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Send it</button>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  renderVals(){
    return {
      can: ['Your name', 'Your phone or email', 'Your address', 'Redo an identity check that failed'],
      cannot: [
        'What a party attested. It is theirs, and you can attach your side to it.',
        'Removing one chapter. Deleting the whole record is the only way any of it comes out.',
        'What a reader already read and kept.'
      ]
    };
  }
}
</script>
</body>
</html>
