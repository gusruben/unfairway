extends Node

var card_name = "Bouncy Ball"
var bounce_increases = [0.4, 0.25, 0.1]

func _ready():
	CaddyManager.impls[card_name] = self

func on_pick(player: golfball):
	var bounce_cards_taken = 0
	for card in player.caddies:
		if card == card_name:
			bounce_cards_taken += 1
	
	if bounce_cards_taken < len(bounce_increases):
		player.stats.s_bounce += bounce_increases[bounce_cards_taken]
	else:
		player.stats.s_bounce += 0.05

func on_ability(player: golfball):
	pass
