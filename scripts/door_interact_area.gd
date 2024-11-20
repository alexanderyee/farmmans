extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@export var is_door_open := false
@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"

# TODO probably should move functionality to parent?
func toggle_door():
	if is_door_open:
		animated_sprite.play("door_close")
	else:
		animated_sprite.play("door_open")
	is_door_open = !is_door_open
	collision_shape.set_disabled(is_door_open)
