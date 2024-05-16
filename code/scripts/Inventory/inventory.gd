class_name Inventory
extends Object

@export var max_capacity:int = 20
var _content:Array[Item] = []

signal item_added(index:int, inventory:Inventory)
signal item_removed(index:int)

func add_item(item:Item, index:int):
	if _content.size() == max_capacity:
		return false
	
	_content.insert(index, item)

	item_added.emit(index, self)
	return true
	
func remove_item(index:int = -1):
	item_removed.emit(index)
	_content.remove_at(index)

func get_item_at(index: int):
	return _content[index]

func get_items() -> Array[Item]:
	return _content
