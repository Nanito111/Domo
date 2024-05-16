class_name InventoryDialog
extends Control

@export var slot_scene:PackedScene

const MAX_BACKPACK_ITEMS:int = 15
const MAX_HAND_ITEMS:int = 5

@onready var backpack_grid:GridContainer = %BackpackGrid
@onready var hand_grid:HBoxContainer = %HandGrid
@onready var backpack_inventory:Panel = %BackpackInventory

var slots_nodes:Array[InventorySlot]

func add_item_to_slot(index:int, inventory:Inventory):
	slots_nodes[index].display_slot(inventory._content[index])

func remove_item_from_slot(index:int):
	slots_nodes[index].restore_slot()

func open_backpack():
	backpack_inventory.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_backpack():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	backpack_inventory.hide()

func _ready():
	slots_nodes.append_array(hand_grid.get_children())
	slots_nodes.append_array(backpack_grid.get_children())
