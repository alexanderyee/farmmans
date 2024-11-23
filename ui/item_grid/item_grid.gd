class_name ItemGrid
extends GridContainer

@export var slot_scene: PackedScene
func display(items: Array[Item]):
	for child in get_children():
		child.queue_free()
	
	var i = 0
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
