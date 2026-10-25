extends RefCounted
# Read-only guidance. WorldModel.fuse remains the sole commit/validation path.
const OFFSETS = [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]
static func options(model, selected: String) -> Array:
 var found := []
 for recipe in model.config.fusions:
  var origins := {}
  for key in model.state.tiles:
   if model.state.tiles[key].get("type","") != recipe.type: continue
   for offset in OFFSETS: origins[model.key(model.coord(key)-offset)] = true
  var best := {}
  for origin in origins:
   var cells: Array[String] = []
   var matches := 0
   var blocked := false
   var wait := 0
   var has_selected := false
   for offset in OFFSETS:
    var key: String = model.key(model.coord(origin)+offset)
    cells.append(key)
    if key == selected: has_selected = true
    var tile: Dictionary = model.state.tiles.get(key,{})
    if tile.get("type","") == recipe.type and tile.get("size",0) == 1 and not tile.has("owner"):
     matches += 1
     for boost in tile.get("boosts",[]): wait = maxi(wait,ceili(maxf(0,boost.until-model.state.time)))
     if model.state.event.targets.has(key): blocked = true
   var ready: bool = model.can_fuse(origin)
   var score: float = matches*100+(1000 if ready else 0)+(20 if has_selected else 0)-Vector2(model.coord(origin)-model.coord(selected)).length()
   var reason := "Ready to combine. Four cells become one sanctuary; discoveries are kept."
   if not ready:
    if matches < 4: reason = "Need %d more matching tiles inside this exact square. Four tiles in a row do not count." % (4-matches)
    elif wait > 0: reason = "Pulse boosts are active. Wait %ds before combining." % wait
    elif blocked: reason = "Dusk Tide covers this group. Finish the event before combining."
    else: reason = "This group is not ready yet."
   var option := {"at":origin,"cells":cells,"type":recipe.type,"recipe":recipe,"matches":matches,"ready":ready,"score":score,"reason":reason}
   if best.is_empty() or score > best.score: best = option
  if not best.is_empty(): found.append(best)
 found.sort_custom(func(a,b): return a.score > b.score)
 return found
