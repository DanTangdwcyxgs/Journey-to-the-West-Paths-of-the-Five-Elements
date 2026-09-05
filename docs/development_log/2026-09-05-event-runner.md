# 2026-09-05 — EventSequence / EventRunner 运行骨架

## 1. 本次目标

把上一批的 `EventDefinition + EventRuntime` 从“单次事件选择执行”推进到“可批量编排的多节点剧情运行时”，同时保持 UI、战斗、世界系统之间的职责边界。

## 2. 修改了什么

新增：

- `scripts/narrative/event_sequence_definition.gd`
- `scripts/narrative/event_runner.gd`
- `combat/test_event_runner.gd`

文档更新：

- `docs/content_pipeline.md`
- `AI_HANDOFF.md`

## 3. 为什么这样修改

单个 Event 已能处理选择和持久化，但真实 JRPG 剧情不是一个 Event 就结束，而是：

`对话 → 选择 → 战斗 → 战后 → 奖励 → 后续对话 → 结束`

如果每个章节继续各自手写流程控制，就会重新产生“一个剧情一个脚本”的技术债，无法满足批量生产需求。

因此新增统一的 Sequence + Runner：内容只描述节点图，Runner 负责执行状态；Presentation 和具体系统只负责响应 action。

## 4. 当前节点类型

- `dialogue`
- `choice`
- `wait`
- `move`
- `battle`
- `reward`
- `jump`
- `end`

## 5. 关键运行规则

### Definition

`EventSequenceDefinition` 只负责数据标准化和结构验证，包括：

- sequence id
- start node
- node id 唯一性
- 节点类型合法性
- next / jump / choice next_map 目标存在性

### Runner

`EventRunner` 只负责：

- 当前节点
- 当前 pending action
- 节点间跳转
- choice 调用 `EventRuntime`
- battle 生成 `EncounterHandoff`
- 状态序列化 / 恢复

Runner 不执行：

- UI
- 动画
- 路径寻路
- CombatEngine
- 具体奖励发放

### Battle

Battle node 不直接打开 BattleUI，而是返回：

`EventRunner → EncounterHandoff → BattleUI / Battle system`

战斗结束后，外部系统调用 `resolve_battle(true)`，Runner 再恢复到下一个剧情节点。

## 6. 测试覆盖

新增代码级回归：

- sequence graph validation
- dialogue → choice
- choice routing
- shared event persistence
- choice 后进入 battle
- `EncounterHandoff` 字段保持
- battle 前保存 runner snapshot
- restore 后继续 battle
- battle victory → reward → end
- stale choice 被拒绝

当前仍未执行真实 Godot Runtime；因此以上只是代码级回归覆盖，不代表 Godot SceneTree 实机通过。

## 7. 已知未完成

最重要的缺口已经从“缺少 Runtime”转为“缺少真实运行接线”：

1. EventRunner 尚未接入真实 Journey / Chapter / Event UI。
2. Battle 返回还未由 Runner 真正驱动 `BattleResolutionService`。
3. 当前 Reward node 只发出 reward action，不自行修改 Inventory，这是为了避免奖励所有权混乱；之后应接正式 RewardService。
4. 还缺少真正的 sequence 数据文件加载器和内容批量生产样例。
5. 仍需要真实 Godot SceneTree 回归。

## 8. 下一步

### Batch 1B — Runtime Validation / Integration

建立一个真实可运行的最小剧情入口：

`对话 → 选择 → Battle → BattleResolutionService → Runner 恢复 → 后续对话 → End`

第一优先级不是继续增加抽象，而是把这条链放进 Godot SceneTree 并实际跑通。

## 9. 接手 Agent 起点

先阅读：

- `AI_HANDOFF.md`
- `docs/content_pipeline.md`
- `scripts/narrative/event_sequence_definition.gd`
- `scripts/narrative/event_runner.gd`
- `combat/test_event_runner.gd`
- `scripts/world/battle_resolution_service.gd`
- 当前 Journey / Narrative 入口 UI

然后开始 Batch 1B，不要再为 EventRunner 添加 UI 职责，也不要把 BattleResolutionService 的逻辑复制进 Runner。
