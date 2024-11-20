extends Node2D

@onready var house_roof: TileMapLayer = $house_roof


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		house_roof.hide()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		house_roof.show()
