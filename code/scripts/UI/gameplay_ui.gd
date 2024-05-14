class_name GameplayUI
extends CanvasLayer

@onready var player = %Player

@onready var inventory_dialog:InventoryDialog = %InventoryDialog
var item_picker:ItemPicker

func _ready():
	item_picker = player.get_node("%ItemPicker")

func _unhandled_input(event):
	if(event.is_action_pressed("p_inventory")):
		if inventory_dialog.is_visible_in_tree():
			inventory_dialog.hide()
		else:
			inventory_dialog.open(item_picker.inventory)
