extends SceneTree

## Headless Godot runtime suite.
## Each test returns a Dictionary with `passed=true`; any failure exits non-zero.

const TEST_SCRIPTS := [
	"res://combat/test_chapter_runtime.gd",
	"res://combat/test_event_runtime.gd",
	"res://combat/test_event_runner.gd",
	"res://combat/test_shared_journey_battles.gd",
	"res://combat/test_battle_resolution_service.gd",
]

func _init() -> void:
	var failures: Array[String] = []
	for path in TEST_SCRIPTS:
		var script := load(path)
		if script == null:
			failures.append("load failed: %s" % path)
			continue
		if not script.has_method("run_all"):
			failures.append("missing run_all: %s" % path)
			continue
		var result: Variant = script.run_all()
		if not result is Dictionary or not result.get("passed", false):
			failures.append("test failed: %s -> %s" % [path, str(result)])
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
