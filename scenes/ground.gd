extends Node2D

@onready var soil: TileMapLayer = $soil

# constants
const SOIL_ATLAS_ID := 0
const FLAT_GROUND_ATLAS_COORDS := Vector2i(1, 1)

func _on_player_tool_usage(action: String, player_pos:Vector2, direction: String) -> void:
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
	# get atlas coord for tile
	var atlas_coords = soil.get_cell_atlas_coords(soil_cell)
	
	# tilling (hoe)
	if action == "TILL":
		# we should only be able to till flat ground (no cliffs, slopes, hills)
		if atlas_coords == FLAT_GROUND_ATLAS_COORDS or atlas_coords.y >= 5:
			soil.set_cell(soil_cell, SOIL_ATLAS_ID, FLAT_GROUND_ATLAS_COORDS)
	pass
