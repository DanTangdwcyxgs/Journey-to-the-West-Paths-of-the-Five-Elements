class_name YellowWindRidgeManager
extends RefCounted

const DATA_PATH := "res://data/world/yellow_wind_ridge.json"
var definition: Dictionary = {}

func _init() -> void:
	load_definition()

func load_definition() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		definition = {}
		return
	var parsed = JSON.parse_string(file.get_as_text())
	definition = parsed if parsed is Dictionary else {}

func is_available(manager: NarrativeManager) -> bool:
	return manager.state.current_global_timeline >= int(definition.get("timeline", 0)) and manager.state.starting_character != "" and "WUKONG_RECRUITED" in manager.state.completed_milestones

func get_current_stage(manager: NarrativeManager) -> Dictionary:
	for stage in definition.get("stages", []):
		if stage is Dictionary:
			var milestone := str(stage.get("milestone", ""))
			if milestone.is_empty() or not manager.state.completed_milestones.has(milestone):
				return stage
	return {}

func get_stages(manager: NarrativeManager) -> Array:
	var stages: Array = []
	for stage in definition.get("stages", []):
		if stage is Dictionary:
			var copy := stage.duplicate(true)
			copy["completed"] = manager.state.completed_milestones.has(str(stage.get("milestone", "")))
			stages.append(copy)
	return stages

func complete_stage(manager: NarrativeManager, stage_id: String) -> Dictionary:
	for stage in definition.get("stages", []):
		if not stage is Dictionary or str(stage.get("id", "")) != stage_id:
			continue
		var milestone := str(stage.get("milestone", ""))
		if not milestone.is_empty() and not manager.state.completed_milestones.has(milestone):
			manager.record_milestone(milestone, "黄风岭：%s" % str(stage.get("name", stage_id)))
		return stage.duplicate(true)
	return {}

func get_stage(stage_id: String) -> Dictionary:
	for stage in definition.get("stages", []):
		if stage is Dictionary and str(stage.get("id", "")) == stage_id:
			return stage
	return {}
