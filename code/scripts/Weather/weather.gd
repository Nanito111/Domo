class_name Weather
extends Node

@onready var source_light:DirectionalLight3D = %SourceLight
@onready var world_environment:WorldEnvironment = %WorldEnvironment
@onready var debug_precipitation:Label = %preInt

@export_group("Day Cycle")
@export var max_day_minutes:float = 6
@export var sky_settings:SkySettings
@export var light_rotation_offset:float = 5

enum DayStates {DAY, NIGHT}
var current_day_state: DayStates = DayStates.DAY

var current_daytime_seconds:float
var current_half_time_percentage:float
var seconds_in_day:float
var day_passed:int = 0

@export_group("Weather")
@export var easy_weather_data:Array[WeatherData]
@export var medium_weather_data:Array[WeatherData]
@export var hard_weather_data:Array[WeatherData]
@export var weather_intensity_by_days: Curve
@export_range(0, 10) var days_to_max_instensity: int = 8

var weather_for_tomorrow: WeatherData
var today_weather: WeatherData

var current_precipitation: WeatherData.PrecipitationType
var precipitation_curve:Curve = Curve.new()
var current_precipitation_intensity:float
var is_on_precipitation:bool=false

signal starting_precipitation()
signal ending_precipitation()

var current_wind_energy:float
var current_cloud_amount:float

@export var temperature_curve_reference:Curve
var current_temperature:float
var temperature_curve:Curve

var current_water_accumulated:float

func calculate_time_variables(delta:float):
	current_daytime_seconds = clampf(current_daytime_seconds + delta, 0, seconds_in_day)
	if (current_daytime_seconds == seconds_in_day):
		current_daytime_seconds = 0

	var half_day:float = seconds_in_day * 0.5

	if (current_day_state == DayStates.NIGHT and current_daytime_seconds < half_day):
		current_day_state = DayStates.DAY

		day_passed += 1

		today_weather = weather_for_tomorrow
		get_temperature_for_today(false)
		get_precipitation_for_today()

		prints("today's weather", today_weather.resource_path)
		weather_for_tomorrow = get_weather()

	if (current_day_state == DayStates.DAY and current_daytime_seconds > half_day):
		current_day_state = DayStates.NIGHT

	current_half_time_percentage = current_daytime_seconds / half_day - current_day_state
	current_half_time_percentage = clampf(current_half_time_percentage, 0, 1)

func light_setting():
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


func day_night_global_shader_parameters():
	if (current_day_state == DayStates.DAY):
		#Sky Colors
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
		#Sky Colors
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

func get_weather():
	var offset:float = clampf(float(day_passed) / float(days_to_max_instensity), 0, 1)
	var intensity:int = roundi(weather_intensity_by_days.sample(offset))

	var next_weather:WeatherData

	match intensity:
		0:
			next_weather = easy_weather_data.pick_random()
		1:
			next_weather = medium_weather_data.pick_random()
		2:
			while true:
				next_weather = hard_weather_data.pick_random()
				if next_weather != today_weather:
					break
		_:
			pass

	return next_weather

func get_precipitation_for_today():
	var precipitation_intensity:float = precipitation_curve.get_point_position(4).y

	for i in range(5):
		if i == 0:
			precipitation_curve.set_point_value(0, precipitation_intensity)
			continue

		precipitation_intensity = randf_range(today_weather.min_precipitation_energy, today_weather.max_precipitation_energy)
		precipitation_curve.set_point_value(i, precipitation_intensity)

func calculate_precipitations_events():
	current_precipitation_intensity = precipitation_curve.sample(current_daytime_seconds / seconds_in_day)
	# debug_precipitation.text = str(current_precipitation_intensity)

	if is_on_precipitation == false and current_precipitation_intensity > 0:
		is_on_precipitation = true
		starting_precipitation.emit()
	elif is_on_precipitation == true and current_precipitation_intensity < 0.1:
		is_on_precipitation = false
		ending_precipitation.emit()

func get_temperature_for_today(init:bool):
	if init == false:
		temperature_curve.set_point_value(0, temperature_curve.get_point_position(4).y)
	else:
		temperature_curve.set_point_value(0, today_weather.min_temperature)

	temperature_curve.set_point_value(1, today_weather.mid_temperature)
	temperature_curve.set_point_value(2, today_weather.max_temperature)
	temperature_curve.set_point_value(3, today_weather.mid_temperature)
	temperature_curve.set_point_value(4, today_weather.min_temperature)


func _ready():
	current_half_time_percentage = 0
	seconds_in_day = max_day_minutes * 60

	easy_weather_data.shuffle()
	medium_weather_data.shuffle()
	hard_weather_data.shuffle()

	precipitation_curve.add_point(Vector2.ZERO)
	precipitation_curve.add_point(Vector2.RIGHT * 0.25)
	precipitation_curve.add_point(Vector2.RIGHT * 0.5)
	precipitation_curve.add_point(Vector2.RIGHT * 0.75)
	precipitation_curve.add_point(Vector2.RIGHT)

	temperature_curve = temperature_curve_reference

	today_weather = get_weather()
	get_temperature_for_today(true)
	get_precipitation_for_today()

	weather_for_tomorrow = get_weather()

	prints("today's weather", today_weather.resource_path)

func _process(delta):
	calculate_time_variables(delta)
	light_setting()
	day_night_global_shader_parameters()
	calculate_precipitations_events()

	current_temperature = temperature_curve.sample(current_daytime_seconds / seconds_in_day)
	debug_precipitation.text = str(current_temperature) + "°C"
	
