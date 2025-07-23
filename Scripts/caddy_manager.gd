extends Node

var p1_caddies = []
var p2_caddies = []

func create_stats():
	return {
		"s_swing_force" : 12,
		"s_bounce" : 0.2,
		"s_mass" : 0.043,
		"s_scale" : 1,
		"s_ability_cooldown" : 5,
		
		# card stats
		"c_repulsion_strength": 0.0,
		"c_repulsion_radius": 0.0,
		"c_attraction_strength": 0.0,
	}

var p1_stats = create_stats()
var p2_stats = create_stats()

var impls = {}

func on_card_pick(card, player):
	print("player ", player+1, " picked ", card)
	if player == GameManager.PLAYER_TYPES.PLAYER1:
		p1_caddies.push_back(card.name)
		impls[card.name].on_pick(GameManager.get_plr(player))
	else:
		p2_caddies.push_back(card.name)
		impls[card.name].on_pick(GameManager.get_plr(player))
	
func on_ability(player):
	#var thread = Thread.new()
	#thread.start(_cycle_abilities.bind(player))
	_cycle_abilities(player)

func _cycle_abilities(player):
	print("cycling", player, GameManager.get_plr(player))
	if player == GameManager.PLAYER_TYPES.PLAYER1:
		for card in p1_caddies:
			impls[card].on_ability(GameManager.get_plr(player))
			await get_tree().create_timer(0.1).timeout
	else:
		for card in p2_caddies:
			impls[card].on_ability(GameManager.get_plr(player))
			await get_tree().create_timer(0.1).timeout
