extends Node
var players: Array[AudioStreamPlayer] = []
var streams := {}
var cursor := 0
var ambience: AudioStreamPlayer
func _ready() -> void:
 ambience = AudioStreamPlayer.new()
 var loop: AudioStreamWAV = load("res://assets/audio/ambience.wav").duplicate()
 loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
 loop.loop_begin = 0
 loop.loop_end = int(loop.get_length()*loop.mix_rate)
 ambience.stream = loop
 ambience.volume_db = -20
 add_child(ambience)
 if DisplayServer.get_name() != "headless": ambience.play()
 for cue in ["harvest","wood","stone","water","card","legendary","reaction","place","evolve","fusion","pulse"]:
  streams[cue] = load("res://assets/audio/"+cue+".wav")
 for i in range(4):
  var player := AudioStreamPlayer.new()
  player.volume_db = -10
  add_child(player)
  players.append(player)
func play(cue: String) -> void:
 if DisplayServer.get_name() == "headless" or not streams.has(cue) or players.is_empty(): return
 var player := players[cursor]
 cursor = (cursor+1)%players.size()
 player.stream = streams[cue]
 player.play()

func _exit_tree() -> void:
 if ambience != null:
  ambience.stop()
  ambience.stream = null
 for player in players:
  player.stop()
  player.stream = null
 streams.clear()
