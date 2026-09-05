# 2026-09-05 — Reward / World Action Services

## Goal

继续把 EventRunner 从“返回 action”推进为真正可批量生产的执行编排：Runner 不直接修改业务状态，而由专门 Service 承担副作用。

## What changed

### RewardService

新增 `scripts/items/reward_service.gd`。

统一处理非战斗剧情奖励：

- `COIN_LOW / COIN_MEDIUM / COIN_HIGH / COIN_LEGENDARY`
- 普通物品奖励
- 显式 `{id, amount, type, currency}` 奖励
- `preview()` 保证预览不修改状态
- `apply_to_manager()` 在 `NarrativeState.inventory` 上提交结果

EventRunner 的 `reward` node 现在通过 `RewardService` 执行，不再自己写库存副作用。

### WorldActionService

新增 `scripts/world/world_action_service.gd`。

统一处理 EventRunner 的：

- `move`：更新 NarrativeState 的世界当前位置、访问节点
- `wait`：提供统一的等待动作校验入口

Runner 不直接碰 World Map UI，也不直接实现地图规则。

## Regression tests

新增：

- `combat/test_reward_service.gd`
- `combat/test_world_action_service.gd`

并把两项加入：

- `tests/runtime_suite.gd`

同时扩展 `combat/test_event_runner.gd`，验证 reward node 实际改变库存。

## Architecture impact

当前运行链进一步稳定为：

`EventSequence JSON → EventSequenceDefinition → EventRunner → Action → Service / Battle Handoff → NarrativeState`

其中：

- Dialogue / Choice：Presentation + EventRuntime
- Reward：RewardService
- Move / Wait：WorldActionService
- Battle：EncounterHandoff → BattleUI → BattleResolutionService

这符合单一事实源原则：

**Runner 负责流程，不负责业务副作用。**

## Test status

上一轮 Godot Runtime #48 已真实通过，包括 EventRunner、EventSession、Sequence validator、Reward 等核心回归。

本次加入 WorldActionService 后，新 CI Run #52 正在执行中，当前不能提前宣称已经通过。

## Known issues

- `move` 当前记录的是世界逻辑位置，不负责真正的角色寻路或场景动画；后续由 WorldAction / Travel Presentation 层接管。
- `wait` 当前是逻辑校验与 action contract，不推进世界时间；如未来加入世界时钟，应集中在 World 系统处理。
- `BountyEncounterState` 仍承担兼容性的跨场景 handoff 存储，后续继续收敛为通用 Scene Handoff Service。

## Next step

优先推进第一条真实 Event Sequence 的 Presentation：稳定对白框、选择框、移动反馈，并继续保留 Runner UI-independent。

随后逐条迁移 Shared Journey，之后才进入 Origin Route 批量迁移和 Camp / Relationship Prototype。

## Handoff point

下一位 Agent 应从：

`EventRunner → RewardService / WorldActionService → NarrativeEventSession → EncounterHandoff`

继续，不要重新设计事件运行层。
