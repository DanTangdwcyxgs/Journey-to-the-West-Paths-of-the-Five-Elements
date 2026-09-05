# Wujing Origin EventSequence Migration — 2026-09-05

## Goal
完成沙悟净（Wujing）Origin Route 的 EventSequence 数据迁移，并建立与悟空、唐僧、龙马、八戒一致的回归验证与 Save/Load 检查。

## What changed
- 将 `WUJING-01` 至 `WUJING-08` 全部加入 `data/narrative/event_sequences_origin.json`。
- 保留既有 Origin 章节顺序，不改动固定世界时间线。
- `WUJING-02` 继续使用生产事件 `WUJING-02`，提供 `ACCEPT_FAULT / QUESTION_SENTENCE` 选择。
- `WUJING-06` 继续使用生产事件 `WUJING-06`，提供 `ATONE / START_AGAIN` 选择。
- `WUJING-03` 复用生产战斗 `WUJING_ORIGIN_FLOWING_SANDS`。
- `WUJING-07` 复用生产战斗 `WUJING_ORIGIN_BODHISATTVA`。
- 新增 `combat/test_wujing_origin_event_sequences.gd`：验证 8 条序列的图结构、Origin namespace、choice 持久化、battle handoff、runner snapshot/restore 与战后 resume。
- 新增 `combat/test_wujing_origin_progression.gd`：完整跑通 8 章，并验证 BattleResolutionService、Save/Load checkpoint、路线完成状态。
- `tests/runtime_suite.gd` 接入两项 Wujing regression。

## Why
Wujing 是当前最后一条尚未完成 EventSequence 迁移的 Origin 主路线。完成后五条个人路线都具备同一种数据驱动剧情执行模型，后续可以从“逐角色迁移”转入“五路线统一质量门”和共享剧情桥接。

## Systems affected
- Narrative / OriginRouteManager
- EventSequenceManager / EventSequenceValidator
- EventRunner / NarrativeState
- BattleResolutionService
- Save / Load
- Headless Godot runtime suite

## Files
- `data/narrative/event_sequences_origin.json`
- `combat/test_wujing_origin_event_sequences.gd`
- `combat/test_wujing_origin_progression.gd`
- `tests/runtime_suite.gd`
- `docs/development_log/2026-09-05-wujing-origin-sequence-migration.md`
- `AI_HANDOFF.md`（CI 成功后同步当前状态）

## Tests
预期新增验证：
- 8/8 Wujing EventSequences load + validate
- 2/2 choice sequences
- 2/2 battle sequences
- Wujing full route progression
- Save/Load checkpoint after `WUJING-03`
- Route completion + choice persistence

## Godot Runtime status
GitHub Actions `Godot Runtime` 在 `tests/runtime_suite.gd` 更新后自动运行。当前提交对应的运行编号需以 Actions 最终结果为准；未将“代码已提交”视为“Runtime 已通过”。

## Known issues
- `BountyEncounterState` 仍是 BattleUI / Journey 之间的兼容 handoff 存储层，后续继续收敛到通用 Scene Handoff Service。
- `move / wait / reward` 仍不是统一的世界执行服务。
- EventSequenceValidator 尚未完全做跨数据文件 cross-reference quality gate。
- EventSequence 的视觉表现仍以现有 Journey Event UI 为主，后续继续补对白框、镜头与角色移动反馈。

## Next step
五条 Origin Route 均已有独立 EventSequence 后，进行统一 cross-reference / route isolation / SceneTree bridge / shared timeline handoff 回归，并开始评估 Origin → Shared Journey 的统一入口。

## Handoff point
当前阶段：**Origin Batch C — 五条个人路线 EventSequence 迁移完成，下一阶段进入五路线统一质量验证。**
