class_name Inventory

@export var max_capacity:int = 20
var _content:Array[Item] = []

func add_item(item:Item):
	if len(_content) < max_capacity:
		_content.append(item)
		return true
	return false
	
func remove_item(item:Item):
	_content.erase(item)

func get_items() -> Array[Item]:
	return _content
