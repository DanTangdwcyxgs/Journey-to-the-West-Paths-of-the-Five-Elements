class_name Combatant
extends RefCounted

var id: String
var display_name: String
var max_hp: int
var hp: int
var attack: int
var defense: int
var speed: int
var base_speed: int
var bp: int = 0
var shield: int
var max_shield: int
var weaknesses: Dictionary = {}
var broken_turns: int = 0
var row: String = "front"
var barrier: int = 0
var aggro_turns: int = 0
var speed_delta: int = 0
var speed_effect_turns: int = 0

func _init(
	p_id: String,
	p_display_name: String,
	p_max_hp: int,
	p_attack: int,
	p_defense: int,
	p_speed: int,
	p_shield: int,
	p_weaknesses: Dictionary,
	p_row: String = "front"
) -> void:
	id = p_id
	display_name = p_display_name
	max_hp = p_max_hp
	hp = p_max_hp
	attack = p_attack
	defense = p_defense
	speed = p_speed
	base_speed = p_speed
	max_shield = p_shield
	shield = p_shield
	weaknesses = p_weaknesses.duplicate(true)
	row = "back" if p_row == "back" else "front"

func is_alive() -> bool:
	return hp > 0

func is_broken() -> bool:
	return broken_turns > 0

func begin_turn() -> void:
	if not is_alive():
		return
	bp = mini(bp + 1, 5)
	if broken_turns > 0:
		broken_turns -= 1
	if aggro_turns > 0:
		aggro_turns -= 1
	if speed_effect_turns > 0:
		speed_effect_turns -= 1
		if speed_effect_turns == 0:
			speed = base_speed

func restore_shield() -> void:
	shield = max_shield

func heal(amount: int) -> int:
	var actual := maxi(amount, 0)
	var previous := hp
	hp = mini(hp + actual, max_hp)
	return hp - previous

func gain_barrier(amount: int) -> int:
	barrier = maxi(barrier + amount, 0)
	return barrier

func apply_speed_delta(delta: int, duration: int) -> void:
	speed_delta = delta
	speed = maxi(base_speed + delta, 1)
	speed_effect_turns = maxi(duration, 0)

func take_damage(amount: int) -> int:
	var incoming := maxi(amount, 0)
	var absorbed := mini(barrier, incoming)
	barrier -= absorbed
	var actual := incoming - absorbed
	hp = maxi(hp - actual, 0)
	return actual
