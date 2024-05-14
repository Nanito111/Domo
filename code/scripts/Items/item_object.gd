class_name ItemObject
extends Area3D

@export var item_resource:Item

func pickup():
	get_parent().queue_free()
