class_name PartyManager
extends RefCounted

## Five-character party with three front slots and two back slots.
## Formation order is independent from recruitment order and is saveable.

const PARTY_SIZE := 5
const FRONT_SIZE := 3
const BACK_SIZE := 2
const CHARACTER_IDS := ["TANG", "WUKONG", "BAJIE", "WUJING", "LONGMA"]

var roster: Array[String] = []
var front_row: Array[String] = []
var back_row: Array[String] = []

func initialize_from_recruited(recruited: Array[String]) -> void:
	roster.clear()
	for id in recruited:
		if id in CHARACTER_IDS and id not in roster and roster.size() < PARTY_SIZE:
			roster.append(id)
	_rebuild_formation()

func initialize_from_saved_state(recruited: Array[String], formation: Dictionary) -> void:
	initialize_from_recruited(recruited)
	if not formation.is_empty():
		restore_formation(formation)

func recruit(character_id: String) -> bool:
	if character_id not in CHARACTER_IDS or character_id in roster or roster.size() >= PARTY_SIZE:
		return false
	roster.append(character_id)
	_rebuild_formation()
	return true

func swap_positions(character_a: String, character_b: String) -> bool:
	if character_a == character_b or character_a not in roster or character_b not in roster:
		return false
	var a := _find_row_and_index(character_a)
	var b := _find_row_and_index(character_b)
	if a.is_empty() or b.is_empty():
		return false
	if a.row == b.row:
		if a.row == "front":
			front_row[a.index] = character_b
			front_row[b.index] = character_a
		else:
			back_row[a.index] = character_b
			back_row[b.index] = character_a
		return true
	if a.row == "front":
		front_row[a.index] = character_b
		back_row[b.index] = character_a
	else:
		back_row[a.index] = character_b
		front_row[b.index] = character_a
	return true

func move_to_front(character_id: String) -> bool:
	if character_id not in back_row or front_row.size() >= FRONT_SIZE:
		return false
	back_row.erase(character_id)
	front_row.append(character_id)
	return true

func move_to_back(character_id: String) -> bool:
	if character_id not in front_row or back_row.size() >= BACK_SIZE:
		return false
	front_row.erase(character_id)
	back_row.append(character_id)
	return true

func get_front_row() -> Array[String]:
	return front_row.duplicate()

func get_back_row() -> Array[String]:
	return back_row.duplicate()

func get_active_order() -> Array[String]:
	var result: Array[String] = []
	result.append_array(front_row)
	result.append_array(back_row)
	return result

func is_full() -> bool:
	return roster.size() == PARTY_SIZE

func to_dict() -> Dictionary:
	return {
		"roster": roster.duplicate(),
		"front_row": front_row.duplicate(),
		"back_row": back_row.duplicate(),
	}

func restore(data: Dictionary) -> void:
	var saved_roster := _string_array(data.get("roster", []))
	if saved_roster.is_empty():
		return
	roster.clear()
	for id in saved_roster:
		if id in CHARACTER_IDS and id not in roster and roster.size() < PARTY_SIZE:
			roster.append(id)
	restore_formation(data)

func restore_formation(data: Dictionary) -> void:
	front_row.clear()
	back_row.clear()
	var saved_front := _string_array(data.get("front_row", []))
	var saved_back := _string_array(data.get("back_row", []))
	for id in saved_front:
		if id in roster and id not in front_row and id not in back_row and front_row.size() < FRONT_SIZE:
			front_row.append(id)
	for id in saved_back:
		if id in roster and id not in front_row and id not in back_row and back_row.size() < BACK_SIZE:
			back_row.append(id)
	for id in roster:
		if id not in front_row and id not in back_row:
			if front_row.size() < FRONT_SIZE:
				front_row.append(id)
			elif back_row.size() < BACK_SIZE:
				back_row.append(id)

func _rebuild_formation() -> void:
	front_row.clear()
	back_row.clear()
	for id in roster:
		if front_row.size() < FRONT_SIZE:
			front_row.append(id)
		elif back_row.size() < BACK_SIZE:
			back_row.append(id)

func _find_row_and_index(character_id: String) -> Dictionary:
	var front_index := front_row.find(character_id)
	if front_index >= 0:
		return {"row": "front", "index": front_index}
	var back_index := back_row.find(character_id)
	if back_index >= 0:
		return {"row": "back", "index": back_index}
	return {}

func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry in value:
			result.append(str(entry))
	return result
