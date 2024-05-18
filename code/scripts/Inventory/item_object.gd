class_name ItemObject
extends RigidBody3D

@export var item_resource:ItemDataModel
@export var items_stacked: int = 1

func pickup():
	queue_free()

func _enter_tree():
	if (item_resource != null):
		add_child(item_resource.world_instance.instantiate())
