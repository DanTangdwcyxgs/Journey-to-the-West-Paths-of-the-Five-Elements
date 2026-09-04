class_name LongmaFormManager
extends RefCounted

const DATA_PATH := "res://data/combat/longma_forms.json"

var forms: Array = []
var duration := 3
var mechanic_cost := 1

func _init() -> void:
	_load_data()

func _load_data() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	forms = parsed.get("forms", []).duplicate(true)
	duration = int(parsed.get("duration", duration))
	mechanic_cost = int(parsed.get("mechanic_cost", mechanic_cost))

func get_form(form_id: String) -> Dictionary:
	for form in forms:
		if str(form.get("id", "")) == form_id:
			return form.duplicate(true)
	return {}

func next_form(current_form: String) -> Dictionary:
	if forms.is_empty():
		return {}
	var index := -1
	for i in range(forms.size()):
		if str(forms[i].get("id", "")) == current_form:
			index = i
			break
	return forms[(index + 1) % forms.size()].duplicate(true)

func shift(actor: Combatant) -> Dictionary:
	if actor == null or actor.id != "longma" or actor.mechanic_resource < mechanic_cost:
		return {}
	var form := next_form(actor.longma_form)
	if form.is_empty():
		return {}
	actor.spend_mechanic_resource(mechanic_cost)
	actor.set_longma_form(
		str(form.get("id", "horse")),
		duration,
		int(form.get("attack_bonus", 0)),
		int(form.get("defense_bonus", 0)),
		int(form.get("speed_bonus", 0))
	)
	return form
