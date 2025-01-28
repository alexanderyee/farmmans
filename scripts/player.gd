extends CharacterBody2D

signal inventory_change # TODO is this still needed? maybe call refresh instead
signal tool_usage
signal highlight_tile_tool

# Properties
@export var speed := 150
@export var sprint_speed_mult := 1.3
@onready var interact_area: Area2D = $Direction/interact_area
@onready var direction: Marker2D = $Direction
@onready var anim_tree: AnimationTree = $AnimationTree

var equipped_slot: int
var face_direction := "down"
var direction_regex: RegEx
var attacking = false

# Start front idle animation on load
func _ready():
	direction_regex = RegEx.new()
	direction_regex.compile("^[^\\_]*\\_?(.*)$")

func _physics_process(_delta):
	var tool_equipped = false
	var weapon_equipped = false
	var equipped_item = Inventory.get_item_at_slot(equipped_slot)
	var mouse_direction := get_relative_mouse_direction()
	if equipped_item:
		if equipped_item.type == "TOOL":
			tool_equipped = true
		elif equipped_item.type == "WEAPON":
			weapon_equipped = true
	
	# highlight tile towards direction of mouse
	emit_signal("highlight_tile_tool", position, mouse_direction, tool_equipped)
	
	# check for primary action (left-click)
	if Input.is_action_just_pressed("primary"):
		if tool_equipped:
			# aim towards mouse cursor
			face_direction = diagonal_to_cardinal(mouse_direction)
			perform_tool_action(equipped_item, mouse_direction)
		if weapon_equipped:
			face_direction = diagonal_to_cardinal(mouse_direction)
			perform_weapon_action(equipped_item, face_direction)
			
	# handle movement
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = raw_input * int(speed * (sprint_speed_mult if Input.is_action_pressed("sprint") else 1.0))
	
	if attacking:
		pass
	else:
		if raw_input == Vector2.ZERO:
			anim_tree.get("parameters/playback").travel("Idle")
		else:
			anim_tree.get("parameters/playback").travel("Walk")
			anim_tree.set("parameters/Idle/BlendSpace2D/blend_position", raw_input)
			anim_tree.set("parameters/Walk/BlendSpace2D/blend_position", raw_input)
		
		if raw_input.length() > 0:
			if abs(raw_input.x) > abs(raw_input.y): # prioritizing vertical movement
				face_direction = "left" if raw_input.x < 0 else "right"
			else:
				face_direction = "up" if raw_input.y < 0 else "down"
	
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
	
func perform_weapon_action(weapon: Item, action_direction: String):
	attacking = true
	# TODO this is a one liner but nonetheless replicated code
	var relative_mouse_direction_2d = get_viewport().get_mouse_position() - get_global_transform_with_canvas().origin
	anim_tree.set("parameters/Attack/BlendSpace2D/blend_position", relative_mouse_direction_2d)
	anim_tree.set("parameters/Idle/BlendSpace2D/blend_position", relative_mouse_direction_2d)
	anim_tree.set("parameters/Walk/BlendSpace2D/blend_position", relative_mouse_direction_2d)
	anim_tree.get("parameters/playback").travel("Attack")

func diagonal_to_cardinal(cardinal: String):
	var matched_groups = direction_regex.search(cardinal).get_strings()
	if matched_groups[1].length() == 0:
		return matched_groups[0]
	return matched_groups[1]

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if "sword" in anim_name:
		attacking = false
