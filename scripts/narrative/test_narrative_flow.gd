extends SceneTree

## Regression coverage for the unified origin-route lifecycle API.
func _initialize() -> void:
	var manager := NarrativeManager.new()
	_assert(manager.start_new_game("WUKONG"), "Wukong should start a valid origin route")

	var first_status := manager.get_origin_status("WUKONG")
	_assert(first_status.get("state", "") == NarrativeState.ROUTE_UNLOCKED, "starting route should be unlocked")
	_assert(first_status.get("current_chapter", "") != "", "starting route should expose a current chapter")
	_assert(first_status.get("completed_chapters", -1) == 0, "new route should have zero completed chapters")
	_assert(first_status.get("total_chapters", 0) > 0, "route should contain chapters")
	_assert(first_status.get("complete", true) == false, "new route cannot be complete")

	var first_chapter := str(first_status.get("current_chapter", ""))
	var completed := manager.complete_origin_chapter("WUKONG")
	_assert(not completed.is_empty(), "current origin chapter should complete")
	_assert(str(completed.get("id", "")) == first_chapter, "completed chapter should match current chapter")
	_assert(first_chapter in manager.state.completed_chapters, "completed chapter should persist in narrative state")

	var second_status := manager.get_origin_status("WUKONG")
	_assert(second_status.get("completed_chapters", 0) == 1, "completed count should advance")
	_assert(second_status.get("current_chapter", "") != first_chapter, "route should advance to the next chapter")
	_assert(second_status.get("current_chapter", "") in manager.state.unlocked_chapters, "next chapter should be unlocked")

	var tang := NarrativeManager.new()
	_assert(tang.start_new_game("TANG"), "Tang should start a valid origin route")
	var tang_status := tang.get_origin_status("TANG")
	_assert(tang_status.get("state", "") == NarrativeState.ROUTE_UNLOCKED, "Tang route should be unlocked")
	_assert(tang.state.route_progress.get("WUKONG", "") == NarrativeState.ROUTE_LOCKED, "other origin routes stay locked")

	print("ALL NARRATIVE FLOW TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
