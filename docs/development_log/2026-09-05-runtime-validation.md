# 2026-09-05 — Godot Headless Runtime Validation

## 1. 本次目标

把项目的既有代码级回归测试提升为真实 Godot 4 headless SceneTree 执行，并让后续 Agent 能持续看到真实编译与运行结果。

## 2. 修改了什么

新增：

- `tests/runtime_suite.gd`
- `.github/workflows/godot-runtime.yml`

并修正了 Godot 4.5.1 实跑过程中暴露的脚本兼容问题：

- `scripts/narrative/event_runtime.gd`：移除 `NarrativeManager` 类型注解，避免 `NarrativeManager → OriginEventManager → EventRuntime` 全局类依赖环导致解析失败。
- `scripts/combat/encounter_manager.gd`：对 `_find_skill()` 返回值使用显式 `Variant`，避免 Godot 无法从无类型返回值推断局部变量。
- `scripts/narrative/shared_event_manager.gd`：对 JSON `events` 原始值使用显式 `Variant`。
- `combat/combatant.gd`：对布尔表达式局部变量使用显式 `bool`。

## 3. 为什么这样修改

第一次加入 CI 后，Godot 能成功安装并运行，但直接执行测试脚本时尚未注册项目 `class_name`，导致大量“Identifier not declared”。因此 workflow 增加了：

`godot --headless --path . --editor --quit`

先完成项目扫描与全局类注册，再运行测试套件。

第二次实跑进一步暴露了真正的 GDScript 解析问题。这里没有通过继续堆测试规避，而是修复脚本依赖和类型推断，使 Runtime Validation 本身也成为可靠的工程能力。

## 4. 当前测试入口

CI 使用 Godot 4.5.1：

`godot --headless --path . --script res://tests/runtime_suite.gd`

当前 suite 收集：

- `combat/test_chapter_runtime.gd`
- `combat/test_event_runtime.gd`
- `combat/test_event_runner.gd`
- `combat/test_shared_journey_battles.gd`
- `combat/test_battle_resolution_service.gd`

注意：这些测试文件内部目前是 `run_all()` 风格；它们覆盖核心状态转换，但还不是完整 UI / Scene interaction 测试。

## 5. 实跑结果

第一次 CI run 在全局类注册之前失败；第二次完成注册后暴露 GDScript 解析错误；随后已修复对应问题并触发新一轮 CI。

最终结果必须以最新 workflow run 为准。本日志提交时不宣称尚未观察到的绿色结果。

## 6. 重要边界

当前 headless runtime validation 不等价于完整游戏体验测试。它可以验证：

- 项目脚本能被 Godot 解析；
- 核心 Runtime 测试可被 Godot 执行；
- 状态转换与部分战斗流程没有编译级阻塞。

它暂时不能替代：

- Journey UI 手动操作；
- Battle UI 完整交互；
- 输入、动画、镜头、VFX、音频；
- 完整 EventRunner → BattleUI → BattleResolutionService → EventRunner 的真实场景回归。

## 7. 当前已知架构问题

1. `ui/battle_ui.gd` 仍保留一套 origin/shared 战斗胜利逻辑，与 `BattleResolutionService` 有重复职责。
2. `EventRunner` 的 battle action 尚未在真实 Journey / Battle UI 中恢复同一个 Runner 实例。
3. `BountyEncounterState` 仍是旧兼容持久化层，尚未存储 EventRunner resume context。
4. Reward node 仍只发出 action，不负责直接写 Inventory。

这些问题不在本批通过增加临时代码解决，以避免重新制造职责耦合。

## 8. 下一步

Batch 1B 的核心目标仍是：

`Journey / Event UI → EventRunner → EncounterHandoff → BattleUI → BattleResolutionService → resume EventRunner → 后续剧情`

并在真实 Godot SceneTree 中建立最小可操作 Vertical Slice。

## 9. 接手 Agent 起点

优先查看：

- `AI_HANDOFF.md`
- `docs/content_pipeline.md`
- `.github/workflows/godot-runtime.yml`
- `tests/runtime_suite.gd`
- `scripts/narrative/event_runner.gd`
- `scripts/narrative/encounter_handoff.gd`
- `ui/journey.gd`
- `ui/battle_ui.gd`
- `scripts/world/battle_resolution_service.gd`

不要在 Runner 内加入 UI 或 CombatEngine 逻辑；下一步应解决恢复上下文与真实场景接线。
