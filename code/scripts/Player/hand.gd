class_name Hand
extends RayCast3D

var inventory:Inventory = Inventory.new()
var current_hand_item:int = 0
var hands_items:Array[Node3D] = []
@export var hand_item_pivot:Node3D

enum PickerStates {
	ON,
	OUT,
}
var picker_item_state: PickerStates = PickerStates.OUT

signal picker_entered
signal picker_exited
signal hand_slot_changed(index:int, old_index:int)

func pickup_item(item_object:ItemObject):
	var item_added: bool = inventory.add_item(
		Item.new(item_object.item_resource, item_object.items_stacked),
		inventory.content.find(null)
	)

	if item_added == true:
		item_object.pickup()
		#print("item picked! item is ", item_instance.item_resource.name)
	#else:
		#print("item not picked! backpack is full ")

func picker_handler():
	if (is_colliding() and get_collider().get_parent().get_parent() is ItemObject):
		if (picker_item_state == PickerStates.OUT):
			picker_item_state = PickerStates.ON
			picker_entered.emit()
			
	elif (not is_colliding() and picker_item_state != PickerStates.OUT):
		picker_item_state = PickerStates.OUT
		picker_exited.emit()

func hand_inventory_input(event:InputEvent):
	var last_hand_item:int = current_hand_item

	if (event.is_action("p_hand_slot_0")):
		current_hand_item = 0
	elif ((event.is_action("p_hand_slot_1"))):
		current_hand_item = 1
	elif ((event.is_action("p_hand_slot_2"))):
		current_hand_item = 2
	elif ((event.is_action("p_hand_slot_3"))):
		current_hand_item = 3
	elif ((event.is_action("p_hand_slot_4"))):
		current_hand_item = 4
	
	
	if hands_items[last_hand_item] != null:
		hands_items[last_hand_item].hide()

	if hands_items[current_hand_item] != null:
		hands_items[current_hand_item].show()

	hand_slot_changed.emit(current_hand_item, last_hand_item)

func add_hand_item(item_index:int, _inventory):
	if item_index > 4:
		return

	hands_items[item_index] = inventory.content[item_index].item_resource.hand_instance.instantiate()
	hand_item_pivot.add_child(hands_items[item_index])

	if item_index == current_hand_item:
		hands_items[item_index].show()
	else:
		hands_items[item_index].hide()

func remove_hand_item(item_index:int, stack:int):
	if item_index > 4 or stack > 0:
		return

	hands_items[item_index].queue_free()
	hands_items[item_index] = null

func _ready():
	hands_items.resize(5)
	hands_items.fill(null)
	inventory.item_added.connect(add_hand_item)
	inventory.item_removed.connect(remove_hand_item)

func _physics_process(_delta):
	picker_handler()

func _unhandled_input(event:InputEvent):
	if (event.is_action_type() and event.is_pressed()):
		hand_inventory_input(event)
		
		if (event.is_action("p_pick_item") and picker_item_state == PickerStates.ON):
			pickup_item(get_collider().get_parent().get_parent() as ItemObject)
