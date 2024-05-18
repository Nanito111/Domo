class_name Item

var item_resource:ItemDataModel
var items_stacked: int

func _init(_item_resource:ItemDataModel, _items_stacked:int):
	item_resource = _item_resource
	items_stacked = _items_stacked

func can_be_stacked():
	return item_resource.max_stack_capacity > items_stacked

func stack_and_get_remaining(stacks_to_add:int):
	items_stacked += stacks_to_add
	var remaining:int = items_stacked - item_resource.max_stack_capacity
	if remaining < 0: remaining = 0
	items_stacked -= remaining

	return remaining
