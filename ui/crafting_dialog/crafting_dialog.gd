class_name CraftingDialog
extends PanelContainer

@export var slot_scene: PackedScene
@onready var recipe_list: ItemList = %RecipeList
@onready var ingredients_container: GridContainer = %IngredientsContainer
@onready var results_container: GridContainer = %ResultsContainer
@onready var craft_button: Button = %CraftButton
@onready var hotbar: Hotbar = $"../Hotbar"

var _selected_recipe:Recipe

func open(recipes:Array[Recipe]):
	show()
	
	recipe_list.clear()
	for recipe in recipes:
		var recipe_index = recipe_list.add_item(recipe.name)
		recipe_list.set_item_metadata(recipe_index, recipe)
	
	recipe_list.select(0)
	_on_recipe_list_item_selected(0)
	
func _on_close_button_pressed() -> void:
	hide()

func _on_recipe_list_item_selected(index: int) -> void:
	_selected_recipe = recipe_list.get_item_metadata(index)
	ingredients_container.display(_selected_recipe.ingredients)
	results_container.display(_selected_recipe.results)
	craft_button.disabled = not Inventory.has_all(_selected_recipe.ingredients)

func _on_craft_button_pressed() -> void:
	for item in _selected_recipe.ingredients:
		Inventory.remove_item(item)
	for item in _selected_recipe.results:
		Inventory.add_item(item)
	craft_button.disabled = not Inventory.has_all(_selected_recipe.ingredients)
	hotbar.refresh()
