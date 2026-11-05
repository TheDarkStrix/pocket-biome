extends RefCounted
const DESCRIPTIONS = {"dry_springs":"Long water channels · earned channels can reach Water through three natural-land steps.","frost_hollow":"A second shade slot · shelter two plots once you earn the Shade canopy.","ember_shore":"A second warmth slot · warm two plots once you earn the Warmth lantern.","river_link":"Firefly lantern · an earned decoration for your home, using no habitat space."}
static func done_state(state: Dictionary, id: String) -> bool: return state.get("expeditions",{}).get(id,{}).get("completed",false)
static func done(m, id: String) -> bool: return done_state(m.state,id)
static func water_reach(m) -> int: return 3 if done(m,"dry_springs") else 2
static func slots(state: Dictionary, mode: String) -> int:
 if state.get("habitat_projects",[]).has("sanctuary_network"): return 2
 if mode == "shade" and done_state(state,"frost_hollow"): return 2
 if mode == "warmth" and done_state(state,"ember_shore"): return 2
 return 1
