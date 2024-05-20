class_name SelfCareInterface
extends Control

@onready var health_bar:ProgressBar = %HealthBar
@onready var hunger_bar:ProgressBar = %HungerBar
@onready var stamina_bar:ProgressBar = %StaminaBar

@onready var temperatures:HBoxContainer = $TemperatureIndicator/PanelContainer/Temperatures
@onready var indicator:Panel = %Indicator

func move_temperature_indicator(temperature_weight:float):
	var max_indicator_position:float = temperatures.get_global_rect().end.x - indicator.size.x
	var min_indicator_position:float = temperatures.get_global_rect().position.x + indicator.size.x
	
	indicator.global_position = Vector2(
		lerpf(
			min_indicator_position,
			max_indicator_position,
			temperature_weight,
		),
		indicator.global_position.y
	)
