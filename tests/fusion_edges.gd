extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
var checks := 0
var failures := 0
func check(ok: bool, text: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+text)
func _init() -> void:
 var m = Model.new()
 m.state.tiles.clear()
 for c in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: m.add_tile(c,"forest")
 m.harvest("1,1")
 check(m.fuse("0,0"),"fusion with cooling component succeeds")
 check(not m.harvest("0,0"),"fusion cannot reset harvested component cooldown")
 m.add_tile(Vector2i(2,1),"water")
 var before: int = m.state.tiles["0,0"].dna.moisture
 m.tick()
 check(m.state.tiles["0,0"].dna.moisture == before+8,"far footprint edge receives water")
 check(m.state.tiles["0,0"].evolution == "grove","ordinary recipes cannot replace fused evolution")
 check(m.neighbors("0,0") == ["2,1"],"footprint excludes self reservations")
 m.state.energy = 200
 check(m.pulse_targets("1,1").has("2,1"),"pulse preview uses entire selected entity")
 var wet: int = m.state.tiles["2,1"].dna.moisture
 m.pulse("rain","0,0")
 check(m.state.tiles["2,1"].dna.moisture > wet,"pulse reaches far entity boundary")
 check(m.state.tiles["0,0"].boosts.size() == 1,"reserved cells do not duplicate pulse")
 var r = Model.new()
 r.state.energy = 200
 r.state.tiles["0,0"].dna.moisture = 95
 r.pulse("rain","0,0")
 check(r.state.tiles["0,0"].dna.moisture == 100,"pulse saturation")
 r.state.time += 12
 r.expire_boosts()
 check(r.state.tiles["0,0"].dna.moisture == 95,"expiry subtracts actual applied boost")
 print("FUSION RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
