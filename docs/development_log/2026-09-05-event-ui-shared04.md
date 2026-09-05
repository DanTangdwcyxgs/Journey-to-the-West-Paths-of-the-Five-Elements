# 2026-09-05 — Event UI / Shared-04 Migration

## 目标

继续 Batch A 的 Event Sequence Presentation，并开始 Batch B：把共享西游的 `SHARED-04-EARLY-DEMON-TALES` 接入统一 EventSequence 执行链。

## 具体修改

### Journey Event Presentation

`ui/journey.gd` 增加稳定的剧情对白表现层：

- 独立 DialoguePanel、Speaker、Text、Hint、EventMeta 控件；
- 对 dialogue action 使用逐字显示；再次点击可立即显示完整对白；
- WAIT action 提供明确的过渡状态并在计时完成后继续 Runner；
- BATTLE action 保持 Handoff 边界，由 Journey 启动 BattleUI，不让 Runner 依赖 UI；
- shared sequence 不再为单个章节硬编码，而是按 `<chapter_id>-SEQUENCE` 自动查找并运行；
- 无战斗的 shared sequence 在 END 时提交对应共享章节；带战斗的章节继续由 `BattleResolutionService` 完成原子章节提交，避免重复推进。

### Shared-04

`data/narrative/event_sequences.json` 新增：

`SHARED-04-EARLY-DEMON-TALES-SEQUENCE`

流程：

`departure dialogue → move(BLACK_WIND_NORTH_PATH) → warning dialogue → wait → resolve dialogue → reward(HERB) → end`

这样黑风山早期妖患不再依赖 Journey 中的旧章节按钮直通逻辑，而是进入统一事件图。

### Regression

新增 `combat/test_journey_event_presentation.gd`，覆盖 Journey 演示壳、对白逐字显示和核心控件；并加入 `tests/runtime_suite.gd`。

`combat/test_event_sequence_validator.gd` 同时验证 Shared-04 sequence 的结构有效性与已有 Shared-03 sequence 的交叉引用。

## 影响范围

- Presentation：Journey 剧情演出更明确；
- Narrative：Shared sequence 可以按章节自动扩展；
- World：Shared-04 的 move action 会通过既有 `WorldActionService` 写入世界地点访问；
- Reward：Shared-04 的 reward action 会通过既有 `RewardService` 执行；
- 不改变 EventRunner 的 UI-independent 设计。

## Godot Runtime

本次提交后，GitHub commit status 当前仍为 `pending`，且尚未返回检查项；因此这里不能声明 Godot Runtime CI 已通过。

本机环境中未检测到 `godot` 可执行文件，因此没有本地替代运行结果可写入。

## 已知问题

- WAIT 目前是 presentation 层计时与 WorldActionService 的验证，不会推动独立的世界时钟；
- MOVE 目前只记录逻辑地点访问，不包含角色路径动画；
- 旧 `BountyEncounterState` 仍承担跨 BattleUI / Journey 的兼容 resume context；
- Shared-05 以后仍需逐条迁移，不能假设所有章节已经进入 EventSequence。

## 下一阶段

1. 根据 CI 结果修正本批潜在回归；
2. 继续迁移 `SHARED-05-GAOJIAZHUANG`，保留招募战与 BattleResolution 原子边界；
3. 再处理 `SHARED-06` 的无战斗章节，验证 sequence completion/reward 链；
4. 之后继续 `SHARED-07/08/09`，再进入 Origin migration。

## 接手 Agent 起点

优先检查最新 `main` 的 Event UI / Shared-04 相关 commit 与 `tests/runtime_suite.gd`，先看 CI 是否已经返回；不要把 `pending` 当作成功。
