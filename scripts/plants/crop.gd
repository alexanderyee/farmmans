class_name Crop
extends Node

signal next_stage_reached

@export var crop_name:String
@export var current_stage := 1
@export var time_per_stage_s := [5, 5, 5, 5]
var growth_rate: float
var growth_progress_percent := 0.0
var is_harvestable := false

var ground_cell: Vector2i

func _init() -> void:
	growth_rate = 0.0

func set_water_level(water_level: float) -> void:
	if water_level <= 0.0:
		set_dying()
	elif water_level <= 0.25:
		set_extremely_dehydrated()
	elif water_level <= 0.5:
		set_dehydrated()
	else:
		set_watered()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	growth_progress_percent += growth_rate
	
	if growth_progress_percent >= 1.0:
		current_stage += 1
		growth_progress_percent = 0.0
		next_stage_reached.emit(crop_name, current_stage, ground_cell)
		if crop_name == "Corn" and current_stage >= 5:
			is_harvestable = true
			growth_rate = 0.0
		elif crop_name != "Corn" and current_stage >= 4:
			is_harvestable = true
			growth_rate = 0.0


func set_watered() -> void:
	if !is_harvestable:
		# reset growth rate to default
		growth_rate = 1.0 / (Engine.physics_ticks_per_second * time_per_stage_s[current_stage - 1])
	
# Called when crop level is between 25% and 50%
func set_dehydrated() -> void:
	if !is_harvestable:
		# crop grows at half the rate
		growth_rate /= 2
	
# Called when crop level is between 0% and 25%
func set_extremely_dehydrated() -> void:
	if !is_harvestable:
		# crop grows at a quarter of the rate
		growth_rate /= 4

func set_dying() -> void:
	growth_rate = 0.0

func get_ground_cell() -> Vector2i:
	return ground_cell
	
func set_ground_cell(cell: Vector2i) -> void:
	ground_cell = cell

func set_crop_name(name: String) -> void:
	crop_name = name
	
func set_stage(stage: int) -> void:
	current_stage = stage
