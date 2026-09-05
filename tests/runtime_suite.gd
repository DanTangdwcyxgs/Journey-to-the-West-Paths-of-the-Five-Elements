extends SceneTree

## Headless Godot runtime suite.
## Supports both static `run_all()` tests and legacy SceneTree test scripts.

const TEST_SCRIPTS := [
	"res://combat/test_chapter_runtime.gd",
	"res://combat/test_event_runtime.gd",
	"res://combat/test_event_runner.gd",
	"res://combat/test_narrative_event_session.gd",
	"res://combat/test_event_sequence_validator.gd",
	"res://combat/test_shared_event_sequences.gd",
	"res://combat/test_origin_event_sequences.gd",
	"res://combat/test_wukong_origin_progression.gd",
	"res://combat/test_tang_origin_event_sequences.gd",
	"res://combat/test_tang_origin_progression.gd",
	"res://combat/test_tang_journey_bridge.gd",
	"res://combat/test_longma_origin_progression.gd",
	"res://combat/test_bajie_origin_event_sequences.gd",
	"res://combat/test_bajie_origin_progression.gd",
	"res://combat/test_wujing_origin_event_sequences.gd",
	"res://combat/test_wujing_origin_progression.gd",
	"res://combat/test_origin_routes_unified.gd",
	"res://combat/test_origin_shared_handoff.gd",
	"res://combat/test_shared_opening_journey_bridge.gd",
	"res://combat/test_shared_battle_journey_bridge.gd",
	"res://combat/test_reward_service.gd",
	"res://combat/test_world_action_service.gd",
	"res://combat/test_shared_encounter_combat.gd",
	"res://combat/test_shared_journey_battles.gd",
	"res://combat/test_battle_resolution_service.gd",
	"res://combat/test_journey_event_presentation.gd",
	"res://combat/test_main_menu_contact.gd",
	"res://combat/test_visual_asset_contract.gd",
]

func _init() -> void:
	var failures: Array[String] = []
	for path in TEST_SCRIPTS:
		var script = load(path)
		if script == null:
			failures.append("load failed: %s" % path)
			continue
		if script.has_method("run_all"):
			var result: Variant = script.run_all()
			if not result is Dictionary or not result.get("passed", false):
				failures.append("test failed: %s -> %s" % [path, str(result)])
			else:
				print("PASS %s" % path)
			continue

		var output: Array = []
		var exit_code := OS.execute(OS.get_executable_path(), PackedStringArray([
			"--headless",
			"--path", ProjectSettings.globalize_path("res://"),
			"--script", path,
		]), output, true)
		if exit_code != 0:
			failures.append("SceneTree test failed: %s exit=%d output=%s" % [path, exit_code, str(output)])
		else:
			print("PASS %s" % path)

	if failures.is_empty():
		print("RUNTIME_SUITE_PASS tests=%d" % TEST_SCRIPTS.size())
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("RUNTIME_SUITE_FAIL failures=%d" % failures.size())
		quit(1)