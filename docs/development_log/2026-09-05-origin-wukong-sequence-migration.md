# 2026-09-05 — Wukong Origin EventSequence Migration

## Goal
以悟空起始路线作为第一条 Origin Route 样板，把真实个人剧情接入与 Shared Journey 相同的 EventSequence → EventRunner → Journey 执行链，同时保留未迁移章节的旧兼容路径。

## What changed
新增三条 Origin Sequence：

- `WUK-01-SEQUENCE`：石猴出世，dialogue → end；
- `WUK-02-SEQUENCE`：水帘洞主，dialogue → battle → after_battle → end；
- `WUK-03-SEQUENCE`：寻仙问道，dialogue → choice → end。

新增 `ui/origin_sequence_journey.gd` 作为小型兼容桥接层：

- 已迁移 Origin chapter 优先进入 EventSequence；
- 未迁移 Origin chapter 继续沿原 Journey 路径；
- Origin non-battle Sequence END 会完成当前 Origin chapter；
- Origin battle Sequence 仍交给 `BattleResolutionService` 的原子结算，不重复完成章节。

`ui/journey.tscn` 改为挂载该 bridge script。

同时修复 `OriginEventManager` 的数据兼容问题：`origin_events.json` 部分事件对象没有显式 `id` 字段，现在 `get_definition()` 会用 chapter_id 归一化事件 ID。

## Why
Origin 迁移不能通过复制一套新的 Journey UI 实现，否则 Shared / Origin 最终会形成两套剧情执行系统。使用继承桥接可以把迁移保持在最小范围，并允许逐章切换，符合项目的渐进迁移原则。

## Validation

- Runtime #94：真实失败，暴露 WUK-03 事件 ID 归一化问题；
- Runtime #96：诊断确认 `WUK-03` raw dictionary 存在，但 EventDefinition 为空；
- 修复 `OriginEventManager.get_definition()` 后 Runtime #98：**success**，WUK-01/02/03 三条 Sequence 均通过；
- 接入 `journey.tscn` 的 Origin bridge 后 Runtime #101：**success**；
- Godot 4.5.1 stable；
- 完整 headless runtime suite 保持通过（当前 suite 已包含 Origin Sequence regression）。

## Known issues

- 当前只迁移悟空 `WUK-01` 至 `WUK-03`，其余 Origin chapters 仍走旧兼容入口；
- Journey 对 MOVE / WAIT / REWARD 的 Presentation 仍较基础；
- Battle handoff 仍通过 `BountyEncounterState` 兼容层；
- Origin Sequence 还没有独立的 SceneTree smoke test，当前验证重点是 Journey 场景脚本可加载 + Runner/Session Runtime 链。

## Next step
继续完成悟空 Origin Route 的选择节点和战斗节点迁移，优先形成从 `WUK-01 → WUK-02 → WUK-03 → ... → WUK-15` 的完整个人历史链，再把同一模式复制到 Tang / Longma / Bajie / Wujing。

## Handoff point
当前代码基线包含 Origin bridge、Wukong 三条 Sequence 与 Origin event ID normalization。下一轮应先检查最新 Godot Runtime，再扩展悟空路线，不要同时批量改五条 Origin Route。
