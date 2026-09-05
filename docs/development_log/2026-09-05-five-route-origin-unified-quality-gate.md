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

## Why
之前每条 Origin Route 都有自己的 regression，但缺少一个统一入口去验证五条路线之间的契约一致性。这个质量门把“内容正确”“handoff 正确”“路线隔离”提升到同一层检查。

## Systems affected
- EventSequenceManager / EventSequenceValidator
- EventRunner / NarrativeEventSession
- OriginEventManager / EncounterManager
- NarrativeManager / NarrativeState
- Headless Godot runtime suite

## Files
- `combat/test_origin_routes_unified.gd`
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

## Godot Runtime status
`Godot Runtime #168` 对初版质量门失败，失败原因是新测试自身使用了不兼容 Godot 4 的两参数 `Dictionary.get()` 调用；同一运行中的既有回归测试均通过。

随后提交 `141e2ebe96d598786b3077fbcb7d1de709a3e744` 修正了第一批错误，但新的运行仍在 quality gate 文件第 83 行发现一处遗漏的两参数 `get()` 调用。

随后提交 `58b90071ec78b9d3a8f475cc568b0711eac295c1` 清理剩余两参数 `Dictionary.get()` 调用；截至本日志更新时，新的 GitHub Actions check 尚未出现最终结论，因此不称为 Runtime 通过。

## Known issues
- 统一质量门当前以测试目录中的 route contract 为显式基准，下一步可考虑把这些 cross-reference 规则下沉到 `EventSequenceValidator`，让生产内容在加载/CI 时直接得到结构化错误。
- `BountyEncounterState` 仍是 BattleUI / Journey 的兼容 handoff 存储层。
- `move / wait / reward` 仍未完全统一到世界执行服务。
- EventSequence 视觉表现仍需继续增强。

## Next step
先确认提交 `58b90071ec78b9d3a8f475cc568b0711eac295c1` 的 Godot Runtime 结果；若通过，则把已验证的 cross-reference 规则逐步内聚到 `EventSequenceValidator`，减少测试与生产校验之间的重复定义，然后继续 Origin → Shared Journey 的统一入口与 SceneTree bridge。

## Handoff point
当前阶段：**Origin Batch C 已完成；五路线 Unified Quality Gate 正在进行最终 CI 收口。**
