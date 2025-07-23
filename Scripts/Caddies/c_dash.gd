extends Node

var card_name = "Dash"

func _ready():
	CaddyManager.impls[card_name] = self

func on_pick(player: golfball):
	print("got dash", player)
	player.stats.s_ability_cooldown += 0.5
	player.has_dash = true

func on_ability(player: golfball):
	GameManager.dash_sound.play()
	player.is_dashing = true
	if player.linear_velocity.length() < 100:
		player.set_axis_velocity(player.linear_velocity.normalized()*60)
	else:
		player.apply_central_impulse(player.linear_velocity.normalized()*30)
