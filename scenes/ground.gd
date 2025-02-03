extends Node2D

@onready var soil: TileMapLayer = $Soil
@onready var grass: TileMapLayer = $Grass
@onready var grass_hill: TileMapLayer = $GrassHill

# constants
const SOIL_ATLAS_ID := 0
const FLAT_GROUND_ATLAS_COORDS := Vector2i(1, 1)
const GRASS_TERRAIN_ID := 1

func _on_player_tool_usage(action: String, player_pos:Vector2, direction: String) -> void:
	var soil_cell := get_relative_tile_to_player(player_pos, direction)
	
	# get atlas coord for tile
	var atlas_coords = soil.get_cell_atlas_coords(soil_cell)
	
	match action:
		"TILL":
			# we should only be able to till flat ground (no cliffs, slopes, hills)
			# TODO replace with custom data attached to tilesets
			if atlas_coords == FLAT_GROUND_ATLAS_COORDS or atlas_coords.y >= 5:
				# we just remove the grass
				grass.erase_cell(soil_cell)
				# get adjacent cells
				
				#grass.set_cells_terrain_path(get_adjacent_cells(soil_cell), 0, 1)
				# we still set the soil to match what was on grass
				#soil.set_cell(soil_cell, SOIL_ATLAS_ID, atlas_coords)
		"PLANT":
			# should only be able to plant on tilled ground
				if atlas_coords == FLAT_GROUND_ATLAS_COORDS:
					pass
	
	pass


func _on_player_highlight_tile_tool(player_pos:Vector2, direction: String, tool_equipped: bool) -> void:
	var soil_cell := get_relative_tile_to_player(player_pos, direction)
	
	# params for shader code
	var tile_size = Vector2(16, 16)
	var highlight_color = Vector4(1.0, 1.0, 1.0, 1.0)
	var map_local = soil.map_to_local(soil_cell)
	soil.material.set_shader_parameter("tile_size", tile_size)
	soil.material.set_shader_parameter("highlight_pos", Vector2(soil_cell))
	soil.material.set_shader_parameter("highlight_color", highlight_color)
	soil.material.set_shader_parameter("highlight_intensity", 0.2)
	soil.material.set_shader_parameter("tool_equipped", tool_equipped)


func get_relative_tile_to_player(player_pos:Vector2, direction: String) -> Vector2i:
	var soil_cell : Vector2i = (soil.local_to_map(player_pos))
	match direction:
		# TODO maybe just split into ternarys left/right up/down?
		"right":
			soil_cell.x += 1
		"down_right":
			soil_cell.x += 1
			soil_cell.y += 1
		"down":
			soil_cell.y += 1
		"down_left":
			soil_cell.x -= 1
			soil_cell.y += 1
		"left":
			soil_cell.x -= 1
		"up_left":
			soil_cell.x -= 1
			soil_cell.y -= 1
		"up":
			soil_cell.y -= 1
		"up_right":
			soil_cell.y -= 1
			soil_cell.x += 1
	return soil_cell

func get_adjacent_cells(cell: Vector2i) -> Array:
	var directions := [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), # Top-left,    Top,   Top-right
		Vector2i(-1, 0),                   Vector2i(1, 0),  # Left,                Right
		Vector2i(-1, 1), Vector2i(0, 1),   Vector2i(1, 1)   # Bottom-left, Bottom, Bottom-right
	]
	
	var adjacent_cells := []
	for dir in directions:
		adjacent_cells.append(cell + dir)
	
	return adjacent_cells
