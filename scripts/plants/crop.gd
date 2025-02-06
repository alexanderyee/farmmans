class_name Crop
extends Node

signal next_stage_reached

@export var crop_name:String
@export var water_level := 0.0
@export var stage_name := "Sapling"
@export var current_stage := 1
@export var time_per_stage_s:int
@onready var timer: Timer = $Timer

var ground_cell: Vector2i

func _init() -> void:
	time_per_stage_s = 3

func _ready() -> void:
	timer.wait_time = time_per_stage_s
	timer.start()
	pass

func _on_timer_timeout() -> void:
	current_stage += 1
	next_stage_reached.emit(crop_name, current_stage, ground_cell)

func is_timer_started() -> bool:
	return !timer.is_stopped()

func get_water_level() -> float:
	return water_level

func set_water_level(wlevel: float) -> void:
	water_level = wlevel

func decrement_water_level() -> void:
	water_level -= 1.0 / 600 # 10 mins til dehydration for now TODO put this as a global?

# Called when crop level is between 25% and 50%
func set_dehydrated() -> void:
	# crop grows at half the rate
	timer.start(timer.time_left * 2)
	
# Called when crop level is between 0% and 25%
func set_extremely_dehydrated() -> void:
	# crop grows at a quarter of the rate
	timer.start(timer.time_left * 4)

func get_ground_cell() -> Vector2i:
	return ground_cell
	
func set_ground_cell(cell: Vector2i) -> void:
	ground_cell = cell

func set_crop_name(name: String) -> void:
	crop_name = name
