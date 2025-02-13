extends Node

enum CROP_STAGES {SAPLING, CROSSBREEDING, MATURING, FRUITING, RIPE, DYING, DEAD}
const DEHYDRATION_STAGE_LENGTH_FACTOR := 2
const EXTREME_DEHYDRATION_STAGE_LENGTH_FACTOR := 4
const TILE_SIZE := 16
const ITEM_RES_PATH = "res://data/items/"

func get_item_resource(item_name: String) -> Item:
	var path := ITEM_RES_PATH + item_name.to_snake_case() + ".tres"
	if ResourceLoader.exists(path):
		var item: Item = ResourceLoader.load(path)
		return item
	return null
