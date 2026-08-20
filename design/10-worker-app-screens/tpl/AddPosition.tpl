<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet>
  <style>
@@CSS@@
@@CHROME@@
    .ruled{display:flex;align-items:center;border-bottom:1px solid var(--rule)}
    .ruled:focus-within{border-bottom:2px solid var(--ink)}
    .ruled input{border:0;outline:0;background:none;font:inherit;color:var(--ink);
                 flex:1;min-width:0;padding:12px 0;font-weight:600;font-size:16px;
                 min-height:44px;box-sizing:border-box}
  </style>
</helmet>

<!-- C2. A position sits inside a chapter, because a chapter is one business
     and a promotion is not a new employer. This is the screen that stops a
     worker filing the same business twice and looking like a job-hopper. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to the chapter">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Add a position</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:88px;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:24px 0 18px;border-bottom:1px solid var(--ink)">
      <span class="t-micro" style="display:block;color:var(--secondary)">Inside this chapter</span>
      <p class="t-rec" style="margin:6px 0 0">Sunrise Foods Manufacturing</p>
      <p class="t-meta" style="margin:4px 0 0;color:var(--secondary)">Mar 2019 to Sep 2021</p>
    </div>
    <div style="padding-top:22px">
      <label class="t-micro" for="pt" style="display:block;color:var(--secondary);padding-bottom:8px">Position</label>
      <div class="ruled"><input id="pt" value="{{ title }}" onInput="{{ onT }}" autocapitalize="words"></div>
      <div style="display:flex;gap:12px;padding-top:22px">
        <sc-for list="{{ months }}" as="m" hint-placeholder-count="2">
          <button class="press" style="flex:1;min-height:44px;border:1px solid var(--rule);
                  border-radius:3px;padding:10px 12px;text-align:left">
            <span class="t-micro" style="display:block;color:var(--secondary)">{{ m.label }}</span>
            <span class="t-data" style="display:block;padding-top:3px">{{ m.value }}</span>
          </button>
        </sc-for>
      </div>
      <p class="t-meta" style="margin:14px 0 0;color:var(--secondary);text-wrap:pretty">
        Positions must sit inside the chapter's own dates, and they may not
        overlap each other. One person does not hold two titles at one business
        at one time, and a record that allowed it could not be read back in order.</p>
    </div>
  </main>
  <div class="actions">
    <button class="btn-primary press">Add the position</button>
  </div>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {title:'Line lead'}; }
  renderVals(){
    return { title: this.state.title, onT: (e) => this.setState({title:e.target.value}),
             months: [{label:'From', value:'Jun 2020'}, {label:'To', value:'Sep 2021'}] };
  }
}
</script>
</body>
</html>
