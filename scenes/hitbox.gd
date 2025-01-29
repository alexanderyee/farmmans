class_name HitBox
extends Area2D

@export var damage := 10

func _init() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
	pass # Replace with function body.



func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
