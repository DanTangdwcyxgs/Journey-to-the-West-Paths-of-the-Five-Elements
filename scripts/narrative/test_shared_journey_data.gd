extends SceneTree

## Regression coverage for data-driven shared chronology, recruitment and world effects.
func _initialize() -> void:
	var chapters := SharedJourneyManager.get_all_chapters()
	_assert(chapters.size() == 9, "shared chapter data should contain the full current nine-chapter spine")
	_assert(str(chapters[0].get("id", "")) == "SHARED-01-FIVE-ELEMENTS", "shared chronology must start at Five Elements Mountain")
	_assert(str(chapters[2].get("next", "")) == "SHARED-04-EARLY-DEMON-TALES", "chapter links must remain ordered")
	_assert(str(chapters[2].get("recruit", [])[0].get("character", "")) == "LONGMA", "Eagle Sorrow should recruit Longma")
	_assert(str(chapters[4].get("recruit", [])[0].get("character", "")) == "BAJIE", "Gaojiazhuang should recruit Bajie")
	_assert(str(chapters[6].get("recruit", [])[0].get("character", "")) == "WUJING", "Flowing Sands should recruit Wujing")

	var manager := NarrativeManager.new()
	_assert(manager.start_new_game("WUKONG"), "Wukong route should initialize")
	manager.encounter_character("TANG")
	manager.encounter_character("WUKONG")
	manager.set_shared_chapter("SHARED-01-FIVE-ELEMENTS")
	_assert(SharedJourneyManager.can_enter("SHARED-01-FIVE-ELEMENTS", manager.state), "first shared chapter should be enterable")
	_assert(SharedJourneyManager.complete("SHARED-01-FIVE-ELEMENTS", manager), "first shared chapter should complete")
	_assert(manager.state.current_shared_chapter == "SHARED-02-EARLY-PILGRIMAGE", "completion should advance to next chapter")
	_assert(manager.state.current_global_timeline == 100, "shared completion should advance timeline")

	manager.set_shared_chapter("SHARED-03-EAGLE-SORROW")
	_assert(SharedJourneyManager.complete("SHARED-03-EAGLE-SORROW", manager), "Longma chapter should complete")
	_assert("LONGMA" in manager.state.recruited_characters, "Longma should be recruited by data event")
	_assert("BAI_LONGMA_RECRUITED" in manager.state.journey_log.active_world_effects, "recruitment world effect should persist")
	_assert("LONGMA-01" in manager.state.available_memory_chapters, "recruitment memories should unlock immediately")

	var snapshot := manager.state.snapshot_shared_context()
	_assert(int(snapshot.get("current_global_timeline", -1)) == 110, "shared snapshot should preserve chronology")
	_assert(snapshot.get("current_shared_chapter", "") == "SHARED-04-EARLY-DEMON-TALES", "shared snapshot should preserve handoff chapter")

	print("ALL SHARED JOURNEY DATA TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
