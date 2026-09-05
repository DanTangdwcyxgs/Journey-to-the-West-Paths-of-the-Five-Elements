# 2026-09-05｜生产型架构与项目对外定位

## 本次更新目的

本次更新不是新增一个单独玩法，而是把项目从“技术原型持续开发”进一步整理成“可以长期批量生产剧情、章节和地图的西游 JRPG 项目”。同时统一项目对外中文表达，让首次进入仓库的人能够快速理解：这是什么游戏、怎么玩、为什么值得继续开发。

## 对外定位

游戏暂定中文名：**《西游：五行之路》**

英文工作名：**Journey to the West: Five Elements Road**

核心一句话：**五个角色，五条人生起点，一条固定的西游历史；玩家选择进入谁的故事，最终与唐僧师徒一起走完西天取经。**

项目核心原则：西游故事第一，原创 JRPG 第二；JRPG 系统服务于西游人物和冲突，而不是反过来让西游角色给一个原创世界当皮肤。

## 本次架构准备

### 1. ChapterDefinition

将章节 JSON 数据转换为统一的领域定义对象，集中处理：

- id
- title
- chapter_type
- owner_character
- timeline
- prerequisites
- event
- encounter
- scene
- rewards
- world_effects
- recruit
- next

目标是让后续章节调用方尽可能依赖稳定 API，而不是散落的 Dictionary key。

### 2. ChapterRuntime

建立统一章节运行前置层，负责：

- 章节是否存在
- 是否已经完成
- 招募条件是否满足
- 章节目的地属于 Event / Battle / Chapter
- 下一章节路由

未来会继续扩展 prerequisite、timeline gate、memory spoiler guard、scene execution 等能力。

### 3. EncounterHandoff

建立与悬赏系统命名无关的中立战斗交接概念。当前继续兼容 `BountyEncounterState`，采用渐进迁移，不破坏现有世界地图和黄风洞流程。

标准目标链：

`Chapter / World → EncounterHandoff → BattleUI → CombatEngine → BattleResolutionService`

### 4. BattleResolutionService

继续作为叙事战斗胜利的原子提交边界：

`Preflight → Reward Preview → State Mutation → Progression → World Effects → One Save`

失败必须恢复快照。

### 5. NarrativeState Choice API

将 Shared Choice 从事件管理器直接写 Dictionary，逐步收敛为明确的状态 API，降低后期系统之间互相知道内部存储结构的风险。

## 内容生产准备

新增 `docs/content_pipeline.md`，规定未来章节的：

- 设计输入
- 数据制作
- 事件制作
- 战斗制作
- 地图制作
- 测试
- Review
- 发布前检查

核心思想：**未来增加一个章节应该主要是生产内容，而不是重新发明程序。**

## README 对外入口调整

README 改为中文优先，并增加：

- 项目愿景
- 玩家怎么玩
- 五人起始路线
- 固定世界时间线
- 招募与个人故事
- 战斗系统
- 世界探索
- 当前完成内容
- 当前未完成内容
- 长期路线图
- 对投资人/合作方的项目价值说明

## AI / Agent 接管机制

新增 `AI_HANDOFF.md`。

要求后续 Agent 首先阅读：

1. `AI_HANDOFF.md`
2. `DEVELOPMENT_RULES.md`
3. `README.md`
4. 核心设计文档
5. 最新 development log

并明确要求每一次有意义的开发更新必须留下：

`docs/development_log/YYYY-MM-DD-<topic>.md`

记录目标、改动、影响、文件、测试、未完成项和下一步入口。

## 重要已知限制

当前 GitHub 工具连接提供了文件/提交等仓库操作，但没有提供“重命名仓库”的写操作接口。因此本次可以直接完成游戏名、README、文档体系和内部项目信息的中文化，但 GitHub 仓库 slug 本身仍需通过 GitHub 网页的 Repository Settings 手动重命名。

在仓库 slug 尚未重命名前，不要批量修改所有历史链接；GitHub 重命名后应统一检查 README、文档链接、脚本、CI、外部引用。

## 测试状态

本次仅完成架构和文档准备，没有声称 Godot Runtime 已通过。Runtime 验证仍属于后续工作。

## 下一步

首要开发批次：**Full Chapter Event Runtime**。

目标是让一个标准章节真正能够执行：

`进入章节 → 场景/对话 → 选择 → 事件 → 战斗 → 胜利结算 → 下一章节`

然后进入：

`Camp / Relationship → 第一完整 Vertical Slice → 五条 Origin Route 批量生产 → Shared Journey 批量生产`

## 接手说明

未来 Agent 不应该继续无目的堆 Manager。优先复用 `ChapterDefinition`、`ChapterRuntime`、`NarrativeManager`、`NarrativeState`、`BattleResolutionService` 和 `EncounterHandoff`，只有发现明确职责缺口时才新增服务。
