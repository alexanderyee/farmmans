class_name CowSit
extends State

@export var cow: CharacterBody2D

var sit_time: float

func enter():
	cow.set_is_sitting(true)
	sit_time = randf_range(2, 5)
	
func exit():
	cow.set_is_sitting(false)
	
func update(delta: float):
	if sit_time > 0:
		sit_time -= delta
	else:
		transitioned.emit(self, "Idle")
	
func physics_update(delta: float):
	if cow:
		cow.velocity = Vector2.ZERO
	
