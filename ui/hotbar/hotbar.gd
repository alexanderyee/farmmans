class_name Hotbar
extends PanelContainer

@export var slot_scene: PackedScene
@onready var item_grid: ItemGrid = %ItemGrid

func _ready():
	refresh()

func refresh() -> void:
	item_grid.display(Inventory.get_hotbar(), 0)

func _on_player_inventory_change() -> void:
	refresh()
