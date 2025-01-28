class_name HitBox
extends Area2D

@export var damage := 10

func _init() -> void:
	collision_layer = 5
	collision_mask = 0

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
