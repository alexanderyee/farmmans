class_name HurtBox
extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("area_entered", self._on_area_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox == null:
		return 
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
	
	pass
