# Development Log Index

所有重要开发更新都必须在本目录留下单独的 Markdown 记录。

命名格式：

`YYYY-MM-DD-<topic>.md`

最新进展首先阅读根目录 `AI_HANDOFF.md`，然后阅读本目录中最新的一条记录。

## 最新记录

- [`2026-09-05 — EventSequence / EventRunner 运行骨架`](2026-09-05-event-runner.md)
- [`2026-09-05 — Chapter Event Runtime 第一批部署`](2026-09-05-chapter-event-runtime.md)

## 规则

一次更新可以包含多个 commit，但应至少对应一份交接记录。

记录必须说明：

- 目标
- 具体修改
- 修改原因
- 影响范围
- 文件变化
- 测试覆盖
- Godot Runtime 是否真实运行
- 已知问题
- 下一阶段
- 接手 Agent 的起点

这样即使未来由不同 AI、Agent 或开发者接手，也不会依赖聊天历史才能理解项目状态。
