extends BattleUI

## Narrative-only override for the atomic victory commit boundary.
## Normal/bounty battles retain the existing BattleUI resolution paths.
## When a battle belongs to an EventSession, its resume context is kept in the
## neutral encounter handoff until JourneyScreen restores the next event action.

func _on_combat_finished(winner: String) -> void:
	if encounter_type != "origin" and encounter_type != "shared":
		super._on_combat_finished(winner)
		return
	if encounter_resolved:
		return
	battle_result_locked = true
	if winner != "allies":
		status_label.text = "战斗失败。可以返回重新准备。"
		return

	var narrative := NarrativeManager.new()
	if not narrative.load():
		status_label.text = "战斗胜利，但存档读取失败。"
		return
	var definition := encounter_manager.get_definition(encounter_id)
	if definition.is_empty():
		status_label.text = "战斗胜利，但找不到遭遇定义。"
		return

	var active_record := BountyEncounterState.get_active_record()
	var rewards: Array = definition.get("rewards", [])
	var world_effects: Array = definition.get("world_effects", [])
	var resolved := BattleResolutionService.resolve_narrative_victory(
		narrative,
		encounter_type,
		encounter_id,
		source_stage_id,
		source_chapter_id,
		source_route_id,
		str(definition.get("name", encounter_id)),
		rewards,
		world_effects,
		encounter_manager
	)
	if resolved.is_empty():
		status_label.text = "战斗胜利，但主线提交失败；未发放奖励。"
		return

	battle_inventory.restore(resolved.get("inventory", {}))
	var event_resume: Dictionary = active_record.get("event_resume", {})
	var event_resumed := false
	if not event_resume.is_empty():
		var session := NarrativeEventSession.resume_from_battle_record(active_record, narrative)
		if session != null:
			var next_action := session.resolve_battle(true)
			if not next_action.is_empty():
				if not BountyEncounterState.start_encounter(
					encounter_type,
					encounter_id,
					source_stage_id,
					source_chapter_id,
					source_route_id,
					{"event_resume": session.to_dict()}
				):
					status_label.text = "战斗已结算，但事件恢复上下文保存失败。"
					return
				event_resumed = true
		else:
			BountyEncounterState.clear()
	else:
		BountyEncounterState.clear()
	encounter_resolved = true
	var next_step := "返回旅途，继续个人路线。" if encounter_type == "origin" else "返回旅途，继续共享主线。"
	if event_resumed:
		next_step = "返回旅途，继续战后剧情。"
	var result_title := "个人章节完成" if encounter_type == "origin" else "共享章节完成"
	var granted: Array = resolved.get("granted", [])
	_show_victory_summary(result_title, str(definition.get("name", encounter_id)), granted, next_step, "继续旅途")
