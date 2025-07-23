extends Control

var loading = false

func _on_button_pressed() -> void:
	if loading:
		return
	loading = true
		
	$/root/Game/MenuSound.play()
	$"Button/Click".visible = true
	$"Button/Hover".visible = false
	$"Button/Click".play()
	
	await get_tree().create_timer(0.3).timeout
	
	var wipe = $"/root/Game/Wipe"
	wipe.play("wipe")
	await get_tree().create_timer(1.0).timeout
	
	$Button/Click.visible = false
	$Button/Hover.visible = true
	$Button/Hover.animation = "default"
	$Button/Hover.frame = 0
	
	
	$LOADING.visible = true
	create_tween().tween_property(wipe, "modulate:a", 0, 0.15)
	CursorManager.hide()
	$LOADING.speed_scale = randf_range(0.75, 1.1)
	$LOADING.play()
	
	var fade_out_length = 0.1
	await get_tree().create_timer(1.9 - fade_out_length).timeout
	create_tween().tween_property(wipe, "modulate:a", 1, fade_out_length)
	await get_tree().create_timer(fade_out_length).timeout
	
	
	wipe.play_backwards("wipe")
	$/root/Game/WipeOutSound.play()
	
	GameManager.on_game_start()
	visible = false
	loading = false

func _on_button_mouse_entered() -> void:
	if loading:
		return
	$/root/Game/MenuHoverSound.play()
	
	CursorManager.hover()
	if $"Button/Hover":
		$"Button/Hover".play("default")

func _on_button_mouse_exited() -> void:
	if loading:
		return
	CursorManager.default()
	$"Button/Hover".play("exit")


func _on_credits_mouse_exited() -> void:
	if loading:
		return
	CursorManager.default()
	$"Credits/Hover".play("exit")

func _on_credits_mouse_entered() -> void:
	if loading:
		return
	$/root/Game/MenuHoverSound.play()
	
	CursorManager.hover()
	$"Credits/Hover".play("default")

var clicked_credits = false
func _on_credits_pressed() -> void:
	if loading:
		return
	$/root/Game/MenuErrorSound.play()
	
	if !clicked_credits:
		clicked_credits = true
		create_tween().tween_property($"CreditsText", "position", Vector2(428.0,660.0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		create_tween().tween_property($"CreditsText", "modulate:a", 0.5, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		await get_tree().create_timer(4.5).timeout
		create_tween().tween_property($"CreditsText", "position", Vector2(428.0,756.0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		create_tween().tween_property($"CreditsText", "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await get_tree().create_timer(0.5).timeout
		clicked_credits = false
