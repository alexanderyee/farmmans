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
	for child: Crop in get_children():
		var crop_water_level = child.get_water_level()
		if crop_water_level <= 0.0:
			# plant is dying
			print("plant dying")
		else:
			child.decrement_water_level()
			# check water levels to see if we should adjust timer
			if child.water_level < 0.25:
				child.set_extremely_dehydrated()
				# send signal to change tilemap
				emit_signal("dehydrate_soil", child.get_ground_cell(), child.water_level)
			if child.water_level < 0.5:
				child.set_dehydrated()
				# send signal to change tilemap
				emit_signal("dehydrate_soil", child.get_ground_cell(), child.water_level)

func add_crop(seed: Item, ground_cell: Vector2i) -> void:
	var crop_instance: Crop = crop_scene.instantiate()
	crop_instance.set_ground_cell(ground_cell)
	crop_instance.set_crop_name(get_crop_name_from_seed(seed))
	crop_instance.next_stage_reached.connect(_on_crop_next_stage_reached)
	add_child(crop_instance)

# TODO should have ground manage water level so that you can water unplanted tiles
func water_crop(ground_cell: Vector2i) -> void:
	for child: Crop in get_children():
		if child.get_ground_cell() == ground_cell:
			child.set_water_level(1.0)
		 
func _on_crop_next_stage_reached(crop_name: String, crop_stage: int, crop_cell: Vector2i):
	emit_signal("grow_crop", crop_name, crop_stage, crop_cell)

func get_crop_name_from_seed(seed: Item) -> String:
	return seed.name.get_slice(" ", 0)

func get_crop_water_levels() -> Array:
	var result = []
	for child: Crop in get_children():
		result.append(child.get_water_level())
	return result

func get_crop_cell_positions() -> Array:
	var result = []
	for child: Crop in get_children():
		result.append(child.get_ground_cell())
	return result
	
