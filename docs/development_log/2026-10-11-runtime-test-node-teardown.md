### Round 34 — 2026-10-11：Runtime Test Node Teardown
- 排查 Godot Runtime suite teardown 诊断：发现 `test_main_menu_contact.gd` 是在长生命周期的 suite SceneTree 进程中以 static `run_all()` 执行；它实例化了整套 MainMenu 控件和独立 AcceptDialog，却没有显式 free，控件数与 `49 CanvasItem RIDs leaked` 的日志规模吻合。
- 增加显式 `dialog.free()` 与 `instance.free()`，保证静态回归在返回结果前释放创建的节点树。
- `test_pixel_ui_font_contract.gd` 在 `hud.queue_free()` 后等待一次 `process_frame`，再退出 SceneTree，避免排队释放还未被引擎处理。
- 这是根据日志定位的测试生命周期修复，不假定它能解决全部 RID/ObjectDB 诊断；验证下一提交 runtime 日志，比较 CanvasItem / TextServer / Viewport 的剩余数量。
- 下一步：若 CanvasItem 泄漏下降，再逐项隔离剩余资源；若不变，先检查其他静态测试中的 detached Node 生命周期，不改无关战斗逻辑。
