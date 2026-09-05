# 2026-09-05 — Sequence Cross-Reference Validation

## Goal
把 EventSequence 的内容质量门槛从图结构校验提升到章节级 cross-reference 校验，避免后续 Origin Route 批量迁移时把错误数据带进 Runtime。

## What changed
增强 `EventSequenceValidator`：

- Sequence 必须声明 `chapter_id`；
- SHARED Sequence 的 `chapter_id` 必须存在于 `shared_chapters.json`；
- ORIGIN Sequence 的 `chapter_id` 必须存在于 `origin_chapters.json`；
- Battle node 的 `source_chapter_id` 必须与 Sequence 的 `chapter_id` 一致；
- Shared Battle 的 encounter_id 必须与对应 chapter 的 encounter_id 一致；
- 继续校验 choice event 与 battle encounter 的存在性；
- 新增 chapter mismatch 与 namespace mismatch regression。

## Why
此前 validator 已经能发现不存在的 event / encounter，但一个合法图仍可能引用错误章节来源，或把 ORIGIN / SHARED 序列绑定到错误的剧情命名空间。这个错误如果进入 Journey，只会在运行时表现为错误的章节完成、战斗来源或选择状态。

## Files

- `scripts/narrative/event_sequence_validator.gd`
- `combat/test_event_sequence_validator.gd`
- `docs/development_log/2026-09-05-sequence-cross-reference-validation.md`

## Validation

Godot Runtime **#89：success**。

- Godot 4.5.1 stable；
- project import：passed；
- signature parser：passed；
- EventRuntime：passed；
- EventRunner：passed；
- headless runtime suite：`RUNTIME_SUITE_PASS tests=12`；
- 新增 cross-reference regression：passed。

## Known issues

- Journey MOVE / WAIT / REWARD 的 Presentation 仍属于基础 UI 壳；
- Battle handoff 仍经 `BountyEncounterState` 兼容层；
- Origin Route 尚未接入统一 EventSequence execution path；
- `docs/AI_MEMORY.md` 的历史 Round 区块仍需在下一次文档整理中合并本轮事实。

## Next step
以 WUKONG Origin Route 为第一条迁移样板，优先把现有章节事件、战斗和选择转换为 EventSequence，再把 Journey 的起始章节选择接入该统一执行路径。

## Handoff point
当前验证基线为 `df994b25175d6257b97e09efe20751796d3eb456`，该提交对应 Godot Runtime #89 通过。
