extends PanelContainer

@onready var texture_rect: TextureRect = %TextureRect
var _id

func display(item:Item):
	if item != null:
		texture_rect.texture = item.icon

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if get_parent().has_method("item_selected"):
			get_parent().item_selected(self)
	if event is InputEventMouseButton and event.is_released():
		if get_parent().has_method("item_selected"):
			get_parent().item_released(self)
	pass # Replace with function body.

func set_slot_id(id: int):
	_id = id

func get_slot_id() -> int:
	return _id
