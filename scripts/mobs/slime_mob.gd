extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed := 15
var player_ref = null
var player_detected := false
var animation_to_play := "idle_down" # TODO replace with default animation?
var is_dying := false
var hitstun_frames_remaining := 0
var face_direction := ""
var position_from_on_hit := Vector2.ZERO
var rng := RandomNumberGenerator.new()
var knockback_t := 0.0
var knockback_position := Vector2.ZERO
@export var hitstop_flash_time_s := 0.2
var hitstop_flash_timer := 0.0
@export var hitstop_flash_intensity := 5.0

# TODO temp fix until we add walk_left
var should_h_flip := false
# Start front idle animation on load
func _ready():
	animated_sprite.stop()
	animated_sprite.play(animation_to_play)
	
func _physics_process(delta):
	# handle movement
	# TODO should probably use the same logic for animation as player.gd
	#	(use face_direction)
	if is_dying:
		return
	if player_detected and player_ref:
		var move_direction = (player_ref.position - position).normalized()
		face_direction = direction_to_cardinal(move_direction)
		velocity = move_direction * speed 
		
		# walk animation
		animation_to_play = get_walk_animation(velocity)
		# TODO temp fix until we add walk_left
		if animation_to_play == "walk_left":
			animation_to_play = "walk_right"
			should_h_flip = true
		else:
			should_h_flip = false
		
	else:
		velocity = Vector2.ZERO
		animation_to_play = "idle_down"
		# TODO make it wander
	
	# handle hitstun, on hit effects
	# hitstun animation # TODO probs better belongs in a func
	if hitstun_frames_remaining > 0:
		# make it shake
		# we change the offset of only the sprite every 4 frames
		if hitstun_frames_remaining % 4 == 0:
			var offset_mult := 1
			# decide whether to offset left or right 
			if hitstun_frames_remaining % 8 == 0:
				offset_mult = -1
			var offset := rng.randi_range(0, 2)
			animated_sprite.offset.x = offset * offset_mult
			
		# knockback
		# lerp towards position it should be knocked back towards
		knockback_t += delta * 0.4
		position = position_from_on_hit.lerp(knockback_position, knockback_t)
		
		# flash
		# flash by changing brightness
		if hitstop_flash_timer > 0:
			var t = hitstop_flash_timer / hitstop_flash_time_s
			var brightness = lerp(1.0, hitstop_flash_intensity, t)
			animated_sprite.material.set_shader_parameter("is_in_hitstop", true)
			animated_sprite.material.set_shader_parameter("flash_intensity", brightness)
			hitstop_flash_timer -= delta
			
		# change animation/interpolate damage pose
		animation_to_play = "front_hit"
		
		# subtract from hitstun frames
		hitstun_frames_remaining -= 1
		velocity = Vector2.ZERO
		
		# check if hitstun is finished
		if hitstun_frames_remaining == 0:
			animated_sprite.offset.x = 0
			knockback_position = Vector2.ZERO
			knockback_t = 0
			animated_sprite.material.set_shader_parameter("is_in_hitstop", false)
	
	animated_sprite.play(animation_to_play)
	animated_sprite.flip_h = should_h_flip
	move_and_slide()

func get_walk_animation(velo: Vector2):
	var anim_to_play = "walk_"
	if velo.length() > 0:
		return anim_to_play + direction_to_cardinal(velo)
	return "idle_down"

func take_hitstun(h_frames: int, knockback: int, pos_hit_from: Vector2) -> void:
	hitstun_frames_remaining = h_frames
	position_from_on_hit = position
	var knockback_vector := (position - pos_hit_from).normalized()
	knockback_vector *= knockback
	knockback_position = position + knockback_vector
	hitstop_flash_timer = hitstop_flash_time_s
	animated_sprite.material.set_shader_parameter("is_in_hitstop", true)
	animated_sprite.material.set_shader_parameter("flash_intensity", hitstop_flash_intensity)

func die() -> void:
	is_dying = true
	animated_sprite.play("death")

# TODO copied from player. should put this in global?
func direction_to_cardinal(dir: Vector2) -> String:
	if abs(dir.x) >= abs(dir.y): # prioritizing horizontal movement
		return "left" if dir.x < 0 else "right"
	return "up" if dir.y < 0 else "down"

func _on_detection_area_body_entered(body: Node2D) -> void:
	player_ref = body
	player_detected = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player_ref = null
	player_detected = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_dying:
		queue_free()
