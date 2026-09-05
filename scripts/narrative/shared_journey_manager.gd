class_name SharedJourneyManager
extends RefCounted

## Canonical shared-journey progression. World chronology only moves forward.
## Chapter content is data-driven; this class owns validation, recruitment and state mutation.

const DATA_PATH := "res://data/narrative/shared_chapters.json"
const SHARED_BATTLE_MILESTONE_PREFIX := "SHARED_BATTLE_"

static var _chapters: Array = []
static var _loaded := false

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_chapters.clear()
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		for chapter in parsed.get("chapters", []):
			if chapter is Dictionary and str(chapter.get("id", "")) != "":
				_chapters.append(chapter.duplicate(true))

static func get_all_chapters() -> Array:
	_ensure_loaded()
	return _chapters.duplicate(true)

static func get_chapter(chapter_id: String) -> Dictionary:
	_ensure_loaded()
	for chapter in _chapters:
		if str(chapter.get("id", "")) == chapter_id:
			return chapter.duplicate(true)
	return {}

static func first_chapter_for_state(state: NarrativeState) -> Dictionary:
	_ensure_loaded()
	if state.current_shared_chapter != "":
		return get_chapter(state.current_shared_chapter)
	for chapter in _chapters:
		if _requirements_met(chapter, state):
			return chapter.duplicate(true)
	return {}

static func can_enter(chapter_id: String, state: NarrativeState) -> bool:
	var chapter := get_chapter(chapter_id)
	if chapter.is_empty():
		return false
	if chapter_id in state.completed_shared_chapters:
		return false
	return _requirements_met(chapter, state)

static func complete(chapter_id: String, manager: NarrativeManager) -> bool:
	if manager == null:
		return false
	var chapter := get_chapter(chapter_id)
	if chapter.is_empty() or not can_enter(chapter_id, manager.state):
		return false

	var snapshot := manager.state.to_dict()
	var encounter_id := str(chapter.get("encounter_id", ""))
	if encounter_id != "":
		var battle_milestone := "%s%s" % [SHARED_BATTLE_MILESTONE_PREFIX, encounter_id]
		if battle_milestone not in manager.state.completed_milestones:
			return false
	else:
		# Encounter rewards are granted by BattleRewardService when the battle is won.
		# Non-combat chapters have no battle to do that work, so their data rewards
		# must be applied here exactly once as part of canonical chapter completion.
		_apply_chapter_rewards(chapter, manager)

	if not manager.complete_chapter(chapter_id, true):
		manager.state = NarrativeState.from_dict(snapshot)
		return false
	manager.advance_world_milestone(str(chapter.get("id", "")), int(chapter.get("timeline", 0)))
	if not _apply_recruitment_events(chapter, manager):
		manager.state = NarrativeState.from_dict(snapshot)
		return false
	if not _apply_world_effects(chapter, manager):
		manager.state = NarrativeState.from_dict(snapshot)
		return false

	var next_id := str(chapter.get("next", ""))
	manager.set_shared_chapter(next_id if next_id != "" else chapter_id)
	if not manager.save():
		manager.state = NarrativeState.from_dict(snapshot)
		return false
	return true

static func next_for_state(state: NarrativeState) -> Dictionary:
	var current := get_chapter(state.current_shared_chapter)
	if current.is_empty():
		return first_chapter_for_state(state)
	var next_id := str(current.get("next", ""))
	if next_id == "":
		return current
	return get_chapter(next_id)

static func _apply_chapter_rewards(chapter: Dictionary, manager: NarrativeManager) -> void:
	var rewards: Array = chapter.get("rewards", [])
	if rewards.is_empty():
		return
	var inventory := InventoryManager.new()
	inventory.restore(manager.state.get_inventory())
	for reward in rewards:
		_apply_reward(inventory, str(reward))
	manager.state.set_inventory(inventory.to_dict())

static func _apply_reward(inventory: InventoryManager, reward_id: String) -> void:
	match reward_id:
		"COIN_LOW":
			inventory.add_currency("COIN", 100)
		"COIN_MEDIUM":
			inventory.add_currency("COIN", 300)
		"COIN_HIGH":
			inventory.add_currency("COIN", 800)
		"COIN_LEGENDARY":
			inventory.add_currency("COIN", 2000)
		_:
			if reward_id != "":
				inventory.add_item(reward_id, 1)

static func _apply_recruitment_events(chapter: Dictionary, manager: NarrativeManager) -> bool:
	for event in chapter.get("recruit", []):
		if not event is Dictionary:
			continue
		var character_id := str(event.get("character", ""))
		if character_id == "":
			continue
		var memories: Array[String] = []
		for memory_id in event.get("memories", []):
			memories.append(str(memory_id))
		if not manager.encounter_character(character_id, memories):
			return false
	return true

static func _apply_world_effects(chapter: Dictionary, manager: NarrativeManager) -> bool:
	for effect in chapter.get("world_effects", []):
		var effect_id := str(effect)
		if effect_id == "" or effect_id in manager.state.journey_log.get("active_world_effects", []):
			continue
		var log := manager.state.get_journey_log()
		var effects: Array = log.get("active_world_effects", []).duplicate()
		effects.append(effect_id)
		log["active_world_effects"] = effects
		manager.state.set_journey_log(log)
	return true

static func _requirements_met(chapter: Dictionary, state: NarrativeState) -> bool:
	var required := str(chapter.get("required", ""))
	match required:
		"WUKONG_RECRUITED":
			return "WUKONG" in state.recruited_characters
		"BAI_LONGMA_RECRUITED":
			return "LONGMA" in state.recruited_characters
		"ZHU_BAJIE_RECRUITED":
			return "BAJIE" in state.recruited_characters
		"SHA_WUJING_RECRUITED":
			return "WUJING" in state.recruited_characters
		"PARTY_FULL":
			return state.recruited_characters.size() >= NarrativeState.CHARACTER_IDS.size()
	return true
