extends Node2D

@onready var soil: TileMapLayer = $soil
@onready var lightgrass: TileMapLayer = $lightgrass
@onready var darkergrasshill: TileMapLayer = $darkergrasshill

var ALL_TILEMAP_LAYERS = [soil, lightgrass, darkergrasshill]
func _on_player_tool_usage(action: String, player_pos:Vector2, direction: String) -> void:
	print(player_pos)
	var soil_cell = (soil.local_to_map(player_pos))
	match direction:
		"forward":
			soil_cell.y += 1
		"down":
			soil_cell.y -= 1
		"right":
			soil_cell.x += 1
		"left":
			soil_cell.x -= 1
	var soil_cell_data = soil.get_cell_tile_data(soil_cell)
	soil.set_cell(soil_cell, 0, Vector2i(1,1))
	pass
