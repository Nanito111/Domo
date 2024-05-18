class_name InventorySlot
extends Panel

@onready var texture_rect:TextureRect = $TextureRect
@onready var label:Label = $Label
@onready var focus_indicator = $FocusIndicator
var slot_index:int
var mouse_on_slot:bool = false
var dragging_slot:bool = false

@onready var drag_position_offset:Vector2 = texture_rect.size * -0.5

signal remove_item_input(index:int)
signal moved_item(origin:int)

func display_slot(item:Item):
	texture_rect.texture = item.item_resource.icon
	label.text = str(item.items_stacked)
	if item.items_stacked > 1:
		label.show()

func update_stack_slot(stack:int):
	if (stack > 1):
		label.show()
	else:
		label.hide()

	label.text = str(stack)

func restore_slot():
	texture_rect.texture = null
	label.text = ""
	label.hide()

func focus_slot():
	focus_indicator.show()

func blur_slot():
	focus_indicator.hide()

func take_item_to_move():
	focus_slot()
	dragging_slot = true

func drop_item_in_slot():
	blur_slot()
	dragging_slot = false
	texture_rect.position = Vector2.ZERO
	moved_item.emit(slot_index)

func _ready():
	label.hide()

func _process(_delta):
	if(dragging_slot):
		texture_rect.global_position = get_global_mouse_position() + drag_position_offset

func _on_gui_input(event:InputEvent):
	if (event.is_action_pressed("p_mouse_l")):
		take_item_to_move()
	if (event.is_action_released("p_mouse_l")):
		drop_item_in_slot()

	if (event.is_action_released("p_mouse_r") and texture_rect.texture != null):
		remove_item_input.emit(slot_index)

func _on_mouse_entered():
	mouse_on_slot = true

func _on_mouse_exited():
	mouse_on_slot = false
