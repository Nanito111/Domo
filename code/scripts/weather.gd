class_name Weather
extends Node

@onready var source_light:DirectionalLight3D = %SourceLight
@export var daytime_multiplier:float = 30
var is_day:bool = true

func _process(delta):
	if (source_light.rotation_degrees.x > 3):
		source_light.global_rotate(Vector3.RIGHT, deg_to_rad(180))
		is_day = not is_day

	if is_day:
		RenderingServer.global_shader_parameter_set_override("StarsBrightness", 0)
		RenderingServer.global_shader_parameter_set_override("SunBrightness", 1.5)
	else:
		RenderingServer.global_shader_parameter_set_override("StarsBrightness", 8)
		RenderingServer.global_shader_parameter_set_override("SunBrightness", 0.5)


	source_light.global_rotate(Vector3.RIGHT, deg_to_rad(daytime_multiplier * delta))
