class_name Inventory
extends Object

const MAX_CAPACITY:int = 25
var content:Array[Item]

signal item_added(index:int, inventory:Inventory)
signal item_stacked(index:int, inventory:Inventory)
signal item_removed(index:int, stack:int)
signal item_moved(origin:int, destination:int)

func check_if_has_item(item_resource:ItemDataModel):
	for item in content:
		if item == null:
			continue
		if item.item_resource == item_resource:
			return true
	return false

func stack_item(item:Item, index:int, inventory_full:bool):
	if not check_if_has_item(item.item_resource) and inventory_full:
		return false

	# buscar item que este disponible para juntarse
	for item_index in range(MAX_CAPACITY):
		if content[item_index] == null:
			continue

		# item_resource es igual al item y puede ser juntado
		if content[item_index].item_resource == item.item_resource and content[item_index].can_be_stacked():
			item.items_stacked = content[item_index].stack_and_get_remaining(item.items_stacked)
			item_stacked.emit(item_index, self)
			if item.items_stacked > 0:
				continue
			break

	# Recorrio todo y el stack sigue teniendo un restante
	if item.items_stacked > 0:
		content[index] = item
		item_added.emit(index, self)
	
	return true

func add_item(item:Item, index:int):
	var inventory_full: bool = not content.has(null)
	# item se puede stackear
	if item.item_resource.max_stack_capacity > 1:
		return stack_item(item, index, inventory_full)

	# inventory is full
	if inventory_full:
		return false

	content[index] = item
	item_added.emit(index, self)
	return true

func remove_item(index:int):
	if (content[index] == null):
		return

	if (content[index].items_stacked > 1):
		content[index].items_stacked -= 1
		item_removed.emit(index, content[index].items_stacked)
	else:
		content[index] = null
		item_removed.emit(index, 0)

func move_item(origin:int, destination:int):
	if content[origin] == null:
		return

	var origin_item: Item = Item.new(
		content[origin].item_resource,
		content[origin].items_stacked
	)

	content[origin] = content[destination]
	content[destination] = origin_item

	item_moved.emit(origin, destination)

func _init():
	content.resize(MAX_CAPACITY)
	content.fill(null)
