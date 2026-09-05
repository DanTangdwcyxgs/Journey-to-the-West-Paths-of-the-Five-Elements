# Five Origin Routes Unified Quality Gate — 2026-09-05

## Goal
在五条 Origin Route 全部迁移到 EventSequence 后，建立统一的跨数据引用、路线隔离与 Runner battle resume 质量门，避免各角色单独通过测试但整体契约出现漂移。

## What changed
- 新增 `combat/test_origin_routes_unified.gd`。
- 统一覆盖 Wukong / Tang / Longma / Bajie / Wujing 五条 Origin Route。
- 当前质量门覆盖 46 条 EventSequence、11 个 choice、13 个 battle handoff。
- 检查每条序列的 `ORIGIN` namespace 与精确 `chapter_id`。
- 检查 choice event 是否存在且所要求的 choice id 存在。
- 检查 battle encounter 是否存在、handoff source chapter / source route 是否匹配、production encounter source 是否匹配。
- 检查 battle runner snapshot / restore / resume。
- 检查每条路线执行后 `starting_character` 不被其他路线污染。
- 将统一质量门加入 `tests/runtime_suite.gd`。
- 将 Origin battle 的 `source_route_id` 与 production encounter `source` cross-reference 下沉到 `EventSequenceValidator`，使生产内容本身在 CI 中直接拒绝路线错配。
- `combat/test_event_sequence_validator.gd` 增加 Origin route presence / route mismatch / missing `source_route_id` 回归。
- 新增 `combat/test_origin_shared_handoff.gd`，验证五条 Origin Route 完成后进入正确的 Shared Journey 章节、时间线里程碑、招募队伍与 Origin 状态清理。

## Why
之前每条 Origin Route 都有自己的 regression，但缺少一个统一入口去验证五条路线之间的契约一致性。这个质量门把“内容正确”“handoff 正确”“路线隔离”提升到同一层检查，并开始把验证规则从测试契约内聚到正式 Validator。

## Systems affected
- EventSequenceManager / EventSequenceValidator
- EventRunner / NarrativeEventSession
- OriginEventManager / EncounterManager
- NarrativeManager / NarrativeState
- StartRouteCatalog
- SharedJourneyManager
- Headless Godot runtime suite

## Files
- `combat/test_origin_routes_unified.gd`
- `combat/test_event_sequence_validator.gd`
- `combat/test_origin_shared_handoff.gd`
- `scripts/narrative/event_sequence_validator.gd`
- `tests/runtime_suite.gd`
- `docs/development_log/2026-09-05-five-route-origin-unified-quality-gate.md`
- `AI_HANDOFF.md`

## Tests
- 五路线独立 sequence load / validate
- 11 个 choice cross-reference
- 13 个 battle cross-reference
- source route / source chapter consistency
- battle snapshot / restore / resume
- route isolation
- Validator rejection for missing / mismatched Origin source route
- 五条 Origin Route → Shared Journey handoff
- handoff timeline / milestone / recruited roster consistency

## Godot Runtime status
**Godot Runtime #171 — SUCCESS.**

本次 head `baa989b5606b864af06ff395b6732ea4fe4846be` 的完整 headless runtime suite 已通过，包含：
- 项目导入与脚本注册
- GDScript signature parser probe
- EventRuntime direct check
- EventRunner direct check
- 五条 Origin unified quality gate
- Origin → Shared handoff regression
- 其余既有战斗 / 世界 / Journey 回归

此前 `Godot Runtime #168`、后续修复运行中暴露的测试自身兼容问题均已完成修正；当前以 #171 的实际 CI 成功结果为准。

## Known issues
- Unified quality gate 仍保留一份显式 route contract 表，未来可进一步减少测试侧重复定义。
- `BountyEncounterState` 仍是 BattleUI / Journey 的兼容 handoff 存储层。
- `move / wait / reward` 尚未完全统一到世界执行服务。
- EventSequence 视觉表现仍需继续增强。

## Next step
五条 Origin Route 与 Shared 入口已经具备统一回归保障，下一阶段优先完成 Shared Journey 的 `SHARED-01 / SHARED-02` EventSequence 迁移，让九段共享主线全部走同一套执行模型；随后再继续完善 SceneTree / BattleUI 真实桥接与第一完整 Vertical Slice。

## Handoff point
当前阶段：**Origin Batch C 完成，五路线 Unified Quality Gate 与 Origin → Shared handoff regression 已通过，正式进入 Shared Journey EventSequence migration。**
