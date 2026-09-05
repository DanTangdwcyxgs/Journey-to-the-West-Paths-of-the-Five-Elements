# 2026-09-05｜README 中文化与投资人入口

## 目标

把仓库首页从“工程 README”升级成真正的产品入口：第一次进入仓库的人，尤其是玩家、开发者、潜在合作方和投资人，可以快速理解项目是什么、怎么玩、长期为什么值得做。

## 已完成

- 新增 `README.zh-CN.md`
- 将中文项目品牌统一为《西游：五行之路》
- 新增 `docs/investor_overview.md`
- 新增 `docs/investor_pitch.md`
- 新增 `docs/project_identity.md`
- 首页结构改为：项目定位 → 核心玩法 → 五主角 → 世界时间线 → 战斗 → 探索 → Vertical Slice → 当前进度 → 长期价值 → AI 开发入口

## 重要品牌调整

旧工作名：`Black Myth: Wukong — JRPG Edition`

新的对外品牌：`《西游：五行之路》`

原因：旧名容易让外部读者误认为项目与《黑神话：悟空》存在官方关联；实际项目的核心 IP 逻辑是西游记叙事本身。

## 仓库 slug

当前 GitHub slug 仍为：

`black-myth-wukong-jrpg`

目标 slug：

`journey-west-five-elements`

工具连接目前没有 Repository Rename 写操作，所以没有伪造完成仓库改名。需要在 GitHub Settings 中执行后，再检查所有 URL 引用。

## AI 接管

本次同时建立：

- `AI_HANDOFF.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-09-05-project-branding-and-agent-handoff.md`
- `docs/development_log/2026-09-05-investor-entry-and-ai-governance.md`

后续所有重大开发更新都必须留下 Development Log。

## 测试

本次属于文档/入口/治理更新，没有运行 Godot Runtime，不应标记 Runtime Verified。

## 下一步

继续 Full Chapter Event Runtime，之后进入 Camp / Relationship，再开始第一条完整 Vertical Slice。
