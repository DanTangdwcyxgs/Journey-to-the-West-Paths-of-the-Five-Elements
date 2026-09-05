# 2026-09-05｜README 同步状态说明

本次已完成中文产品入口与投资人文档体系，并新增 `README.zh-CN.md` 作为完整中文首页内容源。

当前 GitHub connector 对既有 `README.md` 的 Contents 写操作出现接口校验冲突：服务端把 update 视为需要 blob SHA，但当前调用上下文未返回可用的最新 SHA。因此本轮没有用不可靠方式覆盖 `README.md`，避免误伤现有文件。

下一次可在获得 README 最新 blob SHA 后，将 `README.md` 原页直接切换到与 `README.zh-CN.md` 相同的中文产品入口版本。

已完成的正式入口：

- `README.zh-CN.md`
- `docs/investor_overview.md`
- `docs/investor_pitch.md`
- `docs/project_identity.md`
- `AI_HANDOFF.md`
- `docs/development_log/README.md`
- `docs/content_pipeline.md`

仓库 slug 仍保持原值；GitHub connector 没有 Repository Rename 写接口。
