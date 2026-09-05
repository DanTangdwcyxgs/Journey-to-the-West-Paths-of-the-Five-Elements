extends BattleUI

## Narrative-only override for the atomic victory commit boundary.
## Normal/bounty battles retain the existing BattleUI resolution paths.

func _on_combat_finished(winner: String) -> void:
	if encounter_type != "origin" and encounter_type != "shared":
		super._on_combat_finished(winner)
		return
	if encounter_resolved:
		return
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
	BountyEncounterState.clear()
	encounter_resolved = true
	if encounter_type == "origin":
		status_label.text = "个人章节完成：%s · 获得 %s" % [str(definition.get("name", encounter_id)),_format_rewards(resolved.get("granted", []))]
	else:
		status_label.text = "共享章节完成：%s · 获得 %s" % [str(definition.get("name", encounter_id)),_format_rewards(resolved.get("granted", []))]
