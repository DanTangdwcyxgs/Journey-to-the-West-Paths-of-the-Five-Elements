# 2026-09-05 — Wukong Full Origin EventSequence Migration

## Goal
把悟空 Origin Route 的 `WUK-04` 至 `WUK-15` 全部接入现有 EventSequence → EventRunner → Journey 链，形成完整的 `WUK-01 → WUK-15` 个人历史数据闭环，同时保持旧 Origin 入口兼容。

## What changed
更新 `data/narrative/event_sequences.json`，新增 12 条生产 Sequence：

- `WUK-04-SEQUENCE`：菩提门下，dialogue → wait → dialogue → end；
- `WUK-05-SEQUENCE`：大圣初醒，dialogue → dialogue → end；
- `WUK-06-SEQUENCE`：龙宫取宝，dialogue → battle → after_battle → end；
- `WUK-07-SEQUENCE`：地府改命，dialogue → dialogue → end；
- `WUK-08-SEQUENCE`：弼马温，dialogue → choice → end；
- `WUK-09-SEQUENCE`：齐天大圣，dialogue → dialogue → end；
- `WUK-10-SEQUENCE`：偷食蟠桃，dialogue → dialogue → end；
- `WUK-11-SEQUENCE`：天兵天将，dialogue → battle → after_battle → end；
- `WUK-12-SEQUENCE`：二郎神，dialogue → battle → after_battle → end；
- `WUK-13-SEQUENCE`：炼丹炉，dialogue → choice → end；
- `WUK-14-SEQUENCE`：大闹天宫，dialogue → battle → after_battle → end；
- `WUK-15-SEQUENCE`：五行山，dialogue → dialogue → end。

四场新增战斗直接引用现有 `WUKONG_ORIGIN_*` encounter：龙宫、天兵天将、二郎神、天宫；没有重复创建 Combat 领域。

更新 `combat/test_origin_event_sequences.gd`：
- 从只验证 WUK-01~03 改为执行全部 15 条 Wukong production Sequence；
- 验证所有 Sequence graph validate；
- 验证 5 个 Origin Battle handoff，并执行 snapshot → restore → victory resume；
- 验证 3 个 Choice Sequence 的真实选择提交和持久化；
- 保留 WUK-03 EventDefinition identity regression。

## Why
Shared Journey 已经证明 Sequence 可以成为统一的生产剧情执行格式。继续只保留 WUK-01~03 会让悟空路线前段进入两套系统：前三章走新链，后续仍走旧链。现在先把一条完整 Origin Route 做成垂直样板，后续复制到唐僧、白龙马、八戒、沙僧时可以直接复用同一迁移模式。

本轮没有改造 BattleResolutionService，也没有提前拆除 `BountyEncounterState`。战斗的业务结算与 Journey 恢复边界保持不变。

## Validation

此前基础线 Runtime #104 已对 docs/index 后的代码真实通过。

本轮第一次全 15 条 Origin regression 运行触发 Runtime #106：failure。项目导入、脚本注册、signature probe、EventRuntime、EventRunner 均通过，失败集中在新增 `test_origin_event_sequences.gd` 的 action-loop 控制流断言。

随后将该测试改成与已经验证过的 Shared production regression 相同的显式 `END` 节点处理模式，并重新提交。最终 Runtime 结果以最新 main 分支 workflow 为准；在该 workflow 完成前不得将本轮写成 Godot Runtime 已通过。

## Known issues

- Wukong 15 章现在已经进入统一 Sequence 数据层，但 `Journey Presentation` 仍使用现有基础演出；MOVE / WAIT / REWARD 的高级视觉表现尚未完善。
- Origin chapter 的实际持久化推进仍由 `origin_sequence_journey.gd` / `BattleResolutionService` 分工负责，Sequence 本身不承担章节完成副作用。
- Battle handoff 仍通过 `BountyEncounterState` 兼容层。
- 本轮只完成悟空完整路线，没有同时批量迁移其他四个角色。

## Next step
先以最新 Runtime 结果作为本轮收口依据；若通过，再把悟空路线的章节完成、战斗胜利后的 Origin chapter progression 做一次端到端检查，然后开始 Tang Origin 的第一段迁移，而不是立即同时迁移五条路线。

## Handoff point
当前主线最新代码包含 Wukong WUK-01~15 全部 EventSequence 数据，以及覆盖 15 条序列的 production regression。接手时首先查看最新 `Godot Runtime` workflow 和 `combat/test_origin_event_sequences.gd`，确认全路线 regression 后再继续。
