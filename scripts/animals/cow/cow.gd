class_name Cow
extends CharacterBody2D

const PICKUP = preload("res://scenes/pickup.tscn")

@onready var _grass_detection_area: Area2D = $GrassDetectionArea
@onready var _sprite: Sprite2D = $Sprite2D
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

@export var milk_cooldown_s := 5.0

var should_randomly_move := false
var hunger := 0.0:
	set = set_hunger
var milk_level := 0.0
var is_eating := false:
	set = set_is_eating
var is_sitting := false:
	set = set_is_sitting
var is_being_milked := false:
	set = set_is_being_milked
var rng := RandomNumberGenerator.new()
var facing_right := true # by default the sprite/animations are facing right
var grass_in_sight := []

func _ready() -> void:
	_grass_detection_area.collision_mask = 32
	pass
	
func _process(delta: float) -> void:
	if hunger >= 0.0:
		hunger -= delta
		if milk_level < 1.0:
			milk_level += delta / milk_cooldown_s

func _physics_process(delta: float) -> void:
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

func set_is_sitting(b: bool) -> void:
	is_sitting = b
	
func get_current_playing_anim() -> String:
	return state_machine.get_current_node()

# attempts to milk the cow, returns true if we're able to milk, false otherwise (pet)
func milk() -> bool:
	if milk_level >= 1.0:
		# milk the cow
		is_being_milked = true
		
		milk_level = 0.0
		return true
	return false
	
func set_is_being_milked(b: bool) -> void:
	is_being_milked = b

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "love":
		if is_being_milked:
			# cow got done being milked, spawn milk
			var obtainable_item: Obtainable = PICKUP.instantiate()
			var item_resource: Item = Global.get_item_resource("Basic Milk")
			if item_resource:
				obtainable_item.item = item_resource
			
			# set location to be on crop cell
			obtainable_item.global_position = global_position
			
			add_sibling(obtainable_item)
			is_being_milked = false
