# 2026-09-05 — Shared Sequence Runtime Regression

## Goal
把 Shared-03 至 Shared-09 的生产 Event Sequence 从“结构校验”提升到真实 Godot Runtime 执行回归，确认线上 JSON 可以经过 `EventSequenceManager → EventRunner` 实际走到 Battle handoff / END。

## What changed
新增 `combat/test_shared_event_sequences.gd`，直接读取生产 `data/narrative/event_sequences.json` 中的 7 条 Shared Sequence，并逐节点执行：

- Dialogue → complete；
- Choice → 使用对应生产 Choice ID；
- Wait → 校验 seconds 并 complete；
- Move → complete 后验证世界节点访问记录；
- Battle → 校验 encounter_id，并通过 runner snapshot / restore + `resolve_battle(true)` 验证战斗恢复；
- End → 验证 Runner 进入 finished 状态。

同时将测试加入 `tests/runtime_suite.gd`，使其成为完整 Godot Runtime suite 的正式回归项。

## Why
现有 validator 只能证明图结构和 cross-reference 正确，不能证明生产 JSON 真正经过 Runner 后能完整执行。新增测试覆盖了 Shared Journey 当前最关键的两类真实流程：

`dialogue / choice / battle / resume / dialogue / end`

以及

`dialogue / move / wait / dialogue / end`

## First failure and fix
第一次实现触发 Godot Runtime #81：测试自身在 action loop 内过早断言 `runner.is_finished()`，属于 test control-flow bug，不是生产运行时错误。

修正后重新触发 Runtime #82。

## Validation
Godot Runtime #82：**success**。

Godot：`4.5.1.stable.official.f62fdbde1`

Runtime suite：`RUNTIME_SUITE_PASS tests=12`

关键结果：

- 7 / 7 条生产 Shared Sequence 实际执行完成；
- 3 / 3 个 Shared battle sequence 验证了 Battle handoff + runner snapshot/restore + victory resume；
- 1 / 1 个 MOVE sequence 验证 `BLACK_WIND_NORTH_PATH` 写入 world state；
- 原有 Chapter / Event / Reward / World / Battle / Journey Presentation 回归全部继续通过。

## Files

- `combat/test_shared_event_sequences.gd`
- `tests/runtime_suite.gd`
- `docs/development_log/2026-09-05-shared-sequence-runtime-regression.md`
- `docs/AI_MEMORY.md`

## Known issues

- MOVE 目前仍是逻辑地点记录，没有角色路径动画；
- WAIT 目前验证动作，但不推进独立世界时钟；
- Battle Scene Handoff 仍通过 `BountyEncounterState` 兼容层；
- Journey Presentation 仍是基础演出壳，镜头、角色实际移动和更完整的 END / reward 演出尚待补足。

## Next step
继续 P0：强化 Journey SceneTree 对 MOVE / WAIT / END / Battle transition 的表现与回归，然后进入 P1 Origin Route → EventSequence migration。

## Handoff point
当前稳定基线为 `0af166f30cf3bac59a41fce574b93c80e0124a24`，对应 Godot Runtime #82 通过。
