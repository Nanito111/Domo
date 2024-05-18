class_name ItemObject
extends RigidBody3D

@export var item_resource:ItemDataModel
var items_stacked: int = 1

func pickup():
	queue_free()

func _enter_tree():
	add_child(item_resource.world_instance.instantiate())
