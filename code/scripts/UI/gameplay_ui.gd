class_name GameplayUI
extends CanvasLayer

@onready var player:Movement = %Player
@onready var inventory_interface:InventoryDialog = %InventoryInterface
@onready var selfcare_interface:SelfCareInterface = %SelfcareInterface

@onready var hand:Hand = %Player/%Hand
@onready var selfcare:SelfCare = %Player/%SelfCare

func _ready():
	hand = player.get_node("%Hand")
	hand.inventory.item_added.connect(inventory_interface.add_item_to_slot)
	hand.inventory.item_stacked.connect(inventory_interface.item_stacked_to_slot)

	inventory_interface.slot_removed.connect(hand.inventory.remove_item)
	hand.inventory.item_removed.connect(inventory_interface.remove_item_from_slot)
	
	hand.hand_slot_changed.connect(inventory_interface.focus_hand_slot)
	inventory_interface.slot_moved.connect(hand.inventory.move_item)

	inventory_interface.slot_dropped.connect(hand.drop_item)
	inventory_interface.backpack_inventory.hide()

func _process(_delta):
	selfcare_interface.health_bar.value = selfcare.health * 100
	selfcare_interface.hunger_bar.value = selfcare.hunger * 100
	selfcare_interface.stamina_bar.value = selfcare.stamina * 100
	selfcare_interface.move_temperature_indicator(selfcare.get_complete_temperature_weight())

func _unhandled_input(event):
	if(event.is_action_pressed("p_inventory")):
		if inventory_interface.backpack_inventory.visible == true:
			inventory_interface.close_backpack(hand.current_hand_item)
		else:
			inventory_interface.open_backpack()
