extends SceneTree

## Regression coverage for shared-journey event gating and choice persistence.
func _initialize() -> void:
	var manager := NarrativeManager.new()
	_assert(manager.start_new_game("WUKONG"), "Wukong route should start")
	manager.state.recruited_characters = ["TANG", "WUKONG"]
	manager.state.current_shared_chapter = "SHARED-01-FIVE-ELEMENTS"

	var events := SharedEventManager.new()
	var event := events.get_event("SHARED-01-FIVE-ELEMENTS")
	_assert(not event.is_empty(), "shared opening event should load")
	_assert(event.get("choices", []).size() == 2, "opening event should expose two choices")
	_assert(events.get_choice(manager, "SHARED-01-FIVE-ELEMENTS") == "", "choice should start empty")
	_assert(not events.apply_choice(manager, "SHARED-01-FIVE-ELEMENTS", "NOT_A_CHOICE"), "invalid choice must be rejected")
	_assert(events.apply_choice(manager, "SHARED-01-FIVE-ELEMENTS", "TRUST_WUKONG"), "valid choice should be recorded")
	_assert(events.get_choice(manager, "SHARED-01-FIVE-ELEMENTS") == "TRUST_WUKONG", "choice should persist")
	_assert(manager.state.current_global_timeline == 0, "event choices must not mutate shared timeline")

	var longma_event := events.get_event("LONGMA_ENCOUNTER")
	_assert(not longma_event.is_empty(), "Longma encounter event should load")
	_assert(events.apply_choice(manager, "LONGMA_ENCOUNTER", "SAVE_THE_DRAGON"), "Longma choice should be accepted")
	_assert(manager.state.origin_choices.get("SHARED:LONGMA_ENCOUNTER", "") == "SAVE_THE_DRAGON", "shared event choices use a separate namespace")

	print("ALL SHARED EVENT TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
