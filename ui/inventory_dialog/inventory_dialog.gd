class_name InventoryDialog
extends PanelContainer

@export var slot_scene: PackedScene
@onready var grid_container: ItemGrid = %GridContainer

func open(inventory:Inventory):
	show()
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	grid_container.display(inventory.get_items())
	
func _on_close_button_pressed() -> void:
	hide()
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_player_on_inventory_change(inventory:Inventory) -> void:
	grid_container.display(inventory.get_items())
