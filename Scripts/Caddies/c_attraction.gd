extends Node

var card_name = "Gravity Well"

func _ready():
	CaddyManager.impls[card_name] = self

func on_pick(player: golfball):
	var texture = player.find_child("AttractionOverlay")
	texture.visible = true
	texture.play(player.color)

	player.stats.s_ability_cooldown += 3
	
	if 	player.stats.c_attraction_strength == 0:
		player.stats.c_attraction_strength = 10
	else:
		player.stats.c_attraction_strength += 5

func on_ability(player: golfball):
	create_tween().tween_property(player.find_child("AttractionOverlay"), "modulate:a", 1, 1)
	player.is_attracting = true
	await get_tree().create_timer(5).timeout
	if !player || player.is_queued_for_deletion():
		return
	
	player.is_attracting = false
	create_tween().tween_property(player.find_child("AttractionOverlay"), "modulate:a", 0, 1)
