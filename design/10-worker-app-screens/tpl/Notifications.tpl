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

<!-- H2. Three events and no more (plans/worker-surface). 035 B4 removed read
     events from notifications along with every other surface, so there is no
     row here for somebody opening your record. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to your account">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Notifications</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding-top:24px">
      <div class="srow">
        <span style="flex:1;min-width:0">
          <span class="t-body" style="display:block">A party attests your work</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">The one that is worth interrupting you for.</span>
        </span>
        <button class="sw press" role="switch" aria-checked="{{ a }}" aria-label="A party attests your work"
                onClick="{{ aGo }}"><i></i></button>
      </div>
      <div class="srow">
        <span style="flex:1;min-width:0">
          <span class="t-body" style="display:block">A grant is about to end</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">Four days before, so you can send it again if you want to.</span>
        </span>
        <button class="sw press" role="switch" aria-checked="{{ b }}" aria-label="A grant is about to end"
                onClick="{{ bGo }}"><i></i></button>
      </div>
      <div class="srow">
        <span style="flex:1;min-width:0">
          <span class="t-body" style="display:block">A deadline to attach your side</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">Only when one is running.</span>
        </span>
        <button class="sw press" role="switch" aria-checked="{{ c }}" aria-label="A deadline to attach your side"
                onClick="{{ cGo }}"><i></i></button>
      </div>
    </div>
    <div class="grp">
      <p class="t-meta" style="margin:0;color:var(--secondary);text-wrap:pretty">
        There is no notification for somebody reading your record. Grain does not
        surface read events anywhere, because a read stream during a live
        application is an anxiety feed and surveillance of the business.</p>
    </div>
  </main>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {a:true, b:true, c:true}; }
  renderVals(){
    const t = (k) => ({ [k]: this.state[k] ? 'true' : 'false',
                        [k+'Go']: () => this.setState({[k]: !this.state[k]}) });
    return Object.assign({}, t('a'), t('b'), t('c'));
  }
}
</script>
</body>
</html>
