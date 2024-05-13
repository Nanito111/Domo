class_name Look
extends Node

@export_group("Nodes")
@export var _character:Movement
@export var camera:Camera3D
@export var yaw_pivot:Node3D
@export var pitch_pivot:Node3D

@export_group("Mouse Settings")
@export_range(0.0001,2,0.0001) var _mouse_sensitivity:float = 0.5

@export_group("Look Limits")
@export_range(0,180,1,"degrees") var _look_limit_positive_x:float = 0
@export_range(-180,0,1, "degrees") var _look_limit_negative_x:float = 0

var _look_rotation:Vector2 = Vector2()
var _rotation_motion:Vector2 = Vector2()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	yaw_pivot.rotation_degrees = Vector3(0, _look_rotation.y, 0)
	pitch_pivot.rotation_degrees = Vector3(_look_rotation.x, 0, 0)

func _unhandled_input(event):
	if (event is InputEventMouseMotion):
		_rotation_motion = Vector2(event.relative.y, -event.relative.x) * _mouse_sensitivity
		var max_angular_y_velocity:float = _character.max_angular_y_velocity * get_process_delta_time() * 100
		_rotation_motion.y = clampf(_rotation_motion.y, -max_angular_y_velocity, max_angular_y_velocity)
		_look_rotation += _rotation_motion
		_look_rotation.x = clampf(_look_rotation.x, _look_limit_negative_x, _look_limit_positive_x)
		
		if (_look_rotation.y > 180): _look_rotation.y = -180
		if (_look_rotation.y < -180): _look_rotation.y = 180
