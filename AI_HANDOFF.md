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

1. 第一条完整可玩 Vertical Slice 仍需补齐探索/区域进入与最终角色正式 PNG/WebP 资产。图片资产仍受生成额度限制，不把概念展示图当正式资源。
2. Wukong WUK-15 END → Shared-01 交接与失败回滚、Memory 只读播放和白龙马实际招募解锁均已通过 Runtime/Web Demo。
3. 主线地图的五个明确位置——五行山、鹰愁涧、黑风山北道、高老庄、流沙河——均已加入 Shared EventSequence 的 Story MOVE；最新位置提交 `584db9e18ddd3d0a850f2779e9d1acb2e255b880` 通过 Runtime 42/42 与 Web Demo build/deploy。
4. Shared-01 → Shared-02 → Shared-03 白龙马战斗 → Shared-04 的单存档生产 UI smoke 已在提交 `7b1b08a83448419f9cbd867cd15b7dd1f5905a06` 通过 Runtime run [38118079231](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38118079231)（43/43）与 Web Demo run [38118079238](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38118079238) build/deploy。可选黄牙悬赏后从 WorldMap → 返回行程 → Shared-05 高老庄对白/MOVE 的同存档回归已在精确提交 `cf4fde67159f14b5deaf99367f705cb9a8adc8c3` 通过 Runtime [38118968437](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38118968437)（43/43）与 Web Demo [38118968395](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38118968395) build/deploy。自由 WorldMap travel 的保存失败回滚已在精确提交 `d82a8be8a05b7c18f699f3956c4dcc031819ba25` 通过 Runtime [38119239984](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38119239984)（44/44）与 Web Demo [38119240011](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38119240011) build/deploy。WUK-15 真实 END → Shared-01 → Shared-02 → Shared-03 Longma 招募战 → LONGMA-02 Memory 回放/保存重载 → Shared-04 的单存档生产 UI 垂直切片已在精确提交 `b4aa8ef0515354d12705cedd5715bd5321415e30` 通过 Runtime [38119684898](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38119684898)（44/44）与 Web Demo [38119684880](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38119684880) build/deploy。下一步由框架验证转向切片体验节奏、互动探索与正式视觉资产评审。 黄风岭/黄风洞支线的管理器入口、前置阶段锁、洞口 gate 与保存失败回滚已在精确提交 `30f727d181df9b056c2abfb5e8731dcdd2e45840` 通过 Runtime [38120240661](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120240661)（45/45）与 Web Demo [38120240657](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120240657) build/deploy。洞内普通遭遇 → 生产 BattleUI 胜利 → 恢复黄风妖王殿 → 妖王胜利 → 返回安全出口 → 返回黄风岭 的真实 SceneTree 回归已在精确提交 `a552810c769bb2d0725a0edd4fade92a5386c2f0` 通过 Runtime [38120481337](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120481337)（46/46）与 Web Demo [38120481282](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120481282) build/deploy。悬赏结算原子性已在精确提交 `3fd65d9f16453b6cb104ca249b4a87859e47895c` 通过 Runtime [38120711220](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120711220)（47/47）与 Web Demo [38120711189](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120711189) build/deploy。新增回归确认失败后 NarrativeState 与 BountyManager 完整回滚，成功重试只提交一次奖励/日志。生产 BattleUI 的“重试结算”实际点击回归已通过精确实现 SHA `11ed7f160e3c7cf2dd8e6f6140b95aae1df18541` 的 Runtime run [38129703559](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38129703559)（48/48）。PR #23 已合并为 main commit `79442c064362385afc41201a8458bf39efa9b199`；主分支 Runtime run [38129867693](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38129867693) 再次通过 48/48，Web Demo run [38129867663](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38129867663) build/deploy 均成功，地址为 https://dantangdwcyxgs.github.io/Journey-to-the-West-Paths-of-the-Five-Elements/；详见新增 development log。
5. 五条 Origin Route 的 EventSequence 迁移、统一质量门及 namespace 元数据一致性已有实现；新增 cross-reference / route-isolation 缺口按具体回归补强。
6. 非战斗 reward / move / wait 的副作用继续留在 RewardService / WorldActionService，不得移入 EventRunner。
7. Origin → Shared、WorldMap travel、可选悬赏与 Memory 主流程稳定后，再推进 Camp / Relationship Prototype。

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

- `EventSequenceDefinition.validate()` 检查结构：节点 ID、节点类型、起点与图连接。
- `EventSequenceValidator.validate()` 检查跨内容引用：namespace 仅允许 ORIGIN / SHARED；sequence chapter 必须存在于对应的 Origin Route / Shared Journey 内容；choice event 必须存在于匹配的事件目录；battle encounter 必须存在；battle source chapter 必须与 sequence chapter 一致；Shared encounter 必须匹配章节的 canonical encounter；Origin battle 的 route 与 encounter source 必须匹配所属路线。
- Validator 同时检查章节中显式提供的 namespace 元数据：SHARED 章节不能声明为 ORIGIN、`is_origin=true` 或 `is_shared=false`；ORIGIN 章节不能声明为 `SHARED_JOURNEY`、`is_origin=false` 或 `is_shared=true`。Shared chapter 的 `RECRUITMENT` 与 `INTERLUDE` 属于有效类型，不会被误判为 ORIGIN。
- Legacy `origin_chapters.json` 目前未提供 `chapter_type` / `is_origin` / `is_shared`；对于这些记录，Origin Route 目录归属仍是权威来源。缺失 legacy 字段本身不视为冲突。
- `EventSequenceManager` 会拒绝无效序列，并通过 `get_load_errors()` 暴露被拒绝的项目与重复 ID。全 production catalog 校验已包含在 Runtime regression 中。

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

## 11. 下一位 Agent 的推荐工作顺序（2026-10-11 刷新）

### Batch A — Visual Vertical Slice

2026-10-11 视觉分层、Journey END、CJK 字体回退、节点树生命周期、有限 WAV 音效、Main Menu → Journey → WUK-01 smoke，以及 Main Menu → WUK-02 Battle → resume → END/Save smoke 均已通过 Runtime/Web Demo（已确认稳定主线 suite 为 35 entries）。角色正式 PNG/WebP 仍受图像生成额度限制，暂不把概念图作为正式素材。

### Batch B — Journey Presentation & Runtime

MainMenu / Origin battle resume、Origin final END → Shared-01 + rollback、EventSequence content/namespace quality gates、Memory read-only playback + recruitment integration、Shared-04 MOVE → WorldMap + save-failure retry、WorldMap rumor → optional bounty → return、五个主线 Story MOVE 均已通过精确 SHA Runtime/Web Demo。五个主线位置提交 `5e0e11ca890e1469e8b88fd2121c55c10e6f32d4` 的 Runtime [38117827110](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117827110) 42/42，Web Demo [38117827051](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117827051) build/deploy 通过。当前补一条同一存档从 Shared-01 连续走到 Shared-04、经真实白龙马战斗返回的 production SceneTree smoke，本批精确 SHA CI 待验证。

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


## 17. 2026-10-11 Production BattleUI Bounty Settlement Retry

### Implementation
- Added a deterministic NarrativeManager injection seam to BattleUI; the normal gameplay path still constructs a fresh NarrativeManager.
- Added `combat/test_battle_ui_bounty_settlement_retry.gd` and registered it in the Runtime suite. The test instantiates the production battle scene, emits the connected combat victory signal, forces save failure, presses the retry control, then checks exactly-once inventory/journal state and normal exit behavior.
- Expected Runtime suite count: 48.

### Validation gate
- PASS: exact implementation commit `11ed7f160e3c7cf2dd8e6f6140b95aae1df18541`; Runtime run [38129703559](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38129703559) passed `RUNTIME_SUITE_PASS tests=48`.
- PASS: merged main commit `79442c064362385afc41201a8458bf39efa9b199`; Web Demo run [38129867663](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38129867663) passed build, export, upload, and deployment. Runtime run [38129867693](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38129867693) passed all 48 tests.

### Handoff
Exact implementation SHA and merged main SHA both pass Runtime; the merged main SHA also passes Web Demo build/deploy. Next, return to the vertical-slice experience review: pacing, interactive exploration, and final character asset review.


## 18. 2026-10-12 Shared Opening Exploration Affordances

### Implementation
- Shared-02 sequence now points players toward optional map rumors while retaining Eagle Sorrow as the next canonical destination.
- Journey MOVE uses localized WorldMap node names; active EventSequence controls lock scene exits until the sequence returns to the route/shared overview, with an escape path for invalid/empty actions.
- WorldMap displays localized bounty titles and explicit optional/mainline separation. Rumor discovery is a save transaction with complete NarrativeState rollback and retry feedback.
- New/expanded regression coverage registered at 49 Runtime suite entries.

### Validation gate
- PASS: merged main SHA `3c9ace36750c2aa4a009a0b63b66673a78cab1ea`, Godot Runtime [38190663833](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38190663833) reports `RUNTIME_SUITE_PASS tests=49`.
- PASS: Web Demo [38190663847](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38190663847) passed build/export/deploy.

### Handoff
After exact-SHA validation, review Shared-02 → optional rumor exploration → Shared-03 experience, then continue region-entry / interactive exploration and final character asset review. Do not alter fixed Journey chronology or present an optional bounty as the mainline Yellow Wind Ridge arc.


## 19. 2026-10-12 Optional Yellow Fang vs Mainline Yellow Wind King

### Finding
The optional Eagle Sorrow rumor bounty and the Yellow Wind Cave mainline boss both used `BOUNTY_YELLOW_FANG`. Because the cave gate read the shared defeated-target journal, completing the optional bounty first could suppress the required mainline boss.

### Change
- `BOUNTY_YELLOW_FANG` remains the optional “黄牙老妖”.
- `YELLOW_WIND_KING` is a distinct mainline boss definition and battle/journal ID, displayed as “黄风妖王”.
- Cave availability now depends only on the mainline boss ID.
- Regression starts the cave with the optional bounty already defeated, proves the mainline boss remains challengeable, and verifies the mainline victory records `YELLOW_WIND_KING` separately.

### Validation
- First exact-head run [38192876862](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38192876862) failed two assertions: one was checked in the wrong cave room, and the existing bounty retry test expected the previous optional-target name. The production WorldMap bounty test and bounty reward atomicity test passed. Follow-up commit fixes both expectations. PASS: implementation head `e572f2b6149100a7d37ade917ecc9e74c14e4de0`, [Runtime 38193002843](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38193002843), `RUNTIME_SUITE_PASS tests=49`; cave roundtrip, WorldMap rumor/bounty and BattleUI retry tests all pass. A further consistency pass found `YellowWindRidgeManager.BOSS_TARGET_ID` and the ridge stage metadata still pointed at the optional ID; both now use `YELLOW_WIND_KING`, and the cave roundtrip asserts the Ridge gate completes after mainline victory. This latest head must pass exact-head Runtime before marking ready.

### Handoff
Inspect the exact-head CI logs. If both the production cave roundtrip and WorldMap rumor-to-bounty test pass, record the CI result and mark the PR ready. Consider a save migration only if production telemetry or fixtures show existing saves used the shared ID to record a previously defeated mainline boss.


### Completed Handoff — Yellow Wind Ridge Stage / Save-Resume Audit

This older audit instruction has been completed by the implementation and regression recorded below. It is retained as a pointer, not as a pending task.

- The current implementation uses `YELLOW_WIND_KING` for mainline gate completion and `BOUNTY_YELLOW_FANG` for the optional Yellow Fang objective.
- The production BattleUI regression covers the mainline boss save failure, real retry-button commit, distinct journal IDs, fresh NarrativeManager load, and Cave → Ridge return.
- Exact test/implementation SHA `911be5faad001551b330675cf6208b556ac9d82f` passed [Runtime run 38194393891](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38194393891) with `RUNTIME_SUITE_PASS tests=50`. The documentation sync SHA `37d7bfaf71a6694f518a9f23e64eba01e8233777` also passed [Runtime run 38194500393](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38194500393) with 50/50.
- PR #25 remains open. Do not merge without explicit user permission.

Next: inspect the current PR diff and newest branch-head Actions; then review Shared-02 → optional rumor exploration → Shared-03 pacing, region entry / interaction, and final character PNG/WebP assets.

## 20. 2026-10-12 Yellow Wind King Settlement / Save-Resume Audit

### Implementation
- Added a production BattleUI SceneTree test for YELLOW_WIND_KING settlement save failure, retry, distinct journal identity, and Ridge gate completion.
- The fixture begins with BOUNTY_YELLOW_FANG already defeated so its optional history must survive the failed mainline transaction and the successful retry.
- The test reloads the save through a fresh NarrativeManager and the production Cave → Ridge screens; it asserts final room/stage state and preserves the fixed Shared chapter, timeline, and roster.
- Runtime suite expected entries: 50.

### Validation gate
- Test/implementation SHA `911be5faad001551b330675cf6208b556ac9d82f` passed exact-head Godot Runtime run [38194393891](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38194393891): `PASS res://combat/test_yellow_wind_king_settlement_retry.gd` and `RUNTIME_SUITE_PASS tests=50`.
- The first test-only commit had one brittle assertion about the initial button label; it was corrected, and the result above applies to the corrected SHA. Web Demo is not run by the PR workflow; do not claim a feature-branch deploy.
- PR #25 stays open; do not merge without explicit user permission.

### Next Agent
1. Inspect the full PR #25 diff and check the latest branch-head Actions after the documentation-only follow-up; the tested code SHA `911be5faad001551b330675cf6208b556ac9d82f` is green at Runtime 50/50.
2. Preserve the separation of optional and mainline target IDs. Do not merge PR #25 without explicit user permission.
3. Continue the player-facing review of Shared-02 → optional rumors → Shared-03, then region-entry / interactive exploration and final character PNG/WebP asset review. Do not start unrelated Camp/Relationship work.


## 21. 2026-10-12 Shared-02 Optional Exploration Access — Regression Added

### Finding
Shared-02 completes at timeline `105`, but the WorldMap node `EAGLE_SORROW` and its `RUMOR_YELLOW_FANG` both required timeline `110`. The Shared-02 dialogue explicitly invites the player to open the map and hear rumors before continuing to Eagle Sorrow. That promise was unreachable at timeline 105: the map hid the destination and the rumor.

### Change
- Lower only the optional exploration availability thresholds for the Eagle Sorrow map node and Yellow Fang rumor to timeline 105. Shared-03's canonical chapter and recruitment milestone remain at timeline 110.
- Add a production WorldMap SceneTree regression from the real post-Shared-02 state: travel to Eagle Sorrow, hear/discover the optional rumor, launch and win the actual optional bounty battle, return to WorldMap, save/reload, then return to Journey and verify Continue starts `SHARED-03-EAGLE-SORROW-SEQUENCE`.
- Update the static WorldMap manager regression to use the post-Shared-02 timeline before testing Eagle Sorrow access.

### Validation
- PASS: latest test head `ae921d076cedfec500f6eb7e16f57f2ef147d3a5`, [Godot Runtime 38209609249](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38209609249), `RUNTIME_SUITE_PASS tests=51`; logs confirm `test_shared02_optional_rumor_access.gd` passed. The regression checks rumor discovery, actual optional bounty battle/return, then reopening Journey and starting `SHARED-03-EAGLE-SORROW-SEQUENCE`. An earlier test-only head `6515941e0e3f826a588d3a694a7bb5c22e337476` failed because the fixture had not marked Wukong's Origin route complete; the fixture was corrected and the exact newer SHA passed. Do not reuse prior results to validate a later SHA.
- PR #25 remains open and unmerged. No Web Demo run is claimed for the feature branch.

### Next
Runtime has now verified the post-Shared-02 detour and that Journey resumes at Shared-03. Next, do the player-facing visual review and prepare final character asset delivery: the repository has six character SVG placeholders and no `assets/art/characters/final/` PNG/WebP assets. Follow `docs/visual_reference/README.md`; do not treat placeholders as final art.


## 2026-10-12 Visual Asset Source Audit (PR #25)

- Audited the six character SVG placeholders and the catalog / visual contract tests. They remain geometric placeholders; automated tests check resource loading and environment-layer markers, not visual quality.
- Five humanoid placeholders use a 32×48 logical viewBox; Longma uses a horizontal 40×32 viewBox. Review actual in-game scale rather than forcing Longma into a humanoid frame.
- No final character PNG/WebP or player-facing screenshot artifact is present in the reviewed branch. This was source inspection only, not a screenshot acceptance pass.
- Delivery and review requirements are recorded in `docs/development_log/2026-10-12-character-asset-source-audit.md`. Next: deliver six separate transparent pixel-art assets, then run exact-head Runtime/Web Demo validation and inspect actual Journey/battle screenshots. Keep SVG fallbacks; do not merge PR #25 without explicit permission.


## 17. 2026-10-12 Art Catalog Runtime Contract

- `combat/test_visual_asset_contract.gd` now checks the actual production `ArtAssetCatalog` resolution path for all six character IDs and scene textures.
- Character resolution is asserted as final PNG → final WebP → SVG fallback based on files present. Final art remains optional; do not rename placeholders or add unrelated status/infographic images as character assets.
- Existing SVG environment layer markers remain checked. These tests prove resource/path contracts only, not art quality or visual acceptance.
- New log: `docs/development_log/2026-10-12-art-catalog-runtime-contract.md`. Exact-head Runtime must be checked after the update; no new Runtime pass is claimed until Actions confirms it.
- Pending: six separate transparent final character assets and actual Journey/battle screenshot review. Continue non-art production regression work meanwhile.


## Current Handoff — 2026-10-14: Five Elements Mountain Region Exploration

### Completed baseline
- PR #25 fixed optional Yellow Fang / Eagle Sorrow timing; PR #26 added the same-save Shared-02 optional detour regression; PR #27 added the reusable region screen and persisted clue discoveries.
- Main docs-sync SHA `ccc44e226bab2e722fb4413c55f698db9e69cd2f` passed Runtime [38497385618](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497385618) and Web Demo [38497385698](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497385698).
- PR #27 merged as `aac03d053c7ef1f13e5981cdfa6ea8c6a4731ed6`; its Runtime [38497186380](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497186380) passed `RUNTIME_SUITE_PASS tests=52`; Web Demo [38497186366](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497186366) passed build/export/Pages deployment.

### Completed feature work — PR #28
- PR #28: https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/pull/28 merged as `ec6ef177b6a2a604c1f86b7e447f2212af82f069`.
- Added `FIVE_ELEMENTS_MOUNTAIN` to `data/world/regions.json` with timeline 100, milestone `WUKONG_RECRUITED`, and three clue-only points; reused the generic RegionExplorationManager and RegionExploration screen.
- Exact pre-merge docs-sync SHA `384771aadca78ffb5324d47721af511c6e671223` passed Runtime [38497759935](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497759935) with `PASS res://combat/test_region_exploration.gd` and `RUNTIME_SUITE_PASS tests=52`.
- Merged main Runtime [38497860810](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497860810) passed with `PASS res://combat/test_region_exploration.gd` and `RUNTIME_SUITE_PASS tests=52`. Web Demo [38497860796](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497860796) passed import, runtime-before-export, web export, Pages artifact upload, and GitHub Pages deployment.
- Live Demo: https://dantangdwcyxgs.github.io/Journey-to-the-West-Paths-of-the-Five-Elements/
- The region smoke includes current-location / timeline / milestone gates, production WorldMap travel Eagle Sorrow ↔ Five Elements Mountain, point discovery and save/reload, and assertions that the canonical Shared chapter pointer, global timeline, completed chapters, and recruited roster remain unchanged.

### Required next actions
1. Start from the latest main SHA and confirm its current exact-SHA Runtime/Web workflow status after this documentation sync.
2. Continue adding regions only where narrative content is coherent; use data-driven definitions and extend production SceneTree tests rather than adding map-specific screen logic.
3. Conduct player-facing screenshot review and deliver six separate transparent character PNG/WebP assets via `ArtAssetCatalog`. These remain a separate outstanding task; SVG placeholders and automated contract tests are not visual acceptance.

### Constraints
- Optional exploration must not advance the fixed Shared chronology, mutate recruitment, or add completed chapters.
- Treat stale/in-progress historical runs as neither green nor current validation. Only the exact tested SHA and completed run count.
- Save failure must restore the full NarrativeState snapshot and leave the clue retryable.


## 22. 2026-10-14 Black Wind North Path Region Exploration (PR #29)

### Implementation
- PR: https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/pull/29
- Branch: `feature/black-wind-region-exploration-2026-10-14`
- Added `BLACK_WIND_NORTH_PATH` as the third data-driven region, gated by timeline 120 and `BAI_LONGMA_RECRUITED`, with three clue-only observations. This matches the existing `SHARED-04-EARLY-DEMON-TALES` shared chapter and does not add a parallel story route.
- Extended `combat/test_region_exploration.gd` to cover timeline/milestone locks, the production WorldMap → region scene path, persistence across fresh load, return travel, and invariants on Shared chapter pointer, timeline, completed chapters, and recruited roster.
- Added `docs/development_log/2026-10-14-black-wind-north-path-region.md`, indexed it, and recorded the change in `docs/AI_MEMORY.md`.

### Validation gate
- PASS: implementation/test head `c2379b19e72d768957f4f70a206fe393bc8981e8`; Runtime run [38500154155](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38500154155) completed successfully with `RUNTIME_SUITE_PASS tests=52`. The documentation-sync head `32e24b6eb251a12c8fe2f7aaa5d580935a23de48` also passed Runtime [38500329741](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38500329741) at 52/52. Check the newest PR-head Runtime after this final result-recording commit.
- Main baseline `395233d8bcaf13aa9022c33903ab03a75c5a83ae` had successful Runtime run [38498039387](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38498039387) and Web Demo run [38498039390](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38498039390). Baseline results are not evidence for the feature branch.
- No Web Demo deploy is claimed for this unmerged PR. No image-generation or screenshot acceptance was performed.

### Next Agent
1. Inspect the newest PR #29 Runtime run for the exact latest PR head and review logs for `test_region_exploration.gd`.
2. If it fails, fix the underlying fixture/path issue and rerun. If it passes, preserve the exact SHA/run in the development log.
3. Do not merge PR #29 without explicit user permission. Keep final character PNG/WebP assets and screenshot review as separate outstanding work.


## 23. 2026-10-14 Region Entry Requirement Feedback (PR #29 continuation)

### Implementation
- Added `RegionExplorationManager.get_entry_block_reason()` as the single source for both region-entry eligibility and the player's explanation. `can_enter()` now returns whether that reason is empty.
- WorldMap presents inline explanatory text and a tooltip for region entries: current-location/timeline/milestone locks explain the exact missing prerequisite; available regions explain that they are optional clue investigations and do not progress the main story.
- Added friendly text for Wukong, Longma, Bajie, Wujing recruitment and full-party milestones; no internal milestone key is presented to players.
- Extended the production `combat/test_region_exploration.gd` path to verify locked-state feedback and successful re-enablement after restoring the required state.

### Validation gate
- PASS: feature code/test SHA `e50f7089ce18c598f513643149cd31a20eff56e3`, Runtime [38501453314](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38501453314), `PASS res://combat/test_region_exploration.gd`, `RUNTIME_SUITE_PASS tests=52). Final documentation-sync SHA `fcba52ed18c3d65c24ac220d46d78d819f852ee3` passed Runtime [38501734471](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38501734471) at 52/52.
- No Web Demo deployment, visual screenshot acceptance, or image generation is claimed.

### Next Agent
1. Inspect the latest PR #29 head and Runtime. Fix any syntax/fixture/assertion failures and rerun the exact head.
2. Preserve the fixed Journey timeline, the timeline and milestone gates, and the clue-only / no-chapter-progression contract.
3. Keep PR #29 open unless the user explicitly authorizes merge. After validation, choose a further non-art gameplay polish or resume the separate final character asset/screenshot task.


## 25. 2026-10-14 Region Content Catalog Validation

### Implementation
- Added `scripts/world/region_content_validator.gd`; `validate_payload(region_payload, world_map_payload)` provides a reusable CI content contract without adding per-region runtime logic.
- Added `combat/test_region_content_validator.gd` and registered it in `tests/runtime_suite.gd`. Runtime suite count is now 53.
- Contract catches duplicated/blank world-map IDs, region IDs, duplicate region ownership of a location, unknown region locations, empty titles/descriptions, invalid timeline gates, invalid/duplicate milestones, empty clue arrays, global clue-ID collisions, and missing player-facing clue fields.
- Point IDs must be globally unique because `NarrativeState.world_state.discovered_region_points` stores a flat list without a region namespace.

### Validation gate
- First attempt `c10d46cb7c2056017ef4f9481591de0cd93eafff` failed at Runtime [38502308548](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38502308548): valid JSON timeline numbers were represented as floating-point values, but the validator only accepted `TYPE_INT`. This assumption was fixed; negative and fractional values remain invalid.
- PASS: validator fix/test head `22e83daf31ca7176dc9d120595306e9bdab092ad`, Runtime [38502403071](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38502403071), `PASS res://combat/test_region_content_validator.gd`, `RUNTIME_SUITE_PASS tests=53`.
- PASS: expanded negative-test head `da48a2b8fd4e00df8dd4d3ba1c1a47ce33b582aa`, Runtime [38502420049](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38502420049), also at 53/53.
- No image generation, Web Demo deploy or visual screenshot acceptance is claimed. PR #29 stays open and unmerged.

### Next Agent
1. Check the exact-head Runtime after this documentation synchronization.
2. Inspect `scripts/world/journey_log.gd` plus current history / journal UI before implementing a player-facing review list for discovered region clues. Reuse the flat persisted discovery list; do not duplicate persistence or let optional clues advance the mainline.
3. Preserve PR #29's unmerged state unless the user explicitly authorizes merge. Character PNG/WebP production and actual visual acceptance remain separate pending work.


## 26. 2026-10-14 Discovered Region Notes Journal (PR #29 continuation)

### Implementation
- Branch: `feature/black-wind-region-exploration-2026-10-14`; PR #29 stays open and must not be merged without explicit user permission.
- Rechecked the previous exact-head baseline: `826eedcd621f262ea451799bfb4a7e78c35c0602`, Godot Runtime [38502606214](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38502606214), success at 53/53.
- Architecture review: `scripts/world/journey_log.gd` records battles and world effects; region discoveries remain facts in `NarrativeState.world_state.discovered_region_points`. Do not duplicate this persistence.
- Added `RegionExplorationManager.get_discovered_notes()` as a read-only region-catalog projection. The journal only exposes discovered IDs and derives their display fields from `data/world/regions.json`.
- Added `ui/region_notes_log.gd` / `.tscn` and a `旅途见闻` button on WorldMap, with list/detail, an empty state, and a return-to-map action.
- Added `combat/test_region_notes_log.gd` and registered it in `tests/runtime_suite.gd`; suite now expects 54 test entries.
- Development log: `docs/development_log/2026-10-14-region-notes-index.md`; architecture and log index are updated.

### Validation Gate
- PASS: implementation/test head `26c4d27b8464db2b3110d38b634754e04b53b248`, Runtime [38503524908](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38503524908), and documentation-sync head `1de4a24112eb26a2bc8d36f44d2f86340776eaff`, Runtime [38503657814](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38503657814), both passed `PASS res://combat/test_region_notes_log.gd`, `RUNTIME_SUITE_PASS tests=54`.
- No Web Demo deployment, final-art delivery, or screenshot acceptance is claimed.

### Next Agent
1. The exact implementation and docs-sync Runtime gates are both green at 54/54; the PR description includes these run IDs.
2. Next polish: surface the current region's discovered/total clue progress on WorldMap, without creating a second persistence store or implying mainline completion.
3. Keep PR #29 open/unmerged. Final character PNG/WebP assets and actual visual screenshot acceptance remain separate deliverables.

## 27. 2026-10-14 WorldMap Region Discovery Progress Feedback (PR #29 continuation)

### Implementation
- Read the required vision, production and content-pipeline documents before extending the region subsystem. Region progress is presentation feedback, not a new narrative progression rule.
- Added RegionExplorationManager.get_discovery_progress() as a derived summary over region definitions and existing persisted discovery point IDs.
- WorldMap entry labels show discovered/total clues. The hint shows remaining clue count or a local-completion message that explicitly distinguishes regional clue completion from chapter/story completion.
- Extended combat/test_region_exploration.gd rather than adding another duplicate test runner: covers 0/3, 1/3, 3/3 and progress remaining visible after return to WorldMap. Suite count stays 54.
- Development record: docs/development_log/2026-10-14-region-discovery-progress-feedback.md.

### Validation Gate
- Previous verified docs-sync head 1de4a24112eb26a2bc8d36f44d2f86340776eaff passed Runtime [38503657814](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38503657814), RUNTIME_SUITE_PASS tests=54.
- PASS: implementation/test SHA `26d93318759d801f364526cdeae295a978c223d1`, Runtime [38520530322](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38520530322), and docs-sync head `6bb1d0fd7e055736fcdb6f86541a544ac5b7c6a7`, Runtime [38520671947](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38520671947), both include `PASS res://combat/test_region_exploration.gd` and `RUNTIME_SUITE_PASS tests=54`.

### Next Agent
1. The progress-feedback implementation and its docs-sync head are both green at 54/54.
2. Re-read the main Vertical Slice task list and choose the next non-art gap with a clear runtime-testable acceptance contract; don't add another region unless the canonical route justifies it.
3. Keep PR #29 open/unmerged absent explicit approval. Final transparent character PNG/WebP assets and visual screenshot acceptance remain separate deliverables.

## 28. 2026-10-14 Region Exploration Completion Feedback (PR #29 continuation)

### Change
- Region screen progress now shares RegionExplorationManager.get_discovery_progress() with WorldMap; an unfinished area shows remaining clues, and a fully discovered area gives an explicit completed message plus 「旅途见闻」 review guidance.
- Wrapped the status label for narrower viewports.
- Extended combat/test_region_exploration.gd using a complete persisted-state fixture and production region screen. It verifies completion copy, journal guidance, and wording that protects the fixed main story. The suite remains 54 entries.
- Architecture contract and development log are updated in docs/architecture.md and docs/development_log/2026-10-14-region-completion-feedback.md.

### Validation gate
- PASS: implementation/documentation head `43951fa76b45e37dee5f8ed5902b3edc17a55227`, Godot Runtime [38521895114](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38521895114), completed successfully; logs show `PASS res://combat/test_region_exploration.gd` and `RUNTIME_SUITE_PASS tests=54`.
- This is not a Web Demo deployment and does not count as final character PNG/WebP delivery or screenshot acceptance.

### Next Agent
1. Check the exact newest PR #29 Runtime after this result-recording documentation sync; do not assume Run #430 applies to its newer SHA.
2. If the new head fails, fix the source and rerun. Preserve the no-mainline-progression contract.
3. Keep PR #29 open/unmerged unless the user explicitly authorizes merge. Final character PNG/WebP assets and screenshot review remain separate work items.

## 29. 2026-10-14 EventSequence MOVE Map Reference Validation (PR #29 continuation)

### Change
- Content-quality validation now checks every move node before the sequence enters the runtime catalog: map_id must be the currently supported WORLD_MAP, marker_id must be present, and the marker must resolve to WorldMapManager.nodes.
- This closes the path where WorldActionService.apply_move() could fall back to the map ID as a persisted location if a content author omitted marker_id.
- combat/test_event_sequence_validator.gd now covers the valid path and missing marker / unknown marker / missing map ID / unsupported map ID. Production sequence catalog checks remain in the existing Runtime suite (54 entries).
- See docs/development_log/2026-10-14-event-sequence-move-reference-validation.md for details.

### Validation gate
- PASS: implementation/test SHA daa33bb02411173170912eedd037e6dbf1e226f8, Godot Runtime [38522405623](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38522405623), with PASS res://combat/test_event_sequence_validator.gd and RUNTIME_SUITE_PASS tests=54.
- PASS: documentation-sync SHA d5fcf00d8d2d0e360de3f50f1d597de28e2a2c7b, Godot Runtime [38522641916](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38522641916), completed with PASS res://combat/test_event_sequence_validator.gd and RUNTIME_SUITE_PASS tests=54.
- This result applies to that exact head; the result-recording docs update must be checked independently. No Web Demo deploy or visual acceptance is claimed.

### Next Agent
1. Confirm Godot Runtime on the exact head produced by this result-recording update; record the SHA/run in the PR description if it passes.
2. If new maps are implemented later, introduce explicit map-catalog support instead of letting arbitrary map IDs through.
3. Keep PR #29 open/unmerged unless the user explicitly authorizes merge. Final character PNG/WebP assets and screenshots remain outstanding.
