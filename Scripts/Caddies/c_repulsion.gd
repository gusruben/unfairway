extends Node

var card_name = "Repulsion Field"

func _ready():
	CaddyManager.impls[card_name] = self

func on_pick(player: golfball):
	var circle = player.find_child("RepulsionCircle")
	circle.visible = true
	circle.play(player.color)
	
	if player.stats.c_repulsion_strength == 0:
		player.stats.c_repulsion_strength = 8
	else:
		player.stats.c_repulsion_strength += 8
	if player.stats.c_repulsion_radius == 0:
		player.stats.c_repulsion_radius = 150
	else:
		player.stats.c_repulsion_radius += 50
		
	circle.scale = Vector2.ONE * (player.stats.c_repulsion_radius / 150.0) * 2

func on_ability(player: golfball):
	pass
