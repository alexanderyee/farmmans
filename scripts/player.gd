extends CharacterBody2D

signal inventory_change # TODO is this still needed? maybe call refresh instead

# Properties
@export var speed := 200
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_area: Area2D = $Direction/interact_area
@onready var direction: Marker2D = $Direction

var equipped_slot: int
var face_direction := "forward"
var animation_to_play := "idle_forward"

# Start front idle animation on load
func _ready():
	animated_sprite.stop()
	animated_sprite.play("idle_forward")

func _physics_process(_delta):
	# handle movement
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = raw_input * speed
	
	if raw_input.length() > 0:
		if abs(raw_input.x) > abs(raw_input.y): # prioritizing vertical movement
			face_direction = "left" if raw_input.x < 0 else "right"
		else:
			face_direction = "backward" if raw_input.y < 0 else "forward"

	# check for primary action
	if Input.is_action_just_pressed("primary"):
		var equipped_item = Inventory.get_item_at_slot(equipped_slot)
		if equipped_item:
			animation_to_play = equipped_item.animation_name + "_" + face_direction
			print(animation_to_play)
	if !is_non_walk_idle_animation_playing(animation_to_play) or animation_to_play.begins_with("N/A"):
		# if no animation is currently being played, play walk/idle animation
		animation_to_play = ("walk" if velocity.length() > 0.0 else "idle") + "_" + face_direction
	
	animated_sprite.play(animation_to_play)
	
	move_and_slide()
	change_direction_marker(face_direction)
	
	# check interact
	if Input.is_action_just_pressed("interact"):
		for area in interact_area.get_overlapping_areas():
			if area.is_in_group("door"):
				area.toggle_door()
	
	# check hotbar item switch 
	# TODO would it be better practice to let Inventory or Hotbar handle this input listening?
	for i in range(1,7): 
		if Input.is_action_just_pressed("hotbar_" + str(i)):
			equipped_slot = i - 1
			Inventory.set_equipped_slot(equipped_slot)
			emit_signal("inventory_change")
		

	
func change_direction_marker(new_direction:String):
	if new_direction == "forward":
		direction.set_global_rotation(0)
	elif new_direction == "left":
		direction.set_global_rotation(PI / 2)
	elif new_direction == "backward":
		direction.set_global_rotation(PI)
	else:
		direction.set_global_rotation(3 * PI / 2)

func on_item_picked_up(item:Item):
	if item.is_equippable:
		Inventory.add_equippable_item(item)
	else:
		Inventory.add_non_equippable_item(item)
	
	emit_signal("inventory_change")

func is_non_walk_idle_animation_playing(animation_to_play: String):
	if animated_sprite.is_playing():
		var current_animation := animated_sprite.get_animation()
		if !current_animation.begins_with("walk") and !current_animation.begins_with("idle"):
			return true
		if !animation_to_play.begins_with("walk") and !animation_to_play.begins_with("idle"):
			return true
	return false
		
