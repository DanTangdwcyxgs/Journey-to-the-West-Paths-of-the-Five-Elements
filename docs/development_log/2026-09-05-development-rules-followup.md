# 2026-09-05｜Development Rules follow-up

本次确认 AI 接管与开发日志制度已经建立在 `AI_HANDOFF.md` 和 `docs/content_pipeline.md`。

由于当前 GitHub connector 对已存在文件的 Contents update 出现 SHA 参数校验冲突，本轮没有覆盖 `DEVELOPMENT_RULES.md`，避免误写。

当前生效的实际硬性规则仍包括：

- 发现逻辑错误先警告并坚持更优方案
- 固定西游时间线
- 不重复创建 Manager / Service
- 不让 UI 越权拥有核心规则
- 重要更新必须留下 development log
- 不得虚报 Godot Runtime 验证

未来获得正常文件更新接口后，应把“每次重要更新必须留下日志”同步追加到 `DEVELOPMENT_RULES.md`。
