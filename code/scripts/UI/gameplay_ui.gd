class_name GameplayUI
extends CanvasLayer

@onready var player:Movement = %Player
@onready var inventory_interface:InventoryDialog = %InventoryInterface
var hand:Hand

func _ready():
	hand = player.get_node("%Hand")
	hand.inventory.item_added.connect(inventory_interface.add_item_to_slot)
	hand.inventory.item_stacked.connect(inventory_interface.item_stacked_to_slot)
	inventory_interface.slot_removed.connect(hand.inventory.remove_item)
	inventory_interface.backpack_inventory.hide()
	hand.inventory.item_removed.connect(inventory_interface.remove_item_from_slot)
	hand.hand_slot_changed.connect(inventory_interface.focus_hand_slot)
	inventory_interface.slot_moved.connect(hand.inventory.move_item)

func _unhandled_input(event):
	if(event.is_action_pressed("p_inventory")):
		if inventory_interface.backpack_inventory.visible == true:
			inventory_interface.close_backpack(hand.current_hand_item)
		else:
			inventory_interface.open_backpack()
