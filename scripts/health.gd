class_name Health
extends Node

@export var health := 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func subtract_health(damage: int):
	health -= damage
	if health <= 0:
		get_parent().queue_free()
