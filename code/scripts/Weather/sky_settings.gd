class_name SkySettings
extends Resource

@export_group("Sky Colors")
@export var day_sky_colors: Gradient
@export var day_horizon_colors: Gradient
@export var night_sky_colors: Gradient
@export var night_horizon_colors: Gradient

@export_group("Light Energy")
@export var sun_light_energy:Curve
@export var moon_light_energy:Curve

@export_group("Light Colors")
@export var sun_light_color:Gradient
@export var moon_light_color:Gradient

@export_group("Ambient Colors")
@export var day_ambient_color:Gradient
@export var night_ambient_color:Gradient

@export_group("Sun|Moon Size")
@export var sun_size:float
@export var moon_size:float

@export_group("Sun|Moon Brightness")
@export var sun_brightness:float
@export var moon_brightness:float

@export_group("Stars Brightness")
@export var stars_brightness:Curve
