class_name YellowWindRidgeManager
extends RefCounted

const RIDGE_PATH := "res://data/world/yellow_wind_ridge.json"
const BLACK_WIND_LOCATION := "BLACK_WIND_NORTH_PATH"
const GATE_STAGE_ID := "YELLOW_WIND_GATE"
const GATE_MILESTONE := "YELLOW_WIND_GATE_OPEN"
const BOSS_TARGET_ID := "BOUNTY_YELLOW_FANG"

var definition: Dictionary = {}

func _init() -> void:
	var file := FileAccess.open(RIDGE_PATH, FileAccess.READ)
	if file == null:
		push_error("YellowWindRidgeManager: missing data file %s" % RIDGE_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		definition = parsed.duplicate(true)

func is_available(manager: NarrativeManager) -> bool:
	if manager == null or manager.state == null or definition.is_empty():
		return false
	var world: Dictionary = manager.state.get_world_state()
	if str(world.get("current_location", "")) != BLACK_WIND_LOCATION:
		return false
	if manager.state.current_global_timeline < int(definition.get("timeline", 0)):
		return false
	return "BAI_LONGMA_RECRUITED" in manager.state.completed_milestones

func get_stages(manager: NarrativeManager) -> Array:
	var stages: Array = []
	if manager == null or manager.state == null:
		return stages
	for stage_variant in definition.get("stages", []):
		if not stage_variant is Dictionary:
			continue
		var stage: Dictionary = stage_variant.duplicate(true)
		stage["completed"] = _is_stage_completed(manager, stage)
		stages.append(stage)
	var current_index := _first_incomplete_index(stages)
	for i in range(stages.size()):
		stages[i]["available"] = i <= current_index
	return stages

func get_stage(stage_id: String, manager: NarrativeManager = null) -> Dictionary:
	for stage_variant in definition.get("stages", []):
		if not stage_variant is Dictionary or str(stage_variant.get("id", "")) != stage_id:
			continue
		var stage: Dictionary = stage_variant.duplicate(true)
		if manager != null and manager.state != null:
			stage["completed"] = _is_stage_completed(manager, stage)
			var stages := get_stages(manager)
			var current_index := _first_incomplete_index(stages)
			stage["available"] = _stage_index(stages, stage_id) <= current_index
		return stage
	return {}

func get_current_stage(manager: NarrativeManager) -> Dictionary:
	var stages := get_stages(manager)
	for stage in stages:
		if not bool(stage.get("completed", false)):
			return stage.duplicate(true)
	return {}

func can_enter_stage(manager: NarrativeManager, stage_id: String) -> bool:
	if not is_available(manager):
		return false
	var stages := get_stages(manager)
	var stage_index := _stage_index(stages, stage_id)
	if stage_index < 0:
		return false
	return stage_index <= _first_incomplete_index(stages)

func complete_stage(manager: NarrativeManager, stage_id: String) -> Dictionary:
	if manager == null or manager.state == null or not can_enter_stage(manager, stage_id):
		return {}
	var stage := get_stage(stage_id, manager)
	if stage.is_empty():
		return {}
	if bool(stage.get("completed", false)):
		return stage
	if str(stage.get("type", "")).to_upper() == "BOSS_GATE":
		return {}
	var current := get_current_stage(manager)
	if str(current.get("id", "")) != stage_id:
		return {}
	var milestone := str(stage.get("milestone", ""))
	if not milestone.is_empty():
		manager.state.record_milestone(milestone, manager.state.current_global_timeline)
	return stage

func open_gate(manager: NarrativeManager) -> bool:
	if manager == null or manager.state == null or not is_available(manager):
		return false
	if _is_boss_defeated(manager):
		return false
	if str(get_current_stage(manager).get("id", "")) != GATE_STAGE_ID:
		return false
	if GATE_MILESTONE not in manager.state.completed_milestones:
		manager.state.record_milestone(GATE_MILESTONE, manager.state.current_global_timeline)
	return true

func _is_stage_completed(manager: NarrativeManager, stage: Dictionary) -> bool:
	if str(stage.get("id", "")) == GATE_STAGE_ID:
		return _is_boss_defeated(manager)
	var milestone := str(stage.get("milestone", ""))
	return not milestone.is_empty() and milestone in manager.state.completed_milestones

func _is_boss_defeated(manager: NarrativeManager) -> bool:
	return BOSS_TARGET_ID in manager.state.get_journey_log().get("defeated_targets", [])

func _first_incomplete_index(stages: Array) -> int:
	for i in range(stages.size()):
		if not bool(stages[i].get("completed", false)):
			return i
	return stages.size()

func _stage_index(stages: Array, stage_id: String) -> int:
	for i in range(stages.size()):
		if str(stages[i].get("id", "")) == stage_id:
			return i
	return -1
