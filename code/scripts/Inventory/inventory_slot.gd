class_name InventorySlot
extends Panel

@onready var texture_rect:TextureRect = $TextureRect
@onready var label:Label = $Label
@onready var focus_indicator = $FocusIndicator
var slot_index:int

signal remove_item_input(index:int)

func display_slot(item:Item):
	texture_rect.texture = item.item_resource.icon
	label.text = str(item.items_stacked)
	if item.items_stacked > 1:
		label.show()

func update_stack_slot(item:Item):
	if label.visible != true:
		label.show()
	label.text = str(item.items_stacked)

func restore_slot():
	texture_rect.texture = null
	label.text = ""
	label.hide()

func _on_gui_input(event:InputEvent):
	if (event.is_action_released("p_mouse_r") and texture_rect.texture != null):
		remove_item_input.emit(slot_index)

func _ready():
	label.hide()
