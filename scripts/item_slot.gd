extends PanelContainer

@onready var texture_rect: TextureRect = %TextureRect
var _id
var _item

class SlotInfo:
	var id: int
	var item: Item
	func _init(_id, _item):
		id = _id
		item = _item

func display(item:Item):
	if item != null:
		texture_rect.texture = item.icon
		_item = item

func set_slot_id(id: int):
	_id = id

func get_slot_id() -> int:
	return _id

func _get_drag_data(at_position: Vector2) -> Variant:
	
	var drag_preview: Control = make_preview()
	set_drag_preview(drag_preview)
	return SlotInfo.new(_id, _item)
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is SlotInfo
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	# swap
	Inventory.swap_items_at_positions(data.id, _id)
	var item_copy = _item.duplicate() if _item else null
	texture_rect.texture = data.item.icon
	_item = data.item
	
	# set original slot's data to ours
	if get_parent().has_method("set_slot_data"):
		get_parent().set_slot_data(item_copy, data.id)
		
	
func make_preview() -> Control:
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture_rect.texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(48, 48)
	preview_texture.position = Vector2(-24, -24)
	var preview = Control.new()
	preview.add_child(preview_texture)
	
	return preview
