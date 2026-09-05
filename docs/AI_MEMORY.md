# AI Project Memory Ledger

> 这是本项目给 AI / Agent 使用的长期工作记忆。目的不是保存聊天原文，而是保存：我们已经做了什么、为什么这么做、实际验证到了哪里、哪些边界不能破坏、下一步从哪里继续。
>
> 任何新的 AI / Agent 接手项目时，应先读本文件，再读 `AI_HANDOFF.md`、`docs/development_log/README.md` 和最新 development log。聊天历史不是项目唯一事实源。

---

## 0. 永久工作规则

### 0.1 记忆原则
每一轮有实际项目操作，都必须留下可恢复的记录：做了什么、为什么、实际修改、测试/真实运行结果、已知问题、下一步、接手点。不保存无关闲聊，也不把用户原话逐字稿当工程记忆。

### 0.2 绝不能用“看起来应该能跑”替代验证
静态检查、代码推断和真实 Godot Runtime 是三件不同的事情。只有实际运行结果才能写成“Godot Runtime 通过”。`pending`、`statuses: []` 或没有 workflow result 时，必须写成未确认。

### 0.3 当前引擎基准
**Godot 4.5.1 stable**。

### 0.4 核心架构原则
`Content Data → ChapterDefinition → ChapterRuntime → EventSequence/EventRunner → EventRuntime / Combat / World → Presentation`

Runner 负责流程，不负责 UI；NarrativeState 保存世界事实；Service 负责状态副作用；Presentation 负责呈现。

### 0.5 西游时间线不可被玩家顺序改写
玩家可以选择五人任意一人为起点，但世界历史只有一条固定时间线：
`悟空被镇压 → 唐僧开始取经 → 五行山释放悟空 → 鹰愁涧白龙马 → 高老庄八戒 → 流沙河悟净 → 五人完整西行`

Memory / Flashback 是历史回放，不得回写当前世界事实。

### 0.6 迁移必须渐进
旧入口可暂时作为兼容层，但新能力必须沿统一架构接入；不要为了“重构干净”一次性重写所有章节。

---

# 1. 项目当前定位

游戏：`西游：五行之路（Journey to the West: Five Elements Road）`

核心原则：**可玩的《西游记》故事第一，原创 JRPG 第二。**

技术方向：Godot 4 + 像素角色 + HD-2D / 2.5D 环境 + 回合制 JRPG。

叙事结构：五条 Origin Route → 各自经典招募节点 → Shared Journey。

---

# 2. 当前稳定的核心链路

## 2.1 Event Sequence
`Event Sequence JSON → EventSequenceManager → EventSequenceDefinition → EventRunner → NarrativeEventSession → action`

标准 action：`dialogue / choice / wait / move / battle / reward / jump / end`

EventRunner 不创建 UI，不启动 BattleUI，不直接承担库存或世界副作用。

## 2.2 Battle Handoff
`Journey → NarrativeEventSession → EventRunner → EncounterHandoff(+event_resume) → BattleUI → BattleResolutionService → NarrativeEventSession.resume → Journey`

战斗胜利边界：`预检 → 奖励预览 → 状态变更 → 剧情推进 → 世界效果 → 最终 Save`，失败需要回滚。

## 2.3 非战斗副作用
- `RewardService`：统一 narrative reward 的实际库存副作用；
- `WorldActionService`：统一 `move / wait` 的世界动作入口。

不要把这些副作用重新塞回 EventRunner。

## 2.4 Scene Handoff
`BountyEncounterState` 仍兼容旧入口并承载 EventSession resume context。未来再逐步收敛为明确的通用 Scene Handoff Service，不为此破坏现有兼容链。

---

# 3. 历史工作记录

> 以下记录只保存影响后续工程的工作事实与思路，不是聊天逐字稿。

## Round 01 — 五人起始路线与固定世界时间线
### 做了什么
建立五人可选起点与 Origin / Shared 双结构。
### 为什么
起点视角可以自由，但西游历史不能重排。
### 下一步
围绕固定世界时间线建立章节、招募和 Memory。

## Round 02 — 战斗 Domain 基础
### 做了什么
形成 `Combatant / CombatEngine / CombatAction` 以及 HP、ATK、DEF、SPD、BP、Weakness、Shield、Break、Status、Formation。
### 为什么
战斗规则必须属于稳定 Domain 层，而不是 UI 拼装。
### 下一步
技能、敌人、Encounter 和数据驱动内容。

## Round 03 — 五人专属机制与队伍基础
### 做了什么
加入五人基础差异、3 前排 / 2 后排、队伍保存读取、装备和消耗品。
### 为什么
系统服务人物，而不是无目的堆系统。
### 下一步
把队伍能力接入西游剧情与 Encounter。

## Round 04 — World / Rumor / Bounty / 灰盒探索
### 做了什么
建立 World Map / Travel / Rumor / Bounty，以及黄风岭 / 黄风洞灰盒探索链。
### 为什么
先让西游世界具备“可游玩”的基础。
### 下一步
统一世界事件与战斗入口。

## Round 05 — 三场共享招募战
### 做了什么
建立鹰愁涧、高老庄、流沙河三场共享招募战、Encounter AI、招募与 Shared chapter 基础。
### 为什么
招募必须是经典故事中的真实事件，而不是菜单解锁。
### 下一步
统一战斗奖励、章节推进和回滚。

## Round 06 — Shared Chapter 原子结算 / BattleResolution
### 做了什么
统一 `BattleResolutionService`，把战斗奖励、章节推进、世界效果与保存纳入原子边界。
### 为什么
避免部分成功、重复结算与状态不一致。
### 下一步
把这个边界作为 Event Sequence battle node 的后端标准。

## Round 07 — EventDefinition / EventRuntime
### 做了什么
建立数据驱动 EventDefinition / EventRuntime，统一 Origin / Shared 事件选择执行入口。
### 为什么
选择必须持久化，而不是依赖 UI。
### 下一步
扩展为多节点 Event Sequence。

## Round 08 — EventSequenceDefinition / 图结构验证
### 做了什么
建立 Event Sequence 数据结构与图连接校验。
### 为什么
剧情流程应由数据图表达，而不是散落在 Journey UI 的 if/else。
### 下一步
建立真正执行图的 Runner。

## Round 09 — EventRunner 多节点执行
### 做了什么
建立 `EventRunner`，支持 `dialogue / choice / wait / move / battle / reward / jump / end` 和 snapshot。
### 为什么
拆开“章节描述什么”和“流程怎么走”。
### 下一步
建立独立 Session 处理跨场景恢复。

## Round 10 — NarrativeEventSession / Battle Resume
### 做了什么
建立 `NarrativeEventSession`，通过 `event_resume` 跨 Journey / BattleUI 恢复未完成 Sequence。
### 为什么
战斗只是剧情中的一个 action，胜利后必须回到下一节点。
### 下一步
进入真实 Godot Runtime 验证。

## Round 11 — 真实 Godot Runtime 验证
### 做了什么
建立 GitHub Actions Godot headless runtime workflow，基准为 **Godot 4.5.1 stable**，覆盖项目导入、GDScript probe、EventRuntime、EventRunner、EventSession、战斗恢复。
### 为什么
项目明确要求真实运行，不接受“代码看起来正确”。
### 下一步
把已验证 Runtime 接入真实 Godot SceneTree / Journey。

## Round 12 — EventSequence → EventRunner → Action → Service / Handoff
### 做了什么
明确 action 职责：Runner 只请求动作；Reward / World / Battle 通过 Service 或 Handoff 执行。
### 为什么
防止 Runner 演变为理解所有系统的 God Object。
### 下一步
真实 Presentation / SceneTree 接线。

## Round 13 — RewardService
### 做了什么
建立 `scripts/items/reward_service.gd`，统一 narrative reward 的库存副作用，并加入回归测试。
### 为什么
奖励副作用集中管理。
### 下一步
同样统一 `move / wait`。

## Round 14 — WorldActionService
### 做了什么
建立 `scripts/world/world_action_service.gd`，统一 `move / wait` 的执行入口，并加入回归测试。
### 为什么
世界动作应有清晰 Service 边界。
### 注意
`move` 当前主要写逻辑地点/visited node；`wait` 当前验证动作但不推进独立世界时钟。
### 下一步
真实 Presentation / SceneTree 接线。

## Round 15 — Journey Event Presentation / SceneTree 接线
### 做了什么
第一批真实 Journey Presentation：DialoguePanel / Speaker / Text / Hint / EventMeta、对白逐字显示、点击立即完成、WAIT 过渡、BATTLE Handoff，以及 `combat/test_journey_event_presentation.gd`。
### 为什么
Batch 1B 的关键是进入**真实 Godot SceneTree 接线**，不是继续堆 Runtime 抽象。
### 下一步
让更多 Shared Journey 复用同一套 Presentation。

## Round 16 — Shared-04 EventSequence 接线
### 做了什么
新增 `SHARED-04-EARLY-DEMON-TALES-SEQUENCE`，并加入 validator regression。
### 为什么
证明 Shared Journey 可以按 `<chapter_id>-SEQUENCE` 数据驱动运行，而不需要每章专用 UI 分支。
### 关键边界
无战斗 Shared chapter 在 Sequence END 完成；带战斗 chapter 由 `BattleResolutionService` 原子完成，返回后不能重复完成。
### 已知问题
Shared-04 曾同时有 sequence reward 和 chapter reward，会双重发奖；MOVE 还无路径动画。

## Round 17 — AI 持久记忆系统
### 做了什么
建立 `docs/AI_MEMORY.md`，把项目级上下文、架构边界、验证原则和接手方式沉淀到仓库。
### 为什么
聊天上下文不能作为唯一工程状态来源。
### 下一步
以后每个实际仓库工作轮次都增加 Round，并同步 development log。

## Round 18 — Shared-05 / Shared-06 EventSequence Migration
### 做了什么
新增：
- `SHARED-05-GAOJIAZHUANG-SEQUENCE`
- `SHARED-06-FOUR-PERSON-JOURNEY-SEQUENCE`

Shared-05：`arrival dialogue → BAJIE_ENCOUNTER choice → SHARED_GAOJIAZHUANG battle → after-battle dialogue → end`

Shared-06：`depart dialogue → wait → resolve dialogue → end`

同时移除 Shared-04 Sequence 中重复的 `reward(HERB)`，使 chapter reward 成为唯一来源。
### 为什么
验证同一执行链同时覆盖招募战 + BattleUI resume + 原子结算，以及无战斗 END completion + chapter reward，避免内容迁移产生隐藏经济错误。
### 验证
EventSequenceValidator 已覆盖；当时 Godot Runtime 尚未确认。

## Round 19 — Shared-07 / Shared-08 / Shared-09 EventSequence Migration
### 做了什么
新增：
- `SHARED-07-FLOWING-SANDS-SEQUENCE`
- `SHARED-08-PARTY-FULL-SEQUENCE`
- `SHARED-09-FULL-PILGRIMAGE-SEQUENCE`

Shared-07：`river dialogue → WUJING_ENCOUNTER choice → SHARED_FLOWING_SANDS battle → after-battle dialogue → end`

Shared-08：`gather dialogue → PARTY_FULL choice → oath dialogue → end`

Shared-09：`departure dialogue → end`

继续保证 sequence 不复制 `shared_chapters.json` 的 chapter reward。
### 为什么
Shared-04→09 的主体迁移完成后，不再为单个章节维护独立 UI 流程，后续精力应转向真实 Runtime 与 Presentation。
### 验证
当时最新 commit 的 combined status 为 `statuses: []`，不能声明 Runtime 通过。

## Round 20 — Godot 4.5.1 Journey Parse Fix / First Real Failure Loop
### 做了什么
第一次真实执行 Shared-03 至 Shared-09 相关 headless workflow 后，Godot Runtime #75 真实失败，定位到 `ui/journey.gd` 三处 warning-as-error 类型推断：

- `_process()` 的 `target` 显式声明 `int`；
- `_process()` 的 `added` 显式声明 `int`；
- `_start_event_transition()` 的 `seconds` 显式声明 `float`。

新增 `docs/development_log/2026-09-05-godot-runtime-journey-parse-fix.md`。
### 为什么
这是真实 Godot 4.5.1 对当前代码的实际反馈。前 10 个 runtime tests 已通过，失败集中在 Journey Presentation script 编译，因此先修复真实错误再继续推进。
### 重要验证事实
Godot Runtime #75：**failure**。GitHub Actions 实际证明：
- Godot 4.5.1 安装/启动通过；
- 项目导入通过；
- signature parser probe 通过；
- EventRuntime 通过；
- EventRunner 通过；
- runtime suite 前 10 个测试通过；
- `test_journey_event_presentation.gd` 因 `ui/journey.gd` compile error 失败。

Godot #76 已由修复提交触发，当前查询时处于 `queued`，所以**尚未确认通过**。
### 下一步
先读取 Runtime #76 结果；若通过，再完整验证 Shared-03/05/07 battle resume、Shared-04/06/08/09 non-battle completion，以及 Journey SceneTree 的 MOVE/WAIT/END 表现。

---

# 4. 当前任务地图

## 已完成主干

- 五人 Origin / Shared 结构与固定世界时间线；
- Combat Domain 基础；
- World / Rumor / Bounty 与灰盒探索；
- 三场共享招募战；
- Shared chapter 原子结算；
- BattleResolutionService；
- EventDefinition / EventRuntime；
- EventSequenceDefinition；
- EventRunner；
- NarrativeEventSession；
- EventSequenceManager；
- RewardService；
- WorldActionService；
- Journey 第一批真实 Event Presentation / SceneTree 接线；
- Shared-03 至 Shared-09 EventSequence 内容迁移；
- Godot 4.5.1 headless runtime infrastructure。

## 当前优先顺序

### P0 — 真实 Godot Runtime / SceneTree 完整化

1. 读取并处理 Runtime #76 的真实结果；
2. 验证 Shared-03 / 05 / 07：Battle → BattleUI → Resume → END；
3. 验证 Shared-04 / 06 / 08 / 09：non-battle END → chapter completion / reward；
4. 验证 Journey SceneTree 中 MOVE / WAIT / END / Battle transition；
5. 任何失败先修复再继续，不把静态检查写成 Runtime 通过。

### P1 — Origin Migration

Shared Journey 迁移主体已完成。之后按角色逐步将 Origin Route 迁移到 EventSequence，不改变固定全球时间线与经典招募节点。

### P2 — Cleanup / Convergence

清理旧 BattleUI 结算职责，逐步将 `BountyEncounterState` 收敛成通用 Scene Handoff Service，并强化 Sequence cross-reference validation。

### P3 — Camp / Relationship

等叙事链和第一 Vertical Slice 稳定后进入 Camp / Relationship Prototype。

### P4 — Vertical Slice

目标：`一个完整角色起始路线 → 五行山 → 鹰愁涧 → 招募后 Memory`。

---

# 5. 接手协议

新的 AI / Agent 必须按以下顺序：

`docs/AI_MEMORY.md → AI_HANDOFF.md → docs/development_log/README.md → 最新 development log → 当前代码/数据 → GitHub Actions 真实结果`

开始修改前必须先回答：

- 属于 Domain / Content / Narrative / Presentation 哪层？
- 能否复用已有 Manager / Service / Runtime？
- 是否破坏固定世界时间线？
- 是否可能重复奖励、重复章节推进或重复 Save？
- 是否绕过现有 Handoff / Service 边界？
- 是否已经存在兼容迁移层？

### 每轮必须做

`实现 → 回归测试 → 真实 Godot Runtime（适用时）→ development log → AI_MEMORY Round → 必要时更新 AI_HANDOFF`

### 每轮记录模板

```text
## Round XX — YYYY-MM-DD — <主题>

### 做了什么
### 为什么
### 实际修改
### 验证
### 已知问题
### 下一步
### 接手点
```

**项目的长期工程记忆以本文件为准；聊天窗口只用于当前协作，不作为唯一状态源。**
