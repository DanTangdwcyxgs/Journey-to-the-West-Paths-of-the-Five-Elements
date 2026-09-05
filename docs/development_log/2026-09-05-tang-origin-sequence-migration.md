# 2026-09-05 — Tang Origin EventSequence Migration

## Goal
将唐三藏 Origin Route 从旧章节/事件驱动方式迁移到统一 `EventSequence`，并验证新 catalog 结构能够被全局加载器、validator、Journey bridge 与章节状态机消费。

## Changes

新增 `data/narrative/event_sequences_origin.json`，首个 route-specific catalog，包含唐三藏全部 8 章：

- TANG-01：dialogue → end
- TANG-02：dialogue → end
- TANG-03：dialogue → end
- TANG-04：dialogue → choice → end
- TANG-05：dialogue → dialogue → end
- TANG-06：dialogue → battle → after_battle → end
- TANG-07：dialogue → choice → end
- TANG-08：dialogue → battle → after_battle → end

两个战斗直接复用生产 Encounter：
- `TANG_ORIGIN_DOUBLE_RIDGE`
- `TANG_ORIGIN_FIVE_ELEMENTS`

两个选择直接复用现有 Origin event：
- TANG-04
- TANG-07

## Loader architecture

更新 `scripts/narrative/event_sequence_manager.gd`：

- 原 `event_sequences.json` 保持兼容；
- 新增 `event_sequences_origin.json`；
- 两个 catalog 都经过同一个 `EventSequenceDefinition → EventSequenceValidator`；
- sequence id 冲突会被记录为 load error，不会静默覆盖。

这样后续 Longma / Bajie / Wujing 可以继续采用 route-specific catalog，而不必不断扩张一个巨型 JSON。

## Regression

新增：
- `combat/test_tang_origin_event_sequences.gd`
- `combat/test_tang_origin_progression.gd`

覆盖：
- 唐三藏 8 条 production Sequence 全部加载并 validate；
- TANG-06 / TANG-08 battle handoff + snapshot/restore/resume；
- TANG-04 / TANG-07 choice persistence；
- `TANG-01 → TANG-08` 真实 Origin chapter cursor 连续推进；
- battle victory 经过 `BattleResolutionService` 后推进章节；
- non-battle END 使用与 `OriginSequenceJourneyScreen` 一致的 `complete_origin_chapter()`；
- TANG-06 后执行 `Save → 新 NarrativeManager → Load`，恢复到 TANG-07；
- 最终 TANG-08 完成后 route `ROUTE_COMPLETE`、active origin chapter 清空，以及 `TANG_APPROACHES_FIVE_ELEMENTS` 世界效果保持。

`tests/runtime_suite.gd` 当前共 17 个测试。

## Validation

在新 catalog 架构之前，旧 Wukong 15 chapter progression regression 曾因 Godot 4.5.1 warning-as-error 暴露 Variant inference，随后已加入显式类型并修正非战斗 END 收口；Wukong progression 基线已经通过上一轮 Runtime。

新 catalog 迁移后的最终 Tang/Wukong combined Runtime 必须以最新 head 的实际 Godot workflow 结果为准，不能从静态检查推断通过。

## Known issues

- 唐僧路线已经有完整 8 章数据和 progression regression，但还没有单独的完整 SceneTree 点击式玩家 smoke test。
- `BountyEncounterState` 仍是 battle compatibility handoff。
- TANG-08 完成后进入 Shared Journey 的 handoff 还需要在真实 Journey SceneTree 中继续验证。

## Next step
先确认本轮最新 Runtime 全绿；然后为悟空与唐僧分别补最小 SceneTree 入口 smoke coverage，确认 `main menu → journey → event sequence → battle/END → save` 的真实场景层没有断点。之后再迁移 Longma Origin。

## Handoff point
当前已经形成两类 Sequence catalog：shared 主 catalog + origin route-specific catalog。未来 Origin 内容生产优先按 route-specific catalog 扩展，并统一走同一 loader / validator / Journey bridge。
