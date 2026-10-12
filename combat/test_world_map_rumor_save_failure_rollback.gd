extends SceneTree

## Hearing a rumor must be atomic with its save: failure restores both the
## heard-rumor marker and bounty discovery, and leaves the rumor retryable.
class ToggleSaveNarrativeManager:
	extends NarrativeManager

	var save_success: bool = false
	var save_attempts: int = 0

	func save(_path: String = NarrativeSave.SAVE_PATH) -> bool:
		save_attempts += 1
		return save_success

class IsolatedWorldMapScreen:
	extends WorldMapScreen

	func _ready() -> void:
		_load_bounty_definitions()
		_build_ui()
		_refresh()

var failures: Array[String] = []

func _initialize() -> void:
	await _run_smoke()

func _run_smoke() -> void:
	var manager := ToggleSaveNarrativeManager.new()
	_record(manager.start_new_game("WUKONG"), "Wukong should initialize the rumor fixture")
	manager.state.record_milestone("WUKONG_RECRUITED", 100)
	manager.state.current_global_timeline = 110
	manager.state.add_world_node_visit("EAGLE_SORROW")
	var state_before: Dictionary = manager.serialize().duplicate(true)

	var world_map := IsolatedWorldMapScreen.new()
	world_map.narrative = manager
	world_map.world = WorldMapManager.new()
	root.add_child(world_map)
	current_scene = world_map
	await process_frame

	_record(world_map.rumor_list.get_item_count() > 0, "Eagle Sorrow should offer the Yellow Fang rumor")
	_record(not world_map.rumor_button.disabled, "an available rumor should be hearable")
	if world_map.rumor_list.get_item_count() > 0:
		world_map.rumor_list.select(0)
		world_map.rumor_button.emit_signal("pressed")
		await process_frame

		_record(manager.save_attempts == 1, "hearing a rumor should attempt one save")
		_record(manager.serialize() == state_before, "failed rumor save should restore the complete narrative snapshot")
		_record("RUMOR_YELLOW_FANG" not in manager.state.get_world_state().get("heard_rumors", []), "failed rumor save must not persist the heard-rumor marker in memory")
		_record("BOUNTY_YELLOW_FANG" not in manager.state.get_world_state().get("discovered_bounties", []), "failed rumor save must not leave an uncommitted bounty discovery")
		_record(world_map.status_label.text.find("保存失败") >= 0, "failed rumor save should be visible in the map status")
		_record(world_map.rumor_list.get_item_count() > 0, "failed rumor save should keep the rumor available for retry")
		_record(not world_map.rumor_button.disabled, "failed rumor save should leave the hear control enabled")

		manager.save_success = true
		world_map.rumor_list.select(0)
		world_map.rumor_button.emit_signal("pressed")
		await process_frame

		_record(manager.save_attempts == 2, "retrying the rumor should attempt a second save")
		_record("RUMOR_YELLOW_FANG" in manager.state.get_world_state().get("heard_rumors", []), "successful retry should commit the heard-rumor marker")
		_record("BOUNTY_YELLOW_FANG" in manager.state.get_world_state().get("discovered_bounties", []), "successful retry should commit bounty discovery")
		_record(world_map.status_label.text.find("已获得情报") >= 0, "successful retry should show the rumor intelligence feedback")

	var final_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(final_scene):
		final_scene.free()
	await process_frame

	if failures.is_empty():
		print("WORLD_MAP_RUMOR_SAVE_FAILURE_ROLLBACK_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("WORLD_MAP_RUMOR_SAVE_FAILURE_ROLLBACK_FAIL failures=%d" % failures.size())
		quit(1)

func _record(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
