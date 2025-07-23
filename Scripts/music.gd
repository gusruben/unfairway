extends AudioStreamPlayer2D

var track1 = preload("res://Assets/Sounds/Fast Updated.ogg")
var track2 = preload("res://Assets/Sounds/Extra (no Hydro).wav")

var tracks = [track1, track2]
var selected_track = 0

func _on_finished() -> void:
	selected_track = (selected_track + 1) % tracks.size()
	stream = tracks[selected_track]
	play()
