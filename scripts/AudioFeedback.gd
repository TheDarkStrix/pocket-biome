extends Node
var players: Array[AudioStreamPlayer] = []
var streams := {}
var cursor := 0
var ambience: AudioStreamPlayer
var effects_level := 1.0
var music_level := 1.0
var duck := 0.0
var suspended := false
var clock := 0.0
var last_cues := {}
var cue_count := 0
var priorities := {}
func _ready() -> void:
 ambience = AudioStreamPlayer.new()
 var loop: AudioStreamWAV = load("res://assets/audio/ambience.wav").duplicate()
 loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
 loop.loop_begin = 0
 loop.loop_end = int(loop.get_length()*loop.mix_rate)
 ambience.stream = loop
 add_child(ambience)
 if DisplayServer.get_name() != "headless": ambience.play()
 for cue in ["harvest","wood","stone","water","card","legendary","reaction","place","evolve","fusion","pulse","restoration","visitor"]:
  streams[cue] = load("res://assets/audio/"+cue+".wav")
 for i in range(4):
  var player := AudioStreamPlayer.new()
  add_child(player)
  players.append(player)
 configure(1,1)
func configure(effects: float, music: float) -> void:
 effects_level = clampf(effects,0,1)
 music_level = clampf(music,0,1)
 for player in players: player.volume_db = -80 if effects_level <= 0 else -10+linear_to_db(effects_level)
 update_mix()
func set_suspended(value: bool) -> void:
 if suspended == value: return
 suspended = value
 if suspended:
  for player in players: player.stop()
 update_mix()
func update_mix() -> void:
 if ambience == null: return
 ambience.volume_db = -80 if music_level <= 0 else -20+linear_to_db(music_level)-6*smoothstep(0,0.35,duck)
 ambience.stream_paused = suspended or music_level <= 0
func _process(delta: float) -> void:
 if suspended: return
 clock += maxf(delta,0)
 duck = maxf(0,duck-minf(delta,0.1))
 update_mix()
func request(cue: String) -> Dictionary:
 if suspended or effects_level <= 0 or not streams.has(cue): return {}
 var important := cue in ["restoration","legendary","fusion"]
 var cooldown := 0.35 if important else 0.07
 if clock-last_cues.get(cue,-100.0) < cooldown: return {}
 var priority := 2 if important else 1
 var chosen := -1
 for i in range(players.size()):
  var index := (cursor+i)%players.size()
  if not players[index].playing or priorities.get(index,0) < priority:
   chosen = index; break
 if chosen < 0: return {}
 cursor = (chosen+1)%players.size()
 priorities[chosen] = priority
 last_cues[cue] = clock
 cue_count += 1
 if important: duck = 1.5; update_mix()
 return {"player":chosen,"pitch":1.0 if important else 0.97+float(cue_count%5)*0.015}
func play(cue: String) -> void:
 var admitted := request(cue)
 if admitted.is_empty() or DisplayServer.get_name() == "headless": return
 var player := players[admitted.player]
 player.stream = streams[cue]
 player.pitch_scale = admitted.pitch
 player.play()
func _exit_tree() -> void:
 if ambience != null:
  ambience.stop()
  ambience.stream = null
 for player in players:
  player.stop()
  player.stream = null
 streams.clear()
