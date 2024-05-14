class_name Hand
extends RayCast3D

var inventory:Inventory = Inventory.new()

enum PickerStates {
	ON,
	OUT,
}
var picker_item_state: PickerStates = PickerStates.OUT

signal picker_entered
signal picker_exited

func pickup_item(item_instance:ItemObject):
	var item_added: bool = inventory.add_item(item_instance.item_resource)
	if item_added == true:
		item_instance.pickup()
		print("item picked! item is ", item_instance.item_resource.name)
	else:
		print("item not picked! backpack is full ")

func picker_handler():
	if (is_colliding() and get_collider() is ItemObject):
		if (picker_item_state == PickerStates.OUT):
			picker_item_state = PickerStates.ON
			picker_entered.emit()
			
	elif (not is_colliding() and picker_item_state != PickerStates.OUT):
		picker_item_state = PickerStates.OUT
		picker_exited.emit()

func _process(_delta):
	picker_handler()

func _unhandled_input(event):
	if (event.is_action_pressed("p_pick_item") and picker_item_state == PickerStates.ON):
		pickup_item(get_collider() as ItemObject)
		
