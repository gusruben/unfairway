extends Node

var card_name = "Small Ball"

func _ready():
	CaddyManager.impls[card_name] = self

func on_pick(player: golfball):
	player.stats.s_scale -= player.stats.s_scale*0.15
	player.stats.s_mass -= player.stats.s_mass*0.1
	player.stats.s_swing_force -= player.stats.s_swing_force*0.1

func on_ability(player: golfball):
	pass
