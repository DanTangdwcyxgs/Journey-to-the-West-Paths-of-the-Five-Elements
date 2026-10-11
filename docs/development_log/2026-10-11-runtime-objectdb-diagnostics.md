# 2026-10-11 · ObjectDB Teardown Detail Capture

## Goal
Identify the remaining ObjectDB leak warning after renderer and TextServer RID diagnostics disappeared.

## Starting evidence
- The production entry smoke commit `9cf78a11f923ff1834a6f796c3b4b3dfc4cfe0bc` passed Runtime run [38103454949](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38103454949): `RUNTIME_SUITE_PASS tests=33`. The new production MainMenu → Journey → WUK-01 Sequence smoke passed.
- Web Demo run [38103454926](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38103454926) passed.
- After commit `ff50907c95cb5017a8fdad4b2ee27ee773c37ac5`, Canvas / CanvasItem / Viewport / TextServer RID and `resources still in use` diagnostics were no longer present. Only `ObjectDB instances leaked at exit` remained.

## What changed
- Added a temporary step to `.github/workflows/godot-runtime.yml` after the regular suite passes.
- It reruns the same suite with `--verbose`, writes its raw output to a temporary file, and prints only filtered contexts for ObjectDB, leaked instance, and resources-in-use diagnostics.
- The step preserves the verbose run's exit code and does not suppress warnings. It should be removed or narrowed once the remaining object is identified.

## Why
The standard runtime log only gives an aggregate ObjectDB warning. The previous cleanup was confirmed by the disappearance of the renderer/TextServer diagnostic group; the remaining warning now needs specific object details, not more speculative code edits.

## Systems affected
- CI runtime diagnostics only
- No production game logic or data changed

## Files
- `.github/workflows/godot-runtime.yml`
- `docs/AI_MEMORY.md`
- `docs/development_log/2026-10-11-runtime-objectdb-diagnostics.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-main-menu-journey-entry-smoke.md`
- `AI_HANDOFF.md`

## Tests
- Runtime run [38103543718](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38103543718) passed 33/33 and its verbose step identified AudioStreamGeneratorPlayback:9223372175082259984 as the remaining ObjectDB instance.
- Follow-up: SoundManager now explicitly stops the generated player and releases playback / stream references on _exit_tree; an isolated lifecycle regression is added. Confirm this exact commit's normal and verbose Runtime results, then remove the temporary verbose rerun.

## Godot Runtime status
PENDING until exact-head GitHub Actions captures the verbose ObjectDB details.

## Remaining issues
- The suspected source is AudioStreamGeneratorPlayback held by the global GameSfx autoload. The first lifecycle-cleanup attempt awaits exact-head CI to determine whether the warning is resolved.
- The temporary verbose rerun still duplicates the suite and should be removed after validation.

## Next step
Check the verbose step's log for concrete class/object names and inspect only the responsible test or lifecycle boundary. Remove this temporary tracing step as soon as the diagnosis is captured.

## Handoff point
Runtime harness / ObjectDB cleanup. Do not modify battle, story, reward, or save semantics unless the log identifies a concrete production owner.
