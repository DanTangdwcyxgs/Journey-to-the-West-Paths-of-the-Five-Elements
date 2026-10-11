# AI / Agent 接管说明

## 0. 你正在接手什么

这是一个 Godot 4 开发的中文像素 HD-2D 回合制 JRPG。

**游戏名：西游：五行之路（Journey to the West: Five Elements Road）**

核心定位：**可玩的《西游记》故事第一，原创 JRPG 第二。**

视觉语言：像素角色 + HD-2D / 2.5D 环境 + 中国神话建筑与自然景观 + 动态光照 + 回合制 JRPG 战斗。

项目不是“使用西游角色做一款普通原创 RPG”。西游记的经典人物关系、主要地点、招募顺序、重大事件和取经目的必须始终是主线骨架。

---

## 1. 接手时必须先读什么

按以下顺序阅读，禁止跳过：

1. `AI_HANDOFF.md`（本文件）
2. `DEVELOPMENT_RULES.md`
3. `README.md` / `README.zh-CN.md`
4. `docs/game_vision.md`
5. `docs/architecture.md`
6. `docs/production_rules.md`
7. `docs/content_pipeline.md`
8. `docs/five_start_route_chapter_bible.md`
9. 与当前任务直接相关的代码和数据文件
10. `docs/development_log/` 中最新的一条更新记录

如果这些文件之间存在矛盾，以：

`DEVELOPMENT_RULES.md` → `game_vision.md` → `architecture.md` → 最新明确确认的实现状态

为优先级。

---

## 2. 不允许的接手方式

不要看到某个 TODO 就立即写代码。

先回答：

- 这个功能属于 Domain / Content / Narrative / Presentation 哪一层？
- 是否已经有现成 Manager / Service / Runtime 可以复用？
- 是否会破坏固定世界时间线？
- 是否会重复发奖励、重复推进章节或重复保存？
- 是否会让某个系统直接修改另一个系统的内部状态？
- 是否已经存在一个兼容旧系统的迁移层？

如果发现需求与当前架构存在根本冲突，必须先指出问题并选择更优方案，不得为了“完成任务”而制造技术债。

---

## 3. 核心叙事规则

### 玩家顺序自由，世界顺序固定

玩家可以选择五人任意一人作为新游戏起点：

- 孙悟空
- 唐三藏
- 猪八戒
- 沙悟净
- 白龙马

但世界历史只有一条。

选择角色只是选择第一视角，不代表西游历史被重新排列。

### 五条个人路线

每个角色都有自己的 Origin Route，最终在该角色的经典西游节点汇入共享时间线。

### 招募是故事事件

角色不是因为等级够了就加入，而是在对应经典故事节点中真正加入。

大方向：

悟空被镇压 → 唐僧开始取经 → 五行山释放悟空 → 白龙马加入 → 高老庄收八戒 → 流沙河收悟净 → 五人完整西行。

### 个人故事不会消失

角色被招募后，其个人历史立即解锁，可作为 Memory / Flashback 继续体验。

Memory 不得回写并篡改已经确定的当前世界时间线。

---

## 4. 五位主角主题

- 悟空：自由 vs 束缚
- 唐僧：信仰 vs 现实
- 八戒：欲望 vs 责任
- 悟净：罪责 vs 救赎
- 龙马：身份 vs 使命

战斗机制应服务于人物性格，而不是为了系统数量而增加系统。

---

## 5. 当前核心架构

### Domain

纯规则：

- `Combatant`
- `CombatEngine`
- `CombatAction`
- Weakness / Shield / Break
- BP / Boost
- SPD / Turn Order
- Status Effects
- Formation

### Content

数据驱动：

- `data/narrative/`
- `data/combat/`
- `data/world/`
- `data/items/`
- 技能、敌人、章节、事件、地图、奖励等

### Narrative

- `NarrativeState`
- `NarrativeManager`
- `OriginRouteManager`
- `SharedJourneyManager`
- `ChapterDefinition`
- `ChapterRuntime`
- `EventDefinition`
- `EventRuntime`
- `EventSequenceDefinition`
- `EventSequenceManager`
- `EventRunner`
- `NarrativeEventSession`
- `OriginEventManager`
- `SharedEventManager`
- `StartRouteCatalog`
- `BattleResolutionService`

### World / Handoff

- `EncounterHandoff`
- `BountyEncounterState`（兼容旧入口，并承载 EventSession resume context）
- World Map / Travel / Rumor / Bounty
- Dungeon / Checkpoint

### Presentation

- Journey UI
- Battle UI
- World Map
- Dungeon / Cave UI
- Camp UI（后续）

Presentation 不应自行决定核心剧情、奖励或战斗规则。

---

## 6. 当前核心运行链

### 剧情章节

`Content Data → ChapterDefinition → ChapterRuntime → EventSequence/EventRunner → EventRuntime / Combat / World → Presentation`

### 单次事件选择

`Event Data → EventDefinition → EventRuntime → NarrativeState`

### 多段事件

`Event Sequence JSON → EventSequenceManager → EventSequenceDefinition → EventRunner → NarrativeEventSession → action request`

当前标准 action：

- `dialogue`
- `choice`
- `wait`
- `move`
- `battle`
- `reward`
- `jump`
- `end`

Runner 输出的 `battle` 只生成 `EncounterHandoff` 数据，不直接启动 BattleUI。

### 事件与战斗的真实桥接

当前已建立并通过 Godot Runtime CI 验证的推荐链：

`Journey → NarrativeEventSession → EventRunner → EncounterHandoff(+event_resume) → BattleUI → BattleResolutionService → NarrativeEventSession.resume → Journey`

`BountyEncounterState` 目前仍是场景间兼容持久化实现，但其内容已经可以承载 `event_resume`，因此事件会话可以跨场景恢复；后续再把该兼容层逐步替换为更明确的通用 Scene Handoff Service。

### 战斗结果原则

一次胜利必须做到：

`预检 → 奖励预览 → 状态变更 → 剧情推进 → 世界效果 → 最终一次 Save`

任何中途失败都应回滚。

---

## 7. 当前已完成的主要能力

- 五人独立起始路线架构
- 固定全球时间线
- Origin / Shared 双叙事结构
- 招募和个人故事解锁
- Memory 数据基础
- 3 前排 / 2 后排队形
- 保存 / 读取队伍与编队
- HP / ATK / DEF / SPD / BP
- Weakness / Shield / Break
- Speed / Slow / Taunt
- Data-driven Skills
- 五人专属机制基础
- 龙马临时变身
- Inventory / Consumables
- Equipment / Loadout
- World Map / Travel
- Rumor / Bounty
- 黄风岭 / 黄风洞灰盒探索链
- 三场共享招募战：鹰愁涧、高老庄、流沙河
- Encounter AI
- Shared chapter atomic rollback
- Battle reward preview
- Unified BattleResolutionService
- Narrative BattleUI victory integration
- 招募战奖励去重
- ChapterDefinition / ChapterRuntime
- 中立 EncounterHandoff 兼容层
- EventDefinition / EventRuntime
- Origin / Shared 事件选择统一执行入口
- EventSequenceDefinition 图结构验证
- EventRunner 多节点执行与状态恢复
- NarrativeEventSession 事件会话编排与战斗恢复上下文
- EventSequenceManager 数据驱动序列加载
- 首条真实共享剧情序列：`SHARED-03-EAGLE-SORROW-SEQUENCE`
- Journey UI 接入该序列
- Narrative BattleUI 可保存并恢复 EventSession 上下文
- Godot 4.5.1 headless runtime CI
- 当前 CI 已连续验证 EventRunner、EventSession、Shared Battle、BattleResolution 等核心回归
- 内容批量生产规范
- 项目对外中文品牌 / 投资人入口 / AI 接管文档
- 五条 Origin Route 均已有独立 EventSequence 数据链：Wukong / Tang / Longma / Bajie / Wujing
- Wujing Origin 8 章：2 个 choice、2 个 production battle、Save/Load checkpoint regression

---

## 8. 当前主要未完成项

最高优先级：

1. 视觉垂直切片仍是产品目标，但角色最终 PNG/WebP 暂受图像生成额度限制；不把概念展示图当正式资源。Main Menu → WUK-02 real battle → BattleResolutionService → Journey resume → END / Save 真实 SceneTree smoke 已通过，Godot Runtime 35/35；Web Demo build + deploy 也已通过。修复包含战斗恢复不重复推进与 END 后 active / pending resume 文件清理。当前继续推进其他框架切片，额度恢复后再做角色资产垂直切片。
2. 增强 Main Menu → Journey → EventSequence → Battle / END → Save 的 SceneTree 入口和恢复 smoke coverage。
3. 五条 Origin Route 的 EventSequence 迁移、统一质量门和 Origin → Shared handoff 已有实现；后续发现新 cross-reference / route-isolation 缺口时按具体回归补强。
4. 非战斗 reward / move / wait 的副作用继续留在 RewardService / WorldActionService，不得移入 EventRunner。
5. 逐步清理 BattleUI 旧 origin/shared 兼容结算职责与 BountyEncounterState，但不得破坏现有 Handoff + Resolution 兼容链。
6. 当前核心叙事与恢复链稳定后推进 Camp / Relationship Prototype。
7. 完成一个从角色起始路线到白龙马招募与 Memory 的完整 Vertical Slice。

---

## 9. 当前已知架构注意事项

### EventRunner

- UI 无关；不要在 Runner 内创建 Control / Scene / BattleUI。
- Battle 节点只生成 Handoff。
- `END` 节点是终态；`runner.is_finished()` 在呈现 END 时必须为 true。
- `choice` 使用 EventRuntime 持久化，不允许重复执行同一 namespace 下相同 event choice。

### Reward

- 当前 `reward` node 只产生 action，不直接修改库存。
- 战斗奖励由 `BattleResolutionService` 原子处理。
- 后续必须新增通用 `RewardService` 或明确的非战斗奖励服务，再让 reward node 委托它；不要在 EventRunner 里写库存副作用。

### Save / Resume

- EventSession 的 runner snapshot 可以跨 BattleUI / Journey scene。
- 当前 resume context 放在 `user://active_bounty.json` 兼容层；不要把 UI scene 引用序列化进去。
- NarrativeState 仍是世界事实的权威源，session 只是未完成表现流程。

### Sequence Content Quality Gate

当前 `EventSequenceDefinition.validate()` 已检查结构和图连接，但还没有完全检查：

- choice node 对应的 event 是否存在；
- battle node 对应的 encounter 是否存在；
- source_chapter_id 是否与 chapter data 一致；
- namespace 是否与章节类型一致。

后续应把这些升级为内容 CI 的 cross-reference validation，而不是靠 UI 运行时发现。

---

## 10. Godot Runtime 验证状态

最近一次已完成的关键验证：

- Godot：4.5.1 stable
- 项目脚本导入：通过
- GDScript signature parser probe：通过
- EventRuntime direct check：通过
- EventRunner direct check：通过
- headless runtime suite：通过
- EventRunner graph / choice / battle resume / END：通过
- NarrativeEventSession handoff / resume：已加入 suite

历史 CI 编号 #156 / #162 属于早期快照，不代表当前 main 的状态。较新的 `docs/development_log/2026-09-07-battle-reward-party-loop.md` 记录了 Runtime #279 的旧 head 失败及修复后的待验证状态；开始新工作时必须针对最新提交 SHA 检查 Actions，不能把历史成功记录当作当前通过证明。

不要把“代码看起来正确”写成“Godot Runtime 已通过”；必须以实际 CI 结果为准。

---

## 11. 下一位 Agent 的推荐工作顺序（2026-10-10 刷新）

### Batch A — Visual Vertical Slice

2026-10-11 视觉分层、Journey END、CJK 字体回退、节点树释放、有限 WAV 音效与 Main Menu → Journey → WUK-01 入口 smoke 已通过 Runtime/Web Demo；Runtime suite 34 tests。针对完整 Battle → resume → END/Save 新增 Main Menu → WUK-02 SceneTree 回归，等待本提交 CI 验证。角色正式 PNG/WebP 仍受图像生成额度限制，暂不把概念图作为正式素材。

### Batch B — Journey Presentation & Runtime

Journey END / chapter-completion feedback 与 Main Menu → WUK-02 battle / resume / END / Save 场景链已通过 Runtime；下一步继续验证失败恢复、battle rollback / retry 与 Shared 招募战的真实场景链，再进入 Camp / Relationship Prototype。

继续检查 Battle → EventSession resume → Journey 的真实 SceneTree 链路、Save/Load、重复结算保护和失败恢复。所有改动都需要对应 regression 与本提交 SHA 的 Actions 验证。

### Batch C — Narrative execution services

评估非战斗 reward / move / wait 的统一执行入口；副作用留在 Service，不能塞进 EventRunner。WorldActionService 已是 MOVE / WAIT 执行边界，应在扩展前复用现有能力。

### Batch D — Vertical Slice

以一条完整角色起始路线 + 五行山 + 鹰愁涧 + 白龙马招募 + 对应 Memory 为样板，串起剧情、探索、招募、战斗、奖励和存档。

### Batch E — Camp / Relationship

等叙事和战后恢复链稳定后再扩展营地与人物关系，避免同时扩大多个系统。

---

## 12. 每次提交都必须留下什么

每个有意义的实现批次至少更新：

- 代码 / 数据
- 对应回归测试
- 必要架构文档
- `docs/development_log/` 最新开发日志
- `AI_HANDOFF.md`（若当前状态 / 优先级 / 架构发生变化）
- README（若公共能力变化）

日志必须写清：

- Goal
- What changed
- Why
- Systems affected
- Files
- Tests
- Godot Runtime status
- Known issues
- Next step
- Handoff point

---

## 13. 一句话原则

**章节描述发生什么，Runtime 决定怎么执行，NarrativeState 保存事实，Presentation 只负责表现。**

---

## 14. 2026-09-05 当前批次接管快照

### 已完成

- Wujing / 沙悟净 Origin Route 的 `WUJING-01` → `WUJING-08` 已全部迁移到 `data/narrative/event_sequences_origin.json`。
- `WUJING-02` 使用生产 choice event `WUJING-02`。
- `WUJING-03` 使用生产 encounter `WUJING_ORIGIN_FLOWING_SANDS`。
- `WUJING-06` 使用生产 choice event `WUJING-06`。
- `WUJING-07` 使用生产 encounter `WUJING_ORIGIN_BODHISATTVA`。
- 新增 `combat/test_wujing_origin_event_sequences.gd` 与 `combat/test_wujing_origin_progression.gd`。
- `tests/runtime_suite.gd` 已接入 Wujing 两项回归。
- `docs/development_log/2026-09-05-wujing-origin-sequence-migration.md` 已记录本批次。

### 历史验证（仅截至 2026-09-05）

- 当时 Godot Runtime #162 的导入/注册阶段正在执行，最终结果需当时的接手者另行核验。该记录不是当前提交的验证状态。

### 后续状态（已取代本快照中的待办）

- 五路线统一质量门与 Origin → Shared handoff 回归已在后续开发日志中完成并登记。
- Shared-03 至 Shared-09 EventSequence 和相关招募战桥接也已有后续实现与回归。
- 当前工作及最新验证以第 15 节和最新开发日志为准。

## 15. 2026-10-10 Battle Victory Feedback Snapshot

### Current batch
- Battle victory feedback has a dedicated presentation lock so a post-combat refresh cannot replace the result summary.
- The summary surfaces outcome, rewards, and a next-step instruction; the return button label reflects the next destination.
- NarrativeBattleUI distinguishes successful EventSession battle resume from a general return to the Origin / Shared route.
- combat/test_shared_battle_journey_bridge.gd asserts reward display, next-step guidance, button label, and summary persistence across all three shared recruitment battles.

### Validation gate
- Implementation commit 5c0cb1d4c91434fbd475e71aa8dd3e6e8c321209 initially failed the overly-specific next-step assertion.
- Correction commit 7ae2e6f41c627892ab3beb1533e8b0923081e12a passed Godot Runtime run 38042589835; log reported RUNTIME_SUITE_PASS tests=31.
- The suite still logged a missing-font diagnostic and Resource/RID teardown warnings. Those did not fail the run, but should be tracked separately.

### Handoff
Battle resolution remains service-owned. Victory-result presentation is completed for this slice; MOVE / WAIT feedback is the active follow-up documented in section 16.

## 16. 2026-10-10 Journey MOVE / WAIT Presentation

### Implementation
- MOVE now has a dedicated Journey phase, destination map/marker text, a 前往 button, and a short travel transition.
- WAIT explains the pause, surfaces the effective duration, and provides a clear Continue action; the transition state disables the primary button to prevent duplicate completion.
- NarrativeEventSession completion still triggers the existing WorldActionService side-effect boundary; EventRunner remains presentation-independent.
- Regression extended in combat/test_journey_event_presentation.gd for MOVE and WAIT wording/action state.

### Validation gate
- PASS: implementation commit ec58f239dfe46a2204727be142dfdc5717de0a70, runtime run 38042773314; RUNTIME_SUITE_PASS tests=31. The run emitted a missing-font diagnostic and Resource/RID teardown warnings that did not fail the suite.

### Next handoff
Next implement END / chapter-completion feedback and regression, one presentation slice at a time.
