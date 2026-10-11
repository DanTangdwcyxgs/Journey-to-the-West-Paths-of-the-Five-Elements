# AI Project Memory Ledger

> 项目长期 AI / Agent 工程记忆。记录架构、事实、验证结果、边界和接手点，不依赖聊天历史。

---

## 0. 永久工作规则

### 0.1 记忆
每轮实际仓库操作都必须留下可恢复记录：做了什么、为什么、测试、真实 Godot 运行结果、已知问题、下一步、接手点。

### 0.2 验证
静态检查 ≠ Godot Runtime。只有真实 Godot workflow 成功才能写“Godot Runtime 通过”。`queued / in_progress / pending / 无结果` 均不能写通过。

### 0.3 引擎
Godot `4.5.1 stable`。

### 0.4 架构
`Content Data → ChapterDefinition → ChapterRuntime → EventSequence/EventRunner → EventRuntime / Combat / World → Presentation`

Runner 只负责流程；Service 负责业务副作用；Presentation 负责演出。

### 0.5 固定西游时间线
`悟空被镇压 → 唐僧开始取经 → 五行山释放悟空 → 鹰愁涧白龙马 → 高老庄八戒 → 流沙河悟净 → 五人完整西行`

Memory / Flashback 只能历史回放，不得改写当前世界事实。

### 0.6 渐进迁移
旧入口允许作为兼容层；新能力优先进入统一架构，不做无必要的大重构。

### 0.7 每轮流程
`实现 → regression → 真实 Godot Runtime → development log → AI_MEMORY → 必要时更新 AI_HANDOFF`

---

## 1. 项目身份

项目：`西游：五行之路（Journey to the West: Five Elements Road）`

核心定位：经典《西游记》叙事 + 像素 HD-2D / 2.5D + 回合制 JRPG。

GitHub 当前仓库 slug：`black-myth-wukong-jrpg`。公开品牌优先使用 `《西游：五行之路》`，不要把 `Black Myth: Wukong — JRPG Edition` 当正式品牌，避免官方关系误解。

项目负责人：**开发者：蛋汤**。

投资、发行、商务合作及项目交流：**微信：DanTangdwcyxgs**。

主菜单已提供“投资合作 / 联系开发者”入口与复制微信号能力。

---

## 2. 稳定核心链路

### Event Sequence
`EventSequence JSON → EventSequenceManager → EventSequenceDefinition → EventRunner → NarrativeEventSession → action`

支持：`dialogue / choice / wait / move / battle / reward / jump / end`。

### Battle Handoff
`Journey → NarrativeEventSession → EventRunner → EncounterHandoff(+event_resume) → BattleUI → BattleResolutionService → NarrativeEventSession.resume → Journey`

Victory atomic boundary：预检 → reward preview → state mutation → progression → world effects → Save；失败 rollback。

### Noncombat
`RewardService` / `WorldActionService` 负责副作用，Runner 不直接实现库存/世界业务。

### Scene Handoff
`BountyEncounterState` 仍是兼容层；暂不提前收敛成新的通用服务。

---

## 3. 历史工作轮次

### Round 01
建立五人 Origin / Shared 双结构与固定世界时间线。

### Round 02
建立 Combat Domain：HP / ATK / DEF / SPD / BP / Weakness / Shield / Break / Status / Formation。

### Round 03
加入五人专属基础机制、队伍、装备、消耗品与 3 前 / 2 后阵型。

### Round 04
建立 World Map / Travel / Rumor / Bounty 与黄风岭 / 黄风洞灰盒探索。

### Round 05
建立鹰愁涧、高老庄、流沙河三场共享招募战。

### Round 06
建立 `BattleResolutionService`，统一共享战斗奖励、章节推进、世界效果和保存原子边界。

### Round 07
建立 `EventDefinition / EventRuntime`，选择数据驱动与状态持久化。

### Round 08
建立 `EventSequenceDefinition / Validator` 与 graph 校验。

### Round 09
建立 UI-independent `EventRunner` 与 snapshot。

### Round 10
建立 `NarrativeEventSession`，支持跨 Journey / BattleUI 的 `event_resume`。

### Round 11
建立 GitHub Actions Godot 4.5.1 headless runtime workflow。

### Round 12
明确 Action → Service / Handoff 边界。

### Round 13
建立 `RewardService`。

### Round 14
建立 `WorldActionService`。

### Round 15
`ui/journey.gd` 增加真实 SceneTree presentation：DialoguePanel / Speaker / Text / Hint / EventMeta、逐字、WAIT、BATTLE、Choice；加入 Journey presentation regression。

### Round 16
迁移 `SHARED-04-EARLY-DEMON-TALES-SEQUENCE`，移除 sequence reward，避免 chapter reward 双发。

### Round 17
建立 AI 持久记忆 / development log 体系。

### Round 18
迁移 Shared-05 / Shared-06。

### Round 19
迁移 Shared-07 / Shared-08 / Shared-09；Shared-03~09 主体 Sequence 完成。

### Round 20
修复 Godot 4.5.1 Journey warning-as-error 类型推断。Runtime #75 failure，修复后 #76 success，`RUNTIME_SUITE_PASS tests=11`。

### Round 21
新增 `test_shared_event_sequences.gd`，真实执行 Shared-03~09 production Sequence。#81 暴露测试控制流问题，修复后 #82 success：7/7 Sequence、3/3 battle resume、1/1 move side effect。

### Round 22
增强 Sequence cross-reference validation；迁移 Wukong WUK-01~03；新增 `ui/origin_sequence_journey.gd` 兼容桥；修复 `OriginEventManager` 缺失 event id 兼容问题。#94/#96 暴露问题，#98 success，#101 SceneTree bridge success。

### Round 23
完整迁移 Wukong `WUK-04~15`，形成 `WUK-01→WUK-15` 全链；5 个 Origin battle 复用既有 `WUKONG_ORIGIN_*` Encounter；3 个 choice；全路线 Sequence regression。#106 是测试控制流误报，修复后 #109 success，Godot 4.5.1 headless suite 通过。

### Round 24
建立项目负责人署名与投资合作入口：
- `DEVELOPER_NAME = "蛋汤"`；
- `CONTACT_WECHAT = "DanTangdwcyxgs"`；
- 主菜单显示开发者署名；
- 增加投资合作入口；
- 联系面板展示微信并支持 `DisplayServer.clipboard_set()`；
- 新增 `combat/test_main_menu_contact.gd`；
- suite 扩展至 14 tests；
- 投资人资料与项目身份规范同步。

#115 首次失败：contact regression 在 SceneTree 外弹 `AcceptDialog`；随后改成在 SceneTree 内实例化并直接测试 dialog 构造。#122 对修正后的测试成功。

### Round 25
新增 `combat/test_wukong_origin_progression.gd`，把悟空路线从“15 条 Sequence 都能独立执行”提升为“真实章节 cursor 连续推进”回归：
- `WUK-01 → WUK-15` 必须按 `OriginRouteManager.get_current_chapter()` 顺序逐章前进；
- battle 节点使用生产 `EncounterManager` 的 rewards / world effects，并通过 `BattleResolutionService.resolve_narrative_victory()` 原子结算；
- non-battle END 执行与 `OriginSequenceJourneyScreen` 一致的 `complete_origin_chapter()`；
- WUK-02 后真实执行 Save → 新 NarrativeManager → Load，必须恢复到 WUK-03；
- 最终验证 WUK-15 完成、WUKONG route `ROUTE_COMPLETE`、active origin chapter 清空、关键选择与 `WUKONG_HEAVEN_REBELLION` 世界效果保持。

该测试已加入 `tests/runtime_suite.gd`，suite 从 14 项增加到 15 项。

第一次 progression regression Runtime 失败原因是测试第 47 行 Variant 类型推断被 Godot 4.5.1 warning-as-error 拒绝；加入显式 `Dictionary` / `Array` 类型后，又发现非战斗 END 少了 chapter completion 收口，随后按生产桥接逻辑修正。

最终修正提交：`beda90ccac8204b05d07f4191972fd0cc46074d1`。上一版完整 Godot Runtime 对修正前提交 `7e70775...` 成功；最终追加修正后的 workflow 需要以最新 head 为准。

### Round 26
完成首个 route-specific Origin catalog 架构，并开始唐僧路线迁移：
- 新增 `data/narrative/event_sequences_origin.json`，包含 TANG-01~08 全部生产 Sequence；
- `EventSequenceManager` 同时加载 shared `event_sequences.json` 与 route-specific Origin catalog，并拒绝 duplicate sequence id；
- 新增 `combat/test_tang_origin_event_sequences.gd`：验证唐僧 8 条 Sequence、2 个 battle handoff/resume、2 个 choice persistence；
- 新增 `combat/test_tang_origin_progression.gd`：按 TANG-01→TANG-08 验证真实 chapter cursor、battle victory、non-battle END、TANG-06 Save/Load 恢复到 TANG-07、最终 route complete；
- `tests/runtime_suite.gd` 增至 17 tests；
- `test_event_sequence_validator.gd` 增加 TANG-01 route-specific catalog 交叉引用验证。

Wukong progression 修正后的完整 Runtime 已成功通过上一轮验证；唐僧新 catalog 之后的最新 head Runtime 仍需以对应 check-run 最终结果为准。

### Round 27
根据项目负责人新的最终愿景，更新项目情绪北极星并继续扩大 Origin：
- `README.md` 的“最终愿景”统一为：
  `像素与回合制，是我一直以来的偏爱。`
  `我想在方块构筑的世界里，重现儿时傍晚在公园握着掌机、发着光的夏夜。`
  `愿这份游戏，能为你寻回一段沉睡的时光。`
- `docs/game_vision.md` 增加 Emotional North Star / World Construction Aesthetic，把方块构筑、掌机节奏、夏夜光照和“少一点 spectacle、多一点情绪”转成长期设计约束；
- `TANG-01~08` 已完成独立 Origin Sequence catalog；
- `LONGMA-01~06` 已全部加入 `data/narrative/event_sequences_origin.json`；LONGMA-02 / LONGMA-05 为 battle，LONGMA-02 / LONGMA-04 为 choice；
- 新增 `combat/test_tang_journey_bridge.gd`，验证 `journey.tscn` 对 Tang-01 进入统一 Origin Sequence bridge；
- 新增 `combat/test_longma_origin_progression.gd`，验证 LONGMA-01→06 chapter cursor、2 battle、2 choice、save/load、route complete；
- `tests/runtime_suite.gd` 扩展至 19 项；
- 新增 `docs/development_log/2026-09-05-vision-and-origin-expansion.md`；
- `docs/development_log/README.md` 已将本轮记录置于最新记录区。

截至当前最后检查，包含 Longma regression 的 19-test head 已触发 Godot Runtime；Engine import、signature probe、EventRuntime 已通过，最终 runtime suite 仍需等待最终 check-run 结论。

### Round 28 — 2026-10-10：Battle Victory Feedback / Story Continuation
- 接手前先检查 `docs/AI_MEMORY.md`、`AI_HANDOFF.md`、开发日志索引及最近的 Battle → Reward → Party → Camp 记录。
- 按上一轮接手点检查战斗胜利反馈，发现战斗结束信号后的回合流可能立即调用 `_refresh()`，覆盖胜利/奖励消息。
- 在 `BattleUI` 中加入结果展示锁；统一显示完成结果、奖励和下一步提示，并按场景更新返回按钮文字。
- 在 `NarrativeBattleUI` 中区分“战后剧情恢复成功”与“返回个人/共享路线”，不修改战斗结算事务或 EventRunner 的 UI-independent 边界。
- 扩展 `test_shared_battle_journey_bridge.gd`：三场共享招募战均检查奖励行、战后剧情提示、按钮文字，以及调用刷新后结果文本不被覆盖。
- 新增开发日志，并将 2026-09-07 既有记录补入开发日志索引。
- 验证事实：GitHub connector 不能在本地执行 Godot；本批次 Runtime 状态记录为 pending，必须针对实现提交 SHA 检查 Actions 才能宣称通过。
- 下一步：先确认该提交的 Godot Runtime 结果；成功后再推进 Journey 的 MOVE / WAIT 反馈，并保持每批单一视觉验收目标。

### Round 29 — 2026-10-10：Victory Feedback Regression Assertion Correction
- 读取提交 5c0cb1d4c91434fbd475e71aa8dd3e6e8c321209 的 GitHub Actions job log；项目导入、parser probe、EventRuntime、EventRunner 检查均成功，headless suite 在新桥接断言处失败。
- 失败点是测试把下一步提示固定为一个特定句子；应检查胜利摘要包含下一步说明，具体的 EventSession 战后对白在后续断言中独立验证。
- 将回归改为检查“下一步：”字段存在，并在失败时输出实际摘要，便于下次诊断。
- 更新开发日志中的验证事实并增加 follow-up log。
- 修正 AI_HANDOFF.md 中的任务优先级与 2026-09-05 过期快照，避免把已完成的 Shared Sequence 迁移和五路线质量门再次列为未完成。
- 提交 7ae2e6f41c627892ab3beb1533e8b0923081e12a 的 Godot Runtime run 38042589835 已成功，日志为 RUNTIME_SUITE_PASS tests=31。运行期间仍有 missing-font 与 Resource/RID 泄漏诊断，但未影响通过结论。
- 下一步转为 Journey 的 MOVE / WAIT 表现，保持每批单一视觉验收目标。
### Round 30 — 2026-10-10：Journey MOVE / WAIT Presentation
- 在修正胜利反馈回归后读取 GitHub Actions 日志，确认 commit 7ae2e6f41c627892ab3beb1533e8b0923081e12a 的 Godot Runtime 成功，RUNTIME_SUITE_PASS tests=31。
- JourneyScreen 为 MOVE 增加专属旅途移动说明、地图/路标目标、前往按钮和路途过渡提示；MOVE 与 WAIT 都通过界面过渡后才调用 NarrativeEventSession.complete_action()，让 WorldActionService 仍是 MOVE 持久化副作用边界。
- WAIT 表现显示停驻秒数、暂歇对白和继续提示；过渡期间禁用主按钮，避免重复提交同一 action。
- 扩展 test_journey_event_presentation.gd，覆盖 MOVE 目标与操作提示、WAIT 秒数与继续文案。既有 runtime suite 已包含该测试。
- 实现提交 ec58f239dfe46a2204727be142dfdc5717de0a70 的 Godot Runtime run 38042773314 已成功，日志确认 test_journey_event_presentation.gd PASS 与 RUNTIME_SUITE_PASS tests=31。
- 需要留意：前一轮通过的 headless suite 在 teardown 时仍输出 NotoSansSC-Regular.otf missing-font 与 Resource/RID leak 诊断；它们没有导致 tests=31 失败，但属于独立技术债。
- 下一步：继续 Journey 的 END / chapter-completion feedback，并为完成提示补回归；不要同时做大规模 UI 重构。
### Round 31 — 2026-10-11：HD-2D Environment Depth Foundation
- 按项目负责人要求重新审查完整接手文档、内容生产规范、视觉规范、ArtAssetCatalog、VisualOverlay 与视觉资产契约测试；确认当前角色仅有 32×48 逻辑画布的 SVG 占位图，且不存在 `assets/art/**/final/` 最终 PNG/WebP 资产目录。
- 确认当前旅途/战斗背景是少量平面形状组成的简单 SVG，虽已有 VisualOverlay 和 PixelHUD，但不足以达到 Octopath-like HD-2D 的环境层次。
- 将工作优先级从单纯继续 Journey END 文案反馈调整为视觉垂直切片：先提高环境背景分层质量，再逐步替换五名主角与敌人的最终像素角色资产，之后做角色动画、场景光照和战斗镜头。
- 重绘 `journey_scenery.svg`，增加远景山脊、远处寺院、中景悬崖、朝圣道路、前景竹木与灯笼光点等有明确景深职责的层。
- 重绘 `yellow_wind_battle.svg`，增加风沙层、废墟轮廓、战斗地面、余烬裂纹和风旋区域，为角色与技能特效保留空间。
- 扩展 `test_visual_asset_contract.gd`，检查关键图层标记，避免背景被简化回无层次占位图；更新视觉参考文档和接手优先级。
- 本会话没有本地 Godot 可执行运行环境；随后对实现提交 `cb7fd7c577e1811fa3c2b141019db871ed79150a` 检查了对应 Actions：Godot Runtime run `38102287644` 成功，日志包含 `RUNTIME_SUITE_PASS tests=31`；Web Demo run `38102287631` 也成功。
- Runtime 日志仍报告缺失 `res://fonts/NotoSansSC-Regular.otf` 与 Resource/RID teardown 诊断；这些没有使该提交的 31 项 suite 失败，但尚未解决。
- 已知问题：没有最终角色 PNG/WebP；SVG 分层背景是过渡性环境资产，仍需真实游戏窗口截图验收。当前会话的角色图像生成请求被 Free 套餐生成额度限制，未产出可提交正式资源；不会把概念图冒充游戏资产。
- 下一步：图像额度恢复后继续最终角色资产垂直切片；在此之前先推进不依赖图像生成的 Journey END / 章节完成反馈与 SceneTree 回归，并解决字体缺失。

### Round 32 — 2026-10-11：Asset-Generation Blocker Recorded / Journey END Feedback
- 记录图像生成额度限制：本会话未获得可用的最终角色 PNG，不上传概念展示图冒充可投入游戏的素材；美术垂直切片暂时不阻塞框架开发。
- 检查上一提交 `cb7fd7c577e1811fa3c2b141019db871ed79150a` 的专属 CI：Godot Runtime `38102287644` 成功（`RUNTIME_SUITE_PASS tests=31`），Web Demo `38102287631` 成功；Runtime 仍有缺失 CJK 字体和 Resource/RID teardown 诊断。
- Journey 的 END 节点改为明确说明“确认完成会记录章节进度并返回旅途”，操作按钮改为“完成并继续”。
- Shared Sequence END 收口现在显示已完成章节标题及下一章；战后 END 显示战后剧情结算状态。Origin 非战斗 END 显示个人章节完成标题、下一章或个人序章收束信息。
- 对 SharedJourneyManager.complete() 返回值进行处理，不再在章节推进未确认时显示成功文案；Save 失败也会显示明确提示。章节奖励、章节事实和战斗原子结算仍由既有 Manager / Service 承担，Presentation 只负责反馈。
- 扩展 Journey END 展示回归与真实 SHARED-01 → SHARED-02 SceneTree 桥接回归。实现提交 `7ca43f4a9c01370f0adefda4e41f9b28a89f2f76` 的 Godot Runtime run `38103040349` 成功，`RUNTIME_SUITE_PASS tests=31`；该 SHA 的 Web Demo run 被后续 push 取消，后续包含相同 END 改动的 `4b383b1230d19f5eaeb616823bd08e368311592c` 已通过 Web Demo。
- 下一步：确认新提交 CI；再做 Main Menu → Journey → END/Chapter → Save 的更完整 SceneTree smoke。缺失字体与 teardown 诊断单独处理；正式角色 PNG/WebP 待图像生成可用后再进入资产替换。

### Round 33 — 2026-10-11：CJK Font Fallback / Runtime Resource Contract
- 给 `PixelUI` 增加统一的 `load_ui_font()`：存在并可加载时使用项目 CJK 字体，资源缺失时回退到 `ThemeDB.fallback_font`。`PixelHUD` 不再直接 load 缺失路径，因此无字体的本地/headless 环境不会主动触发缺失资源错误。
- `godot-runtime.yml` 在项目导入前下载 `NotoSansSC-Regular.otf`，与 Web Demo 的构建资源准备保持一致。字体仍不提交进 Git。
- 新增 `test_pixel_ui_font_contract.gd`，明确验证故意缺失字体路径时的回退、主题默认字体与 PixelHUD 初始化；Runtime suite 增至 32 项。
- 实现提交 `4b383b1230d19f5eaeb616823bd08e368311592c` 的 Godot Runtime run `38103113032` 成功，日志为 `RUNTIME_SUITE_PASS tests=32`；Web Demo run `38103113019` 成功。
- 字体缺失错误已从对应 Runtime 日志中消失；Canvas / CanvasItem / Viewport / TextServer 等 Resource/RID teardown 诊断仍存在，单独作为下一项质量问题，未宣称已修复。
- 为避免本地或 CI 下载的字体被误提交，`.gitignore` 增加 `/fonts/`。
- 下一步：做 Main Menu → Journey → EventSequence → Battle / END → Save 的完整入口 smoke，并另行定位 Runtime teardown 资源所有权问题。图像生成额度恢复前继续框架工作，最终角色图继续保持未完成状态。

### Round 34 — 2026-10-11：Runtime Test Node Teardown
- 排查 Godot Runtime suite teardown 诊断：发现 `test_main_menu_contact.gd` 是在长生命周期的 suite SceneTree 进程中以 static `run_all()` 执行；它实例化了整套 MainMenu 控件和独立 AcceptDialog，却没有显式 free，控件数与 `49 CanvasItem RIDs leaked` 的日志规模吻合。
- 增加显式 `dialog.free()` 与 `instance.free()`，保证静态回归在返回结果前释放创建的节点树。
- `test_pixel_ui_font_contract.gd` 在 `hud.queue_free()` 后等待一次 `process_frame`，再退出 SceneTree，避免排队释放还未被引擎处理。
- 实现提交 `ff50907c95cb5017a8fdad4b2ee27ee773c37ac5` 的 Runtime run `38103322441` 成功，`RUNTIME_SUITE_PASS tests=32`；Web Demo run `38103322430` 成功。
- 该 Runtime 日志不再报告 Canvas / CanvasItem / Viewport / TextServer RID 泄漏或 `resources still in use`，只保留 `ObjectDB instances leaked at exit`。这验证了节点树生命周期修复消除了前一批 renderer/text resource 警告，但不代表剩余 ObjectDB 警告已解决。
- 下一步：新增生产入口 MainMenu → Journey → WUK-01 Sequence SceneTree smoke；然后用针对性日志追查余下 ObjectDB 警告。


### Round 35 — 2026-10-11：Main Menu → Journey Production Entry Smoke
- 新增 `test_main_menu_journey_entry.gd`，从实际 `main_menu.tscn` 开始，调用新游戏 handler，验证保存发生、场景切换到生产 `journey.tscn`，角色选择得到恢复，再进入实际 `WUK-01-SEQUENCE` 的 Dialogue action。
- 测试前备份并清理 `NarrativeSave.SAVE_PATH`、`BountyEncounterState.PATH`、`BountyEncounterState.RESUME_PATH`，完成后恢复原始字节，避免本地执行时破坏开发者自己的存档或战斗交接记录。
- 新 smoke 加入 `tests/runtime_suite.gd`，从 32 项扩展到 33 项。实现提交 `9cf78a11f923ff1834a6f796c3b4b3dfc4cfe0bc` 的 Runtime run `38103454949` 通过，`RUNTIME_SUITE_PASS tests=33`，并确认 `test_main_menu_journey_entry.gd` PASS；Web Demo run `38103454926` 成功。
- 上一轮 teardown 修复提交 `ff50907c95cb5017a8fdad4b2ee27ee773c37ac5` Runtime `38103322441` / Web Demo `38103322430` 均成功。49 个 CanvasItem 及 Canvas / Viewport / TextServer RID 警告不再出现，剩余 `ObjectDB instances leaked at exit` 尚待隔离。
- 下一步：验证新 SceneTree smoke，随后对剩余 ObjectDB 进行定向诊断，继续保持 Narrative 与 Presentation 的职责边界。


### Round 36 — 2026-10-11：ObjectDB Teardown Detail Capture
- 已确认生产入口 smoke 提交 `9cf78a11f923ff1834a6f796c3b4b3dfc4cfe0bc` 的 Godot Runtime run `38103454949` 成功（33/33），Web Demo run `38103454926` 成功。
- 为排查残留的 `ObjectDB instances leaked at exit`，在 `.github/workflows/godot-runtime.yml` 原 33-test suite 通过后增加一条临时 verbose 重跑步骤；输出完整日志到临时文件，只筛选泄漏实例、ObjectDB 和 resources-in-use 相关上下文，不在普通步骤刷屏。
- Runtime run `38103543718` 在 commit `c62bfdef1e268c8ad726c6287e59490ce8be26d2` 上通过 33 项测试；verbose diagnostics 确认唯一残留为 `AudioStreamGeneratorPlayback:9223372175082259984`。
- 随后针对 `GameSfx` 的 `AudioStreamGeneratorPlayback` 加入显式停止、断开并释放 AudioStreamPlayer 与 playback 引用的逻辑，且增加生命周期回归。此具体修复提交的 Runtime 结果待验证；修复通过后应删除临时 verbose workflow 重跑步骤。


### Round 37 — 2026-10-11：AudioStreamGeneratorPlayback Lifecycle
- 定向 verbose Runtime 日志确认剩余 ObjectDB 对象为 AudioStreamGeneratorPlayback，属于 ui/sound_manager.gd 中生成音效使用的 AudioStreamGenerator 播放对象，而非叙事或 UI 节点。
- SoundManager 增加幂等 _release_audio_resources() 并在 _exit_tree() 调用：停止播放器、断开 stream、释放 playback/stream/播放器引用，并显式移除和释放生成的 AudioStreamPlayer 节点。
- 新增 combat/test_sound_manager_lifecycle.gd，验证主动释放和 autoload GameSfx 实例的资源/节点引用；加入 tests/runtime_suite.gd，suite 扩展到 34 项。
- 新架构提交 `ac5bb6f09af81b1bbfa5fd8b387d6aa9b2191edb` 的 Runtime run `38104194439` 成功（`RUNTIME_SUITE_PASS tests=34`），独立生命周期测试通过；verbose 日志没有 ObjectDB、AudioStreamGeneratorPlayback 或 RID 泄漏诊断。
- Web Demo run `38104194542` 成功。已在验证后的 docs/workflow cleanup commit 中移除临时 verbose 重跑步骤，避免每次 CI 重复执行 34 项测试。
- 下一步：继续更完整的 Main Menu → Journey → battle resume / END → Save SceneTree smoke；保持音频播放生命周期回归。


### Round 38 — 2026-10-11：Audio Lifecycle Validation / CI Cleanup
- 对提交 `ac5bb6f09af81b1bbfa5fd8b387d6aa9b2191edb` 的 Runtime run `38104194439` 验证 34/34 tests pass；verbose 日志筛选结果中没有 ObjectDB instances leaked、AudioStreamGeneratorPlayback 或资源/RID teardown 记录。
- 同一提交的 Web Demo run `38104194542` 成功（build + deploy）。
- 移除 `.github/workflows/godot-runtime.yml` 中仅用于一次诊断的 verbose 重跑，恢复每次 Runtime 只执行一次正式 suite 的轻量流程。
- 更新 SoundManager 与 ObjectDB 诊断日志，明确记录第一次释放引用方案失败，及后续改为按需 PCM WAV/队列播放的有效修复，避免留下过时结论。
- 下一步：继续补齐更完整的 SceneTree battle resume / END / Save 路径；图像生成额度恢复后再进入最终角色 PNG/WebP 资产批次。


### Round 39 — 2026-10-11：Main Menu → Origin Battle → EventSession Resume Smoke
- 新增 SceneTree 入口回归，从生产 MainMenu 选择悟空开始新游戏，真实执行 WUK-01 END 并推进到 WUK-02。
- 让生产 OriginSequenceJourneyScreen 触发 WUK-02 battle action，检查 WUKONG_ORIGIN_WATER_CAVE handoff、source chapter 与序列快照，进入真实 battle_ui.tscn（NarrativeBattleUI）。
- 测试调用真实战斗胜利收口，验证 BattleResolutionService 后的战后摘要、返回旅途按钮、实际场景切换、Journey 自动恢复 WUK-02 的 after-battle Dialogue、战斗存档后章节指针 WUK-03，以及 END 后再次保存且不重复推进。
- 测试对 narrative save / active encounter / pending resume 三个 user:// 文件备份并恢复，以防覆盖开发者存档。
- 本测试新增至 runtime_suite；新提交 Godot Runtime 结果待确认。

---

### Round 40 — 2026-10-11：Battle Resume Terminal Cleanup
- MainMenu → WUK-02 smoke failed on commit 4102cab because the victory UI did not report the after-battle story. Parent commit 959a32f fixed the double-advance by reading the restored action rather than resolving BATTLE twice; Runtime run 38104519997 passed 35 test entries and Web Demo run 38104519990 passed.
- Identified a separate terminal-state persistence issue: generic BountyEncounterState.clear() preserves EventSession resume data, so it is not suitable for the final END boundary.
- Added clear_completed_event_session(), used by Journey and Origin Journey END paths; failures to delete handoff files are visible in completion feedback.
- Added smoke assertions that active and pending resume files are absent after WUK-02 post-battle END, and changed the shared battle bridge regression cleanup to discard temporary resume data because it stops before END.
- Runtime run 38104663818 passed 35/35 for implementation commit ea24dd2; follow-up branch head Runtime run 38104713527 passed 35/35; Web Demo run 38104713524 passed build and deploy. Continue framework regressions without committing concept sheets as production assets.


### Round 41 — 2026-10-11：Full EventSequence Catalog Quality Gate
- 复查发现 `EventSequenceValidator` 已能检查事件、遭遇、章节和路线跨引用，但对应测试只列举少量关键 sequence，未直接要求生产目录零加载/验证错误。
- 扩展 `combat/test_event_sequence_validator.gd`：检查两个 production catalogs 的 `get_load_errors()` 必须为空，确认关键序列全部已加载，并对 `EventSequenceManager.get_all_ids()` 返回的每条序列执行 cross-reference validation。
- 测试结果字段报告实际验证的 production sequence 数量，避免用硬编码样本数代表覆盖面。
- 同步修正文档中已过时的“跨引用验证尚未实现”描述，并明确仍待补的是 chapter_type / legacy 分类标记与 namespace 的显式一致性校验。
- 基线：main commit `173bbb2f8be211ace60f635830b0c0c7ad7a4c5e` 的 Godot Runtime run `38104853441` 通过（35 个测试入口）。实现提交 `0e3998318ea771cee07a3343bc82986e04c3a1e8` 的 Godot Runtime run `38105696943` 通过，日志确认 `PASS res://combat/test_event_sequence_validator.gd` 与 `RUNTIME_SUITE_PASS tests=35`。
- 下一步：通过后继续对 failure recovery / battle rollback-retry 增加独立回归，再扩展 Shared 招募战真实场景链。

### Round 42 — 2026-10-11：BattleResolutionService Save-Failure Rollback Regression
- 在 `combat/test_battle_resolution_service.gd` 增加只用于测试的 `SaveFailingNarrativeManager`，其 save() 明确返回失败并记录是否触达提交边界。
- 使用有效 Shared-03 战斗上下文执行胜利结算，验证服务确实执行到 save 阶段；模拟存档失败时结算必须返回空结果，并将奖励、招募、战斗日志和章节推进的全部 NarrativeState 变化恢复到结算前快照。
- 这项回归不模拟战斗回合，也不更改生产实现；它锁定现有 BattleResolutionService 的原子事务约定。
- 精确提交 `c29702d199036be7a097339c762f61fa87eda933` 的 Godot Runtime run [38105806758](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38105806758) 通过，日志确认 `PASS res://combat/test_battle_resolution_service.gd` 和 `RUNTIME_SUITE_PASS tests=35`；同一 SHA 的 Web Demo run [38105806791](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38105806791) 通过。
- 下一步：修复任何被回归暴露的真实问题；通过后扩展 Shared 招募战的真实 SceneTree 场景链。

### Round 43 — 2026-10-11：Shared Recruitment Battle Real SceneTree Smoke
- 在保留既有跨模块 Shared battle bridge 回归的同时，新增 `combat/test_shared_battle_scene_transition.gd`，验证 Shared-03 / Shared-05 / Shared-07 三场招募战的真实 UI 路径。
- 每场由生产 MainMenu 的 Continue 载入具备 canonical 前置状态的存档；使用 Journey 的真实按钮推进到 choice，点击实际 choice button 后由生产代码切入 `ui/battle_ui.tscn`。
- 调用生产 `NarrativeBattleUI._on_combat_finished` 进入原子结算边界，点击真实的“继续旅途”按钮切回 Journey，断言 EventSession 恢复到战后对话并走到 END。
- 回归检查下一共享章节、招募角色、已完成章节，以及 END 后 active / pending handoff 清理和禁止重复推进。测试会备份并恢复 `user://narrative_slot_1.json`、`active_bounty.json` 与 `pending_event_resume.json`。
- 本批精确提交 Godot Runtime / Web Demo 结果待 Actions 完成后登记；不能用旧 Shared bridge 通过记录替代本次真实 scene transition 结果。
- 下一步：若此 smoke 通过，继续补章节分类字段与 sequence namespace 的显式一致性校验，再评估完整垂直切片中的 Memory 进入路径。

## 4. Wukong Origin 当前状态

Production Sequence：`WUK-01~15` 全部存在。

Battle：
- WUK-02：`WUKONG_ORIGIN_WATER_CAVE`
- WUK-06：`WUKONG_ORIGIN_DRAGON_PALACE`
- WUK-11：`WUKONG_ORIGIN_HEAVENLY_TROOPS`
- WUK-12：`WUKONG_ORIGIN_ERLANG_SHEN`
- WUK-14：`WUKONG_ORIGIN_HEAVEN_PALACE`

Choices：WUK-03 `SEEK_FREEDOM`；WUK-08 `ACCEPT_TITLE`；WUK-13 `ENDURE`。

`ui/origin_sequence_journey.gd`：已迁移章节使用 EventSequence；未迁移章节继续 legacy；non-battle END 完成当前 Origin chapter；battle 由 `BattleResolutionService` 原子推进。

Wukong progression/save regression 已形成；下一步优先补最小 SceneTree 入口 smoke coverage，确认 `main menu → journey → event sequence → battle/END → save`。

---

## 5. Tang Origin 当前状态

Production route：`TANG-01~08`。

Route-specific Sequence catalog：`data/narrative/event_sequences_origin.json`。

Battle：
- TANG-06：`TANG_ORIGIN_DOUBLE_RIDGE`
- TANG-08：`TANG_ORIGIN_FIVE_ELEMENTS`

Choices：TANG-04 / TANG-07。

当前已完成：Sequence catalog、8 chapter Sequence regression、8 chapter progression/save regression、Tang Journey bridge smoke。

尚未确认：最新包含 Longma regression 的 19-test head 的最终 Godot Runtime。

---

## 6. Longma Origin 当前状态

Production route：`LONGMA-01~06`。

Battle：
- LONGMA-02：`LONGMA_ORIGIN_SEA_CLIFF`
- LONGMA-05：`LONGMA_ORIGIN_YINGCHOU`

Choices：LONGMA-02 / LONGMA-04。

当前已完成：Sequence migration、完整 progression/save regression。

尚未确认：最新包含 Longma regression 的 19-test head 的最终 Godot Runtime。

---

## 7. Shared Journey 当前边界

`shared_chapters.json` 是 Shared chapter 事实来源；Sequence 不得复制 chapter reward。

Shared-03：Longma recruitment / Eagle Sorrow / timeline 110。
Shared-04：HERB / timeline 120。
Shared-05：Bajie recruitment / Gaojiazhuang / timeline 130。
Shared-06：HERB / timeline 140。
Shared-07：Wujing recruitment / Flowing Sands / timeline 150。
Shared-08：party full / HERB / timeline 160。
Shared-09：full pilgrimage / COIN_MEDIUM / timeline 170。

`SharedJourneyManager.complete()` 是 canonical shared progression；battle chapter 必须存在 `SHARED_BATTLE_<encounter_id>` milestone。

---

## 8. 当前产品任务地图

### P0 — Journey / SceneTree robustness
MOVE / WAIT, battle victory feedback, Journey END, CJK font fallback, MainMenu → Journey → WUK-01 smoke, and finite PCM WAV SFX cleanup have passed their Runtime gates. The MainMenu → WUK-02 battle/resume test found a real double-advance issue; commit 959a32f fixes the victory resume and passed all 35 runtime test entries. The follow-up terminal cleanup commit ea24dd2 adds a dedicated clear path and asserts both active/pending resume files are absent after END. Runtime run 38104663818 passed 35/35; follow-up branch head Runtime run 38104713527 also passed 35/35, and Web Demo run 38104713524 passed build/deploy. Final PNG/WebP character art remains deferred while image generation is unavailable; do not commit concept sheets as final assets.

### P1 — Cross-route / SceneTree robustness
Wukong、Tang、Longma、Bajie、Wujing 五条 Origin Route 均已完成首轮 Sequence 化，统一五路线质量门与 Origin → Shared handoff 回归已有记录。后续重点是完整 Main Menu → Journey → Sequence → Battle / END → Save 的 SceneTree 入口与恢复边界。

### P2 — Cleanup
逐步收敛旧 BattleUI 结算职责与 `BountyEncounterState`，不得提前破坏兼容链。

### P3 — Camp / Relationship
主叙事链稳定后开始。

### P4 — Vertical Slice
`一个完整角色起始路线 → 五行山 → 鹰愁涧 → 招募 → 对应 Memory`。

### P5 — Product identity / funding
已完成开发者署名与投资合作联系方式入口。后续新增邮箱 / 官网 / Discord / 投资材料链接时，应统一更新主菜单和对外投资资料；未经负责人要求，不得自行替换微信号。

---

## 9. 接手点

优先阅读：
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-09-05-vision-and-origin-expansion.md`
- `docs/development_log/2026-09-05-tang-origin-sequence-migration.md`
- `docs/development_log/2026-09-05-wukong-origin-progression-regression.md`
- `docs/development_log/2026-09-05-developer-credit-investor-contact.md`
- `docs/game_vision.md`
- `README.md`
- `ui/main_menu.gd`
- `combat/test_main_menu_contact.gd`
- `combat/test_wukong_origin_progression.gd`
- `combat/test_tang_origin_event_sequences.gd`
- `combat/test_tang_origin_progression.gd`
- `combat/test_longma_origin_progression.gd`
- `combat/test_tang_journey_bridge.gd`
- `ui/origin_sequence_journey.gd`
- `ui/journey.gd`
- `scripts/narrative/event_sequence_manager.gd`
- `scripts/narrative/event_sequence_validator.gd`
- `scripts/narrative/event_runner.gd`
- `scripts/narrative/narrative_event_session.gd`
- `scripts/narrative/narrative_manager.gd`
- `scripts/world/battle_resolution_service.gd`

任何下一轮继续：
`实现 → regression → Godot Runtime → development log → AI_MEMORY`。
