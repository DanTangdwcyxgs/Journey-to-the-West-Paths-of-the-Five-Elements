# 2026-10-11 · SoundManager Audio Playback Cleanup

## Goal
Resolve the last ObjectDB leak identified in the Runtime teardown diagnostics without suppressing Godot's warning.

## Starting evidence
- Exact-head Runtime run [38103543718](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38103543718) passed the 33-test suite.
- The temporary verbose rerun exposed exactly Leaked instance: AudioStreamGeneratorPlayback:9223372175082259984.
- ui/sound_manager.gd owns the generated stream/player/playback and previously held _playback through shutdown without an explicit teardown path.

## What changed
- Added SoundManager._release_audio_resources(), safe to call more than once.
- It disables processing, clears tracked UI-button references, stops the AudioStreamPlayer, detaches the stream, drops playback/stream/player references and frees the generated player node.
- _exit_tree() calls the same cleanup for the GameSfx autoload at shutdown.
- Added combat/test_sound_manager_lifecycle.gd to test cleanup of a standalone SoundManager and the GameSfx autoload when present.
- Added the regression to tests/runtime_suite.gd, increasing it to 34 entries.
- The temporary verbose workflow step remains for this validation only; once the ObjectDB warning is confirmed gone or narrowed, remove that redundant run.
- Updated docs/AI_MEMORY.md, the diagnostics log, log index and handoff.

## Why
The diagnostic name points to the audio playback object, so this fix is confined to its owner instead of changing Narrative, Battle, UI-scene, or Save logic.

## Systems affected
- Presentation audio lifecycle
- Runtime regression suite
- Temporary CI diagnostics

## Files
- ui/sound_manager.gd
- combat/test_sound_manager_lifecycle.gd
- tests/runtime_suite.gd
- .github/workflows/godot-runtime.yml (temporary tracing step still present)
- docs/development_log/2026-10-11-sound-manager-audio-playback-cleanup.md
- docs/development_log/2026-10-11-runtime-objectdb-diagnostics.md
- docs/development_log/README.md
- docs/AI_MEMORY.md
- AI_HANDOFF.md

## Tests
- Exact-head Runtime suite and verbose teardown output are required before marking this cleanup passed.
- Regression asserts references are cleared and the generated player node is freed.

## Godot Runtime status
PENDING until GitHub Actions complete for this implementation SHA.

## Remaining issues
- The leak's identity has been established; whether the cleanup removes the exit warning remains to be measured.
- Keep the workflow tracing step temporary.

## Next step
Check this commit's Runtime and Web Demo jobs; verify AudioStreamGeneratorPlayback no longer appears. If clean, remove the verbose rerun from CI and record the result.

## Handoff point
Audio / presentation infrastructure only. Do not modify narrative or combat semantics.
