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
- 新提交：`c766f5e49e02e5d5f9c261dcc01741c612c49f`（`ui: make journey origin scene character-focused`）。

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
- `ui/main_theme.tres` 去掉了仓库中不存在的旧字体依赖，避免 Godot 启动时持续报资源缺失。

### 工程验证与修复
- 首次全局 HUD 提交曾因 `pixel_frame.gd` / `pixel_hud.gd` 的 Variant 类型推断触发 Warning treated as error；已全部显式类型化并修复。
- 主菜单重构曾暂时删掉“开发者 / 投资合作”入口；已补回，并通过现有 `test_main_menu_contact` 回归。
- Runtime #252 曾失败，根因是上述 HUD 脚本类型错误；随后修复后，最新 Runtime #255 已 SUCCESS。
- Runtime #255 的 Checkout、Godot 导入、签名探针、EventRuntime、EventRunner、完整 runtime suite 全部成功。
- Web Demo #57：Build Web Demo 的导入、runtime suite、Web export、landing page、GitHub Pages、artifact upload 全部 SUCCESS；Deploy Web Demo 最终状态需要以该 run 的最终结论为准。

### 当前稳定基线
- 当前核心代码基线（本批次结束时）：`8669c69737e7937a36167966a2b1d3abff3ebee9`。
- 全项目长期视觉规范已改为“参考图式硬朗 2D 像素 JRPG HUD”；后续所有新页面、新面板、新敌人状态框都必须沿用这一规范。
- 允许各页面在信息结构上不同，但框体几何、描边语言、色彩层级、像素密度、状态条风格必须统一。

## 2026-09-05 · 保存用户提供的视觉母版

### 参考资产
- 用户提供的战斗 UI 参考画面已保存到仓库：`docs/visual_reference/battle_ui_reference.webp`。
- 为避免仓库体积过大，仓库版采用 384×210 WebP；原始聊天参考图为 1024×559 PNG。
- 同目录新增 `docs/visual_reference/README.md`，记录该图片的用途、视觉规则与后续接手注意事项。

### 接手规则
- 后续模型开始 UI 工作前，优先查看 `docs/visual_reference/battle_ui_reference.webp` 与 `docs/visual_reference/README.md`。
- 该参考图不是某个单独战斗场景的灵感，而是全项目 HUD 的长期视觉母版。
- 不要因为页面类型不同而回到普通圆角卡片、网页表格、浅色表单或简单几何框。

## 2026-09-05 · 非图片优先开发与 AI 美术接口

### 用户新的工作分工
- 用户没有游戏开发/美术经验，因此不要求用户自己定义具体美术规范。
- 用户允许使用 Gemini Banana 等 AI 绘图工具生成最终角色、场景、特效资源。
- 当前优先完成所有非图片工程；美术资源不足不应阻塞玩法、剧情、战斗、地图、保存和 Vertical Slice。
- 程序需要提供稳定的资源接口，使未来替换图片不会修改核心游戏逻辑。

### 本轮新增
- 新增 `scripts/presentation/art_asset_catalog.gd`：统一登记角色与场景资源，提供 `character_texture()` / `scene_texture()` 等访问接口。
- `ArtAssetCatalog` 当前支持最终 PNG/WebP 优先、现有 SVG fallback；缺少最终美术时仍能运行。
- `ui/character_portrait.gd` 已实际接入 `ArtAssetCatalog`，因此肖像可以直接通过新增最终图片替换。
- `ui/visual_overlay.gd` 当前仍保留自己的路径表；尚未完全迁移到 `ArtAssetCatalog`，后续再单独收口，避免在本批次制造大范围风险。
- 新增 `docs/visual_reference/AI_ASSET_PIPELINE.md`：明确 AI 美术资源的尺寸、透明背景、轮廓、像素化、角色识别点、场景留白、HUD 禁区和换图流程。
- 新增 `docs/visual_reference/AI_ASSET_DELIVERY_SPEC.md`：进一步定义 Gemini Banana / 其他图像模型的角色、场景、VFX、动画素材交付格式、命名和质量门槛。
- 新增 `combat/test_art_asset_catalog.gd`，并加入 `tests/runtime_suite.gd`，用于在换图后自动检查所有登记资源是否仍可加载。

### 本批次技术方案
- 采用“玩法程序先行 + AI 美术后置替换”的生产策略。
- Domain / Narrative / World / Save / Presentation Layout 是程序职责。
- 角色图、场景图、怪物图、道具图、VFX、动画帧属于可替换 Presentation Assets。
- 程序通过 Asset Catalog 接受最终美术；AI 出图不应直接改变剧情、战斗和存档逻辑。
- 最终目标是先得到一套可玩的游戏，再逐批把占位 SVG 替换成高质量 PNG/WebP。

### 下一步技术优先级
1. 继续清理非图片技术债，并把已有服务真正收口到统一入口。
2. 完善 Event UI / Presentation：对白、选择、等待、移动反馈、战斗返回。
3. 完善第一条完整 Vertical Slice：五行山 → 鹰愁涧 → 白龙马加入 → 黑风山 → 黄风岭 → 黄风洞 → 黄风妖王 → 善后。
4. 完善 Camp / Relationship 等长期系统。
5. 在上述代码接口稳定后，再批量替换最终 AI 美术资源。

### 当前 CI 状态
- 最近一轮代码修改之后 GitHub Actions 已自动触发新的 Runtime / Web 流程；未拿到最终 conclusion 前，不宣称最新批次已经验证或部署完成。

### 当前稳定工作原则
- 一屏一验收仍然适用于视觉页面；工程基础系统可以连续开发，但不得借工程改动绕过用户视觉验收。
- 每个工作会话都必须继续更新本文件，记录实际 commit、测试结果、当前阻塞和后续接手位置。

### 后续模型接手注意
- 不要重新采用“圆头 + 方身体 + 简单线条”的程序人物。
- 不要把“有 SVG 资源”直接等同于“美术完成”；仍需检查画面构图、缩放、遮挡层级、角色比例、UI 占比和可玩感。
- 用户希望程序持续直接修改 GitHub 仓库、测试并提交，不要反复询问已经明确的目标。
- 用户可以使用 Gemini Banana 等工具生成最终美术；程序必须保持对图片资源的解耦。
- 用户强调每一次工作和方案都要写入 GitHub 的记忆文件，确保后续工作模型可以无缝接手。
