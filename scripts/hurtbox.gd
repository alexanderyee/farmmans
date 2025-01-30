class_name HurtBox
extends Area2D

func _init() -> void:
	collision_layer = 16
	collision_mask = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func take_damage(damage: int) -> void:
	# parent health decrease? maybe do a check if parent has a health/take dam func?
	print("ow from: " + str(get_parent()))
	
