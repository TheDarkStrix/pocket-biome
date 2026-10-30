extends "res://scripts/Main.gd"
# Synthetic display metrics only; gameplay/input use the real inherited code.
func _init() -> void: orbit_enabled = false
var display_dp := 1.6875
func logical_per_dp() -> float:
 return display_dp
