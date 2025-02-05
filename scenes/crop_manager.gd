class_name CropManager
extends Node

signal grow_crop

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
			if child.water_level < 0.5:
				child.set_dehydrated()
				

func add_crop(seed: Item, ground_cell: Vector2i) -> void:
	var crop_instance: Crop = crop_scene.instantiate()
	crop_instance.set_ground_cell(ground_cell)
	crop_instance.next_stage_reached.connect(_on_crop_next_stage_reached)
	add_child(crop_instance)

func _on_crop_next_stage_reached(crop_name: String, crop_stage: int, crop_cell: Vector2i):
	print('hi i grew')
	emit_signal("grow_crop", crop_name, crop_stage, crop_cell)
