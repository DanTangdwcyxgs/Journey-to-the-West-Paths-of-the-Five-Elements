# 2026-09-05 — AI Persistent Memory System

## Goal

把项目的长期 AI 工作记忆从聊天上下文正式迁移到仓库，使新的 AI / Agent 可以只通过阅读仓库恢复开发状态，不依赖此前几十轮聊天。

## What changed

新增：

- `docs/AI_MEMORY.md`

其中包含：

- 项目长期工作规则；
- Godot 4.5.1 基准；
- 核心叙事与固定世界时间线；
- Domain / Content / Narrative / Presentation 架构边界；
- EventRunner / EventSession / Battle Handoff / RewardService / WorldActionService 的职责边界；
- 真实 Godot Runtime 验证原则；
- 当前已完成主干；
- 当前 P0-P5 工作优先级；
- 从现有仓库记录回填的历史 Round 01–16；
- 本轮 Round 17；
- 后续每轮必须使用的记录模板。

更新：

- `docs/development_log/README.md`

将 `AI_MEMORY.md` 提升为正式长期记忆入口，并规定每个有实际仓库修改的 AI 工作轮次必须同步更新长期记忆。

## Why

聊天历史不能作为唯一的工程状态来源。项目已经进入多 Agent / 多轮持续开发阶段，必须让仓库本身成为可移交的工作状态载体。

## Historical backfill scope

本次回填只保留会影响后续开发的项目级信息：做了什么、为什么、关键架构结论、验证原则和下一步。没有保存聊天闲聊，也没有把未经仓库记录支持的细节伪装成精确历史原话。

## Validation

本轮属于文档与交接机制改造，没有修改运行时代码。

- Godot Runtime：未因本轮文档变更重新运行。
- 原因：本轮没有运行时代码 / 数据变更。

## Known issues

- 历史 Round 是根据仓库现有 handoff / development logs 回填，不等价于完整聊天逐字档案；
- 后续每轮的实际代码、数据、测试和架构变化必须持续追加，否则记忆仍会再次断层；
- 当前已有 development logs 和 `AI_HANDOFF.md` 中部分历史描述可能滞后于最新实现，接手时应以最新代码 / 测试 / log 为最终事实依据。

## Next step

继续执行当前 P0：真实 Godot SceneTree / Presentation 完整化，并逐条推进 Shared Journey Migration。

## Handoff point

下一位 Agent 的推荐入口：

`docs/AI_MEMORY.md → AI_HANDOFF.md → docs/development_log/README.md → 最新 development log → 当前任务代码 / 数据 → 实际 Godot Runtime / CI`

从本轮开始，任何实际仓库修改都必须：

`实现 → 测试 → 真实运行（适用时）→ development log → AI_MEMORY Round → 必要时更新 AI_HANDOFF`
