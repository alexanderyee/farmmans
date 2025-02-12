class_name Grass
extends Node2D

var growth_stage := 0
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	area_2d.collision_layer = 32
