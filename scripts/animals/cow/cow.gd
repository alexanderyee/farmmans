class_name Cow
extends CharacterBody2D

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _grass_detection_area: Area2D = $GrassDetectionArea
@onready var _sprite: Sprite2D = $Sprite2D

var should_randomly_move := false
var hunger := 0.0:
	set = set_hunger
var is_eating := false:
	set = set_is_eating
var rng := RandomNumberGenerator.new()
var facing_right := true # by default the sprite/animations are facing right
var grass_in_sight := []

func _ready() -> void:
	_grass_detection_area.collision_mask = 32
	pass
	
func _process(delta: float) -> void:
	if hunger >= 0.0:
		hunger -= delta * 20.0

func _physics_process(delta: float) -> void:
	if velocity.length() > 0:
		_animation_player.play("walk")
	elif is_eating:
		_animation_player.play("eat")
	else:
		_animation_player.play("stand_idle")
	if velocity.x > 0:
		facing_right = true
	elif velocity.x < 0:
		facing_right = false
	_sprite.flip_h = !facing_right
	move_and_slide()

func _on_grass_detection_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Grass:
		grass_in_sight.append(area.get_parent())

func _on_grass_detection_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Grass:
		var grass: Grass = area.get_parent()
		grass_in_sight.remove_at(grass_in_sight.find(grass))
	
func is_hungry() -> bool:
	return hunger <= 0.0
	
func is_grass_in_sight() -> bool:
	return !grass_in_sight.is_empty()

func get_nearest_grass() -> Grass:
	grass_in_sight.sort_custom(closer_grass)
	return grass_in_sight.pop_front()
	
func closer_grass(a: Grass, b: Grass) -> bool:
	var dist_to_a = a.global_position - global_position
	var dist_to_b = b.global_position - global_position
	return dist_to_a < dist_to_b
	
func set_is_eating(b: bool) -> void:
	is_eating = b

func set_hunger(hunger_level: float) -> void:
	hunger = hunger_level
