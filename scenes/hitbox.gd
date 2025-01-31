class_name Hitbox
extends Area2D

@export var damage := 10
@export var hitstun_frames := 30
@export var knockback := 100

func _init() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	# TODO normally I wouldn't like doing this but the class functions as a
	#      component sooo
	if get_parent().has_method("deal_damage"):
		get_parent().deal_damage(damage, hitstun_frames, knockback, area)

func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
