extends SceneTree

## Free map travel must share the story MOVE save boundary: a rejected save
## restores location/history and leaves the same destination retryable.
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
		_build_ui()
		_refresh()

var failures: Array[String] = []

func _initialize() -> void:
	await _run_smoke()

func _run_smoke() -> void:
	var manager := ToggleSaveNarrativeManager.new()
	_record(manager.start_new_game("WUKONG"), "Wukong should initialize the free-travel fixture")
	manager.state.record_milestone("WUKONG_RECRUITED", 100)
	manager.state.current_global_timeline = 120
	manager.state.add_world_node_visit("BLACK_WIND_NORTH_PATH")
	var state_before: Dictionary = manager.serialize().duplicate(true)

	var world_map := IsolatedWorldMapScreen.new()
	world_map.narrative = manager
	world_map.world = WorldMapManager.new()
	root.add_child(world_map)
	current_scene = world_map
	await process_frame

	_record(world_map.status_label.text.find("黑风山北道") >= 0, "map should begin at the saved Black Wind North Path")
	var eagle_index := _find_node(world_map, "鹰愁涧")
	_record(eagle_index >= 0, "Eagle Sorrow should be reachable from Black Wind North Path")
	if eagle_index >= 0:
		world_map.node_list.select(eagle_index)
		world_map.call("_on_node_selected", eagle_index)
		_record(not world_map.travel_button.disabled, "selecting Eagle Sorrow should enable the travel control")

		world_map.travel_button.emit_signal("pressed")
		await process_frame

		_record(manager.save_attempts == 1, "free travel should attempt one save before reporting arrival")
		_record(manager.serialize() == state_before, "failed travel save should restore the complete NarrativeState snapshot")
		_record(str(manager.state.get_world_state().get("current_location", "")) == "BLACK_WIND_NORTH_PATH", "failed travel save must retain the original location")
		_record("EAGLE_SORROW" not in manager.state.get_world_state().get("visited_nodes", []), "failed travel save must remove the uncommitted visit history")
		_record(not world_map.travel_button.disabled, "failed travel should leave the same target enabled for retry")
		_record(world_map.status_label.text.find("保存失败") >= 0, "failed travel save should be visible in the WorldMap status")

		manager.save_success = true
		world_map.travel_button.emit_signal("pressed")
		await process_frame

		_record(manager.save_attempts == 2, "retrying travel should attempt a second save")
		_record(str(manager.state.get_world_state().get("current_location", "")) == "EAGLE_SORROW", "successful retry should commit the target location")
		_record("EAGLE_SORROW" in manager.state.get_world_state().get("visited_nodes", []), "successful retry should commit the destination visit history")
		_record(world_map.status_label.text.find("已抵达") >= 0, "successful travel should show arrival feedback")

	var final_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(final_scene):
		final_scene.free()
	await process_frame

	if failures.is_empty():
		print("WORLD_MAP_TRAVEL_SAVE_FAILURE_ROLLBACK_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("WORLD_MAP_TRAVEL_SAVE_FAILURE_ROLLBACK_FAIL failures=%d" % failures.size())
		quit(1)

func _find_node(world_map: WorldMapScreen, label: String) -> int:
	for index in range(world_map.node_list.get_item_count()):
		if world_map.node_list.get_item_text(index).find(label) >= 0:
			return index
	return -1

func _record(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
