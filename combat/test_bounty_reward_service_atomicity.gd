extends RefCounted

## Bounty settlement must roll back inventory, journal and BountyManager state if persistence fails.
class ToggleSaveNarrativeManager:
	extends NarrativeManager

	var save_succeeds: bool = false
	var save_attempts: int = 0

	func save(_path: String = NarrativeSave.SAVE_PATH) -> bool:
		save_attempts += 1
		return save_succeeds

static func run_all() -> Dictionary:
	var manager := ToggleSaveNarrativeManager.new()
	assert(manager.start_new_game("WUKONG"), "Wukong should initialize bounty settlement state")
	assert(manager.encounter_character("TANG", []), "Tang should be recruited")
	assert(manager.encounter_character("WUKONG", []), "Wukong should be recruited")
	manager.state.set_inventory({
		"currencies": {"COIN": 55},
		"items": {"POTION": 3},
	})
	manager.state.current_global_timeline = 120
	manager.state.set_current_shared_chapter("SHARED-05-GAOJIAZHUANG")

	var bounty_manager := BountyManager.new()
	var file := FileAccess.open("res://data/world/bounties.json", FileAccess.READ)
	assert(file != null, "bounty definition catalog should load")
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary, "bounty catalog should parse as a dictionary")
	bounty_manager.load_definitions(parsed)
	assert(bounty_manager.has_bounty("BOUNTY_YELLOW_FANG"), "Yellow Fang bounty definition should exist")

	var inventory_after_battle: Dictionary = {
		"currencies": {"COIN": 12},
		"items": {"POTION": 1},
	}
	var narrative_before: Dictionary = manager.serialize().duplicate(true)
	var bounty_before: Dictionary = bounty_manager.to_dict().duplicate(true)

	var rejected: Dictionary = BountyRewardService.resolve_defeat(
		manager, bounty_manager, "BOUNTY_YELLOW_FANG", inventory_after_battle
	)
	assert(rejected.is_empty(), "failed save should reject the full bounty settlement")
	assert(manager.save_attempts == 1, "failed bounty settlement should reach exactly one save boundary")
	assert(manager.serialize() == narrative_before, "save failure should restore the exact NarrativeState, inventory and journal")
	assert(bounty_manager.to_dict() == bounty_before, "save failure should restore bounty status and intelligence")
	assert(bounty_manager.get_status("BOUNTY_YELLOW_FANG") == BountyManager.STATUS_UNKNOWN, "failed save must not leave a locally defeated bounty")

	manager.save_succeeds = true
	var committed: Dictionary = BountyRewardService.resolve_defeat(
		manager, bounty_manager, "BOUNTY_YELLOW_FANG", inventory_after_battle
	)
	assert(not committed.is_empty(), "retry should commit the bounty settlement")
	assert(manager.save_attempts == 2, "the successful retry should use one additional save, not a second save inside the service")
	assert(bounty_manager.get_status("BOUNTY_YELLOW_FANG") == BountyManager.STATUS_DEFEATED, "successful commit should mark the bounty defeated")
	assert("BOUNTY_YELLOW_FANG" in manager.state.get_journey_log().get("defeated_targets", []), "successful commit should persist the target in the battle journal")
	assert(int(manager.state.get_inventory().get("currencies", {}).get("COIN", 0)) >= 12, "the post-combat inventory should be the basis for rewards")
	assert(int(manager.state.get_inventory().get("items", {}).get("POTION", 0)) == 1, "consumed items should not reappear after the successful settlement")
	assert(manager.state.current_shared_chapter == "SHARED-05-GAOJIAZHUANG", "bounty settlement must not advance the canonical Shared chapter")
	assert(manager.state.current_global_timeline == 120, "bounty settlement must not advance the fixed Journey chronology")
	assert(not committed.get("applied", {}).get("granted", []).is_empty(), "successful bounty commit should report granted rewards")

	return {
		"passed": true,
		"save_attempts": manager.save_attempts,
		"failure_rollback_checked": true,
		"retry_commit_checked": true,
		"shared_chronology_preserved": true,
	}
