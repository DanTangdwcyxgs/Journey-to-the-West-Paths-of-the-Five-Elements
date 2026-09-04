class_name PartyManager
extends RefCounted

## Five-character party with three front slots and two back slots.
## Active order is deterministic and can be swapped without changing the recruited roster.

const PARTY_SIZE := 5
const FRONT_SIZE := 3
const BACK_SIZE := 2
const CHARACTER_IDS := ["TANG", "WUKONG", "BAJIE", "WUJING", "LONGMA"]

var roster: Array[String] = []
var front_row: Array[String] = []
var back_row: Array[String] = []

func initialize_from_recruited(recruited: Array[String]) -> void:
	roster.clear()
	front_row.clear()
	back_row.clear()
	for id in recruited:
		if id in CHARACTER_IDS and id not in roster:
			roster.append(id)
	_rebuild_formation()

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
	if a.row == "front" and a.index < FRONT_SIZE and b.row == "front" and b.index < FRONT_SIZE:
		front_row[a.index] = character_b
		front_row[b.index] = character_a
		return true
	if a.row == "back" and b.row == "back":
		back_row[a.index] = character_b
		back_row[b.index] = character_a
		return true
	front_row[a.index] = character_b if a.row == "front" else front_row[a.index]
	back_row[a.index] = character_b if a.row == "back" else back_row[a.index]
	front_row[b.index] = character_a if b.row == "front" else front_row[b.index]
	back_row[b.index] = character_a if b.row == "back" else back_row[b.index]
	return true

func move_to_front(character_id: String) -> bool:
	if character_id not in back_row or front_row.size() >= FRONT_SIZE:
		return false
	var back_index := back_row.find(character_id)
	var front_index := front_row.size()
	front_row.append(character_id)
	back_row.remove_at(back_index)
	if front_row.size() > FRONT_SIZE:
		front_row.remove_at(front_index)
		back_row.insert(0, character_id)
		return false
	return true

func move_to_back(character_id: String) -> bool:
	if character_id not in front_row or back_row.size() >= BACK_SIZE:
		return false
	var front_index := front_row.find(character_id)
	front_row.remove_at(front_index)
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
	roster = _string_array(data.get("roster", []))
	front_row = _string_array(data.get("front_row", []))
	back_row = _string_array(data.get("back_row", []))
	if roster.is_empty():
		_rebuild_formation()
	else:
		_rebuild_formation_if_invalid()

func _rebuild_formation() -> void:
	front_row.clear()
	back_row.clear()
	for id in roster:
		if front_row.size() < FRONT_SIZE:
			front_row.append(id)
		elif back_row.size() < BACK_SIZE:
			back_row.append(id)

func _rebuild_formation_if_invalid() -> void:
	var valid := front_row.size() <= FRONT_SIZE and back_row.size() <= BACK_SIZE
	valid = valid and front_row.size() + back_row.size() == roster.size()
	for id in roster:
		valid = valid and (id in front_row or id in back_row)
	if not valid:
		_rebuild_formation()

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
