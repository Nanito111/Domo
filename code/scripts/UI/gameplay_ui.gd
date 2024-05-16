class_name GameplayUI
extends CanvasLayer

@onready var player = %Player

@onready var inventory_interface:InventoryDialog = %InventoryInterface
var hand:Hand

func _ready():
	hand = player.get_node("%Hand")
	hand.inventory.item_added.connect(inventory_interface.add_item_to_slot)
	inventory_interface.backpack_inventory.hide()
	inventory_interface.slot_removed.connect(hand.inventory.remove_item)

func _unhandled_input(event):
	if(event.is_action_pressed("p_inventory")):
		if inventory_interface.backpack_inventory.visible == true:
			inventory_interface.close_backpack()
		else:
			inventory_interface.open_backpack()
