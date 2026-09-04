extends RefCounted

## Lightweight regression tests for narrative invariants.
## Invoke from a Godot test runner or manually during development.

func test_all() -> void:
	_test_any_starting_character()
	_test_origin_progress_persists()
	_test_recruitment_immediately_unlocks_memory()
	_test_party_full_is_not_required()
	_test_memory_does_not_rewind_world()
	_test_shared_recruitment_events()
	_test_party_formation_round_trip()
	_test_save_round_trip()

func _test_any_starting_character() -> void:
	for character_id in NarrativeState.CHARACTER_IDS:
		var manager := NarrativeManager.new()
		assert(manager.start_new_game(character_id))
		assert(manager.state.starting_character == character_id)
		assert(manager.state.route_progress[character_id] == NarrativeState.ROUTE_UNLOCKED)

func _test_origin_progress_persists() -> void:
	var manager := NarrativeManager.new()
	manager.start_new_game("WUKONG")
	manager.state.set_origin_progress("WUKONG_ORIGIN", "WUK-07")
	assert(manager.state.current_origin_route == "WUKONG_ORIGIN")
	assert(manager.state.current_origin_chapter == "WUK-07")
	var restored := NarrativeState.from_dict(manager.serialize())
	assert(restored.current_origin_route == "WUKONG_ORIGIN")
	assert(restored.current_origin_chapter == "WUK-07")
	manager.state.mark_route_complete("WUKONG")
	assert(manager.state.current_origin_route == "")
	assert(manager.state.route_progress["WUKONG"] == NarrativeState.ROUTE_COMPLETE)

func _test_recruitment_immediately_unlocks_memory() -> void:
	var manager := NarrativeManager.new()
	manager.start_new_game("TANG")
	manager.encounter_character("WUKONG", ["WUK-01", "WUK-02"])
	assert(manager.can_enter_memory("WUK-01"))
	assert(manager.can_enter_memory("WUK-02"))

func _test_party_full_is_not_required() -> void:
	var manager := NarrativeManager.new()
	manager.start_new_game("TANG")
	manager.encounter_character("WUKONG", ["WUK-01"])
	assert(not manager.party_full())
	assert(manager.can_enter_memory("WUK-01"))

func _test_memory_does_not_rewind_world() -> void:
	var manager := NarrativeManager.new()
	manager.start_new_game("TANG")
	manager.advance_world_milestone("FIVE_ELEMENTS_MOUNTAIN_REACHED", 80)
	manager.set_shared_chapter("SHARED-01")
	manager.encounter_character("WUKONG", ["WUK-01"])
	var snapshot := manager.begin_memory("WUK-01")
	assert(snapshot["current_global_timeline"] == 80)
	assert(manager.finish_memory("WUK-01"))
	assert(manager.state.current_global_timeline == 80)
	assert(manager.state.current_shared_chapter == "SHARED-01")

func _test_shared_recruitment_events() -> void:
	var manager := NarrativeManager.new()
	manager.start_new_game("TANG")
	manager.encounter_character("WUKONG", ["WUK-01"])
	manager.set_shared_chapter("SHARED-01-FIVE-ELEMENTS")
	assert(SharedJourneyManager.complete("SHARED-01-FIVE-ELEMENTS", manager))
	assert(manager.state.current_shared_chapter == "SHARED-02-EARLY-PILGRIMAGE")
	assert(SharedJourneyManager.complete("SHARED-02-EARLY-PILGRIMAGE", manager))
	assert(SharedJourneyManager.complete("SHARED-03-EAGLE-SORROW", manager))
	assert("LONGMA" in manager.state.recruited_characters)
	assert(manager.can_enter_memory("LONGMA-01"))
	assert(manager.state.current_global_timeline == 110)

	assert(SharedJourneyManager.complete("SHARED-04-EARLY-DEMON-TALES", manager))
	assert(SharedJourneyManager.complete("SHARED-05-GAOJIAZHUANG", manager))
	assert("BAJIE" in manager.state.recruited_characters)
	assert(manager.can_enter_memory("BAJIE-01"))

	assert(SharedJourneyManager.complete("SHARED-06-FOUR-PERSON-JOURNEY", manager))
	assert(SharedJourneyManager.complete("SHARED-07-FLOWING-SANDS", manager))
	assert("WUJING" in manager.state.recruited_characters)
	assert(manager.can_enter_memory("WUJING-01"))

func _test_party_formation_round_trip() -> void:
	var party := PartyManager.new()
	party.initialize_from_recruited(["TANG", "WUKONG", "LONGMA", "BAJIE", "WUJING"])
	assert(party.move_to_back("TANG"))
	assert(party.move_to_front("WUKONG"))
	var serialized := party.to_dict()
	var restored := PartyManager.new()
	restored.initialize_from_saved_state(["TANG", "WUKONG", "LONGMA", "BAJIE", "WUJING"], serialized)
	assert(restored.front_row == party.front_row)
	assert(restored.back_row == party.back_row)

	var state := NarrativeState.new()
	state.starting_character = "TANG"
	state.recruited_characters = ["TANG", "WUKONG", "LONGMA", "BAJIE", "WUJING"]
	state.set_party_formation(serialized)
	var restored_state := NarrativeState.from_dict(state.to_dict())
	assert(restored_state.get_party_formation() == serialized)

func _test_save_round_trip() -> void:
	var path := "user://narrative_test_slot.json"
	var manager := NarrativeManager.new()
	manager.start_new_game("BAJIE")
	manager.advance_world_milestone("ZHU_BAJIE_RECRUITED", 130)
	manager.encounter_character("BAJIE", ["BAJIE-01"])
	manager.complete_chapter("SHARED-GAO-01", true)
	assert(manager.save(path))

	var restored := NarrativeSave.load_state(path)
	assert(restored != null)
	assert(restored.starting_character == "BAJIE")
	assert(restored.current_global_timeline == 130)
	assert("BAJIE" in restored.recruited_characters)
	assert("BAJIE-01" in restored.available_memory_chapters)
	assert("SHARED-GAO-01" in restored.completed_shared_chapters)
	NarrativeSave.delete_save(path)
