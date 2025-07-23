extends Node

enum GAME_STATES {
	TITLE_SCREEN,
	GAMEPLAY,
	WIN_ANIMATION,
	PICKING_CARD
}

enum PLAYER_TYPES {
	PLAYER1,
	PLAYER2
}

var game_state: GAME_STATES = GAME_STATES.TITLE_SCREEN

var p1: golfball
var p2: golfball
var golf_hole: golfhole
var ui_control: ui

var p1_score = 0
var p2_score = 0

var picked_card = false

var maps = [
	load("res://Scenes/Courses/l1.tscn"),
	load("res://Scenes/Courses/l2.tscn"),
	load("res://Scenes/Courses/l3.tscn"),
]

var last_map: int = randi_range(0, maps.size())

var cur_map

const GAMES_TO_WIN = 10

# ability sounds, because they need to be in here for some reason or else it breaks sometimes
var dash_sound
var jump_sound

func _ready() -> void:
	randomize()
	
	cur_map = maps.pick_random().instantiate()
	add_child(cur_map)
	
	get_node("/root/").connect("ready", on_ready)
	
	dash_sound = $/root/Game/DashSound
	jump_sound = $/root/Game/DashSound
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BRACKETLEFT and Input.is_key_pressed(KEY_CTRL):
			p1.teleport(golf_hole.global_position)
		if event.keycode == KEY_BRACKETRIGHT and Input.is_key_pressed(KEY_CTRL):
			p2.teleport(golf_hole.global_position)
	
	if event.is_action_pressed("Fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	var give = $"/root/Game/Game-ui/GiveCardMenu" as TextEdit
	
	if event.is_action_pressed("Pause") and game_state == GAME_STATES.GAMEPLAY:
		get_viewport().set_input_as_handled() # prevent unpausing right away
		
		# escape also exits the dev menu
		if give.visible:
			give.text = ""
			give.release_focus()
			give.visible = false
			return
		
		if get_tree().paused:
			$/root/Game/Pause.unpause()
		else:
			$/root/Game/Pause.pause()
			
	if event.is_action_pressed("Dev") and Input.is_key_pressed(KEY_CTRL) and game_state == GAME_STATES.GAMEPLAY:
		get_viewport().set_input_as_handled() # don't type the char in the textbox
		CursorManager.default()
		give.visible = true
		give.grab_focus()

func on_game_start():
	game_state = GAME_STATES.GAMEPLAY

func on_ready() -> void:
	assert(p1 != null)
	assert(p2 != null)
	assert(golf_hole != null)
	assert(cur_map != null)
	assert(ui_control != null)
	assert(CaddyManager != null)
	assert(Items != null)
	
	ui_control.connect("card_picked", on_card_picked)
	get_node("/root/Game/End-screen").connect("playagain_pressed", on_playagain_pressed)
	get_node("/root/Game/End-screen").connect("back_pressed", on_back_pressed)
	get_node("/root/Game/Pause").connect("back_pressed", on_back_pressed)
	
	# Pre-warm all particle systems after everything is initialized
	_prewarm_all_particles()

func on_goal(player: PLAYER_TYPES):
	game_state = GAME_STATES.WIN_ANIMATION
	
	# gray the bg
	var tween = create_tween()
	
	if player == PLAYER_TYPES.PLAYER1:
		p1_score += 1
		get_node("/root/Game/Game-ui/P1 Score").set_text(str(p1_score))
	else:
		p2_score += 1
		get_node("/root/Game/Game-ui/P2 Score").set_text(str(p2_score))
	
	if (p1_score >= GAMES_TO_WIN or p2_score >= GAMES_TO_WIN):
		$/root/Game/WinGameSound.play()
		GameManager.cur_map.find_child("Golf-hole").z_index = 0
		CursorManager.default()
		tween.tween_property($"/root/Game/Overlay", "modulate:a", 0.75, 0.25)
		if p1_score > p2_score:
			$"/root/Game/End-screen/Panel/Gameover".play("r")
			#$"/root/Game/Game-ui"
		else:
			$"/root/Game/End-screen/Panel/Gameover".play("b")
		$"/root/Game/End-screen/win-label".text = ("[color=#ff8080]Red" if p1_score > p2_score else "[color=#8080ff]Blue") + " Wins![/color]"
		$"/root/Game/End-screen".visible = true
		return
	else:
		$/root/Game/WinLevelSound.play()
		Engine.time_scale = 0.3
		tween.tween_property($"/root/Game/Overlay", "modulate:a", 0.75, 0.25)
		
	
	await get_tree().create_timer(0.5).timeout
	
	game_state = GAME_STATES.PICKING_CARD
	#CursorManager.default()

	Engine.time_scale = 1
	
	# move the whole map out of the way
	p1.freeze = true
	p2.freeze = true
	$/root/Game/SlideSound.play()
	create_tween().tween_property(cur_map, "global_position", cur_map.global_position + Vector2(0, 1000), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(p1, "global_position", p1.global_position + Vector2(0, 1000), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	create_tween().tween_property(p2, "global_position", p2.global_position + Vector2(0, 1000), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.9).timeout
	
	# swap the map while it's hidden
	var maps_index = range(maps.size())
	maps_index.pop_at(last_map)
	last_map = maps_index.pick_random()
	
	cur_map.queue_free()
	cur_map = maps[last_map].instantiate()
	cur_map.global_position.y += 1000
	add_child(cur_map)
	
	$/root/Game/MapSwitchSound.play()
	
	GameManager.cur_map.find_child("Golf-hole").z_index = 0
	picked_card = false
	ui_control.emit_signal(
		"begin_card_pick", 
		PLAYER_TYPES.PLAYER1 if player == PLAYER_TYPES.PLAYER2 else PLAYER_TYPES.PLAYER2
	)
	
	if player == PLAYER_TYPES.PLAYER1:
		$"/root/Game/Game-ui/Particles".play("blue")
	else:
		$"/root/Game/Game-ui/Particles".play("red")
	create_tween().tween_property($"/root/Game/Game-ui/Particles", "modulate:a", 1.0, 0.25)
		
	
func on_card_picked(card, player):
	if picked_card:
		return
	picked_card = true

	$"/root/Game/Select-Card-Sfx".play()

	# move the map back in
	($/root/Game/SlideReverseSound as AudioStreamPlayer2D).play(0.1)
	create_tween().tween_property(cur_map, "global_position", cur_map.global_position - Vector2(0, 1000), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.1).timeout
	p1.freeze = false
	p2.freeze = false
	#p1.global_position.y += 1000
	#p2.global_position.y += 1000
	
	create_tween().tween_property(p1, "global_position", p1.global_position - Vector2(0, 1000), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	create_tween().tween_property(p2, "global_position", p2.global_position - Vector2(0, 1000), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# hide the particles as the map comes in
	create_tween().tween_property($"/root/Game/Game-ui/Particles", "modulate:a", 0.0, 0.7)
	await get_tree().create_timer(0.9).timeout
	
	# de-gray the bg
	create_tween().tween_property($"/root/Game/Overlay", "modulate:a", 0.0, 0.25)
	
	game_state = GAME_STATES.GAMEPLAY
	CursorManager.hide()
	CaddyManager.on_card_pick(card, player)
	
	await get_tree().create_timer(0.25).timeout
	GameManager.cur_map.find_child("Golf-hole").z_index = 100
	p1.freeze = false
	p2.freeze = false
	
func on_playagain_pressed():
	$/root/Game/MenuSound.play()
	
	var wipe = $"/root/Game/Wipe"
	wipe.play("wipe")
	await get_tree().create_timer(1.0).timeout
	$"/root/Game/End-screen".visible = false

	Engine.time_scale = 1
	p1_score = 0
	p2_score = 0
	get_node("/root/Game/Game-ui/P1 Score").set_text(str(p1_score))
	get_node("/root/Game/Game-ui/P2 Score").set_text(str(p1_score))
	
	var maps_index = range(maps.size())
	maps_index.pop_at(last_map)
	last_map = maps_index.pick_random()
	
	cur_map.queue_free()
	cur_map = maps[last_map].instantiate()
	add_child(cur_map)
	game_state = GAME_STATES.GAMEPLAY
	CursorManager.hide()
	
	$"/root/Game/Overlay".modulate.a = 0
	wipe.play_backwards("wipe")
	$/root/Game/WipeOutSound.play()

func on_back_pressed():
	var wipe = $"/root/Game/Wipe"
	wipe.play("wipe")
	await get_tree().create_timer(1.0).timeout
	$"/root/Game/End-screen".visible = false
	$"/root/Game/Pause".visible = false
	
	CaddyManager.p1_stats = CaddyManager.create_stats()
	p1.stats = CaddyManager.p1_stats
	CaddyManager.p2_stats = CaddyManager.create_stats()
	p2.stats = CaddyManager.p2_stats
	
	# fix stuff if the game is paused
	$"/root/Game/Music".volume_db = 0
	GameManager.cur_map.find_child("Golf-hole").z_index = 100

	
	# setup for the next round
	Engine.time_scale = 1
	p1_score = 0
	p2_score = 0
	get_node("/root/Game/Game-ui/P1 Score").set_text(str(p1_score))
	get_node("/root/Game/Game-ui/P2 Score").set_text(str(p1_score))
	$"/root/Game/Overlay".modulate.a = 0
	
	# randomize the map for next time
	var maps_index = range(maps.size())
	maps_index.pop_at(last_map)
	last_map = maps_index.pick_random()
	
	cur_map.queue_free()
	cur_map = maps[last_map].instantiate()
	add_child(cur_map)


	game_state = GAME_STATES.TITLE_SCREEN
	CursorManager.default()
	
	$"/root/Game/Title/LOADING".visible = false
	$"/root/Game/Title".visible = true
	wipe.play_backwards("wipe")
	$/root/Game/WipeOutSound.play()

func get_plr(player):
	print("getting player ", player, ": ", p1)
	return p1 if player == PLAYER_TYPES.PLAYER1 else p2

func _prewarm_all_particles():
	# wait a frame
	await get_tree().process_frame
	
	# hole scoring particles
	if golf_hole:
		var hole_particles = golf_hole.get_node("GPUParticles2D")
		if hole_particles:
			hole_particles.emitting = true
			await get_tree().process_frame
			hole_particles.emitting = false
	
	# ball particles 
	if p1:
		p1._prewarm_ball_particles()
	if p2:
		p2._prewarm_ball_particles()
