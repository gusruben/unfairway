extends Area2D

class_name golfhole

var scored = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("area_entered", area_entered)
	
	GameManager.golf_hole = self
	
func area_entered(area: Area2D) -> void:
	if scored:
		return
	scored = true

	var player = area.get_parent().PLAYER_TYPE
	var mat = $GPUParticles2D.process_material
	if player == GameManager.PLAYER_TYPES.PLAYER1:
		mat.color = Color(237/255.0, 200/255.0, 205/255.0,1)
	else:
		mat.color = Color(199/255.0, 225/255.0, 238/255.0,1)

	$GPUParticles2D.emitting = true
	
	GameManager.on_goal(player)
