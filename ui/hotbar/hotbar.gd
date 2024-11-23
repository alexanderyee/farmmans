class_name Hotbar
extends PanelContainer

@export var slot_scene: PackedScene
@onready var item_grid: ItemGrid = %ItemGrid

func _ready():
	pass

# for init
func refresh_hotbar(inventory: Inventory) -> void:
	item_grid.display(inventory.get_hotbar())

func _on_player_inventory_change(inventory: Inventory) -> void:
		item_grid.display(inventory.get_hotbar())
