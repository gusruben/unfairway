extends Control

signal back_pressed

func pause():
	if GameManager.game_state != GameManager.GAME_STATES.GAMEPLAY:
		$/root/Game/MenuErrorSound.play()
		return
	
	$PauseSound.play()
	CursorManager.default()
	get_tree().paused = true
	$"resume/AnimatedSprite2D".animation = "hover"
	$"resume/AnimatedSprite2D".frame = 0
	$"back/AnimatedSprite2D".animation = "hover"
	$"back/AnimatedSprite2D".frame = 0
	visible = true
	
	# make golf hole not show
	GameManager.cur_map.find_child("Golf-hole").z_index = 0
	
	create_tween().tween_property($"/root/Game/Music", "volume_db", -7, 0.15)
	create_tween().tween_property($"/root/Game/Overlay", "modulate:a", 0.75, 0.25)
	create_tween().tween_property(self, "modulate:a", 1.0, 0.25)
	

func unpause():
	if GameManager.game_state != GameManager.GAME_STATES.GAMEPLAY:
		return
	
	$UnpauseSound.play()
	CursorManager.hide()
	get_tree().paused = false
	$"/root/Game/Music".volume_db = 0
	
	create_tween().tween_property(self, "modulate:a", 0, 0.5)	
	create_tween().tween_property($"/root/Game/Overlay", "modulate:a", 0, 0.5)
	create_tween().tween_property($"/root/Game/Music", "volume_db", 0, 0.25)
	
	await get_tree().create_timer(0.5).timeout
	visible = false
	GameManager.cur_map.find_child("Golf-hole").z_index = 100

# handle 'escape' to unpause
func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		unpause()
		get_viewport().set_input_as_handled() # prevent gamemanager from seeing this input too

func _on_resume_pressed() -> void:
	$"resume/AnimatedSprite2D".play("click")
	unpause()

func _on_resume_mouse_entered() -> void:
	$/root/Game/MenuHoverSound.play()
	CursorManager.hover()
	$"resume/AnimatedSprite2D".play("hover")

func _on_resume_mouse_exited() -> void:
	CursorManager.default()
	$"resume/AnimatedSprite2D".play("exit")

func _on_back_pressed() -> void:
	$/root/Game/MenuSound.play()
	$"back/AnimatedSprite2D".play("click")
	await get_tree().create_timer(0.3).timeout
	get_tree().paused = false
	emit_signal("back_pressed")

func _on_back_mouse_entered() -> void:
	$/root/Game/MenuHoverSound.play()
	CursorManager.hover()
	$"back/AnimatedSprite2D".play("hover")

func _on_back_mouse_exited() -> void:
	CursorManager.default()
	$"back/AnimatedSprite2D".play("exit")
