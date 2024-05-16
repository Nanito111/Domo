class_name InventorySlot
extends Panel

@onready var texture_rect = $TextureRect
@onready var label = $Label
var slot_index:int

signal remove_item_input(index:int)

func display_slot(item:Item):
	texture_rect.texture = item.icon

func restore_slot():
	texture_rect.texture = null

func _on_gui_input(event:InputEvent):
	if (event.is_action_released("p_mouse_r") and texture_rect.texture != null):
		remove_item_input.emit(slot_index)
