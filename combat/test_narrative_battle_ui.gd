extends SceneTree

## Regression coverage for the BattleUI narrative-resolution integration seam.
func _initialize() -> void:
	var scene := load("res://ui/battle_ui.tscn") as PackedScene
	_assert(scene != null, "battle UI scene should load")
	var instance := scene.instantiate()
	_assert(instance is BattleUI, "battle UI scene should instantiate a BattleUI-compatible root")
	_assert(instance.get_script() != null, "battle UI root should have a script")
	_assert(instance.get_script().resource_path == "res://ui/narrative_battle_ui.gd", "battle UI scene should use the narrative resolution override")
	instance.queue_free()
	print("ALL NARRATIVE BATTLE UI INTEGRATION TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
