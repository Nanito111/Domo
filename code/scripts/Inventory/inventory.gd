class_name Inventory
extends Object

const MAX_CAPACITY:int = 25
var _content:Array[Item]

signal item_added(index:int, inventory:Inventory)
signal item_removed(index:int)

func add_item(item:Item, index:int):
	if not _content.has(null):
		return false
	
	_content[index]= item

	item_added.emit(index, self)
	return true
	
func remove_item(index:int):
	_content[index] = null
	item_removed.emit(index)

func get_items() -> Array[Item]:
	return _content

func _init():
	_content.resize(MAX_CAPACITY)
	_content.fill(null)
