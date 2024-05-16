class_name InventorySlot
extends Button

func display_slot(item:Item):
	icon = item.icon
func restore_slot():
	icon = null
