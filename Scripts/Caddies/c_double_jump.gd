extends Node

var card_name = "Double Jump"

const DoubleJumpEffect = preload("res://Scenes/Particles/DoubleJump.tscn")

func _ready():
	CaddyManager.impls[card_name] = self

func on_pick(player: golfball):
	player.stats.s_ability_cooldown += 0.5

func on_ability(player: golfball):
	if !player.has_dash: # dash sound effect takes priority
		GameManager.jump_sound.play()
		
	# particles
	var particles = DoubleJumpEffect.instantiate()
	get_tree().current_scene.add_child(particles)
	particles.global_position = player.global_position
	particles.play()
	
	if player.linear_velocity.y > 10:
		player.set_axis_velocity(Vector2(0, -500))
	else:
		player.apply_central_impulse(Vector2(0, -30))
