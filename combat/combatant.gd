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
var mechanic_resource: int = 0
var mechanic_max: int = 3
var combat_modifiers: Dictionary = {}
var longma_form: String = "horse"
var longma_form_turns: int = 0
var form_attack_bonus: int = 0
var form_defense_bonus: int = 0
var form_speed_bonus: int = 0

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
	if mechanic_resource < mechanic_max:
		mechanic_resource += 1
	if broken_turns > 0:
		broken_turns -= 1
	if aggro_turns > 0:
		aggro_turns -= 1
	if speed_effect_turns > 0:
		speed_effect_turns -= 1
		if speed_effect_turns == 0:
			speed = base_speed
	if longma_form_turns > 0:
		longma_form_turns -= 1
		if longma_form_turns == 0:
			clear_longma_form()

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

func add_mechanic_resource(amount: int) -> int:
	mechanic_resource = clampi(mechanic_resource + amount, 0, mechanic_max)
	return mechanic_resource

func spend_mechanic_resource(amount: int) -> bool:
	if amount < 0 or mechanic_resource < amount:
		return false
	mechanic_resource -= amount
	return true

func set_longma_form(form: String, duration: int, attack_bonus: int, defense_bonus: int, speed_bonus: int) -> void:
	clear_longma_form()
	longma_form = form
	longma_form_turns = maxi(duration, 0)
	form_attack_bonus = attack_bonus
	form_defense_bonus = defense_bonus
	form_speed_bonus = speed_bonus
	attack += attack_bonus
	defense = maxi(defense + defense_bonus, 1)
	speed = maxi(speed + speed_bonus, 1)
	base_speed = speed

func clear_longma_form() -> void:
	attack -= form_attack_bonus
	defense = maxi(defense - form_defense_bonus, 1)
	speed = maxi(speed - form_speed_bonus, 1)
	form_attack_bonus = 0
	form_defense_bonus = 0
	form_speed_bonus = 0
	longma_form = "horse"
	longma_form_turns = 0

func take_damage(amount: int) -> int:
	var incoming := maxi(amount, 0)
	var absorbed := mini(barrier, incoming)
	barrier -= absorbed
	var actual := incoming - absorbed
	hp = maxi(hp - actual, 0)
	return actual

func get_status_summary() -> String:
	var statuses: Array[String] = []
	if is_broken():
		statuses.append("Break %dT" % broken_turns)
	if barrier > 0:
		statuses.append("护盾 +%d" % barrier)
	if aggro_turns > 0:
		statuses.append("嘲讽 %dT" % aggro_turns)
	if speed_effect_turns > 0 and speed_delta != 0:
		statuses.append("速度 %+d %dT" % [speed_delta, speed_effect_turns])
	if id == "longma" and longma_form != "horse":
		statuses.append("形态·%s %dT" % [longma_form, longma_form_turns])
	return "、".join(statuses) if not statuses.is_empty() else "无状态"
