class_name CowEat
extends State

@export var cow: CharacterBody2D
@export var move_speed := 15.0

var move_direction: Vector2
var nearest_grass = null:
	set = set_nearest_grass
var eating_time := 3.0

func enter():
	nearest_grass = cow.get_nearest_grass()
	eating_time = 3.0
	
func update(delta: float):
	if (nearest_grass):
		var direction = nearest_grass.global_position - cow.global_position
		
		if direction.length() > 10:
			move_direction = direction
		else:
			# cow should start eating
			if !cow.is_eating:
				cow.set_is_eating(true)
			move_direction = Vector2.ZERO
			if eating_time > 0.0:
				eating_time -= delta
				if eating_time <= 0.0:
					cow.set_hunger(100.0)
		
		# cow should be done eating
		if !cow.is_hungry() and eating_time <= 0.0:
			cow.set_is_eating(false)
			nearest_grass = null # this should despawn the grass
			transitioned.emit(self, "Idle")

func physics_update(delta: float):
	if cow:
		cow.velocity = move_direction.normalized() * move_speed

func set_nearest_grass(grass) -> void:
	nearest_grass = grass
