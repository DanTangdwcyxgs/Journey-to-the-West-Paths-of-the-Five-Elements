# 2026-10-11 · SoundManager Audio Playback Cleanup

## Goal
Resolve the last ObjectDB leak identified in Runtime teardown diagnostics without suppressing Godot's warning.

## Starting evidence
- Runtime run [38103543718](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38103543718) passed 33 tests, but its verbose rerun exposed AudioStreamGeneratorPlayback as the only leaked ObjectDB instance.
- The first change attempted to explicitly stop and release references at shutdown; commit `16549294504b652d5e5a14087db90940c1a58fa7` still reproduced the warning. That attempt was not treated as a fix.

## What changed
- Replaced the permanently playing AudioStreamGenerator with generated finite AudioStreamWAV clips.
- The SoundManager composes notes, gaps, and hit noise into mono 16-bit PCM data only when an SFX is requested. Short WAV clips are queued so closely spaced calls keep their order rather than overwriting each other.
- The AudioStreamPlayer starts only when a generated sound is ready; after a clip finishes, the stream is cleared and the next queued clip begins.
- SoundManager uses one idempotent _release_audio_resources() method from _exit_tree(), to stop/free the player and clear queued clips and tracked button references.
- Added combat/test_sound_manager_lifecycle.gd. It checks generated PCM WAV format/data, cleanup of an independent SoundManager, and cleanup of the GameSfx autoload.
- Added the test to tests/runtime_suite.gd; suite now has 34 entries.

## Why
The continuous AudioStreamGenerator created a persistent AudioStreamGeneratorPlayback from engine startup and kept it active until shutdown. A one-shot PCM resource is a better fit for the project's short UI/combat sound effects and avoids the permanently active generator object.

## Systems affected
- Presentation audio synthesis and playback
- Runtime lifecycle regression

## Files
- ui/sound_manager.gd
- combat/test_sound_manager_lifecycle.gd
- tests/runtime_suite.gd
- docs/development_log/2026-10-11-sound-manager-audio-playback-cleanup.md
- docs/development_log/2026-10-11-runtime-objectdb-diagnostics.md
- docs/development_log/README.md
- docs/AI_MEMORY.md
- AI_HANDOFF.md

## Tests
- Runtime run [38104194439](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38104194439): PASS, `RUNTIME_SUITE_PASS tests=34`.
- The log confirms `PASS res://combat/test_sound_manager_lifecycle.gd`.
- A verbose rerun produced no ObjectDB / AudioStreamGeneratorPlayback leak entry and no Renderer/TextServer RID teardown diagnostics.
- Web Demo run [38104194542](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38104194542): PASS (build and deploy).

## Remaining issues
- Audio is intentionally serialized through one SFX player; queued finite clips play in call order. This is appropriate for the current short pixel UI/combat cues; if simultaneous layered SFX become a design requirement, introduce a small pooled-player layer and regression tests rather than reverting to a permanent generator.
- Final character PNG/WebP are still not present; image generation was blocked by the Free-plan image-generation limit.

## Next step
Extend the actual SceneTree path through battle handoff / resume and END / chapter completion / Save. Keep the CJK font CI setup and sound lifecycle regression.

## Handoff point
Presentation audio / Runtime lifecycle, not Narrative or combat resolution.
