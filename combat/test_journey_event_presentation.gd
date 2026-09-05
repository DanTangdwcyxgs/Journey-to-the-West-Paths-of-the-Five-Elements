extends SceneTree

## Regression coverage for the Journey event presentation shell.
func _initialize() -> void:
	var scene := load("res://ui/journey.tscn") as PackedScene
	_assert(scene != null, "journey scene should load")
	var instance := scene.instantiate()
	_assert(instance is JourneyScreen, "journey scene should instantiate a JourneyScreen-compatible root")

	instance.call("_build_ui")
	var dialogue_panel := instance.find_child("DialoguePanel", true, false)
	var speaker := instance.find_child("Speaker", true, false)
	var text := instance.find_child("Text", true, false)
	var hint := instance.find_child("Hint", true, false)
	var event_meta := instance.find_child("EventMeta", true, false)
	var choices := instance.find_child("EventChoices", true, false)

	_assert(dialogue_panel != null, "journey should build a dialogue panel")
	_assert(speaker != null, "journey dialogue should expose a speaker label")
	_assert(text != null, "journey dialogue should expose a text label")
	_assert(hint != null, "journey dialogue should expose a reading hint")
	_assert(event_meta != null, "journey dialogue should expose sequence metadata")
	_assert(choices != null, "journey should keep a dedicated event choice container")

	instance.call("_set_dialogue", "玄奘", "鹰愁涧就在前面。", true)
	_assert(instance.dialogue_revealing, "dialogue should start in typewriter mode")
	instance.call("_process", 1.0)
	_assert(not instance.dialogue_revealing, "dialogue should finish revealing after sufficient elapsed time")
	_assert(instance.dialogue_text_label.text == "鹰愁涧就在前面。", "typewriter should reveal the complete dialogue")

	instance.queue_free()
	print("ALL JOURNEY EVENT PRESENTATION TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
