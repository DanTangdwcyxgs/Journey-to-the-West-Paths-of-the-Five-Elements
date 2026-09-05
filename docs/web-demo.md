# Web Demo

本项目提供 Godot 4.5.1 Web Demo，并由 GitHub Actions 构建与发布。

## 首次启用

GitHub 对新仓库需要先启用 Pages。进入仓库：

`Settings` → `Pages` → `Build and deployment` → `Source` → `GitHub Actions`

保存后，在 `Actions` → `Web Demo` → `Run workflow` 手动运行一次。

## Demo 地址

启用并成功部署后：

https://dangtangdwcyxgs.github.io/Journey-to-the-West-Paths-of-the-Five-Elements/

## CI 验证

Web Demo 在发布前会执行完整的 Godot runtime suite。当前主干已经通过 27 项自动化运行测试；Web 导出本身也已经在 CI 中成功完成。

## 说明

第一次失败不是 Godot Web 导出问题，而是仓库尚未启用 GitHub Pages。当前 workflow 已按 GitHub 官方 Pages Actions 模式配置，并为 Pages 部署提供 `pages: write` 与 `id-token: write` 权限。
