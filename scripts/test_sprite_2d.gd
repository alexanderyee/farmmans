extends Sprite2D

func _ready():
	var blue_value = 0.0
	material.set_shader_parameter("blue", blue_value)
