# AI / Agent 接管说明

## 0. 你正在接手什么

这是一个 Godot 4 开发的中文像素 HD-2D 回合制 JRPG 项目。

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
- `OriginEventManager`
- `SharedEventManager`
- `StartRouteCatalog`
- `BattleResolutionService`

### World / Handoff

- `EncounterHandoff`
- `BountyEncounterState`（兼容旧入口）
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

## 6. 当前最重要的运行链

### 剧情章节

`Content Data → ChapterDefinition → ChapterRuntime → EventRuntime / Combat / World → Presentation`

### 事件

`Event Data → EventDefinition → EventRuntime → NarrativeState`

### 战斗

`Chapter/World → EncounterHandoff → BattleUI → CombatEngine → BattleResolutionService → NarrativeState`

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
- 内容批量生产规范
- 项目对外中文品牌 / 投资人入口 / AI 接管文档

注意：当前环境没有真实执行 Godot Runtime，因此任何“测试通过”只能表述为代码级回归覆盖，不得冒充运行结果。

---

## 8. 当前主要未完成项

最高优先级：

1. Godot Runtime 实机验证
2. 完整 EventSequence / EventRunner
3. Event → Battle → Event 返回链
4. Camp / Relationship Prototype
5. 第一完整 Vertical Slice
6. 五人完整 Origin Route 内容生产
7. Shared Journey 大规模内容生产
8. 战斗 UI / 动画 / 镜头 / VFX 美术化
9. HD-2D 环境正式美术
10. 音频与音乐
11. 最终测试、平衡、发行

---

## 9. 下一阶段推荐顺序

不要跳级。

### Batch 1A — Event Runtime（当前）

已经完成 Definition + 单次 Choice Runtime。

下一步补：

`EventSequence → EventRunner → Dialog / Choice / Wait / Move / Battle / Reward / Jump`

目标是做到：

`进入章节 → 对话 → 选择 → 事件 → 战斗 → 战斗返回 → 后续事件 → 章节结算`

### Batch 1B — Runtime 验证

优先建立真实 Godot SceneTree 运行入口，执行核心回归，而不是只保留静态测试文件。

### Batch 2 — Camp / Party / Relationship

`招募 → 营地 → 角色互动 → 编队 → 装备 → Memory → Relationship`

### Batch 3 — 第一完整 Vertical Slice

`五行山 → 鹰愁涧 → 白龙马 → 黑风山 → 黄风岭 → 黄风洞 → 黄风妖王 → 善后`

### Batch 4 — 五人 Origin Route 批量生产

### Batch 5 — Shared Journey 批量生产

---

## 10. 每次修改必须留下交接记录

任何有意义的代码、数据、架构、剧情或设计更新，都必须同时在：

`docs/development_log/YYYY-MM-DD-<topic>.md`

留下记录。

记录至少包含：

- 本次目标
- 修改了什么
- 为什么这样修改
- 影响了哪些系统
- 新增/修改了哪些文件
- 已知未完成项
- 测试覆盖
- 是否实际运行 Godot
- 下一步建议
- 接手 Agent 应从哪里继续

---

## 11. 更新完成后的固定动作

每次完成工作后：

1. 修改代码 / 数据
2. 添加或更新回归测试
3. 更新相关设计文档
4. 写一份 development log
5. 更新 `AI_HANDOFF.md`（如果当前状态、入口或优先级发生变化）
6. 更新 README（如果对外可见能力发生变化）
7. 提交清晰的 commit message
8. 检查工作区是否还有未处理的关键逻辑问题

---

## 12. 给未来 Agent 的一句话

**不要把这个项目当成“一个需要继续补代码的 Godot Demo”，要把它当成“已经建立基础工程、现在开始批量生产一款西游 JRPG”的长期项目。先理解世界时间线和架构边界，再动手。**
