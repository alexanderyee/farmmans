class_name CropManager
extends Node

signal grow_crop
signal dehydrate_soil

var crop_scene = preload("res://scenes/crop.tscn")

func _init() -> void:
	pass
	
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass

func add_crop(seed: Item, ground_cell: Vector2i, water_level: float) -> void:
	var crop_instance: Crop = crop_scene.instantiate()
	crop_instance.set_ground_cell(ground_cell)
	crop_instance.set_crop_name(get_crop_name_from_seed(seed))
	crop_instance.set_water_level(water_level)
	crop_instance.next_stage_reached.connect(_on_crop_next_stage_reached)
	add_child(crop_instance)
 
func _on_crop_next_stage_reached(crop_name: String, crop_stage: int, crop_cell: Vector2i):
	emit_signal("grow_crop", crop_name, crop_stage, crop_cell)

func get_crop_name_from_seed(seed: Item) -> String:
	return seed.name.get_slice(" ", 0)

func get_crop_water_levels() -> Array:
	var result = []
	return result

func get_crop_cell_positions() -> Array:
	var result = []
	for child: Crop in get_children():
		result.append(child.get_ground_cell())
	return result

func get_crop_at_ground_cell(ground_cell: Vector2i) -> Crop:
	for child: Crop in get_children():
		if child.ground_cell == ground_cell:
			return child
	return null

func _on_ground_cell_state_updated(ground_cell: Vector2i, water_level: float) -> void:
	var crop: Crop = get_crop_at_ground_cell(ground_cell)
	if crop:
		crop.set_water_level(water_level)
