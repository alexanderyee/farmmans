extends CharacterBody2D

signal inventory_change # TODO is this still needed? maybe call refresh instead
signal tool_usage
signal highlight_tile_tool

# Properties
@export var speed := 150
@export var sprint_speed_mult := 1.3
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_area: Area2D = $Direction/interact_area
@onready var direction: Marker2D = $Direction

var equipped_slot: int
var face_direction := "down"
var animation_to_play := "idle_down"
var direction_regex: RegEx

# Start front idle animation on load
func _ready():
	animated_sprite.stop()
	animated_sprite.play("idle_down")
	direction_regex = RegEx.new()
	direction_regex.compile("^[^\\_]*\\_?(.*)$")

func _physics_process(_delta):
	# handle movement
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
	velocity = raw_input * int(speed * (sprint_speed_mult if Input.is_action_pressed("sprint") else 1.0))
	
	if raw_input.length() > 0:
		if abs(raw_input.x) > abs(raw_input.y): # prioritizing vertical movement
			face_direction = "left" if raw_input.x < 0 else "right"
		else:
			face_direction = "up" if raw_input.y < 0 else "down"

	# check for mouse movement (tile highlighting)
	var mouse_direction := get_relative_mouse_direction()
	var tool_equipped = false
	var equipped_item = Inventory.get_item_at_slot(equipped_slot)
	if equipped_item:
		if equipped_item.type == "TOOL":
			tool_equipped = true
	emit_signal("highlight_tile_tool", position, mouse_direction, tool_equipped)
		# reset highlight
	# check for primary action
	if Input.is_action_just_pressed("primary"):
		if tool_equipped:
			# aim towards mouse cursor
			face_direction = diagonal_to_cardinal(mouse_direction)
			print(face_direction)
			animation_to_play = equipped_item.animation_name + "_" + face_direction
			perform_tool_action(equipped_item, mouse_direction)
				
	if !is_non_movement_animation_playing(animation_to_play) or animation_to_play.begins_with("N/A"):
		# if no animation is currently being played, play run/walk/idle animation
		var movement_animation = "run" if Input.is_action_pressed("sprint") else "walk"
		animation_to_play = (movement_animation if velocity.length() > 0.0 else "idle") + "_" + face_direction
	
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
	if new_direction == "down":
		direction.set_global_rotation(0)
	elif new_direction == "left":
		direction.set_global_rotation(PI / 2)
	elif new_direction == "up":
		direction.set_global_rotation(PI)
	else:
		direction.set_global_rotation(3 * PI / 2)

func on_item_picked_up(item:Item):
	if item.is_equippable:
		Inventory.add_equippable_item(item)
	else:
		Inventory.add_non_equippable_item(item)
	
	emit_signal("inventory_change")

func is_non_movement_animation_playing(next_animation: String):
	if animated_sprite.is_playing():
		var current_animation := animated_sprite.get_animation()
		if !current_animation.begins_with("run") and !current_animation.begins_with("walk") and !current_animation.begins_with("idle"):
			return true
		if !next_animation.begins_with("run") and !next_animation.begins_with("walk") and !next_animation.begins_with("idle"):
			return true
	return false

func get_relative_mouse_direction() -> String:
	var relative_mouse_direction_2d = get_viewport().get_mouse_position() - get_global_transform_with_canvas().origin
	var mouse_angle := relative_mouse_direction_2d.angle()
	# TODO: any way to simplify 1/8PI or detect diagonals?
	if mouse_angle > -1.0/8*PI and mouse_angle <= 1.0/8*PI:
		return "right"
	elif mouse_angle > 1.0/8*PI and mouse_angle <= 3.0/8*PI:
		return "down_right"
	elif mouse_angle > 3.0/8*PI and mouse_angle <= 5.0/8*PI:
		return "down"
	elif mouse_angle > 5.0/8*PI and mouse_angle <= 7.0/8*PI:
		return "down_left"
	elif mouse_angle > 7.0/8*PI or mouse_angle <= -7.0/8*PI:
		return "left"
	elif mouse_angle > -7.0/8*PI and mouse_angle <= -5.0/8*PI:
		return "up_left"
	elif mouse_angle > -5.0/8*PI and mouse_angle <= -3.0/8*PI:
		return "up"
	elif mouse_angle > -3.0/8*PI and mouse_angle <= -1.0/8*PI:
		return "up_right"
	return ""

func perform_tool_action(tool: Item, action_direction: String):
	
	emit_signal("tool_usage", tool.action, position, action_direction)
	# set tile according to item's action
	return
	
func diagonal_to_cardinal(cardinal: String):
	var matched_groups = direction_regex.search(cardinal).get_strings()
	if matched_groups[1].length() == 0:
		return matched_groups[0]
	return matched_groups[1]
