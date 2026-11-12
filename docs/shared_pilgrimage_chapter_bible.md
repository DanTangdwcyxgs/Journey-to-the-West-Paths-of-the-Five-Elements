# 共同西游主线圣经（Runtime 对齐版）

> 本文是共享西游主线的叙事设计依据。**当前已注册章节以 `data/narrative/shared_chapters.json` 为准，实际事件流程以 `data/narrative/event_sequences.json` 为准。** 本文不会用旧草案编号覆盖真实运行时数据。
>
> 当前已注册的是 SHARED-01～SHARED-09。它们构成五人汇流和完整西游的开篇骨架；SHARED-09 是完整取经旅程入口，不代表八十一难主体已经制作完成。

## 1. 永久原则与内容边界

1. 五个起始角色只是五个叙事入口，不能改变西游世界的历史顺序。
2. 个人 Origin 解释“我是谁”；Shared Journey 记录师徒共同经历的当前世界事件；Memory 只允许回放，不得重写当前世界。
3. 招募发生在世界时间线上。角色加入后，其安全的个人历史立即成为可选回忆；不要求 PARTY_FULL 才解锁。
4. 一项原著劫难可以跨多个游戏章节，一个游戏章节也可以覆盖连续的小型遭遇。不能为了凑数而把 81 难强行做成 81 个大型副本。
5. 原著难次、小说回目、游戏章节 ID、Runtime Ready、Content Complete、Production Accepted 是不同维度。
6. 章节数据、事件序列和本圣经出现矛盾时，先尊重当前 Runtime 状态，再更新本圣经；不能为了让文档“看起来一致”而擅自重排运行时主线。
7. OPTIONAL EXPEDITION / BOUNTY 可以在不推进 Shared 章节和全球时间线的情况下游玩；不得把可选讨伐包装成原著主线劫难已经完成。

## 2. 五种起始路线的固定汇流点

起始角色、个人路线终点与第一个 Shared 入口来自 `data/narrative/starting_routes.json` 和 `StartRouteCatalog`。

| 起始角色 | Origin 终点 | 首个 Shared 入口 | 汇流后的队伍 |
|---|---|---|---|
| 孙悟空 | WUK-15 五行山 | SHARED-01-FIVE-ELEMENTS | 唐僧 + 悟空 |
| 唐僧 | TANG-08 五行山 | SHARED-01-FIVE-ELEMENTS | 唐僧 + 悟空 |
| 白龙马 | LONGMA-06 化作白马 | SHARED-03-EAGLE-SORROW | 唐僧 + 悟空 + 白龙马 |
| 猪八戒 | BAJIE-09 放下 | SHARED-05-GAOJIAZHUANG | 唐僧 + 悟空 + 白龙马 + 八戒 |
| 沙悟净 | WUJING-08 皈依 | SHARED-07-FLOWING-SANDS | 唐僧 + 悟空 + 白龙马 + 八戒 + 悟净 |

起始路线终点是当前实现的硬边界：
- 不把 TANG-09 追加进唐僧 Origin；它曾作为共同早期旅程概念出现。
- 不把 LONGMA-07 / LONGMA-08 追加进白龙马 Origin；它们是招募后的坐骑阶段与龙魂觉醒内容。
- 需要扩写个人历史时，建立独立 Memory 内容目录；不得延长 Origin 路线而移动既有汇流点。

## 3. 当前 Runtime 章节总表

下面的 ID、标题、时间线、后继章节和事件序列必须与运行时 JSON 保持一致。表中“当前覆盖”只描述仓库现在确实存在的内容，不代表整章达到最终内容或美术验收。

| 当前章节 ID | 注册标题 | Timeline | EventSequence | Next |
|---|---|---:|---|---|
| SHARED-01-FIVE-ELEMENTS | 五行山 | 100 | SHARED-01-FIVE-ELEMENTS-SEQUENCE | SHARED-02-EARLY-PILGRIMAGE |
| SHARED-02-EARLY-PILGRIMAGE | 师徒初行 | 105 | SHARED-02-EARLY-PILGRIMAGE-SEQUENCE | SHARED-03-EAGLE-SORROW |
| SHARED-03-EAGLE-SORROW | 鹰愁涧 | 110 | SHARED-03-EAGLE-SORROW-SEQUENCE | SHARED-04-EARLY-DEMON-TALES |
| SHARED-04-EARLY-DEMON-TALES | 黑风山与早期妖患 | 120 | SHARED-04-EARLY-DEMON-TALES-SEQUENCE | SHARED-05-GAOJIAZHUANG |
| SHARED-05-GAOJIAZHUANG | 高老庄 | 130 | SHARED-05-GAOJIAZHUANG-SEQUENCE | SHARED-06-FOUR-PERSON-JOURNEY |
| SHARED-06-FOUR-PERSON-JOURNEY | 四人西行 | 140 | SHARED-06-FOUR-PERSON-JOURNEY-SEQUENCE | SHARED-07-FLOWING-SANDS |
| SHARED-07-FLOWING-SANDS | 流沙河 | 150 | SHARED-07-FLOWING-SANDS-SEQUENCE | SHARED-08-PARTY-FULL |
| SHARED-08-PARTY-FULL | 五人归队 | 160 | SHARED-08-PARTY-FULL-SEQUENCE | SHARED-09-FULL-PILGRIMAGE |
| SHARED-09-FULL-PILGRIMAGE | 完整西行 | 170 | SHARED-09-FULL-PILGRIMAGE-SEQUENCE | 无（后续主线尚待注册） |

### SHARED-01-FIVE-ELEMENTS — 五行山

**叙事职责**：唐僧与悟空在五行山相遇。它是悟空与唐僧起始路线共同的历史锚点，也是师徒关系从陌生、戒备到结伴的起点。

**当前 Runtime 覆盖**：
- EventSequence 有相遇对白、Story MOVE、选择及结束节点。
- 五行山有独立的 Region 数据与三个线索点；区域探索可保存发现状态。
- 个人路线汇流逻辑会将唐僧、悟空放入同一队伍，并记录 `WUKONG_RECRUITED`。

**尚缺内容**：完整的五行山可交互场景、关键角色演出、释放悟空的完整镜头与实际游戏截图验收。不能把 Region clue-only 点误报为完整主线关卡。

### SHARED-02-EARLY-PILGRIMAGE — 师徒初行

**叙事职责**：让玩家感受到五行山之后的第一次共同赶路。它需要把“两个角色在队伍里”转化成“师徒开始理解彼此”。

**当前 Runtime 覆盖**：
- EventSequence 有出发行对白、选择、赶路提示。
- 对话明确提示玩家可打开地图查看传闻，鹰愁涧是下一关键历史节点。
- 已有可选探索入口与存档/返回测试；可选传闻不应擅自完成主线章节。

**尚缺内容**：旅途互动、营地对话、沿途 NPC、完整环境演出与更丰富的师徒关系变化。

### SHARED-03-EAGLE-SORROW — 鹰愁涧

**叙事职责**：白龙从被误认为水中妖物，到显露龙族身份，再承担护送取经人的使命。

**当前 Runtime 覆盖**：
- EventSequence 包含到达、Story MOVE、选择、战斗和战后对白。
- Encounter `SHARED_EAGLE_SORROW` 是正式共享遭遇。
- 招募白龙后记录 `BAI_LONGMA_RECRUITED`，解锁白龙个人历史的安全回忆入口。
- 鹰愁涧 Region 数据包含三个线索点，有进入、发现、存档/读取和返回回归。

**尚缺内容**：完整龙形/马形视觉表现、更多水域互动、Boss 机制演出和正式场景截图验收。白龙此时是坐骑/探索功能，不应提前给予完整龙形战斗成长树。

### SHARED-04-EARLY-DEMON-TALES — 黑风山与早期妖患

**叙事职责**：第一次让队伍面对有组织的妖患，展示悟空的警觉、唐僧的判断以及队伍如何处理危险。

**当前 Runtime 覆盖**：
- EventSequence 指向黑风山北道，包含警告、等待和记录妖踪的对白。
- `BLACK_WIND_NORTH_PATH` 是世界地图节点。
- 区域探索有线索发现与存档回归。

**重要缺口**：当前注册章节只是早期妖患与北道探索骨架。黑风山、观音禅院、袈裟失窃、黑熊精多阶段事件尚不能因章节标题而视为完整实现。对应的 NPC、敌人、Boss、奖励和过场仍需逐项补齐。

### SHARED-05-GAOJIAZHUANG — 高老庄

**叙事职责**：让猪八戒的“天蓬旧身份、猪妖现状、对普通生活的渴望和加入取经的选择”在同一事件中成立。

**当前 Runtime 覆盖**：
- EventSequence 有到达、Story MOVE、选择、共享战斗与战后对白。
- Encounter `SHARED_GAOJIAZHUANG` 是正式共享遭遇。
- 招募后记录 `ZHU_BAJIE_RECRUITED` 并开放八戒安全回忆。
- 高老庄地图节点与世界路线已注册。

**尚缺内容**：完整村庄调查、云栈洞多阶段追踪、身份揭示节奏、非战斗解决方式、关系变化与正式截图验收。

### SHARED-06-FOUR-PERSON-JOURNEY — 四人西行

**叙事职责**：八戒加入后，让队伍从三人/坐骑辅助构成进入四人协作。重点是性格磨合、前后排配合与战斗职责变化。

**当前 Runtime 覆盖**：
- EventSequence 有四人出行对白、等待节点和队伍对话。
- 共享章节数据已设置下一章为 SHARED-07。

**尚缺内容**：当前更接近过渡章节骨架。尚未看到一段完整的四人旅途探索/战斗/奖励闭环。这里也是原著高老庄之后到流沙河之前必须补齐的关键内容窗口。

### SHARED-07-FLOWING-SANDS — 流沙河

**叙事职责**：通过连续遭遇而非单纯击败一个妖怪，让沙悟净面对罪责、赎罪和重新归队。

**当前 Runtime 覆盖**：
- EventSequence 有抵达、Story MOVE、选择、共享战斗和战后对白。
- Encounter `SHARED_FLOWING_SANDS` 已注册。
- 招募后记录 `SHA_WUJING_RECRUITED` 并开放悟净安全回忆。
- 这是五种起始路线中最晚的历史汇流点。

**尚缺内容**：原著连续阻拦/打斗、木叉介入、观音点化、河道探索与完整结局反馈，需要继续拆解成可玩的多阶段流程。

### SHARED-08-PARTY-FULL — 五人归队

**叙事职责**：五人第一次作为一个团队共同立誓。它应是关系章节，不应只是名单里多出一个角色。

**当前 Runtime 覆盖**：
- EventSequence 有五人聚齐、选择和共同誓言对白。
- 章节数据记录 `PARTY_FULL` 世界效果并指向 SHARED-09。

**尚缺内容**：五人营地、角色主动对话、阵型/装备整理、团队协同教学和可见的关系事件。营地相关系统或服务的存在不能替代这一章实际接入与玩家验收。

### SHARED-09-FULL-PILGRIMAGE — 完整西行

**叙事职责**：正式宣告五人团队成立，叙事重心从“招募队友”转为“共同经历取经路上的劫难”。

**当前 Runtime 覆盖**：
- EventSequence 目前是一段出发对白和结束节点。
- 章节数据设置 `FULL_PILGRIMAGE_BEGINS`，timeline 为 170。
- 当前 `next` 为空，代表后续 Shared 主线章节还没有注册到这条数据链。

**关键判断**：SHARED-09 不是八十一难已开始并完成的证明。它只是当前数据目录中完整取经阶段的入口，后续主线劫难必须继续登记、排序并接入。

## 4. 黄风岭：已有纵向切片，但主线位置尚未解决

仓库已有可运行的黄风岭—黄风洞—黄风妖王内容切片：
- Ridge 阶段：`RIDGE_ENTRY`、`ABANDONED_INN`、`SANDSTORM_PASS`、`YELLOW_WIND_GATE`。
- Cave 房间：`CAVE_MOUTH`、`SAND_ALTAR`、`SANDSTORM_HALL`、`YELLOW_WIND_THRONE`。
- 主线 Boss 记录使用 `YELLOW_WIND_KING`，与可选悬赏 `BOUNTY_YELLOW_FANG` 分开。
- 已有阶段解锁、存档失败回滚、洞窟遭遇往返、Boss 结算重试和重新读取测试。

**但当前它还不是正式 Shared chapter**：
- `shared_chapters.json` 没有黄风岭章节 ID。
- 黄风岭胜利不会推进 `current_shared_chapter`、`current_global_timeline` 或 `completed_shared_chapters`。
- 测试夹具把它作为纵向切片/侧区域运行，不证明玩家主线会自然从 SHARED-06 进入黄风岭，再到 SHARED-07。

### 必须解决的原著顺序问题

《西游记》回目顺序中，高老庄（第 18–19 回）之后是黄风岭（第 20–21 回），再之后才是流沙河（第 22 回）。当前 Shared Runtime 链却是：

`SHARED-05 高老庄 → SHARED-06 四人西行 → SHARED-07 流沙河`

所以目前**主线数据跳过了黄风岭**。已有黄风岭切片还按 timeline 120、白龙已招募条件开放，而高老庄章节是 timeline 130；这进一步说明现有区域解锁阈值不是原著主线顺序的证明。

### 推荐的安全接入方案（尚未写入 Runtime）

在 SHARED-06 四人西行之后、SHARED-07 流沙河之前插入一个正式黄风岭共享章节，候选稳定 ID：

`SHARED-06A-YELLOW-WIND`

候选时间线位置可放在 140 与 150 之间，但最终值、前置条件和回滚边界必须在实现时一起确认。接入时应复用已存在的 Ridge/Cave/Boss 系统，不复制一套黄风洞；主线 Boss 胜利应原子地完成该 Shared 章节并继续到 SHARED-07。可选黄牙悬赏仍必须独立，不得代替黄风妖王主线。

**在正式接入之前，黄风岭只能标为“已有纵向切片 / 主线映射待接入”，不得标为第 13–14 难已完成。**

## 5. 后续西游主线顺序（规划，不是 Runtime 注册）

以下是按原著主要事件顺序整理的内容生产方向。除 SHARED-01～09 以外，以下均为规划标签，不代表已经存在相同 ID 的 Runtime 章节。

| 原著顺序方向 | 主要事件 | 81 难映射关注 | 生产原则 |
|---|---|---|---|
| 高老庄之后 | 黄风岭、黄风怪、灵吉菩萨 | TRIAL-013～014 | 优先复用现有 Ridge/Cave 纵向切片，补正式 Shared 入口和结局 |
| 后续诸国 | 宝象国、黄袍怪 | 对应劫难逐条核对 | 城镇调查、国家危机、角色选择 |
| 平顶山 | 金角、银角与法宝 | 对应劫难逐条核对 | 法宝规则、敌人反制、资源管理 |
| 乌鸡国 | 国王被害、真假身份与救主 | 对应劫难逐条核对 | 调查、识别、法术与身份揭露 |
| 号山 | 红孩儿 | 对应劫难逐条核对 | 火焰地形、救援、观音介入 |
| 车迟国 | 三清观、国王与斗法 | 对应劫难逐条核对 | 解谜、法术挑战、团队判断 |
| 通天河前后 | 冰河、灵感大王、观音现身 | 对应劫难逐条核对 | 环境危害、水域、救援 |
| 金兜山 | 青牛精与金刚琢 | 对应劫难逐条核对 | 装备/法宝受制、求援流程 |
| 女儿国与蝎子精 | 取经人情感与责任考验 | 对应劫难逐条核对 | 非战斗、关系、选择后果 |
| 火焰山 | 三调芭蕉扇、牛魔王 | 对应劫难逐条核对 | 多阶段 Boss、环境与盟友关系 |
| 盘丝洞、狮驼岭 | 群妖、三魔王与连续救援 | 对应劫难逐条核对 | 多区域副本、团队配合、战斗疲劳 |
| 小雷音、朱紫国、比丘国等 | 神佛、妖魔与众生关系 | 对应劫难逐条核对 | 主题差异、机制变化 |
| 无底洞、灭法国等 | 末段连续试炼 | 对应劫难逐条核对 | 与前段人物成长呼应 |
| 凤仙郡、玉华州、青龙山等 | 天地秩序与临近终点的考验 | 对应劫难逐条核对 | 世界状态、众生回馈 |
| 天竺、铜台府、凌云渡、灵山 | 终局、脱胎、取经完成 | TRIAL-081 需保留独立语义 | 完成八十一难后再进入成佛结局 |

具体每一难的游戏章节映射以 `docs/narrative/81_TRIALS_MASTER_TRACKER.md` 和 `data/narrative/reference/canonical_81_trials.json` 为准。不得仅凭标题相似就把多条难次标成完成。

## 6. Memory / Flashback 规则

- 招募时只解锁当前时间点以前安全可回放的个人章节。
- Memory 读取 Origin/Memory 内容，不运行历史战斗、奖励、选择副作用或世界地图操作。
- Memory 开始时快照当前共享章节、时间线、队伍、位置和剧情状态；完成或退出后必须回到原始状态。
- 只有 Memory 的 available/played 标记可以改变；存档失败必须回滚并允许重试。
- LONGMA-07 “沉默的旅伴”和 LONGMA-08 “龙魂初醒”属于招募后的角色内容，待独立 Memory/成长目录支持后接入。不能为了复用当前 OriginRouteManager 而把它们追加到白龙马起始路线。

## 7. 起始视角差异与固定时间线

相同 Shared 事件可为不同起始角色提供不同对白、镜头、角色反应和可选回忆，但必须遵守：
- 悟空开局不会跳过唐僧的历史事实。
- 唐僧开局不会把悟空被压五行山的历史倒置。
- 白龙马开局进入鹰愁涧时，唐僧与悟空已经在前面的历史节点相遇。
- 八戒开局进入高老庄时，白龙马的加入事实已经发生。
- 悟净开局进入流沙河时，前四人历史已经发生。
- Memory 不改变以上事实。

视角差异优先用对白、环境反应和回忆入口体现；不复制整套世界时间线。

## 8. 新章节生产 / 验收门槛

任何新增 Shared 章节，必须同时具备：

1. 稳定 chapter ID、标题、时间线、前置条件、后继章节。
2. EventSequence 与章节 ID 一一对应，所有 choice/battle/move 引用通过 validator。
3. 原著回目和具体劫难 ID，说明哪些连续难合并呈现、哪些必须分开。
4. 地图、场景节点、可探索点与明确的进出路径。
5. NPC、普通敌人、精英、Boss 与 encounter ID。
6. 剧情对白、选择、角色反应、失败/重试/返回流程。
7. 战斗机制、弱点、Break、BP、奖励、装备和世界效果。
8. 存档/读取、Battle handoff、失败回滚和重复触发保护。
9. 角色美术、敌人美术、场景、UI、音效、VFX 和动画的独立资产记录。
10. 自动化 Runtime 测试、目标平台构建、真实游戏截图和 ART_REVIEW_STANDARD 验收。

状态不得跳级：
- PLANNED：原著来源、映射理由与章节 brief 已确认。
- DATA_AUTHORED：数据和稳定 ID 已登记、validator 通过。
- RUNTIME_READY：真实入口可完成内容，精确 SHA Runtime 通过。
- CONTENT_COMPLETE：剧情、地图、战斗、奖励、失败/重试与存档逐项验收。
- PRODUCTION_ACCEPTED：美术、音频、UI、目标平台与玩家视角截图验收通过。

**Runtime 通过不是美术通过；章节存在不是内容完成；有 Boss 不等于一难完成。**

## 9. 当前最优先的后续工作

1. 将黄风岭正式插入 SHARED-06 与 SHARED-07 之间，保持原著顺序并复用现有 Ridge/Cave 系统；这项需要更新共享章节链、WorldMap gate、NarrativeState 原子推进和完整 SceneTree 回归。
2. 建立招募后 Memory 独立目录，接入 LONGMA-07/08，不动 Origin 起始路线。
3. 完成 SHARED-04 黑风山与观音禅院的真实故事闭环，而不是只保留北道线索。
4. 为 SHARED-08 补五人营地和关系事件。
5. 从 81 难第 1 条开始，按原著顺序持续维护 crosswalk；优先用现有内容，但不降低验收要求。
