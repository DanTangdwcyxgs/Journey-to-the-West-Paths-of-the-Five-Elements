# AI Project Memory Ledger

> 这是本项目给 AI / Agent 使用的**长期工作记忆**。
>
> 目的不是保存聊天原文，而是保存：**我们已经做了什么、为什么这么做、哪些边界不能破坏、实际验证到了哪里、下一步从哪里继续。**
>
> 任何新的 AI / Agent 接手项目时，应先读本文件，再读 `AI_HANDOFF.md` 和 `docs/development_log/` 最新记录。聊天历史不是项目唯一事实源。

---

## 0. 永久工作规则

### 0.1 记忆原则

每一轮有实际项目操作，都必须留下可恢复的记录。记录只写：本轮做了什么、为什么这么做、实际修改了什么、测试 / 真实运行结果、当前已知问题、下一步、给下一位 Agent 的接手点。不保存无关闲聊，不需要保存用户原话逐字稿。

### 0.2 绝不能用“看起来应该能跑”替代验证

代码检查、静态推断和真实 Godot Runtime 是三件不同的事情。只有实际运行结果才能写成“Godot Runtime 通过”。如果 CI 是 `pending`、没有返回检查项，必须如实记录为未确认，不能提前宣布通过。

### 0.3 当前引擎基准

项目运行基准：**Godot 4.5.1 stable**。

### 0.4 核心架构原则

`Content Data → ChapterDefinition → ChapterRuntime → EventSequence/EventRunner → EventRuntime / Combat / World → Presentation`

Runner 负责流程，不负责 UI；NarrativeState 负责世界事实；Service 负责状态副作用；Presentation 负责呈现。

### 0.5 西游时间线不可被玩家顺序改写

玩家可以选择五人任意一人为起点，但世界历史始终只有一条固定时间线。

`悟空被镇压 → 唐僧开始取经 → 五行山释放悟空 → 鹰愁涧白龙马 → 高老庄八戒 → 流沙河悟净 → 五人完整西行`

Memory / Flashback 是历史回放，不得回写当前世界事实。

### 0.6 迁移必须渐进

旧入口可以暂时作为兼容层，但新能力必须沿统一架构接入。不要为了“重构干净”一次性重写所有章节。

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

`EventRunner` 不创建 UI，不直接启动 BattleUI，不把库存、世界位置等业务副作用硬编码到 Runner 中。

## 2.2 Battle Handoff

`Journey → NarrativeEventSession → EventRunner → EncounterHandoff(+event_resume) → BattleUI → BattleResolutionService → NarrativeEventSession.resume → Journey`

Battle 胜利边界：`预检 → 奖励预览 → 状态变更 → 剧情推进 → 世界效果 → 最终 Save`。失败需要回滚。

## 2.3 非战斗副作用

- `RewardService`：统一 narrative reward 的实际库存副作用；
- `WorldActionService`：统一 `move / wait` 的世界动作入口。

不要把奖励或世界修改重新塞回 `EventRunner`。

## 2.4 Scene Handoff

`BountyEncounterState` 目前仍兼容旧入口，同时承载 EventSession resume context。后续目标是逐步收敛为明确的通用 Scene Handoff Service，但现在不能为此破坏兼容链。

---

# 3. 历史工作记录

> 只保留影响后续工程的项目级动作、理由、验证和接手信息，不是聊天逐字稿。

## Round 01 — 五人起始路线与固定世界时间线

### 做了什么
建立五人可选起点与 Origin / Shared 双结构。

### 为什么
玩家需要自由选择第一视角，但西游历史不能因为选择角色而重排。

### 下一步
围绕固定世界时间线建立章节、招募和 Memory 解锁。

---

## Round 02 — 战斗 Domain 基础

### 做了什么
形成 `Combatant / CombatEngine / CombatAction` 以及 HP、ATK、DEF、SPD、BP、Weakness、Shield、Break、Status、Formation 等核心规则。

### 为什么
战斗必须是稳定的 Domain 层，而不是 UI 拼规则。

### 下一步
补充技能、敌人、Encounter 和数据驱动内容。

---

## Round 03 — 五人专属机制与队伍基础

### 做了什么
加入五人角色基础差异、3 前排 / 2 后排、队伍保存读取、装备和消耗品等基础能力。

### 为什么
系统应该服务人物，而不是堆系统数量。

### 下一步
把这些能力接到西游叙事和实际 Encounter。

---

## Round 04 — World / Rumor / Bounty / 灰盒探索

### 做了什么
建立 World Map / Travel / Rumor / Bounty，以及黄风岭 / 黄风洞灰盒探索链。

### 为什么
先建立“西游世界可游玩”的基础，再接剧情事件。

### 下一步
让世界事件和战斗通过统一入口衔接。

---

## Round 05 — 三场共享招募战

### 做了什么
建立鹰愁涧、高老庄、流沙河三场共享招募战，并形成 Encounter AI、招募、共享章节推进基础。

### 为什么
招募必须是西游故事中的真实事件，而不是菜单解锁。

### 下一步
解决战斗奖励、章节推进、保存和异常回滚的一致性。

---

## Round 06 — Shared Chapter 原子结算 / BattleResolution

### 做了什么
统一 `BattleResolutionService`，把战斗奖励、章节推进、世界效果和保存纳入明确边界，并加入回滚思想。

### 为什么
避免奖励、章节、世界状态出现部分成功或重复结算。

### 下一步
把这个边界作为 Event Sequence 战斗节点的后端结算标准。

---

## Round 07 — EventDefinition / EventRuntime

### 做了什么
建立数据驱动 EventDefinition / EventRuntime，并统一 Origin / Shared 事件选择执行入口。

### 为什么
事件选择必须持久化，不能依赖 UI 按钮保存状态。

### 下一步
从单事件扩展到多节点 Event Sequence。

---

## Round 08 — EventSequenceDefinition / 图结构验证

### 做了什么
建立 Event Sequence 数据结构和图连接校验。

### 为什么
剧情流程应该由数据图表达，而不是散落在 Journey UI 的硬编码 if/else。

### 下一步
建立真正执行图的 Runner。

---

## Round 09 — EventRunner 多节点执行

### 做了什么
建立 `EventRunner`，支持 `dialogue / choice / wait / move / battle / reward / jump / end`，并保存 runner snapshot。

### 为什么
拆开“章节描述什么”和“流程怎么走”，让 Runtime 可以运行不同内容。

### 下一步
建立独立 Session，处理跨场景和跨战斗恢复。

---

## Round 10 — NarrativeEventSession / Battle Resume

### 做了什么
建立 `NarrativeEventSession`，让未完成 EventRunner 流程通过 `event_resume` 跨 Journey / BattleUI 恢复。

### 为什么
战斗只是剧情中的一个 action，战斗结束必须回到 Sequence 下一节点。

### 下一步
用真实 Godot Runtime 验证完整链路。

---

## Round 11 — 真实 Godot Runtime 验证

### 做了什么
建立 GitHub Actions Godot headless runtime workflow，使用 **Godot 4.5.1 stable** 验证项目导入、GDScript probe、EventRuntime、EventRunner、EventSession、战斗恢复等能力。

### 为什么
项目明确要求不再使用“代码看起来正确”代替真实运行。

### 下一步
把已验证 Runtime 接入真实 Godot SceneTree / Journey 场景表现。

---

## Round 12 — EventSequence → EventRunner → Action → Service / Handoff

### 做了什么
明确 action 职责边界：Runner 只请求动作；Reward / World / Battle 通过 Service 或 Handoff 执行。

### 为什么
避免 Runner 变成同时理解库存、世界、UI、战斗的 God Object。

### 下一步
继续真实 Presentation / SceneTree 接线。

---

## Round 13 — RewardService

### 做了什么
建立 `scripts/items/reward_service.gd`，把 narrative `reward` action 的实际库存写入统一到 Service，并加入 `combat/test_reward_service.gd` 回归。

### 为什么
奖励副作用必须集中，避免每个剧情节点自行写 inventory。

### 下一步
同样处理 `move / wait` 的世界副作用。

---

## Round 14 — WorldActionService

### 做了什么
建立 `scripts/world/world_action_service.gd`，统一 `move / wait` 的执行入口，并加入 `combat/test_world_action_service.gd`。

### 为什么
世界动作应该拥有清晰 Service 边界，Runner 不直接修改世界内部状态。

### 下一步
把 WorldAction 接入真实 Presentation / SceneTree。

---

## Round 15 — Journey Event Presentation / SceneTree 接线

### 做了什么
第一批真实 Journey 表现接线：DialoguePanel / Speaker / Text / Hint / EventMeta、对白逐字显示、点击立即完成、WAIT 过渡状态、BATTLE Handoff、Journey Presentation regression，并加入 `tests/runtime_suite.gd`。

### 为什么
Batch 1B 的重点已经明确进入**真实 Godot SceneTree 接线**，不是继续堆 Runtime 抽象。

### 下一步
让更多 Shared Journey 使用同一套 Presentation，并逐条迁移数据。

---

## Round 16 — Shared-04 EventSequence 接线

### 做了什么
新增 `SHARED-04-EARLY-DEMON-TALES-SEQUENCE`，把黑风山早期妖患接入统一事件图，并增加 validator regression。

### 为什么
验证 Shared Journey 不需要为单个章节写专用 UI 分支，可以按 `<chapter_id>-SEQUENCE` 数据驱动运行。

### 关键边界
无战斗 Shared 章节应在 sequence END 时提交章节；带战斗章节由 `BattleResolutionService` 原子提交，Sequence 返回后不能再次完成同一章节。

### 已知问题
Shared-04 曾同时拥有 sequence reward 与 chapter reward，会产生双重发奖风险；MOVE 仍没有路径动画。

---

## Round 17 — AI 持久记忆系统

### 做了什么
建立 `docs/AI_MEMORY.md`，把历史项目级上下文、架构边界、真实验证要求和后续 Agent 接手方式沉淀到仓库。

### 为什么
聊天上下文不能作为唯一工程状态来源。

### 下一步
每轮实际代码 / 数据 / 测试 / 架构变更都追加 Round，并同步 development log。

---

## Round 18 — Shared-05 / Shared-06 EventSequence Migration

### 做了什么
继续 Batch B，把高老庄招募战与四人西行迁移到统一 EventSequence。

新增：

- `SHARED-05-GAOJIAZHUANG-SEQUENCE`
- `SHARED-06-FOUR-PERSON-JOURNEY-SEQUENCE`

Shared-05：

`arrival dialogue → BAJIE_ENCOUNTER choice → SHARED_GAOJIAZHUANG battle → after-battle dialogue → end`

Shared-06：

`depart dialogue → wait → resolve dialogue → end`

同时移除 Shared-04 sequence 中重复的 `reward(HERB)`，因为 `shared_chapters.json` 已经把 HERB 定义为章节奖励，无战斗 chapter 在 END 完成时会由 `SharedJourneyManager` 发放。这样避免同一个章节迁移后发两次奖励。

### 为什么

这一轮不是增加新的抽象，而是继续验证同一条真实运行链能连续覆盖：战斗招募 → BattleUI resume → 原子章节结算，以及无战斗章节 → END 完成 → 章节奖励。奖励唯一来源必须在迁移时明确，否则内容迁移会产生隐藏经济错误。

### 实际修改

- `data/narrative/event_sequences.json`
- `combat/test_event_sequence_validator.gd`
- `docs/development_log/2026-09-05-shared05-shared06-migration.md`

### 验证

- `EventSequenceValidator`：已在回归中加入 Shared-05 / Shared-06。
- Godot Runtime：**未确认通过**。
- 最新测试提交 combined status：`statuses: []`，没有返回 workflow run；因此不能写“Godot Runtime 通过”。

### 已知问题

- MOVE 仍为逻辑 world action，没有角色路径动画；
- WAIT 不推进独立世界时钟；
- `BountyEncounterState` 仍是兼容 Scene Handoff 层；
- Shared-07 / Shared-08 / Shared-09 尚未迁移；
- Journey Event UI 仍是基础 presentation 壳，镜头与角色演出尚未完成。

### 下一步

继续 `SHARED-07-FLOWING-SANDS → SHARED-08-PARTY-FULL → SHARED-09-FULL-PILGRIMAGE`，每条保持“数据 → Runtime → Presentation → 回归 → 真实 Godot Runtime 结果 → memory/log”。

### 接手点

下一位 Agent 先读：`docs/AI_MEMORY.md → docs/development_log/2026-09-05-shared05-shared06-migration.md → data/narrative/event_sequences.json → data/narrative/shared_chapters.json → ui/journey.gd → BattleResolutionService`。

---

# 4. 当前任务地图

## 已完成主干

- 五人 Origin / Shared 叙事结构；
- 固定世界时间线；
- 角色招募节点；
- Combat Domain 基础；
- World / Rumor / Bounty；
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
- Journey 第一批 Event Presentation；
- Shared-03 第一条真实共享 Event Sequence；
- Shared-04 / Shared-05 / Shared-06 共享迁移内容；
- Godot 4.5.1 headless runtime validation 基础设施。

## 当前优先顺序

### P0 — 真实 SceneTree / Presentation 完整化

继续让 EventSequence 在 Journey 中表现为真实的对白、选择、等待、移动反馈，并逐步增加镜头 / 角色反馈，但不能让 Presentation 接管核心剧情规则。

### P1 — Shared Journey Migration

已完成：`SHARED-04 → SHARED-05 → SHARED-06`。

下一步：`SHARED-07 → SHARED-08 → SHARED-09`。

每迁移一条：数据 → Runtime → Presentation → 回归 → development log → AI_MEMORY → 真实 Godot Runtime 状态。

### P2 — Origin Migration

五条 Origin Route 分角色逐步迁移，不能破坏固定全球时间线。

### P3 — Cleanup / Convergence

清理旧 BattleUI 结算职责，逐步把 `BountyEncounterState` 收敛成通用 Scene Handoff Service，并提高 Sequence cross-reference validation。

### P4 — Camp / Relationship

等叙事链稳定后进入 Camp / Relationship Prototype。

### P5 — Vertical Slice

目标 Vertical Slice：`一个完整角色起始路线 → 五行山 → 鹰愁涧 → 招募后 Memory`。

---

# 5. 每次以后必须写入的 Round 模板

```text
## Round XX — YYYY-MM-DD — <本轮主题>

### 做了什么
- ...

### 为什么
- ...

### 实际修改
- 文件：...
- 代码 / 数据：...
- 测试：...

### 验证
- 静态检查：...
- Godot Runtime：通过 / 失败 / pending / 未运行
- CI run / commit：...

### 已知问题
- ...

### 下一步
- ...

### 接手点
- 下一位 Agent 先读什么、从哪里继续...
```

**规则：只要本轮真的改了仓库，就必须更新本文件和对应 development log；不能靠聊天里说过了就算保存。**