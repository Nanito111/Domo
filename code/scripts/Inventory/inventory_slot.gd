class_name InventorySlot
extends PanelContainer

@onready var icon_texure = $IconTexure

func display(item:Item):
	icon_texure.texture = item.icon
