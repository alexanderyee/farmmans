class_name HurtBox
extends Area2D

@onready var health_component: HealthComponent = $"../HealthComponent"

func _init() -> void:
	collision_layer = 16
	collision_mask = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func take_damage(damage: int, hitstun_frames: int, knockback: int, pos_hit_from: Vector2) -> void:
	# parent health decrease? maybe do a check if parent has a health/take dam func?
	
	health_component.subtract_health(damage)
	if get_parent().has_method("take_hitstun"):
		get_parent().take_hitstun(hitstun_frames, knockback, pos_hit_from)
	print("ow from: " + str(get_parent()) + ", at " + str(health_component.get_health()) + " health")
