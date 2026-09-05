# 2026-09-05 — Developer Credit / Investor Contact Entry

## Goal
为项目建立正式的开发者署名与投资合作联系入口，让试玩版、发行版和 GitHub 项目资料都能明确识别项目负责人，并让潜在投资人可以从游戏主菜单快速获得联系方式。

## What changed
更新 `ui/main_menu.gd`：

- 增加统一常量：`DEVELOPER_NAME = "蛋汤"`；
- 增加统一联系方式：`CONTACT_WECHAT = "DanTangdwcyxgs"`；
- 主菜单底部加入 `开发者：蛋汤` 署名；
- 增加 `投资合作 / 联系开发者` 按钮；
- 点击后显示开发者、微信号和投资/发行/商务合作说明；
- 对话框按钮支持复制微信号，使用 Godot `DisplayServer.clipboard_set()`。

新增 `combat/test_main_menu_contact.gd`：

- 验证主菜单 Scene 可以实例化；
- 验证开发者署名存在；
- 验证投资合作按钮存在；
- 验证联系面板展示开发者与微信号；
- 验证“复制微信号”操作入口存在。

更新 `tests/runtime_suite.gd`，把该测试加入完整 Godot headless regression suite。

更新 `docs/investor_overview.md` 与 `docs/project_identity.md`，统一写明：

- 开发者：蛋汤；
- 投资、发行、商务合作及项目交流：微信 `DanTangdwcyxgs`；
- 游戏主菜单提供联系入口。

## Why
联系方式应该是产品层面的正式入口，而不是散落在代码注释或聊天记录里。选择主菜单作为入口可以同时覆盖投资人试玩、公开 Demo 和正式发行版本；联系方式统一为常量，也降低后续修改时出现不一致的风险。

本轮没有增加外部网络跳转，因为微信桌面/移动端 URI 在不同发行环境下并不可靠。当前设计采用“点击入口 → 展示联系方式 → 一键复制”的跨平台方案。

## Validation

- 当前最新 `Godot Runtime` workflow 在本轮最终提交后已触发；截至日志生成时状态仍需以最新 workflow 最终结果为准。
- 新增的主菜单测试包含在完整 runtime suite 中。

## Known issues

- 当前入口提供的是复制微信号，而不是直接唤起微信客户端；这是为了避免不同操作系统与发行环境下的 URI 兼容问题。
- 后续可以增加独立的 Credits / About / Investor 页面，并进一步补充邮箱、商务邮箱、官网或 Demo 链接，但应在联系方式确定后再加入。

## Next step
优先确认最新 Godot Runtime 成功；随后继续 Origin Route 端到端章节推进验收，再进入唐僧 Origin Route 的第一批 EventSequence 迁移。

## Handoff point
主菜单、投资人概览和项目身份规范现在使用同一套开发者身份：`蛋汤` / 微信 `DanTangdwcyxgs`。后续 Agent 不应在公开 UI 或投资资料中删除该入口，除非项目负责人明确要求变更。
