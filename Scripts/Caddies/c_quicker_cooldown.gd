extends Node

var card_name = "Quicker Cooldown"

func _ready():
	CaddyManager.impls[card_name] = self

func on_pick(player: golfball):
	player.stats.s_mass += player.stats.s_mass*0.1
	player.stats.s_ability_cooldown -= 0.5

func on_ability(player: golfball):
	pass
