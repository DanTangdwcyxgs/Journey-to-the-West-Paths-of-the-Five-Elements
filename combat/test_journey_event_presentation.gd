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

	instance.call("_render_event_action", {
		"kind": "move", "node_id": "move_to_north_path",
		"sequence_id": "SHARED-04-EARLY-DEMON-TALES-SEQUENCE",
		"map_id": "WORLD_MAP", "marker_id": "BLACK_WIND_NORTH_PATH",
	})
	_assert(instance.phase_label.text == "旅途移动", "move action should use a dedicated travel phase")
	_assert(instance.dialogue_text_label.text.find("目的地：黑风山北道") >= 0, "move presentation should resolve the marker to its player-facing destination name")
	_assert(instance.dialogue_text_label.text.find("BLACK_WIND_NORTH_PATH") < 0, "move presentation should not expose the internal marker ID")
	_assert(instance.primary_button.text == "前往" and not instance.primary_button.disabled, "move action should expose a forward action")
	_assert(instance.dialogue_hint_label.text.find("旅途过渡") >= 0, "move action should explain the travel transition")
	_assert(instance.world_button.disabled, "world map navigation should be locked during an active event sequence")
	_assert(instance.party_button.disabled, "party navigation should be locked during an active event sequence")
	_assert(instance.save_button.disabled, "manual save should be locked during an active event sequence")
	_assert(instance.back_button.disabled, "return-to-menu navigation should be locked during an active event sequence")
	instance.call("_set_event_navigation_locked", false)
	_assert(not instance.world_button.disabled and not instance.party_button.disabled and not instance.save_button.disabled and not instance.back_button.disabled, "navigation should unlock after the event sequence is released")

	instance.call("_render_event_action", {
		"kind": "wait", "node_id": "pause",
		"sequence_id": "SHARED-04-EARLY-DEMON-TALES-SEQUENCE", "seconds": 0.5,
	})
	_assert(instance.phase_label.text == "停驻片刻 · 0.5 秒", "wait action should show its duration")
	_assert(instance.dialogue_text_label.text.find("片刻后继续前行") >= 0, "wait action should explain the pause")
	_assert(instance.primary_button.text == "继续" and not instance.primary_button.disabled, "wait action should allow the player to continue")
	_assert(instance.dialogue_hint_label.text.find("稍作停留") >= 0, "wait action should explain what continuing will do")

	instance.call("_render_event_action", {
		"kind": "end", "node_id": "finish",
		"sequence_id": "SHARED-04-EARLY-DEMON-TALES-SEQUENCE",
	})
	_assert(instance.phase_label.text == "剧情终点 · 等待确认", "END should communicate that the sequence has reached its endpoint")
	_assert(instance.dialogue_text_label.text.find("记录章节进度") >= 0, "END should explain that completion will record chapter progress")
	_assert(instance.primary_button.text == "完成并继续" and not instance.primary_button.disabled, "END should expose a clear completion action")
	_assert(instance.dialogue_hint_label.text.find("完成记录") >= 0, "END should explain that the Journey layer owns completion recording")

	instance.queue_free()
	print("ALL JOURNEY EVENT PRESENTATION TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
