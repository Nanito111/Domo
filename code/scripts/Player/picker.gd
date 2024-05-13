class_name Picker
extends RayCast3D

enum PickerStates {
	ON,
	OUT,
}
var picker_item_state: PickerStates = PickerStates.OUT

signal picker_entered
signal picker_exited

var item_on_picker: Item = null

func picker_handler():
	if (is_colliding() and get_collider() is ItemObject):
		if (picker_item_state == PickerStates.OUT):
			item_on_picker = (get_collider() as ItemObject).item_resource
			picker_item_state = PickerStates.ON
			picker_entered.emit()
			
	elif (not is_colliding() and picker_item_state != PickerStates.OUT):
		item_on_picker = null
		picker_item_state = PickerStates.OUT
		picker_exited.emit()

func _process(_delta):
	picker_handler()

func _unhandled_input(event):
	if (event.is_action_pressed("p_pick_item") and picker_item_state == PickerStates.ON):
		print("picking: ", item_on_picker.name)
