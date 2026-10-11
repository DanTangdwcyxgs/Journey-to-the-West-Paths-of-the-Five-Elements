extends RefCounted

## Memory playback is read-only until its explicit completion is saved.
class MemoryTestNarrativeManager:
	extends NarrativeManager

	var save_should_succeed: bool = true
	var save_calls: int = 0

	func save(_path: String = NarrativeSave.SAVE_PATH) -> bool:
		save_calls += 1
		return save_should_succeed

static func run_all() -> Dictionary:
	var manager := MemoryTestNarrativeManager.new()
	assert(manager.start_new_game("WUKONG"), "Wukong should initialize the memory test save")
	assert(manager.encounter_character("TANG", []), "Tang should be present in the party")
	assert(manager.encounter_character("WUKONG", []), "Wukong should be present in the party")
	assert(manager.encounter_character("LONGMA", ["LONGMA-01", "LONGMA-02"]), "Longma recruitment should unlock the first two safe memories")
	manager.state.mark_route_complete("WUKONG")
	manager.state.set_current_shared_chapter("SHARED-04-EARLY-DEMON-TALES")
	manager.state.current_global_timeline = 120
	manager.state.completed_shared_chapters.append("SHARED-01-FIVE-ELEMENTS")
	manager.state.completed_shared_chapters.append("SHARED-02-EARLY-PILGRIMAGE")
	manager.state.completed_shared_chapters.append("SHARED-03-EAGLE-SORROW")

	assert(manager.can_enter_memory("LONGMA-01"), "recruitment should unlock Longma's first memory")
	assert(manager.can_enter_memory("LONGMA-02"), "recruitment should unlock Longma's second memory")
	assert(not manager.can_enter_memory("LONGMA-03"), "unlocked memories should remain gated to the explicit unlock list")

	var scene: PackedScene = load("res://ui/journey.tscn") as PackedScene
	assert(scene != null, "production Journey scene should load")
	var journey: JourneyScreen = scene.instantiate() as JourneyScreen
	assert(journey != null, "production Journey scene should instantiate")
	journey.narrative = manager
	journey.call("_build_ui")
	journey.call("_refresh_sidebar")

	var memory_row := -1
	for row_index in range(journey.list.get_item_count()):
		if journey.list.get_item_text(row_index) == "回忆 · LONGMA-02":
			memory_row = row_index
			break
	assert(memory_row >= 0, "Journey sidebar should visibly list the unlocked Longma memory")
	journey.list.select(memory_row)
	journey.call("_on_sidebar_item_selected", memory_row)
	assert(not journey.memory_button.disabled, "selecting an unlocked memory should enable playback")
	journey.call("_play_selected_memory")

	assert(journey.memory_playback_session != null, "memory button should start a playback session")
	assert(journey.memory_playback_session.chapter_title == "龙子获罪", "memory playback should resolve the canonical chapter title")
	assert(journey.memory_playback_session.get_total_entries() == 2, "battle memory should retain dialogue before and after the encounter without running combat")
	assert(journey.dialogue_full_text.find("罪责落到身上") >= 0, "memory playback should show the opening canonical dialogue")
	assert(journey.primary_button.text == "继续回忆", "non-final memory entries should offer Continue")
	assert(journey.party_button.disabled and journey.world_button.disabled and journey.save_button.disabled, "world-changing Journey controls should be locked during playback")

	var before_state: Dictionary = manager.serialize().duplicate(true)
	var before_context: Dictionary = manager.state.snapshot_shared_context()
	assert(before_context == journey.memory_playback_session.shared_context_snapshot, "session should capture the exact shared state before playback")
	assert(manager.serialize() == before_state, "starting memory playback must not mutate narrative state")

	journey.call("_advance_primary")
	assert(not journey.dialogue_revealing, "first advance should reveal the current memory dialogue without skipping it")
	assert(journey.memory_playback_session.get_current_position() == 1, "revealing dialogue should not advance the memory cursor")
	journey.call("_advance_primary")
	assert(journey.memory_playback_session.get_current_position() == 2, "second advance should move to the next dialogue")
	assert(journey.dialogue_full_text.find("真正的担当") >= 0, "the post-battle memory dialogue should be included as text only")
	assert(journey.primary_button.text == "完成回忆", "the final memory entry should expose an explicit completion action")
	assert(manager.serialize() == before_state, "moving through memory must not change shared progress, recruits, chronology or memory flags")
	assert(journey.memory_playback_session.shared_context_unchanged(), "shared world context should remain unchanged during playback")

	journey.call("_advance_primary")
	assert(not journey.dialogue_revealing, "final entry should be revealed before completion is committed")
	manager.save_should_succeed = false
	journey.call("_advance_primary")
	assert(journey.memory_playback_session != null, "save failure should keep the memory open for retry")
	assert(manager.serialize() == before_state, "failed memory completion save should roll all memory flags back")
	assert(manager.save_calls == 1, "first completion attempt should reach the save boundary")
	assert(journey.phase_label.text.find("保存失败") >= 0, "save failure should be visible to the player")

	manager.save_should_succeed = true
	journey.call("_advance_primary")
	assert(journey.memory_playback_session == null, "successful retry should close the memory session")
	assert(manager.save_calls == 2, "successful retry should save once more")
	assert("LONGMA-02" not in manager.state.available_memory_chapters, "completed memory should leave the available list")
	assert("LONGMA-02" in manager.state.played_memory_chapters, "completed memory should be recorded as played")
	assert(manager.state.snapshot_shared_context() == before_context, "memory completion must preserve chapter, roster and world timeline")
	assert(_without_memory_flags(manager.serialize()) == _without_memory_flags(before_state), "the only NarrativeState changes should be the memory available/played flags")
	assert(not journey.party_button.disabled and not journey.world_button.disabled and not journey.save_button.disabled, "Journey controls should be restored after playback")
	assert(journey.phase_label.text.find("西游进度未改变") >= 0, "completion feedback should explicitly preserve the Journey chronology")

	journey.free()
	return {
		"passed": true,
		"memory_dialogues_played": 2,
		"battle_nodes_executed": 0,
		"save_failure_rollback_checked": true,
		"shared_context_preserved": true,
	}

static func _without_memory_flags(data: Dictionary) -> Dictionary:
	var result := data.duplicate(true)
	result.erase("available_memory_chapters")
	result.erase("played_memory_chapters")
	return result
