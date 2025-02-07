extends Node2D

# Signals
signal cell_state_updated

@onready var grass: TileMapLayer = $Grass
@onready var grass_hill: TileMapLayer = $GrassHill
@onready var tilled_soil: TileMapLayer = $TilledSoil
@onready var farm_plants: TileMapLayer = $FarmPlants
@onready var tall_farm_plants: TileMapLayer = $TallFarmPlants
@onready var crop_manager: CropManager = %CropManager

# constants
const LAYER_NAMES := ["GRASS_HILL", "GRASS", "TILLED_SOIL"]
const GROUND_ATLAS_ID := 0
const FLAT_GROUND_ATLAS_COORDS := Vector2i(1, 1)
const GRASS_TERRAIN_ID := 1
const TILLED_SOIL_TERRAIN_ID := 2
const TILLED_DIRT_SOURCE_ID := 7
const FARM_PLANTS_SOURCE_ID := 8
const WATERED_TILLED_DIRT_SOURCE_ID := 9
const SEMI_WATERED_TILLED_DIRT_SOURCE_ID := 10
const DEHYDRATION_RATE = 1.0 / 1200.0

var water_levels := {}

func _process(delta: float) -> void:
	for ground_cell in water_levels:
		var current_water_level = water_levels[ground_cell]
		var tilled_atlas_coords = tilled_soil.get_cell_atlas_coords(ground_cell)
		var tilled_source_id = tilled_soil.get_cell_source_id(ground_cell)
		if current_water_level > 0.0:
			water_levels[ground_cell] -= DEHYDRATION_RATE
			current_water_level = water_levels[ground_cell]
			if water_levels[ground_cell] <= 0.0:
				emit_signal("cell_state_updated", ground_cell, current_water_level)
		
		if current_water_level < 0.25 and tilled_source_id != TILLED_DIRT_SOURCE_ID:
			tilled_soil.set_cell(ground_cell, TILLED_DIRT_SOURCE_ID, tilled_atlas_coords)
			emit_signal("cell_state_updated", ground_cell, current_water_level)
		elif current_water_level < 0.5 and tilled_source_id != SEMI_WATERED_TILLED_DIRT_SOURCE_ID \
			and tilled_source_id != TILLED_DIRT_SOURCE_ID:
			tilled_soil.set_cell(ground_cell, SEMI_WATERED_TILLED_DIRT_SOURCE_ID, tilled_atlas_coords)
			emit_signal("cell_state_updated", ground_cell, current_water_level)
		
func _on_player_tool_usage(tool: Item, player_pos:Vector2, direction: String) -> void:
	var ground_cell := get_relative_tile_to_player(player_pos, direction)
	
	# get atlas coords for tile
	var grass_atlas_coords = grass.get_cell_atlas_coords(ground_cell)
	var tilled_atlas_coords = tilled_soil.get_cell_atlas_coords(ground_cell)
	var farm_plant_atlas_coords = farm_plants.get_cell_atlas_coords(ground_cell)
	var is_cell_occupied_by_crop: bool = farm_plant_atlas_coords.x >= 0 and farm_plant_atlas_coords.y >= 0
	
	match tool.action:
		"TILL":
			# we should only be able to till flat ground (no cliffs, slopes, hills)
			# TODO replace with custom data attached to tilesets (could possibly also use custom
			#      data for planting seeds
			if grass_atlas_coords == FLAT_GROUND_ATLAS_COORDS or grass_atlas_coords.y >= 5:
				if !is_cell_occupied_by_crop:
					tilled_soil.set_cells_terrain_connect([ground_cell], GROUND_ATLAS_ID, TILLED_SOIL_TERRAIN_ID)
		"PLANT":
			# should only be able to plant on tilled ground
			if tilled_atlas_coords.x >= 0 and tilled_atlas_coords.y >= 0 and !is_cell_occupied_by_crop:
				var seed_atlas_coords = get_seed_atlas_coords(tool)
				var ground_cell_water_level = water_levels.get(ground_cell, 0.0)
				if seed_atlas_coords.x >= 0 and seed_atlas_coords.y >= 0:
					farm_plants.set_cell(ground_cell, FARM_PLANTS_SOURCE_ID, seed_atlas_coords)
					crop_manager.add_crop(tool, ground_cell, ground_cell_water_level)
				pass
		"WATER":
			# should only be able to water tilled ground
			if tilled_atlas_coords.x >= 0 and tilled_atlas_coords.y >= 0:
				# set cell to watered version
				tilled_soil.set_cell(ground_cell, WATERED_TILLED_DIRT_SOURCE_ID, tilled_atlas_coords)
				# start keeping track of water level of cell
				water_levels[ground_cell] = 1.0
				emit_signal("cell_state_updated", ground_cell, 1.0)
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

func get_crop_stage_atlas_coords(crop_name: String, crop_stage: int) -> Vector2i:
	if crop_name == "Corn":
		return Vector2i(crop_stage - 1, 1)
	return Vector2i(-1, -1)

func _on_crop_manager_grow_crop(crop_name: String, crop_stage: int, crop_cell: Vector2i) -> void:
	# advance crop at crop_cell to next stage
	var crop_atlas_coords = get_crop_stage_atlas_coords(crop_name, crop_stage)
	if crop_atlas_coords.x >= 0 and crop_atlas_coords.y >= 0:
		farm_plants.set_cell(crop_cell, FARM_PLANTS_SOURCE_ID, crop_atlas_coords)
		# corn edge case
		if crop_name == "Corn" and crop_stage >= 4:
			# if we are at stage 4 or beyond, the corn crop is 2 tiles tall
			var tile_above_crop = crop_cell
			tile_above_crop.y -= 1
			var tall_crop_atlas_coords = crop_atlas_coords
			tall_crop_atlas_coords.y -= 1
			tall_farm_plants.set_cell(tile_above_crop, FARM_PLANTS_SOURCE_ID, tall_crop_atlas_coords)

func get_water_level(ground_cell: Vector2i) -> float:
	return water_levels[ground_cell]
