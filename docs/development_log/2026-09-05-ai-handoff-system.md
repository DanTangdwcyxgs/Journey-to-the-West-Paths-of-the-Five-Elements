# 2026-09-05｜AI / Agent 接管体系

## 目标

降低项目换 AI、换 Agent、换开发者后的理解成本，并防止接手者因为缺少上下文而重复造轮子或破坏既有架构。

## 新规则

任何新 Agent 首先阅读：

`AI_HANDOFF.md`

之后阅读：

`DEVELOPMENT_RULES.md`
`README.md`
`docs/development_log/` 最新记录
`docs/content_pipeline.md`
`docs/architecture.md`

再开始编码。

## 每次更新必须留痕

每次有意义的代码、数据、架构、剧情、测试或文档更新，必须新增一份：

`docs/development_log/YYYY-MM-DD-<topic>.md`

内容包括：

- 目标
- 修改
- 原因
- 影响范围
- 文件
- 测试
- Runtime 验证情况
- 已知问题
- 下一步
- 接手入口

## 为什么这样做

项目会逐渐从几十个基础文件进入大量章节、事件、地图、敌人和人物内容阶段。此时最危险的不是缺少代码，而是不同 Agent 对“当前系统到底是什么状态”产生不同理解。

因此开发日志不是个人笔记，而是项目状态的一部分。

## 与 DEVELOPMENT_RULES 的关系

`DEVELOPMENT_RULES.md` 负责硬性开发纪律；本文件和 `AI_HANDOFF.md` 负责把当前项目状态和接手方法固定下来。

## 当前入口

下一项主开发任务：`Full Chapter Event Runtime`

接手者应该从 ChapterDefinition / ChapterRuntime 进入，而不是重新设计 NarrativeManager。
