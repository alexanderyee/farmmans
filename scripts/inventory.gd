extends Node

const INVENTORY_SIZE := 36
var _contents:Array[Item] = []

func _ready():
	pass

func _init() -> void:
	resize_inventory(INVENTORY_SIZE)
	pass
	
func add_item(item: Item):
	_contents[_contents.find(null)] = item
	
func add_item_at_index(idx: int, item: Item):
	_contents[idx] = item

func remove_item(item: Item):
	var item_index = _contents.find(item)
	_contents[item_index] = null

func remove_item_at_index(item_index: int):
	_contents[item_index] = null

func swap_items_at_positions(pos1: int, pos2: int):
	var pos1_item = _contents[pos1]
	_contents[pos1] = _contents[pos2]
	_contents[pos2] = pos1_item
	
func get_contents() -> Array[Item]:
	return _contents
	
func get_item_at_slot(slot_id: int):
	return _contents[slot_id]
	
func get_hotbar() -> Array[Item]:
	return _contents.slice(0, 6)

func has_all(items: Array[Item]) -> bool:
	var needed:Array[Item] = items.duplicate()
	
	for available in _contents:
		needed.erase(available)
	
	return needed.is_empty()
	
func resize_inventory(size: int):
	_contents.resize(size)
