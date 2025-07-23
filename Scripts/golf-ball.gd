@tool
extends RigidBody2D

class_name golfball

@export var PLAYER_TYPE : GameManager.PLAYER_TYPES = GameManager.PLAYER_TYPES.PLAYER1
var color

@onready var ARROW = $Arrow
@onready var BALL_SHADOW = $"Golf-ball/Sprite2D"
@onready var TIMER_SPRITE = $"TimerSprite/Sp"
@onready var BALL_SPRITE = $"Golf-ball"
@onready var PARTICLES = $GPUParticles2D
@onready var DASH_PARTICLES = $DashParticles

const HitEffect = preload("res://Scenes/Particles/BallHit.tscn")

# particle trail logic
@onready var previous_position = global_position
var min_dist_to_emit = 0.0
var particle_spacing = 4.0

var last_ability = -INF
var stats

var has_dash = false

var was_in_air = true
var last_landing: int

var caddies = []

# card variables
var is_dashing = false
var is_attracting = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	if PLAYER_TYPE == GameManager.PLAYER_TYPES.PLAYER1:
		color = "red"
		caddies = CaddyManager.p1_caddies
	else:
		color = "blue"
		caddies = CaddyManager.p2_caddies

	ARROW.connect("golf_swing", on_golf_swing)
	ARROW.set_player(PLAYER_TYPE == GameManager.PLAYER_TYPES.PLAYER1)
	TIMER_SPRITE.connect("animation_finished", on_timer_animation_finish)
	
	if PLAYER_TYPE == GameManager.PLAYER_TYPES.PLAYER1:
		GameManager.p1 = self
		stats = CaddyManager.p1_stats
		BALL_SPRITE.modulate = Color(0.9, 0.6, 0.6, 1)
	if PLAYER_TYPE == GameManager.PLAYER_TYPES.PLAYER2:
		GameManager.p2 = self
		stats = CaddyManager.p2_stats
		BALL_SPRITE.modulate = Color(0.6, 0.6, 0.9, 1)
		
	if PARTICLES:
		PARTICLES.emitting = false
	
	if caddies.has("Repulsion Field"):
		$RepulsionCircle.play(color)
	if caddies.has("Gravity Well"):
		$AttractionOverlay.play(color)
	
func _input(event: InputEvent) -> void:
	if GameManager.game_state != GameManager.GAME_STATES.GAMEPLAY:
		return
		
	var p_str = "P1" if (PLAYER_TYPE == GameManager.PLAYER_TYPES.PLAYER1) else "P2"
	if event.is_action_pressed(p_str + "_ABILITY"):
		if Time.get_ticks_msec() - last_ability < stats.s_ability_cooldown*1000:
			return
		
		TIMER_SPRITE.visible = true
		TIMER_SPRITE.speed_scale = 1.0/stats.s_ability_cooldown
		TIMER_SPRITE.play()
		CaddyManager.on_ability(PLAYER_TYPE)
		
		last_ability = Time.get_ticks_msec()

func teleport(pos):
	PhysicsServer2D.body_set_state(
		get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D.IDENTITY.translated(pos)
	)

func on_timer_animation_finish():
	TIMER_SPRITE.visible = false

func is_on_ground():
	if $ShapeCast2D.is_colliding():
		return true
	else:
		return false

func on_golf_swing(angle: float, force: float):
	var on_ground = is_on_ground()
	
	var hit_particles = HitEffect.instantiate()
	get_tree().current_scene.add_child(hit_particles)
	hit_particles.global_position = global_position
	if on_ground:
		hit_particles.rotation = -angle
	else:
		hit_particles.rotation = angle
	var mat = hit_particles.process_material
	mat.color = Color(1, 1, 1, 1)
	hit_particles.amount = max(4, int(4 * (force - 1)))
	hit_particles.play()
	# do it again with a different scale of particles
	var hit_particles2 = HitEffect.instantiate()
	get_tree().current_scene.add_child(hit_particles2)
	hit_particles2.global_position = global_position
	if on_ground:
		hit_particles2.rotation = -angle
	else:
		hit_particles2.rotation = angle
	var mat2 = hit_particles2.process_material
	mat2.color = Color(1, 1, 1, 1)
	mat2.scale_min = 2.0
	mat2.scale_max = 2.0
	hit_particles2.amount = max(2, int(2 * (force - 1)))
	hit_particles2.play()
	
	var sfx : AudioStreamPlayer2D = get_node("/root/Game/Golf-Hit-Sfx")
	sfx.pitch_scale = 1 + randf()*0.2-0.1
	sfx.play()
	apply_central_impulse(-Vector2(cos(angle), sin(angle)) * stats.s_swing_force * force)

func _physics_process(delta: float) -> void:	
	if Engine.is_editor_hint():
		return
	
	physics_material_override.bounce = stats.s_bounce
	
	$CollisionShape2D.scale = Vector2.ONE*1.3*stats.s_scale
	$"Golf-ball".scale = Vector2.ONE*2.15*stats.s_scale
	$Area2D.scale = Vector2.ONE*1.3*stats.s_scale
	
	mass = stats.s_mass
	
	ARROW.parent_rot = rotation
	BALL_SHADOW.rotation = -rotation
	
	# particle logic
	# trail
	var dist_traveled = previous_position.distance_to(global_position)
	if dist_traveled > min_dist_to_emit and !is_on_ground():
		var direction = (global_position - previous_position).normalized()
		var num_particles_to_emit = int(dist_traveled / particle_spacing)
		if is_dashing:
			num_particles_to_emit *= 2
		#var num_particles_to_emit = 50
	
		for i in range(num_particles_to_emit):
			var emit_pos = previous_position + direction * (i * particle_spacing)
			#var emit_pos = previous_position + i * ((global_position - previous_position) / num_particles_to_emit)
			var particle_transform = Transform2D(0, emit_pos)
			
			if is_dashing:	
				DASH_PARTICLES.emit_particle(particle_transform, Vector2.ZERO, Color(1,1,1,1), Color(0,0,0,0), 0)
			else:
				PARTICLES.emit_particle(particle_transform, Vector2.ZERO, Color(1,1,1,1), Color(0,0,0,0), 0)
		
		previous_position = global_position
	elif dist_traveled > 0:
		previous_position = global_position
		

	# dash particles
	if is_dashing and was_in_air and is_on_ground():
		is_dashing = false	
		
	# bounce particles
	if stats.s_bounce > 0.2 and was_in_air and is_on_ground():
		var hit_particles = HitEffect.instantiate()
		get_tree().current_scene.add_child(hit_particles)
		hit_particles.global_position = global_position
		hit_particles.rotation = -PI / 4.0
		var mat = hit_particles.process_material
		mat.color = Color(235/255.0, 184/255.0, 231/255.0, 1.0)
		hit_particles.amount = int(4 * (stats.s_bounce / 2.0))
		hit_particles.play()
		# do it again with a different scale of particles
		var hit_particles2 = HitEffect.instantiate()
		get_tree().current_scene.add_child(hit_particles2)
		hit_particles2.global_position = global_position
		hit_particles2.rotation = -PI / 4.0
		var mat2 = hit_particles2.process_material
		mat2.scale_min = 2.0
		mat2.scale_max = 2.0
		hit_particles2.amount = int(2 * (stats.s_bounce / 2.0))
		hit_particles2.play()
	
	var other_player: RigidBody2D
	if PLAYER_TYPE == GameManager.PLAYER_TYPES.PLAYER1:
		other_player = GameManager.p2
	else:
		other_player = GameManager.p1 
	
	# card logic
	var seen_cards = [] # prevent running the same code twice (stacking cards should just increase their power)
	for card in caddies:
		if seen_cards.has(seen_cards):
			continue
			
		if card == "Repulsion Field":
			if self.position.distance_to(other_player.position) < stats.c_repulsion_radius:
				var added_vector = other_player.position - self.position
				added_vector = added_vector.normalized() * (stats.c_repulsion_radius / max(25, self.position.distance_to(other_player.position))) * stats.c_repulsion_strength
				other_player.linear_velocity += added_vector
				
			# circle goes from 0-1 opacity as the player distance goes from ~160-0
			$RepulsionCircle.modulate.a = 1 - min(1, self.position.distance_to(other_player.position) / (stats.c_repulsion_radius + 25))
			$RepulsionCircle.rotation = -self.rotation
		
		if card == "Gravity Well":
			if is_attracting:
				var added_vector = self.position - other_player.position
				added_vector = added_vector.normalized() * stats.c_attraction_strength
				other_player.linear_velocity += added_vector
				
			$AttractionOverlay.rotation = -self.rotation
	
		seen_cards.push_back(card)
		
	# sound logic
	if was_in_air and is_on_ground():
		$/root/Game/LandSound.play()
	
	was_in_air = !is_on_ground()

func _prewarm_ball_particles():
	# pre-warm ball particles
	
	# hit effect
	var prewarm_particles = HitEffect.instantiate()
	get_tree().current_scene.add_child(prewarm_particles)
	prewarm_particles.global_position = Vector2(-10000, -10000)  # Off-screen
	prewarm_particles.amount = 1
	prewarm_particles.emitting = true
	
	# trail
	if PARTICLES:
		PARTICLES.emitting = true
		await get_tree().process_frame
		PARTICLES.emitting = false
	
	# dash
	if DASH_PARTICLES:
		DASH_PARTICLES.emitting = true
		await get_tree().process_frame
		DASH_PARTICLES.emitting = false
	
	# cleanup
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(prewarm_particles):
		prewarm_particles.queue_free()
