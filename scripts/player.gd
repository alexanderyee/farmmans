extends CharacterBody2D

# Constants
const action_anim_names := ["Hoe", "Hatchet", "Sword", "Water"] # TODO map these to resourcetable
const movement_anim_names := ["Idle", "Run", "Walk"]
const PICKUP = preload("res://scenes/pickup.tscn")

# Signals
signal inventory_change # TODO is this still needed? maybe call refresh instead
signal tool_usage
signal highlight_tile_tool

# Properties
@export var speed := 150
@export var sprint_speed_mult := 1.3

@onready var interact_area: Area2D = $Direction/interact_area
@onready var direction: Marker2D = $Direction
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var ground: Ground = %ground

var equipped_slot: int
var face_direction := "down"
var direction_regex: RegEx
var in_action := false
var enemies_hit := []
var sword_timescale_frame_counter := 0

# Start front idle animation on load
func _ready():
	direction_regex = RegEx.new()
	direction_regex.compile("^[^\\_]*\\_?(.*)$")
	
func _physics_process(_delta):
	var tool_equipped := false
	var weapon_equipped := false
	var equipped_item = Inventory.get_item_at_slot(equipped_slot)
	var mouse_direction := get_relative_mouse_diagonal()
	if equipped_item:
		if equipped_item.type == "TOOL":
			tool_equipped = true
		elif equipped_item.type == "WEAPON":
			weapon_equipped = true
	var cell_to_highlight = get_cell_to_highlight()
	
	# highlight tile towards direction of mouse
	emit_signal("highlight_tile_tool", cell_to_highlight, tool_equipped)
	
	# check for primary action (left-click)
	if Input.is_action_just_pressed("primary") and !in_action:
		var relative_mouse_direction_2d: Vector2 = get_relative_mouse_direction_2d()
		face_direction = direction_to_cardinal(relative_mouse_direction_2d)
		if tool_equipped:
			var clicked_cell = get_cell_to_highlight()
			# aim towards mouse cursor diagonal
			perform_tool_action(equipped_item, clicked_cell)
		if weapon_equipped:
			perform_weapon_action(equipped_item, face_direction)
			
	# check for secondary action (right-click)
	if Input.is_action_just_pressed("secondary") and !in_action:
		# get cell mouse is in
		var clicked_cell = get_cell_to_highlight()
		
		# check if crop exists and harvestable
		var harvested_crop_name: String = ground.harvest_crop(clicked_cell)
		if !harvested_crop_name.is_empty():
			# spawn pickuppable crop item
			var obtainable_item: Obtainable = PICKUP.instantiate()
			var item_resource: Item = Global.get_item_resource(harvested_crop_name)
			if item_resource:
				obtainable_item.item = item_resource
			
			# set location to be on crop cell
			obtainable_item.global_position = ground.get_global_position_of_cell(clicked_cell)
			
			add_sibling(obtainable_item)
		
		# check if a cow needs to be milked (2nd method, right click)
		
	# handle movement
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = raw_input * int(speed * (sprint_speed_mult if Input.is_action_pressed("sprint") else 1.0))
	
	if in_action:
		velocity = Vector2.ZERO
		if sword_timescale_frame_counter > 0:
			sword_timescale_frame_counter -= 1
			if sword_timescale_frame_counter == 0:
				anim_tree.set("parameters/Sword/TimeScale/scale", 1.0)
	else:
		if raw_input == Vector2.ZERO:
			anim_tree.get("parameters/playback").travel("Idle")
		else:
			if Input.is_action_pressed("sprint"):
				# TODO could probably utilize the BlendSpace2D here but want to keep things simple atm
				anim_tree.get("parameters/playback").travel("Run")
			else:
				anim_tree.get("parameters/playback").travel("Walk")
			set_anim_tree_blend_position(raw_input, false)
		
		if raw_input.length() > 0:
			if abs(raw_input.x) >= abs(raw_input.y): # prioritizing horizontal movement
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
		# check if a cow needs to be milked (1st method, interact)
		for body in interact_area.get_overlapping_bodies():
			if body is Cow:
				body.milk()
	
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

func get_relative_mouse_diagonal() -> String:
	var mouse_angle := get_relative_mouse_direction_2d().angle()
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

func perform_tool_action(tool: Item, clicked_cell: Vector2i) -> void:
	var relative_mouse_direction_2d = get_relative_mouse_direction_2d()
	set_anim_tree_blend_position(relative_mouse_direction_2d, true)
	if tool.animation_name in action_anim_names:
		anim_tree.get("parameters/playback").travel(tool.animation_name)
		in_action = true
	# set tile according to item's action
	emit_signal("tool_usage", tool, position, clicked_cell)
	return
	
func perform_weapon_action(weapon: Item, action_direction: String) -> void:
	in_action = true
	enemies_hit = []
	# TODO this is a one liner but nonetheless replicated code
	var relative_mouse_direction_2d = get_relative_mouse_direction_2d()
	set_anim_tree_blend_position(relative_mouse_direction_2d, true)
	anim_tree.get("parameters/playback").travel("Sword")
	return

func direction_to_cardinal(dir: Vector2) -> String:
	if abs(dir.x) >= abs(dir.y): # prioritizing horizontal movement
		return "left" if dir.x < 0 else "right"
	return "up" if dir.y < 0 else "down"

# personal note: does this execute during a cancelled animation (e.g. we get hit
# during an animation)
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.capitalize().get_slice(" ", 0) in action_anim_names:
		in_action = false

func set_anim_tree_blend_position(blend_position: Vector2, include_action_anims: bool) -> void:
	if include_action_anims:
		for action_anim_name in action_anim_names:
			anim_tree.set("parameters/" + action_anim_name + "/BlendSpace2D/blend_position", blend_position)
	for movement_anim_name in movement_anim_names:
			anim_tree.set("parameters/" + movement_anim_name + "/BlendSpace2D/blend_position", blend_position)
	
func deal_damage(damage: int, hitstun_frames: int, knockback: int, area: Area2D):
	if !enemies_hit.has(area):
		enemies_hit.append(area)
		if area.has_method("take_damage"):
			area.take_damage(damage, hitstun_frames, knockback, position)
		sword_timescale_frame_counter = hitstun_frames / 4
		anim_tree.set("parameters/Sword/TimeScale/scale", 0.5)

func get_relative_mouse_direction_2d() -> Vector2:
	return get_viewport().get_mouse_position() - get_global_transform_with_canvas().origin

func get_cell_to_highlight() -> Vector2i:
	var player_to_mouse_vec = get_global_mouse_position() - global_position
	player_to_mouse_vec = player_to_mouse_vec.limit_length(Global.TILE_SIZE * 1.5)
	
	var pos_to_highlight = global_position + player_to_mouse_vec
	var cell_to_highlight = ground.get_tile_from_pos(pos_to_highlight)
	return cell_to_highlight
	
