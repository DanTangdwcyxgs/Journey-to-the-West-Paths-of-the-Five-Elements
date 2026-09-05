# AI Project Memory Ledger

> 这是本项目给 AI / Agent 使用的**长期工作记忆**。
>
> 目的不是保存聊天原文，而是保存：**我们已经做了什么、为什么这么做、哪些边界不能破坏、实际验证到了哪里、下一步从哪里继续。**
>
> 任何新的 AI / Agent 接手项目时，应先读本文件，再读 `AI_HANDOFF.md` 和 `docs/development_log/` 最新记录。聊天历史不是项目唯一事实源。

---

## 0. 永久工作规则

### 0.1 记忆原则

每一轮有实际项目操作，都必须留下可恢复的记录。记录只写：

- 本轮做了什么；
- 为什么这么做；
- 实际修改了什么；
- 测试 / 真实运行结果；
- 当前已知问题；
- 下一步；
- 给下一位 Agent 的接手点。

不保存无关闲聊，不需要保存用户原话逐字稿。

### 0.2 绝不能用“看起来应该能跑”替代验证

代码检查、静态推断和真实 Godot Runtime 是三件不同的事情。

只有实际运行结果才能写成“Godot Runtime 通过”。如果 CI 是 `pending`、没有返回检查项，必须如实记录为未确认，不能提前宣布通过。

### 0.3 当前引擎基准

项目运行基准：**Godot 4.5.1 stable**。

### 0.4 核心架构原则

`Content Data → ChapterDefinition → ChapterRuntime → EventSequence/EventRunner → EventRuntime / Combat / World → Presentation`

Runner 负责流程，不负责 UI；NarrativeState 负责世界事实；Service 负责状态副作用；Presentation 负责呈现。

### 0.5 西游时间线不可被玩家顺序改写

玩家可以选择五人任意一人为起点，但世界历史始终只有一条固定时间线。

大方向：

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

标准 action：

`dialogue / choice / wait / move / battle / reward / jump / end`

`EventRunner` 不创建 UI，不直接启动 BattleUI，不把库存、世界位置等业务副作用硬编码到 Runner 中。

## 2.2 Battle Handoff

推荐真实链路：

`Journey → NarrativeEventSession → EventRunner → EncounterHandoff(+event_resume) → BattleUI → BattleResolutionService → NarrativeEventSession.resume → Journey`

Battle 胜利边界：

`预检 → 奖励预览 → 状态变更 → 剧情推进 → 世界效果 → 最终 Save`

失败需要回滚。

## 2.3 非战斗副作用

已经建立：

- `RewardService`：统一 narrative reward 的实际库存副作用；
- `WorldActionService`：统一 `move / wait` 的世界动作入口。

因此不要再把奖励或世界修改直接塞回 `EventRunner`。

## 2.4 Scene Handoff

`BountyEncounterState` 目前仍兼容旧入口，同时承载 EventSession resume context。

后续目标：逐步收敛为更明确的通用 Scene Handoff Service，但没有必要为了这个目标现在就破坏兼容链。

---

# 3. 历史工作记录（截至本记忆文件建立前）

> 下面是根据仓库中的 `AI_HANDOFF.md`、development logs 和当前实现状态整理的**项目级工作记忆回填**。不是聊天逐字稿；只保留影响后续开发的动作、理由和结论。

## Round 01 — 五人起始路线与固定世界时间线

### 做了什么
建立了五人可选起点与 Origin / Shared 双结构。

### 为什么
玩家需要自由选择第一视角，但西游历史不能因为选择角色而重排。

### 核心结论
选择角色 ≠ 改写历史。角色被招募的经典节点仍是固定世界事件。

### 下一步
围绕固定世界时间线建立章节、招募和 Memory 解锁。

---

## Round 02 — 战斗 Domain 基础

### 做了什么
形成 `Combatant / CombatEngine / CombatAction` 及 HP、ATK、DEF、SPD、BP、Weakness、Shield、Break、Status、Formation 等核心规则。

### 为什么
战斗必须成为稳定的 Domain 层，而不是由 UI 拼规则。

### 下一步
继续补充技能、敌人、Encounter 和数据驱动内容。

---

## Round 03 — 五人专属机制与队伍基础

### 做了什么
加入五人角色基础差异、3 前排 / 2 后排、队伍保存读取、装备和消耗品等基础能力。

### 为什么
JRPG 系统要服务人物，而不是堆系统数量。

### 下一步
把这些能力接到西游叙事与实际 Encounter。

---

## Round 04 — World / Rumor / Bounty / 灰盒探索

### 做了什么
建立 World Map / Travel / Rumor / Bounty，以及黄风岭 / 黄风洞灰盒探索链。

### 为什么
先建立“西游世界可以被游玩”的基础，再把剧情事件接进去。

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
统一 `BattleResolutionService`，把战斗奖励、章节推进、世界效果和保存纳入一个明确边界，并加入回滚思想。

### 为什么
避免“奖励发了但章节没推进”“章节推进了但奖励失败”“重复保存/重复结算”等一致性问题。

### 下一步
把这个边界作为 Event Sequence 战斗节点的后端结算标准。

---

## Round 07 — EventDefinition / EventRuntime

### 做了什么
建立数据驱动的 EventDefinition / EventRuntime，并统一 Origin / Shared 的事件选择执行入口。

### 为什么
事件选择需要持久化，不能依赖 UI 按钮本身保存状态。

### 下一步
从单事件扩展到多节点 Event Sequence。

---

## Round 08 — EventSequenceDefinition / 图结构验证

### 做了什么
建立 Event Sequence 数据结构和 `EventSequenceDefinition.validate()` 图连接校验。

### 为什么
剧情流程应该由数据图表达，而不是散落在 Journey UI 里的硬编码 if/else。

### 下一步
建立真正执行图的 Runner。

---

## Round 09 — EventRunner 多节点执行

### 做了什么
建立 `EventRunner`，支持 `dialogue / choice / wait / move / battle / reward / jump / end`，并保存 runner snapshot 供恢复。

### 为什么
把“章节描述什么”和“流程怎么走”拆开，让同一套 Runtime 可运行不同内容。

### 下一步
建立独立 Session，处理跨场景和跨战斗恢复。

---

## Round 10 — NarrativeEventSession / Battle Resume

### 做了什么
建立 `NarrativeEventSession`，让 EventRunner 的未完成流程可以通过 `event_resume` 跨 Journey / BattleUI 恢复。

### 为什么
战斗不是剧情流程的终点，而是流程中的一个 action；战斗结束必须回到原 Sequence 的下一节点。

### 下一步
加入真实 Godot Runtime 回归，证明链路不是静态代码拼接。

---

## Round 11 — 真实 Godot Runtime 验证

### 做了什么
建立 GitHub Actions Godot headless runtime workflow，使用 **Godot 4.5.1 stable** 验证项目导入、GDScript probe、EventRuntime、EventRunner、EventSession、战斗恢复等能力。

### 为什么
项目明确要求不再用“代码看起来正确”代替运行验证。

### 核心结论
以后只有真实 Godot Runtime / CI 结果才可写“通过”。

### 下一步
把已验证的 Runtime 真正接入 Godot SceneTree / Journey 场景表现。

---

## Round 12 — EventSequence → EventRunner → Action → Service / Handoff

### 做了什么
明确 action 的职责边界：Runner 只请求动作；Reward / World / Battle 通过各自 Service 或 Handoff 执行。

### 为什么
防止 Runner 变成一个同时懂库存、世界、UI、战斗的巨大 God Object。

### 下一步
继续接真实 Presentation 和 SceneTree。

---

## Round 13 — RewardService

### 做了什么
建立 `scripts/items/reward_service.gd`，把 narrative `reward` action 的实际库存写入统一到 Service，并加入 `combat/test_reward_service.gd` 回归。

### 为什么
奖励副作用必须集中，避免未来每个剧情节点自己写 inventory。

### 下一步
同样处理 `move / wait` 的世界副作用。

---

## Round 14 — WorldActionService

### 做了什么
建立 `scripts/world/world_action_service.gd`，统一 `move / wait` 的执行入口，并加入 `combat/test_world_action_service.gd`。

### 为什么
世界动作应该和奖励一样拥有清晰 Service 边界，Runner 不直接修改世界内部状态。

### 注意
当前 `move` 主要记录逻辑地点 / visited node；`wait` 当前验证动作但不推进独立世界时钟。这是已知限制，不应伪装成完整探索表现。

### 下一步
把 WorldAction 接入真实 Presentation / SceneTree。

---

## Round 15 — Journey Event Presentation / SceneTree 接线

### 做了什么
对 `ui/journey.gd` 做第一批真实 Journey 表现接线：

- DialoguePanel / Speaker / Text / Hint / EventMeta；
- dialogue 逐字显示与点击立即完成；
- WAIT 的过渡状态与计时；
- BATTLE 保持 Handoff 边界并启动 BattleUI；
- 为 presentation 增加回归测试 `combat/test_journey_event_presentation.gd`；
- 加入 `tests/runtime_suite.gd`。

### 为什么
Batch 1B 的重点不是继续堆 Runtime 抽象，而是进入**真实 Godot SceneTree 接线**。这也是此前讨论中最容易被误记的关键点：这里的下一步核心不是再次抽象 EventRunner，而是让已经验证的流程进入真实场景节点生命周期。

### 下一步
让更多 Shared Journey 章节使用同一套 Journey Event Presentation，并逐条迁移数据。

---

## Round 16 — Shared-04 EventSequence 接线

### 做了什么
新增：

`SHARED-04-EARLY-DEMON-TALES-SEQUENCE`

当前数据流程为：

`departure dialogue → move(BLACK_WIND_NORTH_PATH) → warning dialogue → wait → resolve dialogue → reward(HERB) → end`

并在 `combat/test_event_sequence_validator.gd` 中加入 Shared-04 sequence 校验。

### 为什么
证明 Shared Journey 不再需要为单个章节写专用 UI 分支，而可以按 `<chapter_id>-SEQUENCE` 读取数据。

### 重要架构边界
Shared 无战斗章节应在 sequence 完成时提交章节；带战斗的章节由 `BattleResolutionService` 完成原子章节提交，Sequence 返回后不能再次完成同一章节，否则会重复推进。

### 已知问题
Shared-04 当前 sequence 内存在 reward，而章节数据本身也存在奖励定义；正式收敛前必须避免双重发奖。MOVE 目前仍是逻辑 world action，没有路径动画。

---

## Round 17 — AI 持久记忆系统（本轮）

### 做了什么
建立本文件 `docs/AI_MEMORY.md`，把历史项目级上下文、架构边界、真实验证要求和后续 Agent 接手方式沉淀到仓库。

同时把“以后每轮有实际操作都要记下来”正式设为项目工作规则。

### 为什么
聊天上下文不能作为唯一项目记忆。任何新的 AI / Agent 都应该能够只读仓库，就恢复：做到了哪里、为什么这么做、下一步是什么。

### 下一步
从本轮开始，每一个有实际代码 / 数据 / 测试 / 架构变更的工作轮次，都在本文件新增一条 `Round XX`，并同步 `docs/development_log/`。

### 接手点
下一位 Agent：先读本文件 → `AI_HANDOFF.md` → `docs/development_log/README.md` → 最新 development log → 当前任务代码 / 数据 → 再开始修改。

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
- Shared-04 第一条新增共享迁移内容；
- Godot 4.5.1 headless runtime validation 基础设施。

## 当前优先顺序

### P0 — 真实 SceneTree / Presentation 完整化

继续让 EventSequence 在 Journey 中表现为真实的对白、选择、等待、移动反馈，并逐步增加镜头 / 角色反馈，但不能让 Presentation 接管核心剧情规则。

### P1 — Shared Journey Migration

按顺序逐条迁移：

`SHARED-04 → SHARED-05 → SHARED-06 → SHARED-07 → SHARED-08 → SHARED-09`

每迁移一条：数据 → Runtime → Presentation → 回归 → development log。

### P2 — Origin Migration

五条 Origin Route 分角色逐步迁移，不能破坏固定全球时间线。

### P3 — Cleanup / Convergence

清理旧 BattleUI 结算职责，逐步把 `BountyEncounterState` 收敛成通用 Scene Handoff Service，并提高 Sequence cross-reference validation。

### P4 — Camp / Relationship

等叙事链稳定后进入 Camp / Relationship Prototype。

### P5 — Vertical Slice

目标 Vertical Slice：

`一个完整角色起始路线 → 五行山 → 鹰愁涧 → 招募后 Memory`

---

# 5. 每次以后必须写入的 Round 模板

复制以下模板作为新的一轮：

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
