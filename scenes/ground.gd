extends Node2D

@onready var grass: TileMapLayer = $Grass
@onready var grass_hill: TileMapLayer = $GrassHill
@onready var tilled_soil: TileMapLayer = $TilledSoil
@onready var farm_plants: TileMapLayer = $FarmPlants

# constants
const LAYER_NAMES := ["GRASS_HILL", "GRASS", "TILLED_SOIL"]
const GROUND_ATLAS_ID := 0
const FLAT_GROUND_ATLAS_COORDS := Vector2i(1, 1)
const GRASS_TERRAIN_ID := 1
const TILLED_SOIL_ID := 2
const FARM_PLANTS_SOURCE_ID := 8

func _on_player_tool_usage(tool: Item, player_pos:Vector2, direction: String) -> void:
	var ground_cell := get_relative_tile_to_player(player_pos, direction)
	
	# get atlas coords for tile
	var grass_atlas_coords = grass.get_cell_atlas_coords(ground_cell)
	var tilled_atlas_coords = tilled_soil.get_cell_atlas_coords(ground_cell)
	
	match tool.action:
		"TILL":
			# we should only be able to till flat ground (no cliffs, slopes, hills)
			# TODO replace with custom data attached to tilesets (could possibly also use custom
			#      data for planting seeds
			if grass_atlas_coords == FLAT_GROUND_ATLAS_COORDS or grass_atlas_coords.y >= 5:
				tilled_soil.set_cells_terrain_connect([ground_cell], GROUND_ATLAS_ID, TILLED_SOIL_ID)
		"PLANT":
			# should only be able to plant on tilled ground
			if tilled_atlas_coords.x >= 0 and tilled_atlas_coords.y >= 0:
				var seed_atlas_coords = get_seed_atlas_coords(tool)
				if seed_atlas_coords.x >= 0 and seed_atlas_coords.y >= 0:
					farm_plants.set_cell(ground_cell, FARM_PLANTS_SOURCE_ID, seed_atlas_coords)
				pass
	
	pass


func _on_player_highlight_tile_tool(player_pos:Vector2, direction: String, tool_equipped: bool) -> void:
	var ground_cell := get_relative_tile_to_player(player_pos, direction)
	
	# params for shader code
	var tile_size = Vector2(16, 16)
	var highlight_color = Vector4(1.0, 1.0, 1.0, 1.0)
	var map_local = grass.map_to_local(ground_cell)
	grass.material.set_shader_parameter("tile_size", tile_size)
	grass.material.set_shader_parameter("highlight_pos", Vector2(ground_cell))
	grass.material.set_shader_parameter("highlight_color", highlight_color)
	grass.material.set_shader_parameter("highlight_intensity", 0.2)
	grass.material.set_shader_parameter("tool_equipped", tool_equipped)


func get_relative_tile_to_player(player_pos:Vector2, direction: String) -> Vector2i:
	var cell : Vector2i = (grass.local_to_map(player_pos))
	match direction:
		# TODO maybe just split into ternarys left/right up/down?
		"right":
			cell.x += 1
		"down_right":
			cell.x += 1
			cell.y += 1
		"down":
			cell.y += 1
		"down_left":
			cell.x -= 1
			cell.y += 1
		"left":
			cell.x -= 1
		"up_left":
			cell.x -= 1
			cell.y -= 1
		"up":
			cell.y -= 1
		"up_right":
			cell.y -= 1
			cell.x += 1
	return cell

func get_seed_atlas_coords(item: Item) -> Vector2i:
	if item.name == "Corn Seed":
		return Vector2i(0, 1)
	return Vector2i(-1, -1)
