# 2026-09-05 — Emotional North Star / Tang & Longma Origin Expansion

## Goal
把项目最终愿景从单纯的“完成一场西游”提升为更明确的情绪目标：用像素、回合制和方块构筑的世界，重现儿时傍晚拿着掌机、发着光的夏夜，并让玩家找回一段沉睡的时光。

同时继续扩大 Origin EventSequence 迁移范围，让唐僧、白龙马也进入与悟空相同的可验证运行链。

## What changed

### Product vision
更新：
- `README.md`
- `docs/game_vision.md`

新增并统一表达：
> 像素与回合制，是我一直以来的偏爱。
>
> 我想在方块构筑的世界里，重现儿时傍晚在公园握着掌机、发着光的夏夜。
>
> 愿这份游戏，能为你寻回一段沉睡的时光。

`docs/game_vision.md` 同时把该愿景转化为工程约束：
- 方块构筑强调可读、模块化、近似玩具般的空间形体，而非写实或简单复制 voxel 风格；
- 掌机式节奏意味着给玩家观察、思考和等待的空间；
- 夜晚光照、雾、材质与场景尺度应服务于“发光的夏夜”这一长期情绪目标；
- 大型视觉功能需要判断它是在强化情绪还是只增加 spectacle。

### Origin catalog
继续使用独立 `data/narrative/event_sequences_origin.json`，不把所有 Origin 路线重新塞进 Shared catalog。

唐僧：
- TANG-01~08 全部迁移；
- TANG-06 / TANG-08 复用既有 Origin Encounter；
- TANG-04 / TANG-07 复用已有 choice event。

白龙马：
- LONGMA-01~06 全部迁移；
- LONGMA-02 / LONGMA-05 复用既有 Origin Encounter；
- LONGMA-02 / LONGMA-04 使用已有 choice event。

### Loader
`EventSequenceManager` 现在同时加载：
- `event_sequences.json`
- `event_sequences_origin.json`

重复 Sequence ID 会被拒绝，Route-specific catalog 进入同一运行目录。

### Regression
新增：
- `combat/test_tang_origin_event_sequences.gd`
- `combat/test_tang_origin_progression.gd`
- `combat/test_tang_journey_bridge.gd`
- `combat/test_longma_origin_progression.gd`

当前 runtime suite 扩展到 19 项。

悟空 progression regression 已验证“按实际 chapter cursor 连续推进”的生产状态模型；唐僧和白龙马沿用同一模式。

## Why
项目正在从“基础架构原型”进入内容生产期。为了后续快速批量制作五条人物路线，需要先证明：

`Origin Chapter → EventSequence → Choice/Battle → Chapter completion → Save/Load → 下一章`

这条链可以成为所有人物路线的通用生产模板。

同时，新的情绪愿景意味着后续画面、地图、UI、音频和战斗演出不能只追求技术指标，而要统一服务于玩家对“掌机夏夜”的记忆感。

## Validation

- Wukong progression 最新完整 Godot Runtime 已成功通过上一阶段验证。
- 唐僧独立 catalog 加入后的 Godot Runtime 已成功通过上一阶段验证。
- 白龙马 progression 与唐僧 Journey bridge 纳入最新总 suite 后，对应 head 的 Godot Runtime 正在执行；截至本日志生成时仍需等待最终结果。
- 最新 head 当前执行顺序已进入 EventRunner 检查，尚未到最终 runtime suite 阶段。

## Known issues

- `ui/origin_sequence_journey.gd` 仍是渐进迁移兼容桥；非迁移路线继续使用 legacy path。
- Battle Scene Handoff 仍使用 `BountyEncounterState` compatibility layer。
- 唐僧 / 白龙马目前虽然有完整后端 Sequence，但还需要更多完整 SceneTree 点击级验证。
- 最终愿景已经写入 README / game vision，但尚未进一步转化为完整视觉规范、配色、灯光、音频和镜头标准。

## Next step
先确认最新 19-test Godot Runtime 全绿；随后补唐僧 / 白龙马最小 SceneTree 入口与 battle resume smoke，再推进八戒、悟净 Origin Sequence migration。

## Handoff point
当前 Origin 迁移状态：
- Wukong：15/15 Sequence + progression/save regression；
- Tang：8/8 Sequence + progression/save regression + Journey bridge smoke；
- Longma：6/6 Sequence + progression/save regression；
- Bajie：尚未迁移；
- Wujing：尚未迁移。

产品最高层情绪目标已经确定为“方块构筑世界里的掌机夏夜”，后续设计应将其视为长期北极星。
