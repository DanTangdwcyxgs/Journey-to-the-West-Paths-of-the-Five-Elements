# 2026-09-05 — EventRunner Runtime 收口与 EventSession 跨战斗恢复

## Goal

把统一事件运行层从“代码骨架”推进到可以真实跨 Journey / Battle 场景恢复的可生产链路，并用 Godot 4.5.1 headless CI 验证。

## What changed

### 1. EventRunner Godot 兼容问题收口

`EventRunner` 避免对高层 `NarrativeManager` 做类型依赖，并将原成员名 `namespace` 改为 `event_namespace`，解决 Godot 全局类扫描 / 解析问题。

同时修复 `END` 节点语义：到达显式 END 节点时 Runner 立即进入 `finished` 状态，而不是继续停留在 `waiting`。

### 2. EventRunner 完成真实 Runtime 验证

测试覆盖：

- EventSequence 图结构校验；
- Dialogue → Choice；
- Choice 持久化；
- Choice → Battle；
- Battle pending snapshot；
- Restore；
- Battle → Reward；
- Reward → END；
- END 为终态。

Godot Runtime #25 已通过上述链路。

### 3. 新增 NarrativeEventSession

文件：`scripts/narrative/narrative_event_session.gd`

Session 负责事件业务会话编排，但不接触 UI。主要能力：

- 创建并持有 EventRunner；
- 统一转发 dialogue / choice / battle 等动作；
- 判断是否等待 Battle；
- 生成包含 `event_resume` 的 Battle handoff；
- 从 handoff 恢复 session；
- Battle 胜利后继续 EventRunner。

### 4. Encounter handoff 承载 resume context

`BountyEncounterState.start_encounter()` 增加 `extra` 参数，保留兼容旧入口，同时允许存储 `event_resume`。

这里仍然只是场景间的兼容持久化，不是 NarrativeState 的事实源。

### 5. 新增 EventSequenceManager + 第一条真实序列

文件：

- `scripts/narrative/event_sequence_manager.gd`
- `data/narrative/event_sequences.json`

第一条生产样板：

`SHARED-03-EAGLE-SORROW-SEQUENCE`

链路：

`Arrival Dialogue → LONGMA_ENCOUNTER Choice → SHARED_EAGLE_SORROW Battle → After Battle Dialogue → END`

它使用现有鹰愁涧共享招募战，不新增第二套战斗规则。

### 6. Journey / Narrative BattleUI 接入

Journey 现在优先识别第一条真实 Sequence，并由 `NarrativeEventSession` 驱动。

当事件进入 Battle 时：

`Journey → EventSession → EventRunner → EncounterHandoff(+event_resume) → BattleUI`

Battle 胜利仍然只通过：

`BattleResolutionService`

完成主线事实、奖励和世界推进；完成后保存 EventSession resume context。

返回 Journey 后继续显示 EventRunner 的 after-battle dialogue，而不是重新开始章节。

### 7. 回归测试

新增：

`combat/test_narrative_event_session.gd`

并接入：

`tests/runtime_suite.gd`

覆盖 Session → Handoff → Restore → Battle Resume。

## Why

这是批量生产所必须的边界：

- Story author 不需要为每段剧情写新的 UI / Battle scene；
- Battle 不需要知道 EventRunner；
- EventRunner 不需要知道 BattleUI；
- NarrativeState 继续保存世界事实；
- 跨场景中断只保存可序列化的业务上下文。

## Files

- `scripts/narrative/event_runner.gd`
- `scripts/narrative/narrative_event_session.gd`
- `scripts/narrative/event_sequence_manager.gd`
- `scripts/world/bounty_encounter_state.gd`
- `data/narrative/event_sequences.json`
- `ui/journey.gd`
- `ui/narrative_battle_ui.gd`
- `combat/test_event_runner.gd`
- `combat/test_narrative_event_session.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`

## Tests

已验证的 Godot 4.5.1 Runtime 版本：

- Godot Runtime #25：EventRunner 终态修复后全套核心回归通过；
- Godot Runtime #34：包含 EventSession / Journey / Narrative BattleUI 相关实现后，全套 headless suite 通过。

## Current Runtime Status

以实际 CI 为准，当前最近已完成成功运行是 Godot Runtime #34。

不要将当前版本写成“桌面完整游戏运行验证通过”；目前验证重点是 headless runtime、剧情状态、战斗结算与跨场景恢复链。

## Known issues

1. `reward` EventRunner 节点目前仍只是 action，不直接发奖；战斗奖励仍由 BattleResolutionService 处理。
2. `move / wait` 仍主要产生 action，尚未统一接入 WorldActionService。
3. Sequence cross-reference validation 还未检查 event / encounter / chapter / namespace 的完整一致性。
4. `BountyEncounterState` 仍是旧兼容命名，后续需要收敛成通用 Scene Handoff Service。
5. Journey 当前只迁移第一条真实 Sequence，其余章节继续走兼容旧路径。

## Next step

优先级：

1. 完善第一条 Event Sequence 的视觉表现；
2. 建立 RewardService / WorldActionService；
3. 为 Sequence 增加 cross-reference content validation；
4. 迁移剩余 Shared Journey 招募章节；
5. 再开始 Origin Route 批量迁移；
6. 进入第一完整 Vertical Slice。

## Handoff point

当前稳定边界：

`Content Data → Definition → Runtime → EventSession → Handoff → BattleResolution → NarrativeState → Presentation`

核心原则保持不变：

**章节描述发生什么，Runtime 决定怎么执行，NarrativeState 保存事实，Presentation 只负责表现。**
