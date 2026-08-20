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

<!-- G2. On or off, imprint or not, and a preview. 056 makes it off by
     default, so this screen is where publication is an act rather than a
     state somebody discovers. The preview matters: nobody should publish a
     page they have not read. -->
<div style="width:100%;height:100%;min-height:752px;position:relative;overflow:hidden;background:var(--paper)">
  <header class="pushhead">
    <button class="iconbtn press" aria-label="Back to sharing">
      <svg width="22" height="22" viewBox="0 0 24 24"><use href="#i-back"></use></svg>
    </button>
    <h1 class="t-serial" style="margin:0">Your public page</h1>
  </header>

  <main class="dissolve" style="position:absolute;top:52px;bottom:0;left:0;right:0;overflow-y:auto;padding:0 20px 32px">
    <div style="padding:24px 0 16px;border-bottom:1px solid var(--ink)">
      <p class="t-lead" style="margin:0;line-height:1.35;text-wrap:pretty">{{ headline }}</p>
      <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-wrap:pretty">
        hiregrain.com/u/liezel-mendoza. The address is yours whether the page is
        on or off, and it never goes to anyone else.</p>
    </div>

    <div class="grp">
      <div class="srow">
        <span style="flex:1;min-width:0">
          <span class="t-body" style="display:block">Publish the page</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">Anyone who has the address can open it, including a search engine.</span>
        </span>
        <button class="sw press" role="switch" aria-checked="{{ pageOn }}" aria-label="Publish the page"
                onClick="{{ pageOnGo }}"><i></i></button>
      </div>
      <div class="srow">
        <span style="flex:1;min-width:0">
          <span class="t-body" style="display:block">Draw the imprint on it</span>
          <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">Shown to anyone who opens the page, and never in search results, because an indexed figure cannot be taken back.</span>
        </span>
        <button class="sw press" role="switch" aria-checked="{{ figOn }}" aria-label="Draw the imprint on it"
                onClick="{{ figOnGo }}"><i></i></button>
      </div>
    </div>

    <div class="grp">
      <div class="sechead"><h3 class="t-sec" style="margin:0">What it will show</h3></div>
      <sc-for list="{{ facts }}" as="f" hint-placeholder-count="4">
        <div class="srow">
          <span style="flex:1;min-width:0">
            <span class="t-body" style="display:block;text-wrap:pretty">{{ f.label }}</span>
            <span class="t-meta" style="display:block;color:var(--secondary);padding-top:2px;text-wrap:pretty">{{ f.note }}</span>
          </span>
          <span class="t-data col-r" style="color:{{ f.color }}">{{ f.state }}</span>
        </div>
      </sc-for>
    </div>

    <div class="grp">
      <button class="btn-secondary press" style="width:100%">Read it as a stranger would</button>
      <p class="t-meta" style="margin:10px 0 0;color:var(--secondary);text-align:center;text-wrap:pretty">
        Opens the page exactly as somebody with no Grain account sees it.</p>
    </div>
  </main>

</div>
@@ICONS@@
</x-dc>

<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic {
  constructor(p){ super(p); this.state = {page:false, fig:true}; }
  renderVals(){
    return {
      headline: this.state.page
        ? 'Your page is on. Anyone with the address can read it.'
        : 'Your page is off. Nobody reaches your record by searching for you.',
      pageOn: this.state.page ? 'true' : 'false',
      pageOnGo: () => this.setState({page: !this.state.page}),
      figOn: this.state.fig ? 'true' : 'false',
      figOnGo: () => this.setState({fig: !this.state.fig}),
      facts: [
        {label:'Chapters, parties and dates', note:'Who you worked for, when, and in what position.', state:'Always', color:'var(--ink)'},
        {label:'Which party attested each chapter', note:'The business, a coworker the worker named, or none.', state:'Always', color:'var(--ink)'},
        {label:'Your imprint', note:'Only to someone who opens the page.', state: this.state.fig ? 'Visitors' : 'Off', color:'var(--ink)'},
        {label:'Your phone and email', note:'Never on a page and never in anything you send.', state:'Never', color:'var(--secondary)'}
      ]
    };
  }
}
</script>
</body>
</html>
