class_name Movement
extends CharacterBody3D
@export_group("Nodes")
@export var _look:Look
@export var _selfcare:SelfCare

@export_group("Movement Speed")
@export_subgroup("Stand")
@export var _stand_walk_speed:float = 4
@export var _stand_run_speed:float = 6

@export_group("Physics Settings")
@export var _acceleration_factor:float = 5.5
@export var _stopping_factor:float = 15
@export var _air_braking_factor:float = 2
@export var max_angular_y_velocity:float = 20
@export var _jump_impulse:float = 4
@export_range(0, 1, 0.001) var _landing_penalty:float = 0.9

@export_group("Other Properties")
@export_range(0, 10, 0.1) var _max_landing_penalty_time:float = 6
@export_range(0, 1, 0.001) var _landing_penalty_time_multiplier:float = 0.3

var _speed_values: PackedFloat32Array

enum PaceStates {WALK, RUN}
var current_pace_state: PaceStates = PaceStates.WALK

enum MovementStates {AIR, MOVING, SWIMING}
var current_movement_state: MovementStates = MovementStates.MOVING

var _gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _input_dir:Vector2 = Vector2.ZERO

signal air_landing

var _velocity: Vector3 = Vector3.ZERO

func input_pace_control(event:InputEvent):
	if (event.is_action_pressed("p_run")):
		current_pace_state = PaceStates.RUN
	if (event.is_action_released("p_run")):
		current_pace_state = PaceStates.WALK

func jump():
	return _jump_impulse

func ground_movement(
	direction:Vector3,
	speed:float,
	delta:float,
	inertia_factor:float
):
	_velocity.x = lerp(_velocity.x, direction.x * speed, delta * inertia_factor)
	_velocity.z = lerp(_velocity.z, direction.z * speed, delta * inertia_factor)
	if (Input.is_action_just_pressed("p_jump")):
		_velocity.y = jump()

func air_movement(
	input_direction:Vector3,
	speed:float,
	delta:float
):
	var inertia:Vector3 = Vector3(_velocity.x, 0, _velocity.z)
	var input_movement:Vector3 = input_direction * speed * delta
	var air_velocity:Vector3 = inertia.move_toward(Vector3.ZERO, delta * _air_braking_factor) + input_movement
	_velocity.x = air_velocity.x
	_velocity.z = air_velocity.z

func on_landing_penalty():
	var last_fall_speed:float = _velocity.y
	var penalty_time:float = clampf(last_fall_speed * _landing_penalty_time_multiplier, 0, _max_landing_penalty_time)
	
	var current_penalty_time:float = 0
	var penalty_value = _landing_penalty
	
	while (current_penalty_time < 1):
		current_penalty_time += get_physics_process_delta_time() # TODO: add penalty_time, maybe with a curve
		penalty_value = lerpf(_landing_penalty, 1, current_penalty_time)
		penalty_value = clampf(penalty_value, _landing_penalty, 1)
		
		_velocity.x = _velocity.x * penalty_value
		_velocity.z = _velocity.z * penalty_value
		
		await get_tree().physics_frame

func _ready():
	_speed_values = [_stand_walk_speed, _stand_run_speed]
	air_landing.connect(on_landing_penalty)

func _physics_process(delta):
	var speed:float
	
	if (current_movement_state != MovementStates.SWIMING):
		speed = _speed_values[current_pace_state]
		speed = lerpf(_stand_walk_speed, speed, _selfcare.stamina)

	_input_dir = Input.get_vector("p_right", "p_left", "p_backward", "p_forward")
	var direction:Vector3 = (_look.yaw_pivot.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	var inertia_factor = _acceleration_factor if _input_dir != Vector2.ZERO else _stopping_factor
	
	if (is_on_floor()):
		if (current_movement_state == MovementStates.AIR):
			air_landing.emit()

		current_movement_state = MovementStates.MOVING
		ground_movement(
			direction,
			speed,
			delta,
			inertia_factor
		)
	else:
		current_movement_state = MovementStates.AIR
		_velocity.y -= _gravity * delta
		air_movement(
			direction,
			speed,
			delta
		)
	velocity = _velocity
	move_and_slide()

func _unhandled_input(event):
	input_pace_control(event)
