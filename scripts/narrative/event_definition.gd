class_name EventDefinition
extends RefCounted

## Normalized narrative event contract.
## Events describe presentation and choices; persistent effects are applied by EventRuntime.

var raw: Dictionary = {}

func _init(data: Dictionary = {}) -> void:
	raw = data.duplicate(true)

func get_id() -> String:
	return str(raw.get("id", raw.get("event_id", "")))

func get_title() -> String:
	return str(raw.get("title", get_id()))

func get_text() -> String:
	return str(raw.get("text", raw.get("description", "")))

func get_choices() -> Array:
	return raw.get("choices", []).duplicate(true)

func get_choice(choice_id: String) -> Dictionary:
	for choice in get_choices():
		if choice is Dictionary and str(choice.get("id", "")) == choice_id:
			return choice.duplicate(true)
	return {}

func has_choices() -> bool:
	return not get_choices().is_empty()

func has_choice(choice_id: String) -> bool:
	return not get_choice(choice_id).is_empty()

func to_dict() -> Dictionary:
	return raw.duplicate(true)

func is_empty() -> bool:
	return get_id().is_empty()
