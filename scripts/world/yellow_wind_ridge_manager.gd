class_name YellowWindRidgeManager
extends RefCounted

var definition: Dictionary = {}

func _init() -> void:
	var file := FileAccess.open("res://data/world/yellow_wind_ridge.json", FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		definition = parsed

func get_stages(manager: NarrativeManager) -> Array:
	var stages: Array = []
	for stage in definition.get("stages", []):
		if stage is Dictionary:
			var copy: Dictionary = stage.duplicate(true)
			copy["completed"] = manager.state.completed_milestones.has(str(stage.get("milestone", "")))
			stages.append(copy)
	return stages

func complete_stage(manager: NarrativeManager, stage_id: String) -> Dictionary:
	for stage in definition.get("stages", []):
		if not stage is Dictionary or str(stage.get("id", "")) != stage_id:
			continue
		var milestone := str(stage.get("milestone", ""))
		var already_completed := not milestone.is_empty() and manager.state.completed_milestones.has(milestone)
		if already_completed:
			return stage
		if not milestone.is_empty():
			manager.state.record_milestone(milestone, manager.state.current_global_timeline)
		return stage
	return {}