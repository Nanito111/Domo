class_name ItemDataModel
extends Resource

@export var name:String
@export var hand_instance:PackedScene
@export var world_instance:PackedScene
@export var icon:Texture2D
@export_range(1, 42) var max_stack_capacity:int = 0
