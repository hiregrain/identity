<!doctype html>
<html>
<head><meta charset="utf-8"><script src="./support.js"></script></head>
<body>
<x-dc>
<helmet><style>@@CSS@@</style></helmet>
<!-- Option A is the shipped screen itself, mounted rather than copied, so the
     baseline in this comparison can never drift from the real one. -->
<div style="width:360px;height:800px;position:relative;overflow:hidden">
  <dc-import name="Handle" hint-size="360px,800px"></dc-import>
</div>
</x-dc>
<script data-dc-script data-props='{"$preview":{"width":360,"height":800}}'>
class Component extends DCLogic { renderVals(){ return {}; } }
</script>
</body>
</html>
