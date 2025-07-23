extends Node

var pointer = preload("res://Assets/Sprites/cursor-normal.png")
var hand = preload("res://Assets/Sprites/cursor-click.png")

func _ready():
	Input.set_custom_mouse_cursor(pointer)
	Input.set_custom_mouse_cursor(hand, Input.CURSOR_POINTING_HAND)

func hover():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(hand)

func default():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(pointer)

func hide():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
