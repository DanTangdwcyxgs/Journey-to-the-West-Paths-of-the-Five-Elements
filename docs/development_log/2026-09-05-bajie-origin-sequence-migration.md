# 2026-09-05 — Bajie Origin EventSequence Migration

## Goal

继续 Batch C Origin migration，将猪八戒完整个人路线接入 route-specific `EventSequence` catalog，并保持固定西游世界时间线、BattleResolution 原子边界与 Save/Resume 行为。

## Changes

### Bajie EventSequence

`data/narrative/event_sequences_origin.json` 新增 `BAJIE-01` 到 `BAJIE-09` 全部 9 章：

- BAJIE-01：dialogue → end
- BAJIE-02：dialogue → choice → end
- BAJIE-03：dialogue → dialogue → end
- BAJIE-04：dialogue → end
- BAJIE-05：dialogue → end
- BAJIE-06：choice → battle → after_battle → end
- BAJIE-07：dialogue → dialogue → end
- BAJIE-08：dialogue → battle → after_battle → end
- BAJIE-09：dialogue → end

两个战斗直接复用生产 Encounter：

- `BAJIE_ORIGIN_GAO_WILD`
- `BAJIE_ORIGIN_WUKONG_DUEL`

两个选择直接复用现有 Origin events：

- `BAJIE-02`
- `BAJIE-06`

### Regression

新增：

- `combat/test_bajie_origin_event_sequences.gd`
- `combat/test_bajie_origin_progression.gd`

覆盖：

- 9 条 production Sequence 加载与 `EventSequenceValidator` 交叉引用校验；
- 两场战斗的 Encounter handoff、runner snapshot/restore/resume；
- 两个 choice 的持久化；
- `BAJIE-01 → BAJIE-09` 连续 Origin cursor 推进；
- 战斗胜利通过 `BattleResolutionService` 推进章节；
- `BAJIE-06` 后 Save → 新 `NarrativeManager` → Load 恢复到 `BAJIE-07`；
- 最终路线进入 `ROUTE_COMPLETE` 并清空 active origin chapter。

`tests/runtime_suite.gd` 已加入两项测试。

## Architecture

本轮没有修改 EventRunner、Journey Presentation 或 Combat Domain。Bajie 继续使用现有 route-specific catalog、统一 validator、Journey bridge 与 BattleResolutionService。

## Godot Runtime

Godot Runtime #156 已完成并 **success**。本批新增的 Bajie Sequence、progression regression、runtime suite 集成均通过；workflow 的 Import、signature parser、EventRuntime、EventRunner、headless runtime suite 全部成功。

此前 head `91412a892a3093d2aded4f1e540c71e69692bc36` 的 Godot Runtime #152 也已成功。

## Known issues

- Wujing Origin 尚未迁移。
- `BountyEncounterState` 仍是跨 BattleUI / Journey 的兼容 handoff 层。
- MOVE 仍主要是逻辑世界地点动作，没有角色路径动画。

## Next step

继续迁移 `WUJING-01` 到 `WUJING-08`，这是最后一条尚未进入统一 route-specific EventSequence 的完整 Origin 路线。完成后统一检查五路线的 cross-reference、SceneTree bridge 与共享时间线 handoff。

## Handoff point

当前 route-specific Origin catalog 已覆盖 Wukong、Tang、Longma、Bajie；Wujing 是最后一条尚未进入统一 EventSequence 的完整 Origin 路线。
