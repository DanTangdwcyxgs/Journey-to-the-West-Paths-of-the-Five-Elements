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
- 当前只完成资源级静态修改与契约回归代码；本会话没有本地 Godot 可执行运行环境，不能宣称本批次 Godot Runtime 通过。必须检查本提交 SHA 的 GitHub Actions。
- 已知问题：没有最终角色 PNG/WebP；缺失字体 `res://fonts/NotoSansSC-Regular.otf` 仍需处理；SVG 分层背景是过渡性环境资产，仍需要真实游戏窗口内的截图验收。
- 下一步：先检查本提交的 Godot Runtime 与 Web Demo 构建；通过后进行角色资产第一批（Wukong / Tang / Bajie / Wujing / Longma）替换，并解决字体资源缺失。
---

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

### P0 — Emotional / Journey presentation
MOVE / WAIT 的基础提示与过渡已完成首轮并通过 Runtime；下一步补 END / chapter-completion feedback，继续验证 Battle → Resume → END 不重复结算，再逐步把“方块构筑世界里的掌机夏夜”落实到灯光、镜头、环境层次、UI节奏和音频，而不是只停留在文案。

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
