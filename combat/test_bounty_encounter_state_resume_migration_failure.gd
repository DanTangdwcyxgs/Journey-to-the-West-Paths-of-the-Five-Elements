extends RefCounted

## Deterministic filesystem failure injection for active -> pending EventSession migration.
## A directory at RESUME_PATH makes FileAccess.open(RESUME_PATH, WRITE) fail. The
## active handoff must remain byte-for-byte intact as the only durable copy.
static func run_all() -> Dictionary:
	var failures: Array[String] = []
	var active_path: String = BountyEncounterState.PATH
	var resume_path: String = BountyEncounterState.RESUME_PATH
	var active_abs := ProjectSettings.globalize_path(active_path)
	var resume_abs := ProjectSettings.globalize_path(resume_path)

	if DirAccess.dir_exists_absolute(active_abs) or DirAccess.dir_exists_absolute(resume_abs):
		return {
			"passed": false,
			"reason": "refusing to alter a directory occupying a handoff file path",
		}

	var active_backup := _capture_file(active_path)
	var resume_backup := _capture_file(resume_path)

	_remove_file(active_path, failures)
	_remove_file(resume_path, failures)

	var fixture := {
		"event_resume": {
			"sequence_id": "TEST-FAILED-RESUME-MIGRATION",
			"runner": {"cursor": "battle", "pending_kind": "BATTLE"},
		},
		"encounter_type": "origin",
		"encounter_id": "LONGMA_ORIGIN_SEA_CLIFF",
		"source_chapter_id": "LONGMA-02",
		"source_route_id": "LONGMA_ORIGIN",
	}
	var started := BountyEncounterState.start_encounter(
		"origin",
		"LONGMA_ORIGIN_SEA_CLIFF",
		"",
		"LONGMA-02",
		"LONGMA_ORIGIN",
		{"event_resume": fixture.get("event_resume", {})}
	)
	_record(started, failures, "fixture should persist the active battle handoff")

	var active_before: PackedByteArray = FileAccess.get_file_as_bytes(active_path) if started else PackedByteArray()
	var directory_created := DirAccess.make_dir_absolute(resume_abs) == OK
	_record(directory_created, failures, "test should create a directory at RESUME_PATH to force the write-open failure")

	if directory_created:
		BountyEncounterState.clear()
		_record(FileAccess.file_exists(active_path), failures, "failed migration must preserve the active handoff file")
		if FileAccess.file_exists(active_path):
			var active_after: PackedByteArray = FileAccess.get_file_as_bytes(active_path)
			_record(active_after == active_before, failures, "failed migration must preserve active handoff bytes exactly")
		_record(DirAccess.dir_exists_absolute(resume_abs), failures, "failed migration must not remove or replace the blocking directory")
		_record(
			FileAccess.open(resume_path, FileAccess.READ) == null,
			failures,
			"failed migration must not create a partial pending-resume file"
		)
		var removed_directory := DirAccess.remove_absolute(resume_abs) == OK
		_record(removed_directory, failures, "test should remove its temporary blocking directory before restoring user data")

	_restore_file(active_path, active_backup, failures)
	_restore_file(resume_path, resume_backup, failures)

	return {
		"passed": failures.is_empty(),
		"failure_count": failures.size(),
		"failures": failures,
		"preserves_active_handoff_on_resume_write_failure": failures.is_empty(),
	}

static func _capture_file(path: String) -> Dictionary:
	var exists := FileAccess.file_exists(path)
	var content: PackedByteArray = FileAccess.get_file_as_bytes(path) if exists else PackedByteArray()
	return {"existed": exists, "content": content}

static func _remove_file(path: String, failures: Array[String]) -> void:
	if not FileAccess.file_exists(path):
		return
	var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_record(error == OK, failures, "test setup/cleanup should remove %s (error=%s)" % [path, str(error)])

static func _restore_file(path: String, backup: Dictionary, failures: Array[String]) -> void:
	if bool(backup.get("existed", false)):
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			_record(false, failures, "could not restore previous user file: %s" % path)
			return
		file.store_buffer(backup.get("content", PackedByteArray()) as PackedByteArray)
		file.close()
	else:
		_remove_file(path, failures)

static func _record(condition: bool, failures: Array[String], message: String) -> void:
	if not condition:
		failures.append(message)
