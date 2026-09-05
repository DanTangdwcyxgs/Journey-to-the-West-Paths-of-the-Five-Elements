# 2026-09-05 — Wukong Origin Chapter Progression Regression

## Goal
补齐悟空 Origin Route 从“Sequence 能执行”到“真实章节状态能连续推进”的回归覆盖，验证玩家实际路线所依赖的章节状态、战斗胜利推进、保存/读取以及最终路线完成。

## What changed
新增 `combat/test_wukong_origin_progression.gd`：

- 从 `WUK-01` 开始，按生产 Origin Route 当前章节逐章执行 `WUK-01 → WUK-15`；
- 每章开始前验证 `OriginRouteManager.get_current_chapter()` 与预期章节一致，防止章节跳跃；
- 直接使用生产 `EventSequence`，验证 dialogue / wait / choice / battle / end；
- 战斗节点使用生产 `EncounterManager` 读取 rewards / world effects，再交给 `BattleResolutionService` 原子结算；
- 非战斗章节在 END 后执行与 `OriginSequenceJourneyScreen` 相同的 `complete_origin_chapter()` 收口；
- WUK-02 后执行真实 `save → 新 NarrativeManager → load`，确认恢复到 WUK-03；
- 最终验证 WUK-15 完成、WUKONG route 为 `ROUTE_COMPLETE`、active origin chapter 清空，以及关键选择/世界效果保持。

更新 `tests/runtime_suite.gd`：
- 将该回归加入完整 suite；
- suite 从 14 项增加到 15 项。

## Why
原有 `test_origin_event_sequences.gd` 已经能够证明 15 条生产 Sequence 的 graph、battle handoff/resume 和 choice execution 正常，但它是在同一个 NarrativeManager 上逐条独立启动 Sequence，没有验证真正的 Origin chapter cursor 是否随着上一章完成而进入下一章。

这次回归把 Sequence execution 与 `OriginRouteManager + NarrativeState + NarrativeSave + BattleResolutionService` 连接起来，重点验证“玩家章节推进”这一更接近实际产品入口的状态链。

测试中的非战斗 END 显式调用 `complete_origin_chapter()`，对应生产 `OriginSequenceJourneyScreen._finish_event_session()` 的行为；战斗章节则由 `BattleResolutionService` 完成章节推进，避免重复完成。

## Validation

- 前一轮主菜单开发者/投资合作入口 Runtime #122：success；
- 本轮第一次 progression regression Runtime：failure，原因是新测试中的 `encounter_definition := ...` 触发 Godot 4.5.1 warning-as-error 的 Variant 类型推断；
- 随后加入显式 `Dictionary` / `Dictionary` / `Array` 类型；
- 下一次静态审查发现非战斗 Origin END 还需要执行章节完成收口，因此再次修正测试逻辑；
- 修正后的最终提交 Runtime 是否通过，必须以该提交对应最新 Godot workflow 的真实结果为准。

## Known issues

- 该回归验证的是生产状态机和 Journey bridge 对应的后端推进逻辑，尚未直接模拟玩家在完整 SceneTree 中逐个点击 15 章的 UI 操作。
- 战斗进入/返回仍通过现有 `BountyEncounterState` compatibility handoff。

## Next step
确认最终 progression regression Runtime 通过后，继续做 Wukong Origin SceneTree 端到端入口 smoke coverage；完成悟空路线后再开始 Tang Origin 第一批 Sequence 迁移。

## Handoff point
悟空 Origin 已具备完整 `WUK-01 → WUK-15` Sequence 数据，现增加了逐章推进与 save/load regression。下一轮优先关注玩家入口与场景层是否能完整消费这一状态链，而不是重新设计 Origin backend。
