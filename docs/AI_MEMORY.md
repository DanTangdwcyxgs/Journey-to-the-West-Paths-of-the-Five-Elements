# AI Project Memory Ledger

> 项目长期 AI / Agent 工程记忆。记录架构、事实、验证结果、边界和接手点，不依赖聊天历史。

---

## 0. 永久工作规则

### 0.1 记忆原则
每轮实际仓库操作都必须留下可恢复记录：做了什么、为什么、实际修改、测试/真实运行结果、已知问题、下一步、接手点。

### 0.2 验证原则
静态检查 ≠ Godot Runtime。只有真实 Godot workflow 成功才能写“Godot Runtime 通过”。`pending`、`statuses: []` 或无 workflow result 均只能写未确认。

### 0.3 引擎基准
**Godot 4.5.1 stable**。

### 0.4 架构原则
`Content Data → ChapterDefinition → ChapterRuntime → EventSequence/EventRunner → EventRuntime / Combat / World → Presentation`

Runner 只负责流程，不负责 UI 和业务副作用；NarrativeState 保存世界事实；Service 承担库存/世界/战斗等副作用；Presentation 负责演出。

### 0.5 固定西游时间线
玩家可以从五人任意角色视角开始，但世界历史不能被玩家顺序重排：
`悟空被镇压 → 唐僧开始取经 → 五行山释放悟空 → 鹰愁涧白龙马 → 高老庄八戒 → 流沙河悟净 → 五人完整西行`

Memory / Flashback 只能历史回放，不得回写当前世界事实。

### 0.6 渐进迁移
旧入口可保留为兼容层；新能力优先接入统一架构，不为“重构干净”一次性重写全部章节。

### 0.7 每轮流程
`实现 → 回归测试 → 真实 Godot Runtime（适用时）→ development log → AI_MEMORY Round → 必要时更新 AI_HANDOFF`

---

## 1. 项目定位

游戏：`西游：五行之路（Journey to the West: Five Elements Road）`

核心原则：**可玩的《西游记》故事第一，原创 JRPG 第二。**

技术方向：Godot 4 + 像素角色 + HD-2D / 2.5D 环境 + 回合制 JRPG。

结构：五条 Origin Route → 经典招募节点 → Shared Journey。

---

## 2. 当前稳定核心链路

### 2.1 Event Sequence
`Event Sequence JSON → EventSequenceManager → EventSequenceDefinition → EventRunner → NarrativeEventSession → action`

支持 action：`dialogue / choice / wait / move / battle / reward / jump / end`。

### 2.2 Battle Handoff
`Journey → NarrativeEventSession → EventRunner → EncounterHandoff(+event_resume) → BattleUI → BattleResolutionService → NarrativeEventSession.resume → Journey`

战斗胜利边界：预检 → 奖励预览 → 状态变更 → 剧情推进 → 世界效果 → 最终 Save；失败需回滚。

### 2.3 非战斗副作用
- `RewardService`：统一 narrative reward 库存副作用；
- `WorldActionService`：统一 `move / wait`；
- `EventRunner` 不直接实现上述业务。

### 2.4 Scene Handoff
`BountyEncounterState` 当前仍承担兼容 handoff 与 EventSession resume context。未来可逐步收敛成通用 Scene Handoff Service，但目前不要为此破坏兼容链。

---

## 3. 历史工作事实

### Round 01 — 五人起始路线与固定时间线
建立五人可选起点、Origin / Shared 双结构和固定世界时间线。

### Round 02 — Combat Domain
建立 `Combatant / CombatEngine / CombatAction`，含 HP、ATK、DEF、SPD、BP、Weakness、Shield、Break、Status、Formation。

### Round 03 — 五人机制与队伍
加入五人基础差异、队伍保存读取、装备和消耗品，形成 3 前排 / 2 后排基础。

### Round 04 — World / Rumor / Bounty
建立 World Map / Travel / Rumor / Bounty 与黄风岭 / 黄风洞灰盒探索。

### Round 05 — 三场共享招募战
建立鹰愁涧、高老庄、流沙河三场共享招募战及 Encounter AI、招募与 Shared chapter 基础。

### Round 06 — Shared 原子结算
统一 `BattleResolutionService`，使战斗奖励、章节推进、世界效果和保存处于原子边界。

### Round 07 — EventDefinition / EventRuntime
事件选择数据驱动，选择状态持久化，统一 Origin / Shared 选择执行入口。

### Round 08 — EventSequenceDefinition / Validator
建立多节点 Sequence 数据结构和 graph/cross-reference 校验。

### Round 09 — EventRunner
建立 UI-independent Runner，支持 dialogue/choice/wait/move/battle/reward/jump/end 与 snapshot。

### Round 10 — NarrativeEventSession
建立跨 Journey / BattleUI 的 `event_resume`，战斗成为剧情中的 action。

### Round 11 — Godot Runtime Infrastructure
建立 GitHub Actions Godot 4.5.1 headless runtime workflow，覆盖项目导入、脚本 probe、核心 Runtime 和战斗恢复。

### Round 12 — Action → Service / Handoff
明确 Runner 只请求动作，Reward / World / Battle 由 Service 或 Handoff 执行。

### Round 13 — RewardService
建立统一 narrative reward service 与 regression test。

### Round 14 — WorldActionService
建立统一 `move / wait` service 与 regression test。当前 `move` 记录逻辑地点/visited node；`wait` 不推进独立世界时钟。

### Round 15 — Journey Presentation / SceneTree
`ui/journey.gd` 增加真实 SceneTree UI：DialoguePanel / Speaker / Text / Hint / EventMeta、逐字显示、点击立即显示、WAIT 过渡、BATTLE handoff、Choice UI；新增 Journey presentation runtime test。

### Round 16 — Shared-04 EventSequence
加入 `SHARED-04-EARLY-DEMON-TALES-SEQUENCE`。发现 sequence reward 与 chapter reward 会双发，已移除 sequence reward，chapter reward 成为唯一来源。

### Round 17 — AI 持久记忆系统
建立本文件与 development log 体系，要求每个实际仓库工作轮次同步记录。

### Round 18 — Shared-05 / Shared-06 Migration
加入：
- `SHARED-05-GAOJIAZHUANG-SEQUENCE`: arrival → choice → battle → after_battle → end；
- `SHARED-06-FOUR-PERSON-JOURNEY-SEQUENCE`: depart → wait → resolve → end。

### Round 19 — Shared-07 / Shared-08 / Shared-09 Migration
加入：
- `SHARED-07-FLOWING-SANDS-SEQUENCE`: river → choice → battle → after_battle → end；
- `SHARED-08-PARTY-FULL-SEQUENCE`: gather → choice → oath → end；
- `SHARED-09-FULL-PILGRIMAGE-SEQUENCE`: departure → end。

Shared-03 至 Shared-09 主体 Sequence 数据迁移完成。

### Round 20 — Godot 4.5.1 Journey Parse Fix
Godot Runtime #75 首次真正执行 Shared-03 至 Shared-09 相关回归时，`ui/journey.gd` 出现三处 warning-as-error Variant 类型推断问题：
- `_process()` `target` → `int`；
- `_process()` `added` → `int`；
- `_start_event_transition()` `seconds` → `float`。

修复提交：`641aac770c063eebf00f477df8443a32f60d0938`。

实际 Runtime #75：failure；Godot 4.5.1、项目导入、signature probe、EventRuntime、EventRunner 及前 10 个 suite 测试通过，失败集中在 Journey presentation compile。

随后 Runtime #76 对修复后的代码真实通过，`RUNTIME_SUITE_PASS tests=11`。

### Round 21 — Shared Production Sequence Runtime Regression
新增 `combat/test_shared_event_sequences.gd`，直接读取生产 `data/narrative/event_sequences.json`，把 Shared-03 至 Shared-09 七条生产 Sequence 真正送入 `EventSequenceManager → EventRunner` 执行。

覆盖：
- Dialogue / Choice / Wait / Move / Battle / End 实际推进；
- 3 条 Battle Sequence 的 encounter id 校验；
- Battle runner snapshot → restore → victory resume；
- Shared-04 的 MOVE 写入 `BLACK_WIND_NORTH_PATH` world state；
- 7 / 7 Sequence 进入 finished。

首次实现触发 Runtime #81：新测试自己的 control-flow bug，在 action loop 内过早断言 `runner.is_finished()`；不是生产代码失败。修正后重新运行。

Runtime #82：**success**。

真实结果：
- Godot `4.5.1.stable.official.f62fdbde1`；
- `RUNTIME_SUITE_PASS tests=12`；
- 7 / 7 production Shared Sequence 执行通过；
- 3 / 3 battle handoff + snapshot/restore/resume 通过；
- 1 / 1 MOVE world-state side effect 通过；
- 原有 Chapter / Event / Reward / World / Battle / Journey Presentation tests 全部继续通过。

当前稳定基线：`0af166f30cf3bac59a41fce574b93c80e0124a24`（随后仅有文档记录提交）。

---

## 4. Shared Journey 当前数据边界

`data/narrative/shared_chapters.json` 为章节事实来源：
- Shared-03 Longma recruitment / `SHARED_EAGLE_SORROW` / timeline 110；
- Shared-04 reward HERB / timeline 120；
- Shared-05 Bajie recruitment / `SHARED_GAOJIAZHUANG` / timeline 130；
- Shared-06 reward HERB / timeline 140；
- Shared-07 Wujing recruitment / `SHARED_FLOWING_SANDS` / timeline 150；
- Shared-08 party convergence / reward HERB / timeline 160；
- Shared-09 final pilgrimage / reward COIN_MEDIUM / timeline 170。

Sequence **不得复制 chapter reward**，避免重复经济结算。

`SharedJourneyManager.complete()` 是 canonical shared progression：
- combat chapter 必须先存在 `SHARED_BATTLE_<encounter_id>` milestone；
- non-combat chapter 由 chapter definition 发 reward；
- complete chapter、推进 timeline、apply recruit/world effects、设置 next chapter、可选 save；
- 后续失败必须 rollback。

`JourneyScreen._finish_event_session()` 当前规则：
- non-battle sequence 且 current shared chapter 仍等于 sequence chapter → 在 END 完成章节；
- battle sequence → 跳过重复 completion，因为 `BattleResolutionService` 已经完成 source chapter。

---

## 5. 当前任务地图

### P0 — Journey SceneTree 完整化
下一步优先：
1. 强化 MOVE 的视觉/状态反馈；
2. 强化 WAIT 的过渡表现；
3. END / chapter completion feedback；
4. 保持 Battle → BattleUI → Resume → END 边界不重复结算；
5. 必要时增加对应 SceneTree regression。

已知限制：MOVE 仍无角色路径动画；WAIT 不推进独立世界时钟；Battle handoff 仍经 `BountyEncounterState`。

### P1 — Origin Migration
Shared-03 → Shared-09 Sequence 迁移完成后，逐角色逐章把 Origin Route 迁移到 EventSequence，必须保持固定世界时间线和经典招募节点。

建议顺序：先选择一个完整起始角色路线做 Vertical Slice，再扩大到其余角色，避免一次性迁移五条路线。

### P2 — Cleanup / Convergence
逐步收敛旧 BattleUI 结算职责与 `BountyEncounterState`，但不能提前破坏现有兼容链。

### P3 — Camp / Relationship
叙事主链稳定后进入 Camp / Relationship prototype。

### P4 — Vertical Slice
目标：`一个完整角色起始路线 → 五行山 → 鹰愁涧 → 招募 → 对应 Memory`。

---

## 6. 接手点

当前应从主分支最新提交开始检查，优先阅读：
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-09-05-shared-sequence-runtime-regression.md`
- `ui/journey.gd`
- `scripts/narrative/event_runner.gd`
- `scripts/narrative/narrative_event_session.gd`
- `scripts/narrative/shared_journey_manager.gd`

任何下一轮修改继续执行：
`实现 → regression → Godot Runtime → development log → AI_MEMORY Round`。
