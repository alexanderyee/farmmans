extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed := 15
var player_ref = null
var player_detected = false
var animation_to_play = "idle_down" # TODO replace with default animation?

# TODO temp fix until we add walk_left
var should_h_flip := false
# Start front idle animation on load
func _ready():
	animated_sprite.stop()
	animated_sprite.play(animation_to_play)
	
func _physics_process(_delta):
	# handle movement
	# TODO should probably use the same logic for animation as player.gd
	#	(use face_direction)
	if player_detected and player_ref:
		var move_direction = (player_ref.position - position).normalized()
		velocity = move_direction * speed 
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
	animated_sprite.play(animation_to_play)
	animated_sprite.flip_h = should_h_flip
	move_and_slide()
	pass

func get_walk_animation(velo: Vector2):
	var anim_to_play = "walk_"
	if velo.length() > 0:
		if abs(velo.x) > abs(velo.y): # prioritizing vertical movement
			anim_to_play += "left" if velo.x < 0 else "right"
		else:
			anim_to_play += "up" if velo.y < 0 else "down"
	else:
		return "idle_down"
	return anim_to_play

func _on_detection_area_body_entered(body: Node2D) -> void:
	player_ref = body
	player_detected = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player_ref = null
	player_detected = false
