extends RefCounted

## Regression checks for data-driven origin chapter choices.

static func run() -> void:
	var narrative := NarrativeManager.new()
	assert(narrative.start_new_game("WUKONG"))
	var events := OriginEventManager.new()
	assert(events.has_event("WUK-03"))
	assert(not events.apply_choice(narrative, "WUK-03", "MISSING"))
	assert(events.apply_choice(narrative, "WUK-03", "SEEK_FREEDOM"))
	assert(narrative.state.get_origin_choice("WUK-03") == "SEEK_FREEDOM")
	assert(int(narrative.state.relationship_values.get("WUKONG_FREEDOM", 0)) == 2)
	assert(not events.apply_choice(narrative, "WUK-03", "SEEK_POWER"))

	narrative.save("user://test_origin_event_manager.json")
	var restored := NarrativeManager.new()
	assert(restored.load("user://test_origin_event_manager.json"))
	assert(restored.state.get_origin_choice("WUK-03") == "SEEK_FREEDOM")
	assert(int(restored.state.relationship_values.get("WUKONG_FREEDOM", 0)) == 2)
