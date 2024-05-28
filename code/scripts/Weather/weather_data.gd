class_name WeatherData
extends Resource

enum PrecipitationType {
	NONE,
	RAIN,
	HAIL,
	SNOW,
}

@export_group("Precipitaion")
@export var precipitation:PrecipitationType
@export var precipitation_scene: PackedScene
@export var min_precipitation_energy: float
@export var max_precipitation_energy: float

@export_group("Wind")
@export var min_wind_energy:float
@export var max_wind_energy:float
@export var wind_randomness:Curve

@export_group("Cloud")
@export var min_cloud_amount:float
@export var max_cloud_amount:float

@export_group("Temperature")
@export var min_temperature:float
@export var mid_temperature:float
@export var max_temperature:float
