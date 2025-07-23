extends Node

var card_name = "Big Arm"

func _ready():
	CaddyManager.impls[card_name] = self

func on_pick(player: golfball):
	player.stats.s_swing_force += player.stats.s_swing_force*0.2

func on_ability(player: golfball):
	pass
