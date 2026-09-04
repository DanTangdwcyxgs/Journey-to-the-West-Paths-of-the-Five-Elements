extends RefCounted

static func run() -> void:
	var event_file := FileAccess.open("res://data/narrative/origin_events.json", FileAccess.READ)
	assert(event_file != null)
	var event_data = JSON.parse_string(event_file.get_as_text())
	assert(event_data is Dictionary)
	assert(event_data.get("events", {}).has("WUK-03"))
	assert(event_data.get("events", {}).has("WUK-08"))
	assert(event_data.get("events", {}).has("WUK-13"))

	var narrative := NarrativeManager.new()
	assert(narrative.start_new_game("WUKONG"))
	narrative.state.record_origin_choice("WUK-03", "SEEK_POWER")
	narrative.state.record_origin_choice("WUK-08", "REJECT_BINDING")
	assert(narrative.state.get_origin_choice("WUK-03") == "SEEK_POWER")
	assert(narrative.state.get_origin_choice("WUK-08") == "REJECT_BINDING")

	var attacker := Combatant.new("wukong", "孙悟空", 100, 20, 5, 12, 2, {})
	attacker.attack += 2
	attacker.speed += 1
	assert(attacker.attack == 22)
	assert(attacker.speed == 13)
