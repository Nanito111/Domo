class_name Weather
extends Node

@export var max_day_minutes:float = 12
@export var sky_settings:SkySettings
@export var light_rotation_offset:float = 5
@export var current_daytime_seconds:float = 0

enum DayStates {DAY, NIGHT}
@export var current_day_state: DayStates = DayStates.DAY

var current_half_time_percentage:float
var seconds_in_day:float

@onready var source_light:DirectionalLight3D = %SourceLight
@onready var world_environment:WorldEnvironment = %WorldEnvironment

func calculate_time_variables(delta:float):
	current_daytime_seconds = clampf(current_daytime_seconds + delta, 0, seconds_in_day)
	if (current_daytime_seconds == seconds_in_day):
		current_daytime_seconds = 0

	var half_day:float = seconds_in_day * 0.5

	if (current_day_state == DayStates.NIGHT and current_daytime_seconds < half_day):
		current_day_state = DayStates.DAY
		print(source_light.rotation_degrees.x)

	if (current_day_state == DayStates.DAY and current_daytime_seconds > half_day):
		current_day_state = DayStates.NIGHT

	current_half_time_percentage = current_daytime_seconds / half_day - current_day_state
	current_half_time_percentage = clampf(current_half_time_percentage, 0, 1)


func _ready():
	current_half_time_percentage = 0
	seconds_in_day = max_day_minutes * 60

func _process(delta):
	calculate_time_variables(delta)

	source_light.rotation.x = lerpf(
		deg_to_rad(light_rotation_offset),
		deg_to_rad(-180 - light_rotation_offset),
		current_half_time_percentage
	)

	RenderingServer.global_shader_parameter_set_override("LightDirection", -source_light.basis.z)
	RenderingServer.global_shader_parameter_set_override("LightColor", source_light.light_color)
	RenderingServer.global_shader_parameter_set_override("LightEnergy", source_light.light_energy)

	RenderingServer.global_shader_parameter_set_override(
		"StarsBrightness",
		sky_settings.stars_brightness.sample(current_daytime_seconds / seconds_in_day)
	)
	if (current_day_state == DayStates.DAY):
		#SKY COLORS
		RenderingServer.global_shader_parameter_set_override(
			"HorizonColor",
			sky_settings.day_horizon_colors.sample(current_half_time_percentage)
		)
		RenderingServer.global_shader_parameter_set_override(
			"SkyColor",
			sky_settings.day_sky_colors.sample(current_half_time_percentage)
		)
		#light color
		source_light.light_color = sky_settings.sun_light_color.sample(current_half_time_percentage)
		#ambient color
		world_environment.environment.background_color = sky_settings.day_ambient_color.sample(current_half_time_percentage)
		#light intensity
		source_light.light_energy = sky_settings.sun_light_energy.sample(current_half_time_percentage)
		#sun size
		RenderingServer.global_shader_parameter_set_override("SunSize", sky_settings.sun_size)
		#sun size
		RenderingServer.global_shader_parameter_set_override("SunBrightness", sky_settings.sun_brightness)
	else:
		#SKY COLORS
		RenderingServer.global_shader_parameter_set_override(
			"HorizonColor",
			sky_settings.night_horizon_colors.sample(current_half_time_percentage)
		)
		RenderingServer.global_shader_parameter_set_override(
			"SkyColor",
			sky_settings.night_sky_colors.sample(current_half_time_percentage)
		)
		#light color
		source_light.light_color = sky_settings.moon_light_color.sample(current_half_time_percentage)
		#ambient color
		world_environment.environment.background_color = sky_settings.night_ambient_color.sample(current_half_time_percentage)
		#light intensity
		source_light.light_energy = sky_settings.moon_light_energy.sample(current_half_time_percentage)
		#sun size
		RenderingServer.global_shader_parameter_set_override("SunSize", sky_settings.moon_size)
		#sun size
		RenderingServer.global_shader_parameter_set_override("SunBrightness", sky_settings.moon_brightness)
