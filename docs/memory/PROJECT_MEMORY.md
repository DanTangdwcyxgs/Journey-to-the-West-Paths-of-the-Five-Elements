# 《西游：五行之路》项目持续记忆

> 用途：供后续工作模型接手。每次工作会话结束后，在本文件追加一条记录。不要删除既有记录；以最新记录为当前状态，并保留历史决策与已验证结果。

## 2026-09-05 · 视觉重构阶段 / 会话记录

### 用户核心反馈
- 当前像素人物此前存在严重问题：基本是“一个方框一个圆形”，不像真正可玩的 JRPG 像素角色。
- 用户要求继续推进，但采用“一屏一验收”：完成一个画面后先让用户进入查看，再做下一屏。
- 本阶段视觉目标：真正的低分辨率像素 JRPG，而不是程序几何占位。角色必须通过轮廓、发型/头饰、服装、武器、阴影、配色和动作空间形成识别度。

### 本阶段已完成
- 建立独立像素角色资产：悟空、唐僧、八戒、悟净、龙马、黄风怪。
- 建立像素场景资产：旅途场景、黄风战斗场景、取经路线地图。
- `ui/visual_overlay.gd` 已从程序几何人物切换到加载 SVG 像素资产；统一使用 `TEXTURE_FILTER_NEAREST`，保持像素边缘。
- `ui/character_portrait.gd` 已切换到同套像素角色资源，避免场景与肖像画风分裂。
- Runtime 回归已增加像素资产加载验证。

### 工程验证
- Godot Runtime #238：SUCCESS。
- 最新已验证 Runtime commit：`1ef2c0cf02973aafbf002795ee37c4e8a7809cf1`。
- Runtime suite 当前通过 28 项测试。
- Web Demo 在视觉提交线上重新触发构建；早先暴露的 `character_portrait.gd` 类型推断错误已修正。

### CI 发现
- Web 构建早期导入阶段曾出现字体资源尚未完成导入的问题；工作流已有 Godot asset import warm-up。
- `character_portrait.gd` 曾因 `target` 从 Variant 推断失败导致 Warning treated as error；已显式类型化并重新触发 Web 构建。
- 不要把 pending / in_progress CI 描述成已经部署成功；以后以最新 run 的最终 conclusion 为准。

### 一屏一验收规则
1. 一次只修改一个可直接进入查看的画面。
2. 修改完成后运行 Runtime 与 Web CI 验证。
3. 验证完成后只让用户验收当前屏幕，不提前自动修改下一屏。
4. 用户反馈后再进入下一屏。
5. 优先顺序：主菜单 → 个人序章第一场景 → 共享旅途场景 → 黄风岭 → 战斗 → 地图/其他辅助界面。

### 主菜单单屏
- `ui/main_menu.gd` 已完成第一版 JRPG 标题画面重构。
- 主菜单采用西游场景背景、标题/副标题、角色选择、开始/继续入口和少量存档信息。
- 提交：`d22a41ac7993f87340905281220838b769e1c7ef`。
- 用户随后发送“继续”，因此主菜单视为通过当前阶段验收，进入下一屏。

### 本轮新增：个人序章第一场景
- 重做 `ui/journey.gd` 的视觉结构：删除旧式“左侧大量剧情数据 + 右侧路线 ItemList”的仪表盘式布局。
- 新结构改为：西游场景占主要视觉区域；顶部显示章节信息；底部居中大对话框；选项/继续/回忆/队伍/地图/保存等功能收进对话框与底栏。
- 保留原有叙事、选项、战斗接管、共享主线、存档和队伍逻辑。
- `ui/visual_overlay.gd` 同步调整：进入个人序章时不再把五人横排在画面中，而是突出当前起始角色的大像素立绘，并加入地面阴影和少量场景地标；进入共享旅途后才恢复五人队伍构图。
- 新提交：`b24c93787848bf6bb148e96de75eff908b7ace9b`（`ui: rebuild opening journey scene as jrpg dialogue screen`）。
- 新提交：`c766f5e49e02e5d5d5f9c261dcc01741c612c49f`（`ui: make journey origin scene character-focused`）。

### 当前验收状态
- Web Demo run #45 已针对 `c766f5e...` 自动触发，目前状态为 queued，尚未得到最终 conclusion；因此不能宣称 Web 已部署完成。
- 本轮代码已进入 GitHub 默认分支，等 CI 最终结果后让用户进入检查个人序章第一场景。
- 当前不要继续改共享旅途、黄风岭、战斗或地图屏，先等待用户对这一屏的视觉反馈。

## 2026-09-05 · 用户提供新视觉标准：统一全项目像素 UI

### 新参考标准
- 用户提供战斗画面参考图，要求全项目统一向该视觉语言靠拢，而不是只改战斗屏。
- 核心视觉规范：硬朗 2D 像素 UI、45°切角装甲面板、双层描边、青绿色主高亮、金色/橙色战斗高亮、深蓝黑底、细密点阵装饰、顶部行动顺序条、右上目标/HP/弱点/护盾框、底部角色状态与 COMMAND 面板。
- “像素”不等于黑底+普通字体；构图、信息层级和框体形状必须明显接近示例图的 JRPG 战斗 HUD。

### 本轮代码改动
- 新增 `ui/pixel_frame.gd`：可复用的 45°切角装甲 `PanelContainer`，支持双层边框、点阵、铆钉式装饰和像素最近邻过滤。
- 新增 `ui/pixel_ui.gd`：全局 UI Theme 工厂，统一 Button / ItemList 的深色装甲底、青色 hover、金色 pressed、硬边框和紧凑字体规格。
- 新增 `ui/pixel_hud.gd`：全局 HUD 皮肤层，按照当前场景自动绘制主菜单、剧情、战斗、世界地图、黄风场景的切角装甲框；战斗额外绘制 TURN / ACTION QUEUE、TARGET / HP / WEAK / SHIELD、角色 FRAME STATUS、COMMAND // ACT 和分段式状态条。
- `ui/visual_overlay.gd` 接入 `PixelHUD`，使全项目自动获得统一 HUD 皮肤，同时保留原有场景背景和角色层。

### 工程状态
- 全局视觉提交：`064ffbfca63e09590544fbe5d2e0392b2d92c75e`，message=`ui: apply global pixel HUD skin to all screens`。
- 当前 Godot Runtime #249 正在执行；前置的 Checkout / Setup Godot / Verify Godot 已通过，`Import project and register scripts` 当时仍 in_progress，尚未拿到最终 conclusion。
- 当前 Web Demo 的上一条 build 已存在；不要把 in_progress / queued 描述成部署成功。

### 当前执行方式
- 用户明确要求可以直接参照该战斗示例图调整“其他所有画风”。因此本规范视为全项目长期视觉规范，而不是单个战斗页面的临时主题。
- 下一次模型接手前，优先等待 `064ffb...` 的 Runtime / Web CI 最终结论，再根据用户验收反馈决定是否继续逐屏精修；不要恢复旧式网页表单风格。

### 后续模型接手注意
- 不要重新采用“圆头 + 方身体 + 简单线条”的程序人物。
- 不要把“有 SVG 资源”直接等同于“美术完成”；仍需检查画面构图、缩放、遮挡层级、角色比例、UI 占比和可玩感。
- 用户希望程序持续直接修改 GitHub 仓库、测试并提交，不要反复询问已经明确的目标。
- 每个工作会话都必须把实际改动、测试、当前 commit、未完成事项和下一步写入本文件。
