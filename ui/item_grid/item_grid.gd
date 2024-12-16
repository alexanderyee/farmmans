class_name ItemGrid
extends GridContainer

@export var slot_scene: PackedScene
const EQUIPPED_ITEM_THEME = preload("res://ui/hotbar/equipped_item_theme.tres")

func display(items: Array[Item], starting_slot_id: int):
	for child in get_children():
		child.queue_free()
	
	var i = starting_slot_id
	var equipped_slot = Inventory.get_equipped_slot()
	for item in items:
		var slot = slot_scene.instantiate()
		if equipped_slot == i:
			slot.get_child(0).get_child(0).theme = EQUIPPED_ITEM_THEME
		add_child(slot)
		slot.display(item)
		slot.set_slot_id(i)
		i+=1

func set_slot_data(item: Item, slot_id: int):
	for child in get_children():
		if child._id == slot_id:
			child._item = item
			child.texture_rect.texture = item.icon if item else null
			return
	get_tree().call_group("inventory_ui", "refresh")
