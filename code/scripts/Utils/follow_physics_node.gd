class_name FollowPhysicsNode
extends Node3D

@export var _target_node:Node3D

var _previus_target_position:Vector3
var _current_target_position:Vector3

func _ready():
	top_level = true
	global_position = _target_node.global_position
	
	_previus_target_position = _target_node.global_position
	_current_target_position = _target_node.global_position

func _process(_delta):
	var physics_interpolation_fraction:float = clampf(Engine.get_physics_interpolation_fraction(), 0, 1)
	global_position = _previus_target_position.lerp(_current_target_position, physics_interpolation_fraction)

func _physics_process(_delta):
	_previus_target_position = _current_target_position
	_current_target_position = _target_node.global_position
