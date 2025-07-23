extends Sprite2D

signal golf_swing
signal activate_ability

var keybind = "P1_Swing"
var cur_orbit = 0
var cur_force = 1
var parent_rot = 0
var orbiting = false
var forcing = false
var p1 = true
var time_at_start_forcing = 0

func set_player(is_p1: bool) -> void:
	p1 = is_p1
	keybind = "P1_Swing" if p1 else "P2_Swing"

func _input(event: InputEvent) -> void:	
	if GameManager.game_state != GameManager.GAME_STATES.GAMEPLAY:
		return
	
	if event.is_action_pressed(keybind):
		assert(!orbiting)
		if not forcing:
			orbiting = true
			visible = true
			cur_orbit = -PI/2
			cur_force = 1
	if event.is_action_released(keybind):
		if forcing:
			emit_signal("golf_swing", cur_orbit, cur_force)
			forcing = false
			visible = false
		elif orbiting:
			orbiting = false
			forcing = true
			time_at_start_forcing = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.game_state != GameManager.GAME_STATES.GAMEPLAY:
		orbiting = false
		forcing = false
		visible = false
	
	if !orbiting and !forcing:
		return
	
	if orbiting:
		cur_orbit += (-delta if p1 else delta) * PI * 1.5
	if forcing:
		cur_force = sin((Time.get_ticks_msec() - time_at_start_forcing)*0.005 - PI/3)+2
	
	var vis_orbit = cur_orbit - parent_rot
	
	transform = Transform2D(
		vis_orbit+PI,
		Vector2(2, 2),
		0,
		-Vector2(cos(vis_orbit),
		sin(vis_orbit))*(5+cur_force*40)
	)
	
