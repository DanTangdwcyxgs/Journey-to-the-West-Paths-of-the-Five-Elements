# Development Log Index

所有重要开发更新都必须在本目录留下单独的 Markdown 记录。

项目长期 AI 记忆见：[`docs/AI_MEMORY.md`](../AI_MEMORY.md)。任何 AI / Agent 接手时，先阅读该文件，再按本索引进入最新 development log。

命名格式：

`YYYY-MM-DD-<topic>.md`

## 最新记录

- [`2026-09-05 — Developer Credit / Investor Contact Entry`](2026-09-05-developer-credit-investor-contact.md)
- [`2026-09-05 — Wukong Full Origin EventSequence Migration`](2026-09-05-wukong-full-origin-sequence-migration.md)
- [`2026-09-05 — Wukong Origin EventSequence Migration`](2026-09-05-origin-wukong-sequence-migration.md)
- [`2026-09-05 — Sequence Cross-Reference Validation`](2026-09-05-sequence-cross-reference-validation.md)
- [`2026-09-05 — Shared Sequence Runtime Regression`](2026-09-05-shared-sequence-runtime-regression.md)
- [`2026-09-05 — Godot Runtime Journey Parse Fix`](2026-09-05-godot-runtime-journey-parse-fix.md)
- [`2026-09-05 — Shared-07 / Shared-08 / Shared-09 EventSequence Migration`](2026-09-05-shared07-shared09-migration.md)
- [`2026-09-05 — Shared-05 / Shared-06 EventSequence Migration`](2026-09-05-shared05-shared06-migration.md)
- [`2026-09-05 — AI Persistent Memory`](2026-09-05-ai-persistent-memory.md)
- [`2026-09-05 — Event UI / Shared-04 Migration`](2026-09-05-event-ui-shared04.md)
- [`2026-09-05 — Reward / World Action Services`](2026-09-05-runtime-action-services.md)
- [`2026-09-05 — EventSession 跨战斗恢复`](2026-09-05-event-session-runtime.md)
- [`2026-09-05 — Godot Headless Runtime Validation`](2026-09-05-runtime-validation.md)
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

### AI 长期记忆规则

凡是 AI / Agent 对仓库进行实际代码、数据、测试或架构文档修改，都必须同步更新 `docs/AI_MEMORY.md`，增加一条 Round 记录。该记录只保存工作事实、决策理由、验证结果和下一步，不依赖聊天历史。

这样即使未来由不同 AI / Agent / 开发者接手，也不会依赖聊天历史才能理解项目状态。
