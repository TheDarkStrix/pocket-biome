extends RefCounted
# Cosmetic state only. No rewards, timers, saves or occupancy are owned here.
var known := {}
var appearances := {}
var animations := {}
var initialized := false
var cues: Array[String] = []
var weather := []
var harvests := []
func sync(tiles: Dictionary) -> void:
 cues.clear()
 var next := {}
 var next_appearances := {}
 for key in tiles:
  var tile: Dictionary = tiles[key]
  if tile.has("owner"): continue
  var signature := "%s:%s:%s" % [tile.id,tile.evolution,tile.size]
  next[key] = signature
  next_appearances[key] = {"type":tile.type,"evolution":tile.evolution,"size":tile.size}
  if initialized and known.get(key,"") != signature:
   var kind := "place" if not known.has(key) else ("fusion" if tile.size == 4 else "evolve")
   animations[key] = {"kind":kind,"elapsed":0.0,"duration":0.55 if kind == "place" else 1.4}
   animations[key]["previous"] = appearances.get(key,{})
   var parts := []
   if kind == "fusion":
    var pair: PackedStringArray = key.split(",")
    var origin := Vector2i(int(pair[0]),int(pair[1]))
    for offset in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]:
     var at: Vector2i = origin+offset
     var old_key := "%d,%d" % [at.x,at.y]
     if appearances.has(old_key):
      var part: Dictionary = appearances[old_key].duplicate()
      part["key"] = old_key
      parts.append(part)
   animations[key]["parts"] = parts
   cues.append(kind)
 known = next
 appearances = next_appearances
 initialized = true
 for key in animations.keys():
  if not next.has(key): animations.erase(key)

func advance(delta: float) -> bool:
 var was_animating := not animations.is_empty() or not weather.is_empty() or not harvests.is_empty()
 for effect in weather.duplicate():
  effect.elapsed += delta
  if effect.elapsed >= effect.duration: weather.erase(effect)
 for effect in harvests.duplicate():
  effect.elapsed += delta
  if effect.elapsed >= 0.8: harvests.erase(effect)
 for key in animations.keys():
  animations[key].elapsed += maxf(0,delta)
  if animations[key].elapsed >= animations[key].duration: animations.erase(key)
 return was_animating

func pose(key: String) -> Dictionary:
 if not animations.has(key): return {"scale":1.0,"rise":0.0,"burst":0.0,"mix":1.0,"previous":{},"parts":[],"progress":1.0}
 var animation: Dictionary = animations[key]
 var t: float = clampf(animation.elapsed/animation.duration,0,1)
 var eased := 1.0-pow(1.0-t,3)
 var amount := 0.25 if animation.kind == "place" else 0.12
 return {"scale":1.0-amount*(1-eased)+sin(t*PI)*0.08,"rise":-28.0*(1-eased),"burst":sin(t*PI),"mix":eased if animation.kind == "evolve" else (clampf((t-0.25)/0.55,0,1) if animation.kind == "fusion" else 1.0),"previous":animation.previous,"parts":animation.parts,"progress":t}

func pulse(power: String, key: String, targets: Array = []) -> void:
 if weather.size() >= 2: weather.pop_front()
 weather.append({"power":power,"key":key,"targets":targets.duplicate(),"elapsed":0.0,"duration":3.2})
func harvest(key: String, text: String, resource: String = "") -> void:
 if harvests.size() >= 12: harvests.pop_front()
 harvests.append({"key":key,"text":text,"resource":resource,"elapsed":0.0})
