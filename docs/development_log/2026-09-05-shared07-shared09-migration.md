# 2026-09-05 — Shared-07 / Shared-08 / Shared-09 EventSequence Migration

## Goal

完成 Batch B 的第一轮 Shared Journey 数据迁移：把流沙河招募战、五人归队过场、完整西行起点全部接入统一 EventSequence 执行链。

## What changed

新增三个共享序列：

- `SHARED-07-FLOWING-SANDS-SEQUENCE`
- `SHARED-08-PARTY-FULL-SEQUENCE`
- `SHARED-09-FULL-PILGRIMAGE-SEQUENCE`

### Shared-07

`river dialogue → WUJING_ENCOUNTER choice → SHARED_FLOWING_SANDS battle → after-battle dialogue → end`

战斗仍只通过 `EncounterHandoff` 进入 BattleUI，并由 `BattleResolutionService` 负责原子章节结算、招募与世界效果。Sequence 不重复推进章节。

### Shared-08

`gather dialogue → PARTY_FULL choice → oath dialogue → end`

无战斗，END 时由 Journey 现有 sequence completion 逻辑提交章节。章节奖励与 `PARTY_FULL` 世界效果继续以 `shared_chapters.json` 为事实来源。

### Shared-09

`departure dialogue → end`

作为完整五人西行的共享主线起点。章节完成时由章节数据负责 `COIN_MEDIUM` 奖励和 `FULL_PILGRIMAGE_BEGINS` 世界效果。

### Regression

扩展 `combat/test_event_sequence_validator.gd`，现在一次回归会检查 Shared-03 至 Shared-09 全部七条 EventSequence，并继续验证故意错误的 choice / encounter / chapter cross-reference 会被拒绝。

## Why

本轮完成后，`SHARED-04 → SHARED-09` 已不再需要依赖旧的 Journey 专用分支来推进章节，Shared Journey 招募链及招募后的连续过场统一进入：

`Chapter data → EventSequence → EventRunner → Journey SceneTree / Battle Handoff → Chapter completion`

这一步的价值在于验证“同一 Runtime 可以连续承载整段共享西游”，而不是只验证单个孤立示例。

同时继续遵守奖励唯一来源：Sequence 不复制 chapter reward；非战斗章节在 END 完成时由 `SharedJourneyManager` 应用章节奖励。

## Systems affected

- Narrative：Shared-07/08/09 数据迁移；
- Presentation：继续复用 Journey Event UI；
- Battle：Shared-07 保持现有 Handoff + Resolution 原子边界；
- Progression：Shared-08/09 END 完成共享章节；
- Validation：Shared sequence cross-reference 回归扩大到 7 条。

## Files

- `data/narrative/event_sequences.json`
- `combat/test_event_sequence_validator.gd`
- `docs/development_log/2026-09-05-shared07-shared09-migration.md`
- `docs/AI_MEMORY.md`

## Validation

- `EventSequenceValidator`：已覆盖 Shared-03 至 Shared-09。
- Godot Runtime：**未确认通过**。
- GitHub combined status：截至该批提交检查时尚未返回 workflow run / status，因此不能声称 Runtime 通过。

## Known issues

- 这批迁移验证的是统一 Runtime / 数据链，不代表镜头、角色动画、路径移动、音频等完整演出已经完成；
- `MOVE` 当前主要是逻辑世界状态记录；
- `WAIT` 当前不推进独立世界时钟；
- `BountyEncounterState` 仍为兼容 Scene Handoff 层；
- Origin Route 尚未迁移到 EventSequence；
- Journey Event Presentation 仍可继续增强 SceneTree 反馈。

## Next step

进入 Batch C 前，优先补一轮真实 Godot Runtime：至少覆盖 Shared-03/05/07 的 battle resume 和 Shared-04/06/08/09 的 non-battle END completion；同时继续完善 Journey SceneTree 的 MOVE / BATTLE / END 反馈。

## Handoff point

下一位 Agent 从：

`docs/AI_MEMORY.md → docs/development_log/2026-09-05-shared07-shared09-migration.md → data/narrative/event_sequences.json → ui/journey.gd → scripts/narrative/battle_resolution_service.gd → combat/test_event_sequence_validator.gd`

开始。