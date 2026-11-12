# 西游八十一难总台账（来源核对与项目交叉映射版）

> 更新时间：2026-11-12。本文严格区分原著难次、小说回目引用、游戏章节、Runtime 可玩、内容完成和生产验收。**来源记录 81/81 不代表游戏完成 81/81。**

## 1. 目前可以确认的原著基准

《西游记》第九十九回的难簿正文逐项列出**第一难至第八十难**，紧接着明确写明“还少一难”，命八大金刚“还生一难”。之后的通天河西岸补难情节中，师徒四众连马被放落，白鼋因唐僧未替它问寿数而翻落水中。因此本台账采用：

- **第 1–80 难**：第九十九回难簿逐条原文，名称以该回文字为主。
- **第 81 难**：第九十九回后续通天河白鼋翻落情节，作为补足九九之数的末难。它是依据本回叙事形成的独立记录，不冒称为前段难簿中的第八十一条原文。
- 小说回目号参考次级对照表，并与仓库固定版本的 100 回目录交叉验证；回目号不是第九十九回难簿对每项直接标注的内容。
- 第 2–4 难的次级索引标为“附录”；表中第九回仅作正文故事情境定位，不能取代对附录版本的核对。

### 依据

1. **主依据**：[《西游记》第九十九回（维基文库）](https://zh.wikisource.org/zh-hans/西遊記/第099回) — 难簿第一至第八十难及补数情节。
2. **回目交叉表**：[西游记·九九八十一难](https://yuwenkaodian.com/xiyouji/81risk) — 提供每项难次对应的章回、人物和地点；仅作次级定位工具。
3. **仓库锁定的回目索引**：`data/narrative/reference/xiyouji_chapter_index.json`，上游 `gazhikaba/xiyouji_txt` commit `419a54fbaf368af463dd863b8271ec7bb176b3b3`。该文件是 100 回标题索引，不是劫难清单。

来源数据已落在 `data/narrative/reference/canonical_81_trials.json`，每项包含稳定 ID、难次、名称、别名/异文、难簿行号范围、小说回目、游戏映射状态。

## 2. 进度口径

本项目要分别报告三个维度：

| 维度 | 当前结果 | 含义 |
|---|---:|---|
| 原著难次身份登记 | 81 / 81 | 80 条难簿原列 + 1 条第九十九回补数情节 |
| 直接关联现有共享章节且有 Runtime 证据 | 4 条 | 仅证明对应内容路径有运行时回归，不代表内容/美术验收 |
| 部分映射 / 纵向切片待接主线 | 5 条 | 3 条部分共享章节映射 + 2 条黄风岭现有纵向切片但尚无正式 Shared chapter crosswalk |
| 尚无直接游戏章节映射 | 72 条 | 需要设计和生产，不得报成完成 |
| Production Accepted | 0 条经本轮确认 | 尚未完成逐难截图、美术、音频、目标平台验收 |

## 3. 状态定义

| 状态 | 含义 | 必要证据 |
|---|---|---|
| UNMAPPED | 尚无可靠游戏章节映射 | 无 |
| PARTIAL_CROSSWALK | 有候选章节，但当前实现只覆盖部分原著要素 | 明确章节 ID、覆盖/缺口说明 |
| RUNTIME_EVIDENCE | 对应的玩家路径已有 Runtime 回归 | 精确 SHA 的 Godot Runtime 成功 |
| VERTICAL_SLICE_NOT_MAINLINE_MAPPED | 有独立纵向切片，但尚未接入可追踪的共享主线章节 ID | 区域/洞府/Boss 测试与待接主线说明 |
| CONTENT_COMPLETE | 剧情、探索、战斗、奖励、世界后果、失败/重试、存档等逐项验收 | 完整内容检查表 |
| PRODUCTION_ACCEPTED | 美术、音频、UI、截图、目标平台均通过 | ART_REVIEW_STANDARD + 精确 SHA CI + 实际游戏画面证据 |

状态不能跳级。Runtime 通过不等于剧情完整，更不等于正式美术通过。

## 4. 八十一难逐条来源与项目映射

`小说回目` 是次级索引所给的章节定位，需在实际编写该难的剧本时再对照仓库锁定版本核对。游戏映射为空表示当前没有可证明的一对一对应，不允许凭章节标题相似就自动计数。

| ID | 原著难次名称 / 异文 | 小说回目 | 当前游戏章节候选 | 项目状态 |
|---|---|---:|---|---|
| TRIAL-001 | 金蝉遭贬 | 12,100 | — | UNMAPPED |
| TRIAL-002 | 出胎几杀 | 9 | — | UNMAPPED |
| TRIAL-003 | 满月抛江 | 9 | — | UNMAPPED |
| TRIAL-004 | 寻亲报冤 | 9 | — | UNMAPPED |
| TRIAL-005 | 出城逢虎 | 13 | — | UNMAPPED |
| TRIAL-006 | 折从落坑（异文：落坑折从） | 13 | — | UNMAPPED |
| TRIAL-007 | 双叉岭上 | 13 | — | UNMAPPED |
| TRIAL-008 | 两界山头 | 14 | SHARED-01-FIVE-ELEMENTS | PARTIAL_CROSSWALK |
| TRIAL-009 | 陡涧换马 | 15 | SHARED-03-EAGLE-SORROW | RUNTIME_EVIDENCE |
| TRIAL-010 | 夜被火烧 | 16 | SHARED-04-EARLY-DEMON-TALES | PARTIAL_CROSSWALK |
| TRIAL-011 | 失却袈裟 | 16,17 | SHARED-04-EARLY-DEMON-TALES | PARTIAL_CROSSWALK |
| TRIAL-012 | 收降八戒 | 18,19 | SHARED-05-GAOJIAZHUANG | RUNTIME_EVIDENCE |
| TRIAL-013 | 黄风怪阻 | 20 | — | UNMAPPED |
| TRIAL-014 | 请求灵吉 | 21 | — | UNMAPPED |
| TRIAL-015 | 流沙难渡 | 22 | SHARED-07-FLOWING-SANDS | RUNTIME_EVIDENCE |
| TRIAL-016 | 收得沙僧 | 22 | SHARED-07-FLOWING-SANDS | RUNTIME_EVIDENCE |
| TRIAL-017 | 四圣显化 | 23 | — | UNMAPPED |
| TRIAL-018 | 五庄观中 | 24 | — | UNMAPPED |
| TRIAL-019 | 难活人参 | 25,26 | — | UNMAPPED |
| TRIAL-020 | 贬退心猿 | 27 | — | UNMAPPED |
| TRIAL-021 | 黑松林失散 | 28 | — | UNMAPPED |
| TRIAL-022 | 宝象国捎书 | 29 | — | UNMAPPED |
| TRIAL-023 | 金銮殿变虎 | 30,31 | — | UNMAPPED |
| TRIAL-024 | 平顶山逢魔 | 32 | — | UNMAPPED |
| TRIAL-025 | 莲花洞高悬 | 33,34,35 | — | UNMAPPED |
| TRIAL-026 | 乌鸡国救主 | 36,37,38 | — | UNMAPPED |
| TRIAL-027 | 被魔化身 | 39 | — | UNMAPPED |
| TRIAL-028 | 号山逢怪 | 40 | — | UNMAPPED |
| TRIAL-029 | 风摄圣僧 | 40 | — | UNMAPPED |
| TRIAL-030 | 心猿遭害 | 41 | — | UNMAPPED |
| TRIAL-031 | 请圣降妖 | 42 | — | UNMAPPED |
| TRIAL-032 | 黑河沉没 | 43 | — | UNMAPPED |
| TRIAL-033 | 搬运车迟 | 44 | — | UNMAPPED |
| TRIAL-034 | 大赌输赢 | 45,46 | — | UNMAPPED |
| TRIAL-035 | 祛道兴僧 | 45,46 | — | UNMAPPED |
| TRIAL-036 | 路逢大水 | 47 | — | UNMAPPED |
| TRIAL-037 | 身落天河 | 48 | — | UNMAPPED |
| TRIAL-038 | 鱼篮现身 | 49 | — | UNMAPPED |
| TRIAL-039 | 金兜山遇怪（异文：兜山遇怪（底本文字缺字）） | 50 | — | UNMAPPED |
| TRIAL-040 | 普天神难伏 | 51 | — | UNMAPPED |
| TRIAL-041 | 问佛根源 | 52 | — | UNMAPPED |
| TRIAL-042 | 吃水遭毒 | 53 | — | UNMAPPED |
| TRIAL-043 | 西梁国留婚 | 54 | — | UNMAPPED |
| TRIAL-044 | 琵琶洞受苦 | 55 | — | UNMAPPED |
| TRIAL-045 | 再贬心猿 | 56 | — | UNMAPPED |
| TRIAL-046 | 难辨猕猴 | 57,58 | — | UNMAPPED |
| TRIAL-047 | 路阻火焰山 | 59,60,61 | — | UNMAPPED |
| TRIAL-048 | 求取芭蕉扇 | 59,60,61 | — | UNMAPPED |
| TRIAL-049 | 收缚魔王 | 61 | — | UNMAPPED |
| TRIAL-050 | 赛城扫塔 | 62 | — | UNMAPPED |
| TRIAL-051 | 取宝救僧 | 63 | — | UNMAPPED |
| TRIAL-052 | 棘林吟咏 | 64 | — | UNMAPPED |
| TRIAL-053 | 小雷音遇难 | 65 | — | UNMAPPED |
| TRIAL-054 | 诸天神遭困 | 66 | — | UNMAPPED |
| TRIAL-055 | 稀柿同秽阻（异文：稀柿衕秽阻） | 67 | — | UNMAPPED |
| TRIAL-056 | 朱紫国行医 | 68 | — | UNMAPPED |
| TRIAL-057 | 拯救疲癃 | 69 | — | UNMAPPED |
| TRIAL-058 | 降妖取后 | 69,70,71 | — | UNMAPPED |
| TRIAL-059 | 七情迷没 | 72 | — | UNMAPPED |
| TRIAL-060 | 多目遭伤 | 73 | — | UNMAPPED |
| TRIAL-061 | 路阻狮驼 | 74 | — | UNMAPPED |
| TRIAL-062 | 怪分三色 | 74,75,76 | — | UNMAPPED |
| TRIAL-063 | 城里遇灾 | 77 | — | UNMAPPED |
| TRIAL-064 | 请佛收魔 | 77 | — | UNMAPPED |
| TRIAL-065 | 比丘救子 | 78 | — | UNMAPPED |
| TRIAL-066 | 辨认真邪 | 78,79 | — | UNMAPPED |
| TRIAL-067 | 松林救怪 | 80 | — | UNMAPPED |
| TRIAL-068 | 僧房卧病 | 81 | — | UNMAPPED |
| TRIAL-069 | 无底洞遭困 | 82,83 | — | UNMAPPED |
| TRIAL-070 | 灭法国难行（异文：钦法国难行） | 84,85 | — | UNMAPPED |
| TRIAL-071 | 隐雾山遇魔 | 85,86 | — | UNMAPPED |
| TRIAL-072 | 凤仙郡求雨 | 87 | — | UNMAPPED |
| TRIAL-073 | 失落兵器 | 88 | — | UNMAPPED |
| TRIAL-074 | 会庆钉钯 | 88,89 | — | UNMAPPED |
| TRIAL-075 | 竹节山遭难 | 88,89,90 | — | UNMAPPED |
| TRIAL-076 | 玄英洞受苦 | 91 | — | UNMAPPED |
| TRIAL-077 | 赶捉犀牛 | 92 | — | UNMAPPED |
| TRIAL-078 | 天竺招婚 | 93,94,95 | — | UNMAPPED |
| TRIAL-079 | 铜台府监禁 | 96,97 | — | UNMAPPED |
| TRIAL-080 | 凌云渡脱胎 | 98 | — | UNMAPPED |
| TRIAL-081 | 通天河补一难 | 99 | — | UNMAPPED |

## 5. 本轮发现并修正的错误判断

### TANG-09 不是缺失的起始路线 Sequence

- `data/narrative/starting_routes.json` 将唐僧起始路线终点固定为 `TANG-08`，交接到 `SHARED-01-FIVE-ELEMENTS`。
- `StartRouteCatalog`、唐僧路线进度测试与汇流矩阵也以 `TANG-08` 为终点。
- Bible 中的 `TANG-09 黑风山前` 描述的是师徒相会后的共同早期旅程，概念内容与 `SHARED-02-EARLY-PILGRIMAGE` / `SHARED-04-EARLY-DEMON-TALES` 的部分设计有重叠。
- **结论**：不要把 TANG-09 硬塞进 Origin route，否则会改变现有起始路线交接语义。它应作为 Shared 内容交叉映射/文档旧 ID 整理，不是现有 Origin 数据目录的直接 bug。

### LONGMA-07 / LONGMA-08 不是缺失的起始路线 Sequence，但确实是未交付的角色内容

- `starting_routes.json` 和 `StartRouteCatalog` 明确以 `LONGMA-06` 为白龙马起始路线终点，并在鹰愁涧进入 `SHARED-03-EAGLE-SORROW`。
- `docs/bai_longma_route.md` 将 LONGMA-07“沉默的旅伴”定义为入队后的坐骑阶段，将 LONGMA-08“龙魂初醒”定义为后续危机中的战斗形态觉醒。
- 当前 MemoryPlayback 只从 `OriginRouteManager` 查找章节；若把 07/08 追加到起始路线，当前顺序完成判断会要求它们也完成后才允许起始路线交接。
- **结论**：不把 07/08 直接追加到 `LONGMA_ORIGIN`。它们应作为独立的招募后 Memory / 角色成长内容设计；当前尚无独立 Memory catalog，故状态是“设计存在、运行时未交付”，不是可忽略的事项。

## 6. 本轮确认的共享主线文档漂移

`docs/shared_pilgrimage_chapter_bible.md` 的部分标题/章节编号与 Runtime 数据不一致。例如其开篇章节说明把黑风山写作 SHARED-01，而 `data/narrative/shared_chapters.json` 的真实注册顺序是：

1. SHARED-01 五行山
2. SHARED-02 师徒初行
3. SHARED-03 鹰愁涧
4. SHARED-04 黑风山与早期妖患
5. SHARED-05 高老庄
6. SHARED-06 四人西行
7. SHARED-07 流沙河
8. SHARED-08 五人归队
9. SHARED-09 完整西行

本轮已在 Bible 顶部加上运行时 ID 对齐表和使用优先级，避免继续用旧标题给 81 难分配错误章节。旧章节设计段落仍需后续逐节迁移到对应真实 ID，不能因为增加提示就算内容冲突彻底清零。

## 7. 起源线与共享主线目录审计

- Bible 概念章节数：49（悟空 15、唐僧 9、八戒 9、悟净 8、白龙马 8）。
- 运行时 `origin_chapters.json` 起始路线章数：46（悟空 15、唐僧 8、八戒 9、悟净 8、白龙马 6）。
- Origin Sequence 目录：31 条（唐僧 8、八戒 9、悟净 8、白龙马 6）；悟空 15 条位于 `event_sequences.json`，namespace 仍为 ORIGIN。
- Shared Sequence：9 条；合计 55 条 Sequence。当前两个 Sequence 目录的 ID/chapter_id 无重复。
- 49 与 46 的差异不是自动认定的数据 bug：TANG-09 是共享旅程设计，LONGMA-07/08 是招募后的角色内容。需要后续将二者分别纳入 Shared 与 Memory 的正式生产清单。

## 8. 当前优先级与下一步

1. **先整理 Shared Bible**：逐段把旧章节标题/段落迁移到当前 SHARED-01～09 的真实 ID；明确 SHARED-09 之后黄风岭主线如何接入，不要继续让共享章节定义与 JSON 冲突。
2. **单独设计 Memory catalog**：让 LONGMA-07/08 可以作为招募后的回忆/成长事件播放，又不延长 LONGMA 起始路线、不改写世界时间线。
3. **优先补足第 13–14 难黄风岭主线**：已有黄风岭—黄风洞—黄风妖王纵向切片与保存/重试测试，但尚未建立正式 Shared chapter crosswalk。
4. 其后按原著顺序推进宝象国、平顶山、乌鸡国、红孩儿、车迟国、通天河等内容。
5. 每个劫难按地图、NPC、怪物、Boss、对话、事件选择、战斗、奖励、失败/重试、保存读取、回归测试、正式美术和截图验收逐项通过后，才能升级状态。

---

## 9. 当前验收闸门

本目录新增 `combat/test_canonical_81_trials.gd`，由 Godot Runtime suite 执行，检查：

- 恰好 81 条，ID 连续且唯一；
- 前 80 条来自第九十九回难簿，末条明确标记为补数情节；
- 每条至少有小说章节定位，且回目号存在于锁定的 100 回索引；
- 所有关联的 Shared chapter ID 必须真实存在于 `shared_chapters.json`；
- 游戏状态值必须属于受控集合，不允许误把无映射记录标记完成。

当前 Runtime suite 在新测试提交后须重新跑精确 SHA；旧 SHA 成功不能替代新 SHA 验收。
