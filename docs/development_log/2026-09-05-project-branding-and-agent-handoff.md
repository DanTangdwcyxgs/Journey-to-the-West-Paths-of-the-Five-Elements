# 2026-09-05｜项目中文品牌、投资人入口与 AI 接管体系

## 目标

本次更新解决三个长期问题：

1. 仓库首页没有用最短路径讲清楚游戏构想和玩法。
2. 外部读者尤其是投资人、合作开发者无法快速理解项目长期价值。
3. 未来由其它 AI / Agent 接手时过度依赖聊天历史，存在乱改架构、重复造轮子和破坏剧情时间线的风险。

## 项目品牌

当前工作名统一为：

**《西游：五行之路》**

英文工作名：

**Journey to the West: Five Elements Road**

公开介绍应优先使用中文项目名。

旧名 `Black Myth: Wukong — JRPG Edition` 不再作为对外品牌主标题，避免外部产生与《黑神话：悟空》官方关联的误解。

## 对外 README

README 改为中文优先的产品入口，重点回答：

- 这是什么游戏？
- 玩家怎么玩？
- 为什么五个角色都能开局？
- 为什么不会改变西游历史？
- 五个角色分别有什么玩法和人物主题？
- 战斗怎么玩？
- 81 难怎么规划？
- 当前项目做到哪里？
- 下一阶段做什么？
- 为什么这个项目适合长期扩展？

并新增投资人/合作方详细介绍入口：

`docs/investor_overview.md`

## AI / Agent 接管体系

新增根目录：

`AI_HANDOFF.md`

该文件规定未来 Agent 的固定接手顺序、架构边界、叙事硬规则、当前能力、当前缺口和下一步。

新增：

`docs/development_log/README.md`

定义开发日志格式。

并要求每次重要更新新增：

`docs/development_log/YYYY-MM-DD-<topic>.md`

日志必须包含：

- 目标
- 修改内容
- 修改原因
- 影响范围
- 文件
- 测试
- Runtime 是否真实验证
- 已知问题
- 下一步
- Agent 接手入口

## 内容生产规范

新增：

`docs/content_pipeline.md`

统一未来章节、事件、战斗、地图、招募、Memory、奖励和测试的制作方法。

核心原则：

> 不为一个章节写一次性程序，而是为未来 100 个章节建立标准。

## 重要架构判断

不进行全项目推倒重做。

保留现有 Combat / Narrative / World 基础，新增 Definition / Runtime / Pipeline 层，采取渐进迁移。

## GitHub 仓库名称限制

本次可以修改仓库内的游戏品牌、README、项目文档和内部项目信息，但当前 GitHub connector 没有提供 Repository Rename 写接口，因此无法在工具层直接将 GitHub slug 改名。

目标 slug：

`journey-west-five-elements`

执行 GitHub 仓库改名后，应检查：

- README 链接
- Git remote
- CI / Actions
- 外部文档链接
- 任何硬编码仓库 URL

## 测试状态

本次为文档、架构治理和项目入口更新，没有声称 Godot Runtime 已通过。

## 下一步

继续执行：

**Full Chapter Event Runtime**

目标：让数据定义的章节真正能被统一 Runtime 执行，并把章节内容生产从“脚本式”逐步变成“数据驱动 + 通用 Runtime”。
