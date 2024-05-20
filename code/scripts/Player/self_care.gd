class_name SelfCare
extends Node

@export var player: Movement
@export var temperature_curve: Curve

var health:float = 1

const MAX_HUNGER_DECREASE:float = 0.2
const MIN_HUNGER_DECREASE:float = 0.05
const HUNGER_DYING:float = 0.05
const HUNGER_HEALTH_RECOVER:float = 0.1
var hunger:float = 1

const MAX_BODY_TEMPERATURE:float = 46.5
const MIN_BODY_TEMPERATURE:float = 24
const TEMPERATURE_DYING:float = 0.2
const IDEAL_BODY_TEMPERATURE: Vector2 = Vector2(36.1, 37.2)
var body_temperature: float = 36.7

const WATER_STAMINA_DECREASE: float = 0.05
const WATER_STAMINA_DYING: float = 0.2
const MIN_RUN_STAMINA_DECREASE: float = 0.1
const MAX_RUN_STAMINA_DECREASE: float = 0.3
const MAX_STAMINA_RECOVER: float = 0.2
const MIN_STAMINA_RECOVER: float = 0.05
var stamina:float = 1

signal death

func eat_something(increase:float):
	hunger = clampf(hunger + increase, 0, 1)

func get_complete_temperature_weight():
	var weight:float = (body_temperature - MIN_BODY_TEMPERATURE) / (MAX_BODY_TEMPERATURE - MIN_BODY_TEMPERATURE)
	weight = temperature_curve.sample(weight)
	return weight

func get_temperature_weight(temperature_limit:float, temperature_ideal:float):
	var weight:float = 1 - (body_temperature - temperature_limit) / (temperature_ideal - temperature_limit)
	weight = clampf(weight, 0, 1)
	return weight

func clamp_values():
	health = clampf(health, 0, 1)
	hunger = clampf(hunger, 0, 1)
	body_temperature = clampf(body_temperature, MIN_BODY_TEMPERATURE, MAX_BODY_TEMPERATURE)
	stamina = clampf(stamina, 0, 1)

func check_health():
	if (health <= 0):
		death.emit()

func hunger_decrease(delta:float):
	hunger -= lerpf(
		MIN_HUNGER_DECREASE,
		MAX_HUNGER_DECREASE,
		get_temperature_weight(MIN_BODY_TEMPERATURE, IDEAL_BODY_TEMPERATURE.x)
	) * delta

func hunger_health_recovering(delta:float):
	if (player.current_movement_state == Movement.MovementStates.SWIMING):
		if (hunger >= 0.5):
			health += HUNGER_HEALTH_RECOVER * delta
	else:
		if (hunger >= 0.5 and stamina >= 0.25):
			health += HUNGER_HEALTH_RECOVER * delta

func hunger_dying(delta:float):
	if (hunger <= 0):
		health -= HUNGER_DYING * delta

func temperature_dying(delta:float):
	if (body_temperature > IDEAL_BODY_TEMPERATURE.y):
		health -= lerpf(
			0,
			TEMPERATURE_DYING,
			get_temperature_weight(MAX_BODY_TEMPERATURE, IDEAL_BODY_TEMPERATURE.y)
		) * delta
	elif (body_temperature < IDEAL_BODY_TEMPERATURE.x):
		health -= lerpf(
			0,
			TEMPERATURE_DYING,
			get_temperature_weight(MIN_BODY_TEMPERATURE, IDEAL_BODY_TEMPERATURE.x)
		) * delta

func stamina_recovering(delta:float):
	if (
	player.current_movement_state != Movement.MovementStates.SWIMING
	and
	player.current_pace_state == Movement.PaceStates.WALK
	):
		var recover_weight:float
		if (body_temperature > IDEAL_BODY_TEMPERATURE.y):
			recover_weight = get_temperature_weight(MAX_BODY_TEMPERATURE, IDEAL_BODY_TEMPERATURE.y)
		elif (body_temperature < IDEAL_BODY_TEMPERATURE.x):
			recover_weight = get_temperature_weight(MIN_BODY_TEMPERATURE, IDEAL_BODY_TEMPERATURE.x)
		else:
			recover_weight = 0
		
		stamina += lerpf(
			MAX_STAMINA_RECOVER,
			MIN_STAMINA_RECOVER,
			recover_weight
		) * delta

func stamina_decrease(delta:float):
	if (player.current_movement_state == Movement.MovementStates.SWIMING):
		stamina -= WATER_STAMINA_DECREASE * delta

	elif(player.current_pace_state == Movement.PaceStates.RUN):
		var decrease_weight:float
		if (body_temperature > IDEAL_BODY_TEMPERATURE.y):
			decrease_weight = get_temperature_weight(MAX_BODY_TEMPERATURE, IDEAL_BODY_TEMPERATURE.y)
		elif (body_temperature < IDEAL_BODY_TEMPERATURE.x):
			decrease_weight = get_temperature_weight(MIN_BODY_TEMPERATURE, IDEAL_BODY_TEMPERATURE.x)
		else:
			decrease_weight = 0

		stamina -= lerpf(
			MAX_RUN_STAMINA_DECREASE,
			MIN_RUN_STAMINA_DECREASE,
			decrease_weight
		) * delta

func water_stamina_dying(delta):
	if (player.current_movement_state == Movement.MovementStates.SWIMING and stamina <= 0):
		health -= WATER_STAMINA_DYING * delta

func _process(delta:float):
	clamp_values()
	check_health()
	hunger_decrease(delta)
	hunger_health_recovering(delta)
	hunger_dying(delta)
	temperature_dying(delta)
	stamina_recovering(delta)
	stamina_decrease(delta)
	water_stamina_dying(delta)

#func _unhandled_input(event):
	#if (event.is_action("p_scroll_up")):
		#body_temperature += 0.1
	#if (event.is_action("p_scroll_down")):
		#body_temperature -= 0.1
