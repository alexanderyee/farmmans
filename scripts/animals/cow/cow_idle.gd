class_name CowIdle
extends State

@export var cow: CharacterBody2D
@export var move_speed := 10.0

var move_direction: Vector2
var wander_time: float

func randomize_wander():
	# 50/50 chance the cow will stay still
	var should_move := randi() % 2 == 0
	if should_move:
		move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_time = randf_range(1, 3)
	else:
		# another 50/50 for whether the cow should sit
		var should_sit := randi() % 2 == 0
		if should_sit:
			transitioned.emit(self, "Sit")
		move_direction = Vector2.ZERO
		wander_time = randf_range(1, 3)
		
func enter():
	randomize_wander()
	
func update(delta: float):
	if wander_time > 0:
		wander_time -= delta
		# if cow is hungry and sees grass, we want to move towards it
		if cow.is_hungry() and cow.is_grass_in_sight():
			transitioned.emit(self, "Eat")
	else:
		randomize_wander()
		
func physics_update(delta: float):
	if cow:
		# TODO this serves as a quick fix rather than adding too many States,
		#      both in the animation_tree and StateMachine

		if cow.get_current_playing_anim() == "stand" or cow.is_being_milked:
			cow.velocity = Vector2.ZERO
		else:
			cow.velocity = move_direction * move_speed
