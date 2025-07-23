extends Control

signal playagain_pressed
signal back_pressed

func _on_playagain_pressed() -> void:
	$"play-again/AnimatedSprite2D".play("click")
	await get_tree().create_timer(0.3).timeout
		
	emit_signal("playagain_pressed")

func _on_playagain_mouse_entered() -> void:
	$/root/Game/MenuHoverSound.play()
	CursorManager.hover()
	$"play-again/AnimatedSprite2D".play("hover")

func _on_playagain_mouse_exited() -> void:
	CursorManager.default()
	$"play-again/AnimatedSprite2D".play("exit")


func _on_back_pressed() -> void:
	$/root/Game/MenuSound.play()
	$"back/AnimatedSprite2D".play("click")
	await get_tree().create_timer(0.3).timeout
	emit_signal("back_pressed")

func _on_back_mouse_entered() -> void:
	$/root/Game/MenuHoverSound.play()
	CursorManager.hover()
	$"back/AnimatedSprite2D".play("hover")

func _on_back_mouse_exited() -> void:
	CursorManager.default()
	$"back/AnimatedSprite2D".play("exit")
