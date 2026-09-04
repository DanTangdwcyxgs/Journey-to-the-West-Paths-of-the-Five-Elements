class_name NarrativeSaveManager
extends Node

## Autoload-friendly persistence wrapper around NarrativeSave.
## Keeps save/load orchestration out of UI scenes.

signal saved(path: String)
signal loaded(path: String, success: bool)

@export var save_path: String = NarrativeSave.SAVE_PATH

func save_narrative(manager: NarrativeManager) -> bool:
	var success := NarrativeSave.save_state(manager.state, save_path)
	if success:
		saved.emit(save_path)
	return success

func load_narrative(manager: NarrativeManager) -> bool:
	var restored := NarrativeSave.load_state(save_path)
	var success := restored != null
	if success:
		manager.state = restored
	loaded.emit(save_path, success)
	return success

func has_narrative_save() -> bool:
	return NarrativeSave.has_save(save_path)

func delete_narrative_save() -> bool:
	return NarrativeSave.delete_save(save_path)
