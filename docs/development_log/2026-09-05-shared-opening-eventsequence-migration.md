# Shared Opening EventSequence Migration — 2026-09-05

## Goal
完成 Shared Journey 开篇 `SHARED-01-FIVE-ELEMENTS` 与 `SHARED-02-EARLY-PILGRIMAGE` 的 EventSequence 迁移，让 Shared 01-09 全部进入统一数据驱动执行模型。

## What changed
- 将 `SHARED-01-FIVE-ELEMENTS` 与 `SHARED-02-EARLY-PILGRIMAGE` 加入 `data/narrative/event_sequences.json`。
- 两章均通过 `EventSequenceManager` / `EventSequenceValidator` 进入运行时目录。
- 两章选择继续复用生产 `shared_events.json` 中的选择定义：
  - SHARED-01 → `TRUST_WUKONG`
  - SHARED-02 → `KEEP_MOVING`
- 更新 `combat/test_shared_event_sequences.gd`，现在统一执行 Shared 01-09 共 9 条序列，验证 6 个 choice、3 个 battle handoff、1 个 world move。
- 新增 `combat/test_shared_opening_journey_bridge.gd`，通过真实 `JourneyScreen` SceneTree 路径验证：Origin 完成 → Shared 01 session → dialogue → choice → choice persistence → END → Shared 02。
- `tests/runtime_suite.gd` 纳入 Shared opening bridge regression。

## Why
Shared 03-09 已经走 EventSequence，但 Shared 01-02 仍依赖旧式 Shared chapter 判断。迁移后，个人起点进入共享世界的最初一段体验也与后续共享剧情采用相同 Runner / Session / Presentation 链。

## Tests
- Shared 01-09 EventSequence load / validate / execute
- 6 个 Shared choice persistence
- 3 个 Shared battle handoff + runner restore/resume
- 1 个 world move execution
- Origin → Shared 01 SceneTree bridge
- Shared 01 completion → Shared 02 timeline continuation

## Godot Runtime status
**Godot Runtime #172 — SUCCESS.**

head `63ec4db5cca2a7bfd036ba6f8d4e336a7f1ca330` 的完整 headless runtime suite 通过，`RUNTIME_SUITE_PASS tests=26`。

本次通过项包括：
- EventSequenceValidator
- 全部五条 Origin Route unified gate
- Origin → Shared handoff
- Shared 01-09 EventSequence runtime
- Shared opening JourneyScreen SceneTree bridge
- 既有战斗 / 奖励 / 世界 / Journey 回归

## Architecture result
当前共享主线已经形成：

`Origin Route → handoff_origin_to_shared() → JourneyScreen → NarrativeEventSession → EventRunner → Shared EventSequence → SharedJourneyManager.complete()`

Shared 01 的章节奖励与世界推进仍由 `SharedJourneyManager` 负责，EventRunner 不直接产生库存副作用，符合现有架构边界。

## Known issues
- Shared EventSequence 目前仍有部分章节奖励依赖 `SharedJourneyManager.complete()`，尚未统一成显式 `reward` service。
- `move / wait` 仍主要产生 action，世界执行层还需要进一步统一。
- `BountyEncounterState` 仍是兼容 handoff 存储层。
- EventSequence 的对白框、镜头、角色移动反馈仍需增强。

## Next step
1. 为 Shared 03-09 增加统一 JourneyScreen / BattleUI SceneTree bridge 回归，覆盖鹰愁涧、高老庄、流沙河三个真实招募节点。
2. 开始把 `reward` 节点与非战斗奖励收敛到统一 RewardService。
3. 将 Shared Journey 的最终五人集结与完整取经入口做成第一个完整 Vertical Slice。

## Handoff point
当前阶段：**Shared Journey EventSequence 迁移已覆盖 SHARED-01 至 SHARED-09，并通过 Godot Runtime #172；下一阶段进入 Shared Battle/SceneTree 真实桥接与 Vertical Slice。**
