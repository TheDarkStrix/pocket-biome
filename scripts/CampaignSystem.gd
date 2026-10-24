extends RefCounted
# Composition service: every operation receives the authoritative model explicitly.
static func defaults() -> Dictionary:
 return {"audio_levels":{"music":0.6,"sfx":0.8},"text_scale":1.0,"hints":{},"chapter":1,"chapter_rewards":[],"stats":{"pulses":0,"fusions":0,"automation_coins":0,"crafted_brick":0,"built_golem":0,"built_windmill":0},"jobs":[],"blueprints":{},"next_job":1,"settings":{"vibration":true,"sfx":true,"music":true,"reduced_motion":false,"analytics":false,"tutorial_seen":false,"challenge_events":true},"event":{"next_at":300.0,"until":0.0,"targets":[],"cleared":[],"applied":{},"completed":0},"reward_requests":{},"reward_limits":{"day":0,"count":0},"entitlements":[],"transactions":[],"cosmetic":"day"}

func chapter_definition(m) -> Dictionary:
 return m.config.chapters[clampi(int(m.state.chapter)-1,0,4)]

func metric(m, id: String) -> int:
 if id == "cells": return m.state.tiles.size()
 if id == "discoveries": return m.state.discoveries.size()
 if id in ["harvests","expansions"]: return int(m.state[id])
 return int(m.state.stats.get(id,0))

func chapter_progress(m) -> String:
 var definition := chapter_definition(m)
 var text: String = definition.hint+"\n"
 for id in definition.checks: text += "%s %d/%d   " % [id.replace("_"," "),mini(metric(m,id),definition.checks[id]),definition.checks[id]]
 return text

func evaluate(m) -> void:
 var definition := chapter_definition(m)
 var complete := true
 for id in definition.checks:
  if metric(m,id) < definition.checks[id]: complete = false
 if not complete or m.state.chapter_rewards.has(int(m.state.chapter)): return
 m.state.chapter_rewards.append(int(m.state.chapter))
 m.record_event("chapter_completed",{"chapter":m.state.chapter})
 m.state.coins += int(definition.reward)
 m.state.inventory.star_dew = mini(m.config.economy.inventory_limit,m.state.inventory.star_dew+2)
 m.state.energy = mini(200,m.state.energy+100)
 m.message = "CHAPTER COMPLETE · "+definition.name
 if m.state.chapter < 5: m.state.chapter += 1

func has_structure(m, type: String) -> bool:
 if type == "hand": return true
 for key in m.state.tiles:
  if m.state.tiles[key].get("type","") == type: return true
 return false

func craft(m, recipe_id: String, quantity: int = 1) -> bool:
 if quantity < 1 or quantity > 3: return false
 for recipe in m.config.crafting:
  if recipe.id != recipe_id: continue
  if recipe.has("entitlement") and not m.state.entitlements.has(recipe.entitlement):
   m.message = "This is a cosmetic item from the Founder collection."
   return false
  if not has_structure(m,recipe.requires):
   m.message = "Needs a "+recipe.requires.capitalize()+" on the island."
   return false
  if recipe.has("tile") and m.state.blueprints.get(recipe.tile,0)+quantity > 10000: return false
  if m.state.jobs.size() >= 3:
   m.message = "Three projects are already in progress."
   return false
  var cost: Dictionary = recipe.cost.duplicate()
  for resource in cost: cost[resource] = int(cost[resource])*quantity
  if not m.spend(cost):
   m.message = "Gather the listed materials first."
   return false
  m.state.jobs.append({"id":m.state.next_job,"recipe":recipe_id,"until":m.state.time+crafting_seconds(m,recipe)*quantity,"quantity":quantity})
  m.state.next_job += 1
  m.message = "Crafting · "+recipe.name
  return true
 return false

func deploy(m, blueprint: String, at: String) -> bool:
 # Explicit replacement of an empty meadow only, never an occupied structure/resource.
 if not m.state.pending.is_empty() or not m.state.tiles.has(at): return false
 var tile: Dictionary = m.state.tiles[at]
 if tile.has("owner") or tile.type != "grass" or tile.evolution != "" or tile.size != 1: return false
 if m.state.blueprints.get(blueprint,0) < 1 or not m.config.tiles.has(blueprint): return false
 if m.state.event.targets.has(at): return false
 m.state.blueprints[blueprint] -= 1
 m.add_tile(m.coord(at),blueprint)
 m.message = "Built · "+blueprint.capitalize()
 return true

func tick(m) -> void:
 for job in m.state.jobs.duplicate():
  if job.until > m.state.time: continue
  var recipe: Dictionary = {}
  for candidate in m.config.crafting:
   if candidate.id == job.recipe: recipe = candidate
  if recipe.has("tile"):
   var id: String = recipe.tile
   m.state.blueprints[id] = int(m.state.blueprints.get(id,0))+int(job.get("quantity",1))
  else:
   var room := true
   for resource in recipe.output:
    if m.state.inventory[resource]+recipe.output[resource]*int(job.get("quantity",1)) > m.config.economy.inventory_limit: room = false
   if not room: continue
   for resource in recipe.output:
    m.state.inventory[resource] += int(recipe.output[resource])*int(job.get("quantity",1))
    m.state.stats["crafted_"+resource] = int(m.state.stats.get("crafted_"+resource,0))+int(recipe.output[resource])*int(job.get("quantity",1))
  m.state.jobs.erase(job)
  m.message = "Ready · "+recipe.name
 var keys: Array = m.state.tiles.keys()
 keys.sort()
 for key in keys:
  var tile: Dictionary = m.state.tiles[key]
  if tile.has("owner") or not tile.get("enabled",true): continue
  var interval: int = m.config.tiles[tile.type].get("interval",0)
  if interval <= 0 or tile.get("next_production",m.state.time+interval) > m.state.time: continue
  if tile.type == "furnace": interval = maxi(1,ceili(float(interval)/int(tile.get("level",1))))
  tile.next_production = m.state.time+interval
  match tile.type:
   "windmill":
    var output: int = tile.get("level",1)
    m.state.coins += output
    m.state.stats.automation_coins += output
   "golem":
    var harvested := 0
    for neighbor in m.neighbors(key):
     if m.state.tiles[neighbor].type in ["stone","iron"] and m.state.tiles[neighbor].ready <= m.state.time:
      if m.harvest(neighbor,true):
       harvested += 1
       if harvested >= int(tile.get("level",1)): break
   "totem":
    for neighbor in m.neighbors(key): m.state.tiles[neighbor].ready = maxf(m.state.time,m.state.tiles[neighbor].ready-2*int(tile.get("level",1)))
   "furnace":
    if m.state.jobs.size() < 3 and m.state.inventory.stone >= 2 and m.state.inventory.wood >= 1:
     craft(m,"brick")
 event_tick(m)
 evaluate(m)

func start_event(m) -> bool:
 if m.state.chapter < 3 or not m.state.settings.challenge_events: return false
 var event: Dictionary = m.state.event
 if event.until > 0 or m.state.time < event.next_at: return false
 var candidates := []
 for key in m.state.tiles:
  var tile: Dictionary = m.state.tiles[key]
  if tile.has("owner") or tile.size != 1: continue
  if m.config.tiles[tile.type].resource != "": continue
  candidates.append(key)
 candidates.sort()
 if candidates.size() < 2:
  m.message = "Dusk needs two non-resource tiles; your harvest nodes stay safe."
  return false
 event.targets = [candidates[0],candidates[1]]
 event.cleared = []
 event.applied = {}
 event.until = m.state.time+60
 for key in event.targets:
  var dna: Dictionary = m.state.tiles[key].dna
  var applied: int = mini(20,dna.heat)
  event.applied[key] = applied
  dna.heat -= applied
 m.message = "DUSK TIDE · Warm the two marked tiles with Heat or a Rain Totem."
 return true

func clear_event_target(m, key: String) -> void:
 var event: Dictionary = m.state.event
 if event.until <= 0 or not event.targets.has(key) or event.cleared.has(key): return
 if m.state.tiles.has(key):
  var tile: Dictionary = m.state.tiles[key]
  if tile.has("dna"): tile.dna.heat = clampi(tile.dna.heat+event.applied.get(key,0),0,100)
 event.cleared.append(key)

func event_tick(m) -> void:
 var event: Dictionary = m.state.event
 if event.until <= 0: return
 for key in event.targets:
  for neighbor in m.neighbors(key):
   if m.state.tiles[neighbor].type == "totem": clear_event_target(m,key)
 var success: bool = event.cleared.size() == event.targets.size()
 if not success and m.state.time < event.until: return
 for key in event.targets: clear_event_target(m,key)
 if success:
  event.completed += 1
  m.state.coins += 15
  m.state.inventory.star_dew = mini(m.config.economy.inventory_limit,m.state.inventory.star_dew+1)
  m.message = "DUSK RESTORED · +15 coins, +1 Star Dew"
 else: m.message = "Dusk passed peacefully. Your island is safe."
 event.until = 0.0
 event.next_at = m.state.time+300
 event.targets = []
 event.cleared = []
 event.applied = {}

func retire(m, at: String) -> bool:
 if at in ["0,0","1,0","0,1"] or not m.state.pending.is_empty() or m.state.event.targets.has(at): return false
 if not m.state.tiles.has(at): return false
 var tile: Dictionary = m.state.tiles[at]
 if tile.has("owner") or tile.size != 1 or (tile.type == "grass" and tile.evolution == ""): return false
 if m.config.tiles[tile.type].category == "structure":
  m.state.blueprints[tile.type] = int(m.state.blueprints.get(tile.type,0))+1
 m.add_tile(m.coord(at),"grass")
 m.message = "Meadow restored. Your discoveries remain in the Codex."
 return true

func trade(m, resource: String, quantity: int) -> bool:
 if quantity <= 0 or resource not in ["wood","stone","fiber","clay","iron","brick"]: return false
 if not m.spend({resource:quantity}): return false
 m.state.coins += quantity
 m.message = "Traded %d %s for %d coins" % [quantity,resource,quantity]
 return true

func toggle_automation(m, at: String) -> bool:
 if not m.state.tiles.has(at): return false
 var tile: Dictionary = m.state.tiles[at]
 if tile.has("owner") or m.config.tiles[tile.type].category != "structure": return false
 tile.enabled = not tile.get("enabled",true)
 return true

func upgrade_structure(m, at: String) -> bool:
 if not m.state.tiles.has(at): return false
 var tile: Dictionary = m.state.tiles[at]
 if tile.has("owner") or m.config.tiles[tile.type].category != "structure": return false
 var level: int = tile.get("level",1)
 if not m.config.tiles[tile.type].get("upgradeable",true): return false
 if level >= 3 or not m.spend(m.config.upgrades[str(level)]): return false
 tile.level = level+1
 m.message = "%s upgraded to level %d" % [tile.type.capitalize(),tile.level]
 m.record_event("structure_upgraded",{"type":tile.type,"level":tile.level})
 return true

func crafting_seconds(m, recipe: Dictionary) -> float:
 var level := 1
 if recipe.requires != "hand":
  for tile in m.state.tiles.values():
   if tile.get("type","") == recipe.requires: level = maxi(level,int(tile.get("level",1)))
 return float(recipe.seconds)/level
