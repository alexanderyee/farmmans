extends Node

const INVENTORY_SIZE := 36
const HOTBAR_SIZE := 6
var _contents:Array[Item] = []
var equipped_slot = -1

func _ready():
	pass

func _init() -> void:
	resize_inventory(INVENTORY_SIZE)
	pass

func add_item(item: Item):
	_contents[_contents.find(null)] = item

func add_item_at_index(idx: int, item: Item):
	_contents[idx] = item

# equippable items should be added to next available slot in hotbar
func add_equippable_item(item: Item):
	add_item(item)

# non-equippable items should just be added to next empty slot in main inv.
func add_non_equippable_item(item: Item):
	for i in range(HOTBAR_SIZE, INVENTORY_SIZE):
		if _contents[i] == null:
			_contents[i] = item
			return

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
	return _contents.slice(0, HOTBAR_SIZE)

func has_all(items: Array[Item]) -> bool:
	var needed:Array[Item] = items.duplicate()
	
	for available in _contents:
		needed.erase(available)
	
	return needed.is_empty()

func resize_inventory(size: int):
	_contents.resize(size)

func get_equipped_slot() -> int:
	return equipped_slot

func set_equipped_slot(slot_idx: int):
	equipped_slot = slot_idx
