# Five Origin Routes Unified Quality Gate — 2026-09-05

## Goal
在五条 Origin Route 全部迁移到 EventSequence 后，建立统一的跨数据引用、路线隔离与 Runner battle resume 质量门，避免各角色单独通过测试但整体契约出现漂移。

## What changed
- 新增 `combat/test_origin_routes_unified.gd`。
- 统一覆盖 Wukong / Tang / Longma / Bajie / Wujing 五条 Origin Route。
- 当前质量门覆盖 46 条 EventSequence、12 个 choice、16 个 battle handoff。
- 检查每条序列的 `ORIGIN` namespace 与精确 `chapter_id`。
- 检查 choice event 是否存在且所要求的 choice id 存在。
- 检查 battle encounter 是否存在、handoff source chapter / source route 是否匹配、production encounter source 是否匹配。
- 检查 battle runner snapshot / restore / resume。
- 检查每条路线执行后 `starting_character` 不被其他路线污染。
- 将统一质量门加入 `tests/runtime_suite.gd`。
- 将 Origin battle 的 `source_route_id` 与 production encounter `source` cross-reference 进一步下沉到 `EventSequenceValidator`，使生产内容本身在 CI 中直接拒绝路线错配。
- `combat/test_event_sequence_validator.gd` 增加 Origin route presence / route mismatch / missing `source_route_id` 回归。

## Why
之前每条 Origin Route 都有自己的 regression，但缺少一个统一入口去验证五条路线之间的契约一致性。这个质量门把“内容正确”“handoff 正确”“路线隔离”提升到同一层检查，并开始把验证规则从测试契约内聚到正式 Validator。

## Systems affected
- EventSequenceManager / EventSequenceValidator
- EventRunner / NarrativeEventSession
- OriginEventManager / EncounterManager
- NarrativeManager / NarrativeState
- Headless Godot runtime suite

## Files
- `combat/test_origin_routes_unified.gd`
- `combat/test_event_sequence_validator.gd`
- `scripts/narrative/event_sequence_validator.gd`
- `tests/runtime_suite.gd`
- `docs/development_log/2026-09-05-five-route-origin-unified-quality-gate.md`
- `AI_HANDOFF.md`

## Tests
- 五路线独立 sequence load / validate
- choice cross-reference
- battle cross-reference
- source route / source chapter consistency
- battle snapshot / restore / resume
- route isolation
- Validator rejection for missing / mismatched Origin source route

## Godot Runtime status
`Godot Runtime #168` 对初版质量门失败，失败原因是新测试自身使用了不兼容 Godot 4 的两参数 `Dictionary.get()` 调用；同一运行中的既有回归测试均通过。

随后提交 `141e2ebe96d598786b3077fbcb7d1de709a3e744` 修正第一批调用，但运行继续在第 83 行发现一处遗漏；提交 `58b90071ec78b9d3a8f475cc568b0711eac295c1` 修正后，运行发现 EventDefinition 没有通用 `get()` 接口而是通过 `get_choices()` 暴露 choices；该问题随后在 `e348971a2293e773fa19745acc684b4793a336d4` 修正。

随后提交 `d0c6214748b400cce59654c092d4c11ec0882434` 与 `d5b707e5ae5da65bf3c23e7b315f42791caab049` 将 Origin battle route cross-reference 下沉到正式 Validator，并补充 Validator regression。提交 `d5b707e5ae5da65bf3c23e7b315f42791caab049` 的 `Godot Runtime` 已触发，目前为 queued / 未得出最终结论；因此本阶段仍不称为 Runtime 全绿。

## Known issues
- 统一质量门目前仍保留显式 route contract 表，后续可以继续减少测试侧重复定义，让更多约束完全由 content validator 负责。
- `BountyEncounterState` 仍是 BattleUI / Journey 的兼容 handoff 存储层。
- `move / wait / reward` 仍未完全统一到世界执行服务。
- EventSequence 视觉表现仍需继续增强。

## Next step
确认 `d5b707e5ae5da65bf3c23e7b315f42791caab049` 的 Godot Runtime；通过后继续把统一 quality gate 收敛到 Validator，并着手验证 Origin → Shared Journey 的 SceneTree bridge / shared timeline handoff。

## Handoff point
当前阶段：**Origin Batch C 已完成；五路线 Unified Quality Gate + Validator cross-reference 正在 CI 收口。**
