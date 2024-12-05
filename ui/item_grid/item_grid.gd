class_name ItemGrid
extends GridContainer

@export var slot_scene: PackedScene

func display(items: Array[Item], starting_slot_id: int):
	for child in get_children():
		child.queue_free()
	
	var i = starting_slot_id
	for item in items:
		var slot = slot_scene.instantiate()
		add_child(slot)
		slot.display(item)
		slot.set_slot_id(i)
		i+=1

func item_selected(slot):
	print(slot)
	print(slot.get_slot_id())

func item_released(slot):
	print(slot)
	print(slot.get_slot_id())

func set_slot_data(item: Item, slot_id: int):
	for child in get_children():
		if child._id == slot_id:
			child._item = item
			child.texture_rect.texture = item.icon if item else null
			return
	get_tree().call_group("inventory_ui", "refresh")
