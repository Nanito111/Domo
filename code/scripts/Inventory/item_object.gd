class_name ItemObject
extends Area3D

@export var item_resource:ItemDataModel
@export var items_stacked: int = 1

func pickup():
	get_parent().queue_free()
