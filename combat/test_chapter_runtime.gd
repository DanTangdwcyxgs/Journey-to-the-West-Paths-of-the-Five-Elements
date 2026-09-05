extends SceneTree

## Regression coverage for the production-oriented chapter contract.
func _initialize() -> void:
	var state := NarrativeState.new()
	state.initialize_for_start("WUKONG")
	state.mark_recruited("WUKONG")

	var prerequisite_blocked := ChapterDefinition.new({
		"id": "TEST-PREREQ",
		"chapter_type": "SHARED_JOURNEY",
		"required": "WUKONG_RECRUITED",
		"prerequisites": ["TEST-PREVIOUS"],
	})
	_assert(not ChapterRuntime.can_enter(prerequisite_blocked, state), "missing prerequisite should block chapter")
	state.record_chapter_complete("TEST-PREVIOUS", true)
	_assert(ChapterRuntime.can_enter(prerequisite_blocked, state), "completed prerequisite should allow chapter")

	var shared := ChapterDefinition.new({
		"id": "TEST-SHARED",
		"title": "测试共享章节",
		"chapter_type": "SHARED_JOURNEY",
		"is_shared": true,
		"timeline": 120,
		"required": "WUKONG_RECRUITED",
		"event": "TEST-EVENT",
		"encounter_id": "TEST_ENCOUNTER",
		"next": "TEST-NEXT",
	})
	_assert(shared.get_id() == "TEST-SHARED", "chapter id should normalize")
	_assert(shared.get_chapter_type() == "SHARED_JOURNEY", "chapter type should normalize")
	_assert(shared.get_event_id() == "TEST-EVENT", "event id should normalize")
	_assert(shared.is_combat(), "encounter chapter should be combat")
	_assert(ChapterRuntime.can_enter(shared, state), "recruitment requirement should be satisfied")
	_assert(ChapterRuntime.destination(shared).get("kind", "") == "battle", "combat chapter should route to battle")
	_assert(ChapterRuntime.next_id(shared) == "TEST-NEXT", "next chapter should normalize")

	var event_only := ChapterDefinition.new({
		"id": "TEST-EVENT-ONLY",
		"chapter_type": "SHARED_JOURNEY",
		"required": "WUKONG_RECRUITED",
		"event_id": "TEST-EVENT-2",
	})
	_assert(ChapterRuntime.destination(event_only).get("kind", "") == "event", "event chapter should route to event")

	print("ALL CHAPTER RUNTIME TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
