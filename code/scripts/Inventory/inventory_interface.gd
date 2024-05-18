class_name InventoryDialog
extends Control

@export var slot_scene:PackedScene

@onready var backpack_grid:GridContainer = %BackpackGrid
@onready var hand_grid:HBoxContainer = %HandGrid
@onready var backpack_inventory:PanelContainer = %BackpackInventory

var slots_nodes:Array[InventorySlot]

signal slot_removed(index:int)
signal slot_moved(origin:int, destination:int)

func add_item_to_slot(index:int, inventory:Inventory):
	slots_nodes[index].display_slot(inventory.content[index])

func item_stacked_to_slot(index:int, inventory:Inventory):
	slots_nodes[index].update_stack_slot(inventory.content[index].items_stacked)

func remove_item_from_slot(index:int, stack:int): 
	if stack < 1:
		slots_nodes[index].restore_slot()
	else:
		slots_nodes[index].update_stack_slot(stack)

func open_backpack():
	backpack_inventory.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_backpack(current_hand_item:int):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	for slot in slots_nodes:
		if slot.slot_index == current_hand_item:
			continue
		slot.blur_slot()

	backpack_inventory.hide()


func focus_hand_slot(index:int, old_index:int = -1):
	if old_index != -1:
		slots_nodes[old_index].focus_indicator.hide()

	slots_nodes[index].focus_indicator.show()

func get_hovered_slot():
	for slot in slots_nodes:
		if (slot.mouse_on_slot):
			return slot.slot_index
	return -1

func dropping_item(item_to_drop:int):
	prints("dropping item", item_to_drop)

func move_item_to_slot(origin:int):
	var destination:int = get_hovered_slot()
	if destination == -1:
		dropping_item(origin)
		return
	slot_moved.emit(origin, destination)

	var origin_slot_texture:Texture2D = slots_nodes[origin].texture_rect.texture
	var origin_slot_stack:String = slots_nodes[origin].label.text

	slots_nodes[origin].texture_rect.texture = slots_nodes[destination].texture_rect.texture
	slots_nodes[origin].label.text = slots_nodes[destination].label.text

	slots_nodes[destination].texture_rect.texture = origin_slot_texture
	slots_nodes[destination].label.text = origin_slot_stack
	
	slots_nodes[origin].update_stack_slot(
		slots_nodes[origin].label.text.to_int()
	)
	slots_nodes[destination].update_stack_slot(
		slots_nodes[destination].label.text.to_int()
	)

func emit_signal_slot_removed(index:int):
	slot_removed.emit(index)

func _ready():
	slots_nodes.append_array(hand_grid.get_children())
	slots_nodes.append_array(backpack_grid.get_children())
	
	for index in range(slots_nodes.size()):
		slots_nodes[index].slot_index = index
		slots_nodes[index].remove_item_input.connect(emit_signal_slot_removed)
		slots_nodes[index].moved_item.connect(move_item_to_slot)
