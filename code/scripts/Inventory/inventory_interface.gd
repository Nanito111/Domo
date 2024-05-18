class_name InventoryDialog
extends Control

@export var slot_scene:PackedScene

@onready var backpack_grid:GridContainer = %BackpackGrid
@onready var hand_grid:HBoxContainer = %HandGrid
@onready var backpack_inventory:PanelContainer = %BackpackInventory

var slots_nodes:Array[InventorySlot]

signal slot_removed(index:int)

func add_item_to_slot(index:int, inventory:Inventory):
	slots_nodes[index].display_slot(inventory.content[index])

func item_stacked_to_slot(index:int, inventory:Inventory):
	slots_nodes[index].update_stack_slot(inventory.content[index])

func remove_item_from_slot(index:int):
	slots_nodes[index].restore_slot()
	slot_removed.emit(index)

func open_backpack():
	backpack_inventory.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_backpack():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	backpack_inventory.hide()

func _ready():
	slots_nodes.append_array(hand_grid.get_children())
	slots_nodes.append_array(backpack_grid.get_children())
	
	for index in range(slots_nodes.size()):
		slots_nodes[index].slot_index = index
		slots_nodes[index].remove_item_input.connect(remove_item_from_slot)
