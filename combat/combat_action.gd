class_name CombatAction
extends RefCounted

var id: String
var display_name: String
var element: String
var power: int
var shield_hit: int
var bp_cost: int
var effects: Dictionary = {}

func _init(
	p_id: String,
	p_display_name: String,
	p_element: String,
	p_power: int,
	p_shield_hit: int = 0,
	p_bp_cost: int = 0,
	p_effects: Dictionary = {}
) -> void:
	id = p_id
	display_name = p_display_name
	element = p_element
	power = p_power
	shield_hit = p_shield_hit
	bp_cost = p_bp_cost
	effects = p_effects.duplicate(true)
