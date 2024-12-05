class_name InventoryDialog
extends PanelContainer

@export var slot_scene: PackedScene
@onready var item_grid: ItemGrid = %ItemGrid


func open():
	show()
	refresh()
	
func _on_close_button_pressed() -> void:
	hide()

func _on_player_inventory_change() -> void:
	refresh()

func refresh():
	item_grid.display(Inventory.get_contents().slice(6), 6)
