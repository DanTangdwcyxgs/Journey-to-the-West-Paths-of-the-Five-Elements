# 2026-09-05｜投资人入口与 AI 开发治理

## 目标

让任何第一次打开 GitHub 仓库的人，在首页快速理解项目；同时让未来任何 AI / Agent 可以不依赖聊天历史、安全接手项目。

## 已完成

- 中文游戏品牌统一为《西游：五行之路》
- 英文工作名统一为 `Journey to the West: Five Elements Road`
- 新增 `docs/project_identity.md`
- 新增 `docs/investor_overview.md`
- 新增 `docs/investor_pitch.md`
- 新增 `AI_HANDOFF.md`
- 新增 `docs/development_log/README.md`
- 已建立“每次重大更新必须留下 development log”的硬性流程
- `docs/content_pipeline.md` 作为未来批量内容生产规范

## 对外沟通重点

README 应优先回答：

1. 这是什么游戏？
2. 玩家怎么玩？
3. 五个起始角色是什么关系？
4. 为什么五个起点不会产生五个平行世界？
5. 战斗有什么独特玩法？
6. 游戏为什么具备长期内容扩展价值？
7. 当前已经做到了哪里？
8. 接下来怎么从 Vertical Slice 扩大到完整西游？

## AI 接手重点

新 Agent 必须先读 `AI_HANDOFF.md`，然后读 `DEVELOPMENT_RULES.md` 和最新开发日志，再查看任务相关代码。

禁止：

- 看到 TODO 就直接实现
- 重复建立已经存在的 Manager / Service
- 绕过 NarrativeState 修改世界进度
- 让 UI 自己决定核心剧情
- 让 Event 自己发奖励
- 在未检查时间线的情况下添加剧情

## 仓库改名限制

目标 GitHub slug：`journey-west-five-elements`。

当前工具没有 Repository Rename 写接口，因此暂时没有伪造“仓库已改名”。游戏品牌已经完成中文化；仓库 slug 需要在 GitHub Settings 手动修改。

## 测试状态

本次没有运行 Godot Runtime，因此不得标记为 Runtime Verified。

## 下一步

继续进入 Full Chapter Event Runtime，优先建立标准章节的真实事件执行循环。
