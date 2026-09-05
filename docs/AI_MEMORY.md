# AI Project Memory Ledger

> 项目长期 AI / Agent 工程记忆。记录架构、事实、验证结果、边界和接手点，不依赖聊天历史。

---

## 0. 永久工作规则

### 0.1 记忆
每轮实际仓库操作都必须留下可恢复记录：做了什么、为什么、实际修改、测试、真实 Godot 运行结果、已知问题、下一步、接手点。

### 0.2 验证
静态检查 ≠ Godot Runtime。只有真实 Godot workflow 成功才能写“Godot Runtime 通过”。`queued / in_progress / pending / 无结果` 均不能写通过。

### 0.3 引擎
Godot `4.5.1 stable`。

### 0.4 架构
`Content Data → ChapterDefinition → ChapterRuntime → EventSequence/EventRunner → EventRuntime / Combat / World → Presentation`

Runner 只负责流程；Service 负责业务副作用；Presentation 负责演出。

### 0.5 固定西游时间线
`悟空被镇压 → 唐僧开始取经 → 五行山释放悟空 → 鹰愁涧白龙马 → 高老庄八戒 → 流沙河悟净 → 五人完整西行`

Memory / Flashback 只能历史回放，不得改写当前世界事实。

### 0.6 渐进迁移
旧入口允许作为兼容层；新能力优先进入统一架构，不做无必要的大重构。

### 0.7 每轮流程
`实现 → regression → 真实 Godot Runtime → development log → AI_MEMORY → 必要时更新 AI_HANDOFF`

---

## 1. 项目身份

项目：`西游：五行之路（Journey to the West: Five Elements Road）`

核心定位：经典《西游记》叙事 + 像素 HD-2D / 2.5D + 回合制 JRPG。

GitHub 当前仓库 slug：`black-myth-wukong-jrpg`。公开品牌应优先使用 `《西游：五行之路》`，不要把 `Black Myth: Wukong — JRPG Edition` 当作正式品牌，以免产生官方关系误解。

项目负责人对外统一署名：**开发者：蛋汤**。

投资、发行、商务合作及项目交流：**微信：DanTangdwcyxgs**。

游戏主菜单已提供“投资合作 / 联系开发者”入口，并可复制微信号。

---

## 2. 稳定核心链路

### Event Sequence
`EventSequence JSON → EventSequenceManager → EventSequenceDefinition → EventRunner → NarrativeEventSession → action`

支持：`dialogue / choice / wait / move / battle / reward / jump / end`。

### Battle Handoff
`Journey → NarrativeEventSession → EventRunner → EncounterHandoff(+event_resume) → BattleUI → BattleResolutionService → NarrativeEventSession.resume → Journey`

Victory atomic boundary：预检 → reward preview → state mutation → progression → world effects → Save；失败 rollback。

### Noncombat
`RewardService` / `WorldActionService` 负责副作用，Runner 不直接实现库存/世界业务。

### Scene Handoff
`BountyEncounterState` 仍是兼容层；暂不提前收敛成新的通用服务。

---

## 3. 历史工作轮次

### Round 01
建立五人 Origin / Shared 双结构与固定世界时间线。

### Round 02
建立 Combat Domain：HP / ATK / DEF / SPD / BP / Weakness / Shield / Break / Status / Formation。

### Round 03
加入五人专属基础机制、队伍、装备、消耗品与 3 前 / 2 后阵型。

### Round 04
建立 World Map / Travel / Rumor / Bounty 与黄风岭 / 黄风洞灰盒探索。

### Round 05
建立鹰愁涧、高老庄、流沙河三场共享招募战。

### Round 06
建立 `BattleResolutionService`，统一共享战斗的奖励、章节推进、世界效果和保存原子边界。

### Round 07
建立 `EventDefinition / EventRuntime`，选择数据驱动与状态持久化。

### Round 08
建立 `EventSequenceDefinition / Validator` 与 graph 校验。

### Round 09
建立 UI-independent `EventRunner` 与 snapshot。

### Round 10
建立 `NarrativeEventSession`，支持跨 Journey / BattleUI 的 `event_resume`。

### Round 11
建立 GitHub Actions Godot 4.5.1 headless runtime workflow。

### Round 12
明确 Action → Service / Handoff 边界。

### Round 13
建立 `RewardService`。

### Round 14
建立 `WorldActionService`。

### Round 15
`ui/journey.gd` 增加真实 SceneTree presentation：DialoguePanel / Speaker / Text / Hint / EventMeta、逐字、WAIT、BATTLE、Choice；加入 Journey presentation regression。

### Round 16
迁移 `SHARED-04-EARLY-DEMON-TALES-SEQUENCE`，移除 sequence reward，避免 chapter reward 双发。

### Round 17
建立 AI 持久记忆 / development log 体系。

### Round 18
迁移 Shared-05 / Shared-06。

### Round 19
迁移 Shared-07 / Shared-08 / Shared-09；Shared-03~09 主体 Sequence 完成。

### Round 20
修复 Godot 4.5.1 Journey warning-as-error 类型推断。Runtime #75 failure，修复后 #76 success，`RUNTIME_SUITE_PASS tests=11`。

### Round 21
新增 `test_shared_event_sequences.gd`，真实执行 Shared-03~09 production Sequence。#81 暴露测试自身 control-flow bug，修复后 #82 success：7/7 Sequence、3/3 battle resume、1/1 move side effect。

### Round 22
增强 Sequence cross-reference validation；迁移 Wukong WUK-01~03；新增 `ui/origin_sequence_journey.gd` 兼容桥；修复 `OriginEventManager` 缺失 event id 兼容问题。#94/#96 暴露问题，#98 success，#101 SceneTree bridge success。

### Round 23
完整迁移 Wukong `WUK-04~15`，形成 `WUK-01→WUK-15` 全链；5 个 Origin battle 均复用既有 `WUKONG_ORIGIN_*` Encounter；3 个 choice；全路线 regression。#106 是测试控制流误报，修复后 #109 **success**，Godot 4.5.1 headless suite 通过。

### Round 24
建立项目负责人署名与投资合作联系方式：
- `ui/main_menu.gd` 增加 `DEVELOPER_NAME = "蛋汤"`；
- `CONTACT_WECHAT = "DanTangdwcyxgs"`；
- 主菜单显示“开发者：蛋汤”；
- 增加“投资合作 / 联系开发者”；
- 联系面板展示微信并支持 `DisplayServer.clipboard_set()`；
- 新增 `combat/test_main_menu_contact.gd`；
- runtime suite 扩展至 14 tests；
- `docs/investor_overview.md` / `docs/project_identity.md` / development log 同步负责人身份。

本轮第一次 Runtime #115 failure，失败原因是新回归测试在 SceneTree 外直接弹 `AcceptDialog`。已经改成将 MainMenu 实例挂入 SceneTree 后再验证。

修正测试提交：`63b7e0b56d34d2ee611078b367604fe2af94740e`。

`Godot Runtime #118` 对修正后的提交需要以最终 workflow 结果为准；本记忆在写入时仍将其标为待确认。

---

## 4. Wukong Origin 当前状态

Production Sequence 已覆盖 `WUK-01~15`：
- WUK-02：`WUKONG_ORIGIN_WATER_CAVE`
- WUK-06：`WUKONG_ORIGIN_DRAGON_PALACE`
- WUK-11：`WUKONG_ORIGIN_HEAVENLY_TROOPS`
- WUK-12：`WUKONG_ORIGIN_ERLANG_SHEN`
- WUK-14：`WUKONG_ORIGIN_HEAVEN_PALACE`

Choices：WUK-03 `SEEK_FREEDOM`；WUK-08 `ACCEPT_TITLE`；WUK-13 `ENDURE`。

`ui/origin_sequence_journey.gd`：已迁移章节使用 EventSequence；未迁移章节继续 legacy；non-battle END 完成当前 Origin chapter；battle 由 `BattleResolutionService` 原子推进。

下一步：做 Wukong 整条路线的 chapter progression / save / SceneTree 端到端检查，确认 15 章从玩家入口切换章节、battle victory 推进、END 保存无断点；然后再开始 Tang Origin。

---

## 5. Shared Journey 当前边界

`shared_chapters.json` 是 Shared chapter 事实来源；Sequence 不得复制 chapter reward。

Shared-03：Longma recruitment / Eagle Sorrow / timeline 110。
Shared-04：HERB / timeline 120。
Shared-05：Bajie recruitment / Gaojiazhuang / timeline 130。
Shared-06：HERB / timeline 140。
Shared-07：Wujing recruitment / Flowing Sands / timeline 150。
Shared-08：party full / HERB / timeline 160。
Shared-09：full pilgrimage / COIN_MEDIUM / timeline 170。

`SharedJourneyManager.complete()` 是 canonical shared progression；battle chapter 必须存在 `SHARED_BATTLE_<encounter_id>` milestone。

---

## 6. 当前产品任务地图

### P0 — Journey presentation
MOVE 视觉/状态反馈；WAIT 过渡；END / chapter completion feedback；保持 Battle → Resume → END 不重复结算；必要时增加 SceneTree regression。

### P1 — Origin migration
Wukong WUK-01~15 已完成 Sequence 数据迁移；下一阶段先做 progression / save / SceneTree 端到端，再迁移 Tang / Longma / Bajie / Wujing。

### P2 — Cleanup
逐步收敛旧 BattleUI 结算职责与 `BountyEncounterState`，不得提前破坏兼容链。

### P3 — Camp / Relationship
主叙事链稳定后开始。

### P4 — Vertical Slice
`一个完整角色起始路线 → 五行山 → 鹰愁涧 → 招募 → 对应 Memory`。

### P5 — Product identity / funding
已完成开发者署名及投资合作联系方式入口。后续新增邮箱 / 官网 / Discord / 投资材料链接时，应统一更新主菜单和对外投资资料；未经负责人要求，不得自行替换微信号。

---

## 7. 接手点

优先阅读：
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-09-05-developer-credit-investor-contact.md`
- `docs/development_log/2026-09-05-wukong-full-origin-sequence-migration.md`
- `ui/main_menu.gd`
- `combat/test_main_menu_contact.gd`
- `ui/origin_sequence_journey.gd`
- `ui/journey.gd`
- `scripts/narrative/event_sequence_validator.gd`
- `scripts/narrative/event_runner.gd`
- `scripts/narrative/narrative_event_session.gd`
- `scripts/world/battle_resolution_service.gd`

任何下一轮继续：
`实现 → regression → Godot Runtime → development log → AI_MEMORY`。
