extends RefCounted

## The retry control must retry settlement without replaying the finished battle.
class RetryableBattleUI:
	extends BattleUI

	var test_narrative: NarrativeManager
	var settlement_attempts: int = 0
	var successful_commits: int = 0

	func _load_narrative_for_resolution() -> NarrativeManager:
		return test_narrative

	func _resolve_bounty_defeat(_narrative: NarrativeManager) -> Dictionary:
		settlement_attempts += 1
		if settlement_attempts == 1:
			return {}
		successful_commits += 1
		return {
			"target_name": "黄牙",
			"applied": {
				"granted": [{"id": "COIN", "amount": 10}],
			},
		}

	func _clear_bounty_handoff() -> void:
		pass

static func run_all() -> Dictionary:
	var ui := RetryableBattleUI.new()
	ui.test_narrative = NarrativeManager.new()
	assert(ui.test_narrative.start_new_game("WUKONG"), "test NarrativeState should initialize")
	ui.encounter_type = "bounty"
	ui.encounter_id = "BOUNTY_YELLOW_FANG"
	ui.source_stage_id = ""
	ui.engine.turn_number = 4
	var turn_before_retry: int = ui.engine.turn_number
	ui._build_ui()

	ui._on_combat_finished("allies")
	assert(ui.bounty_settlement_pending, "first failed settlement should expose retry state")
	assert(not ui.battle_result_locked, "failed save must unlock the result handler for retry")
	assert(not ui.encounter_resolved, "failed settlement must not resolve the encounter")
	assert(ui.return_button.text == "重试结算", "return control should become the settlement retry button")
	assert(ui.settlement_attempts == 1, "initial victory should attempt settlement exactly once")

	# Exercise the real Button signal connection, not the private handler directly.
	ui.return_button.pressed.emit()
	assert(ui.settlement_attempts == 2, "clicking retry should run the settlement handler again")
	assert(ui.successful_commits == 1, "the successful settlement should commit exactly once")
	assert(not ui.bounty_settlement_pending, "successful retry should clear pending settlement state")
	assert(ui.encounter_resolved, "successful retry should resolve the encounter")
	assert(ui.battle_result_locked, "successful retry should lock the completed result")
	assert(ui.return_button.text == "返回地图", "successful settlement should restore the normal destination label")
	assert(ui.status_label.text.contains("悬赏完成"), "success feedback should replace the retry warning")
	assert(ui.engine.turn_number == turn_before_retry, "settlement retry must not advance or replay combat")

	ui.free()
	return {
		"passed": true,
		"settlement_attempts": 2,
		"successful_commits": 1,
		"retry_button_signal_checked": true,
		"combat_not_replayed": true,
	}
