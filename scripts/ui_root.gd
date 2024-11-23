extends CanvasLayer

@export var all_recipe_resources: ResourceGroup

@onready var player: CharacterBody2D = %Player
@onready var inventory_dialog: InventoryDialog = %InventoryDialog
@onready var crafting_dialog: CraftingDialog = %CraftingDialog
@onready var hotbar: Hotbar = %Hotbar

const INVENTORY_SIZE = 36

var _all_recipes:Array[Recipe] = []

func _ready() -> void:
	all_recipe_resources.load_all()
	all_recipe_resources.load_all_into(_all_recipes)
	player.inventory.resize_inventory(INVENTORY_SIZE)
	
	hotbar.refresh_hotbar(player.inventory)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("inventory"):
		if not inventory_dialog.visible:
			inventory_dialog.open(player.inventory)
			crafting_dialog._on_close_button_pressed()
		else:
			inventory_dialog._on_close_button_pressed()
	if event.is_action_released("crafting"):
		if not crafting_dialog.visible:
			crafting_dialog.open(_all_recipes, player.inventory)
			inventory_dialog._on_close_button_pressed()
		else:
			crafting_dialog._on_close_button_pressed()
		
