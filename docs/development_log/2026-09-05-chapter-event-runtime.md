# 2026-09-05 — Chapter Event Runtime 第一批部署

## 本次目标

把项目从“章节数据 + 各自的 EventManager”推进到可批量生产的统一事件运行层，为后续五条 Origin Route、Camp、Memory、Relationship 和 Shared Journey 大规模内容生产准备稳定入口。

## 核心判断

当前项目不需要推倒 Narrative / Combat / World 基础架构重写，但必须补齐 Definition → Runtime 这一层。否则随着章节数量增长，UI 和各个 Manager 会继续直接操作 raw Dictionary，导致同一种事件在不同章节出现不同的状态存储、重复副作用和难以迁移的问题。

因此采用渐进式迁移：保留现有可工作的内容和兼容层，新增统一 Definition / Runtime，再逐步把旧调用迁移过去。

## 本次完成

### 1. 新增 EventDefinition

文件：`scripts/narrative/event_definition.gd`

作用：

- 统一事件 ID、标题、文本、choices 的读取接口；
- 屏蔽大多数调用方对 raw JSON key 的直接依赖；
- 为未来 Event UI / Cutscene Runtime 提供稳定数据契约。

### 2. 新增 EventRuntime

文件：`scripts/narrative/event_runtime.gd`

作用：

- 验证事件与 namespace；
- 防止重复选择；
- 验证 choice 存在；
- 将通用持久化效果交给统一运行层处理；
- 最终通过 `NarrativeState` 记录选择。

当前通用 effects：

- `relationship_values`
- `milestones`
- `world_rumors`
- `memory_chapters`

角色专属战斗 modifier 暂不并入 Generic Event Effects，保留在现有 Origin 兼容层，避免为了统一而过早设计过大的 schema。

### 3. OriginEventManager 接入 EventRuntime

文件：`scripts/narrative/origin_event_manager.gd`

Origin 事件现在通过 `EventDefinition + EventRuntime` 执行选择，同时保留 `get_choice_effects()`，保证现有 CombatPartyBuilder 等调用不需要一次性重写。

### 4. SharedEventManager 接入 EventRuntime

文件：`scripts/narrative/shared_event_manager.gd`

Shared 事件现在同样通过 `EventDefinition + EventRuntime` 执行，并继续通过 `NarrativeState.record_shared_choice()` 持久化。

### 5. Event Runtime namespace 隔离

事件选择现在必须明确属于：

- `ORIGIN`
- `SHARED`

避免同名事件在不同层级互相污染选择状态。

### 6. 新增事件运行时回归测试

文件：`combat/test_event_runtime.gd`

覆盖：

- 事件是否可呈现；
- 选择是否成功；
- Shared choice 是否持久化；
- relationship effect；
- milestone effect；
- rumor effect；
- memory unlock effect；
- 单次选择不能重复执行。

## 当前未完成

本次仍然没有把完整的“对话播放 / 镜头 / NPC 行走 / 多段事件链 / Event → Battle → Event”全部做完。

当前 EventRuntime 是“状态与选择执行层”，不是最终的 Cutscene / Dialogue 播放器。

下一批需要在此基础上增加：

1. `EventSequence / EventRunner`：支持多段事件节点串联；
2. Dialog / Choice / Wait / Move / Battle / Reward / Jump 等标准节点；
3. Event → Battle Handoff；
4. Battle 完成后返回 Event Runner；
5. 事件失败 / 中断时的恢复策略；
6. 最小 Journey UI 集成；
7. 完整 Vertical Slice 回归测试。

## 测试状态

已新增代码级回归测试，但当前开发环境没有实际运行 Godot，因此不得把本次测试描述为 Godot Runtime 已通过。

## 架构影响

新的推荐调用链：

`Event Data → EventDefinition → EventRuntime → NarrativeState`

共享章节继续使用：

`Chapter Data → ChapterDefinition → ChapterRuntime → SharedJourneyManager`

战斗继续使用：

`Chapter / World → EncounterHandoff → BattleUI → CombatEngine → BattleResolutionService`

## 下一位 Agent 应从哪里开始

优先阅读：

1. `AI_HANDOFF.md`
2. `DEVELOPMENT_RULES.md`
3. 本文件
4. `scripts/narrative/event_definition.gd`
5. `scripts/narrative/event_runtime.gd`
6. `scripts/narrative/chapter_definition.gd`
7. `scripts/narrative/chapter_runtime.gd`
8. `docs/content_pipeline.md`

下一任务不要重新设计事件系统；应该直接在现有 EventRuntime 上增加 `EventRunner / EventSequence`，并先用一个真实共享章节做完整链路验证。

## 核心原则

**章节描述发生什么，Runtime 决定怎么执行，NarrativeState 保存事实，Presentation 只负责表现。**
