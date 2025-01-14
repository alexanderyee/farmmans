extends Node2D

@onready var soil: TileMapLayer = $soil

# constants
const SOIL_ATLAS_ID := 0
const FLAT_GROUND_ATLAS_COORDS := Vector2i(1, 1)

func _on_player_tool_usage(action: String, player_pos:Vector2, direction: String) -> void:
	var soil_cell := get_relative_tile_to_player(player_pos, direction)
	
	# get atlas coord for tile
	var atlas_coords = soil.get_cell_atlas_coords(soil_cell)
	
	# tilling (hoe)
	if action == "TILL":
		# we should only be able to till flat ground (no cliffs, slopes, hills)
		# TODO replace with custom data attached to tilesets
		if atlas_coords == FLAT_GROUND_ATLAS_COORDS or atlas_coords.y >= 5:
			soil.set_cell(soil_cell, SOIL_ATLAS_ID, FLAT_GROUND_ATLAS_COORDS)
			
			
	pass


func _on_player_highlight_tile_tool(player_pos:Vector2, direction: String) -> void:
	var soil_cell := get_relative_tile_to_player(player_pos, direction)
	
	# params for shader code
	var tile_size = Vector2(16, 16)
	var highlight_color = Vector4(1.0, 1.0, 1.0, 1.0)
	var map_local = soil.map_to_local(soil_cell)
	soil.material.set_shader_parameter("tile_size", tile_size)
	soil.material.set_shader_parameter("highlight_pos", Vector2(soil_cell))
	soil.material.set_shader_parameter("highlight_color", highlight_color)
	soil.material.set_shader_parameter("highlight_intensity", 0.2)
	

func get_relative_tile_to_player(player_pos:Vector2, direction: String) -> Vector2i:
	var soil_cell : Vector2i = (soil.local_to_map(player_pos))
	match direction:
		"forward":
			soil_cell.y += 1
		"down":
			soil_cell.y -= 1
		"right":
			soil_cell.x += 1
		"left":
			soil_cell.x -= 1
	return soil_cell
