# 西游八十一难总台账（审计初版）

> 状态基线：2026-11-12。本文是追踪与验收账本，不宣称已经完成 81 难的原著考据映射。
> 
> **重要区分**：原著劫难编号、游戏章节设计、已写入数据、运行时可玩、生产验收是五种不同状态，不能互相替代。

## 1. 本轮审计结论

### 已确认的项目事实

- 五人起始路线 Bible 当前章节定义数：悟空 15、唐僧 9、八戒 9、悟净 8、白龙马 8，合计 **49 个 Origin 章节定义**。
- 当前 `data/narrative/event_sequences_origin.json` 实际登记：唐僧 8、八戒 9、悟净 8、白龙马 6，合计 **31 条 Origin Sequence**。
- 悟空路线的 15 条 Sequence 已在 `data/narrative/event_sequences.json` 登记（WUK-01～WUK-15）；它们仍属于个人 Origin Route，不因存放在共享序列目录而变成 Shared 主线。
- 因此已能明确指出两处 Bible 与 Origin Sequence 数量差异：`TANG-09` 尚未出现在 Origin catalog；`LONGMA-07`、`LONGMA-08` 尚未出现在 Origin catalog。它们目前只能标记为“设计已定义、数据序列未登记”，不能标记完成。
- 已存在的共享章节、区域探索和黄风岭纵向切片，只能按各自真实覆盖范围计入，不可直接折算成若干原著劫难。
- README 的 81 Trials Philosophy 明确允许大小试炼混合，不要求 81 个大型副本；但仍需建立 81 个可追溯的独立记录。

### 当前不能给出的数字

**不能给出“已完成 X/81”**：仓库没有原著 81 难逐条编号映射，也没有统一的逐难验收证据链。49 是 Origin Bible 章节定义数，不是 81 难完成数；31 是 Origin Sequence 数据数，不是可玩完成数。

## 2. 状态定义（强制统一）

| 状态 | 含义 | 必要证据 |
|---|---|---|
| UNMAPPED | 尚未完成原著劫难身份/编号核对 | 无 |
| PLANNED | 已确认对应原著劫难并写明游戏设计 | 原著来源、映射理由、章节 brief |
| DATA_AUTHORED | 章节/事件/遭遇/奖励等数据已登记 | 文件路径 + 稳定 ID + validator |
| RUNTIME_READY | 玩家可从真实入口完成该内容 | SceneTree/Runtime 回归、存档恢复 |
| CONTENT_COMPLETE | 剧情、探索、战斗、奖励、世界后果和必要演出达到章节验收 | 内容清单逐项通过 |
| PRODUCTION_ACCEPTED | 美术、音频、UI、截图和目标平台验收通过 | 资产审核、精确 SHA CI、玩家视角证据 |
| BLOCKED | 存在未解决的依赖/设计冲突/失败测试 | 问题单与解除条件 |

状态不可跳级。可同时记录多个子系统状态，但总状态取最弱的必需门槛。

## 3. 每一难必须记录的字段

每条记录必须具备：
1. 难次 ID（`TRIAL-001` 至 `TRIAL-081`）与原著回目/来源；
2. 原著劫难名称、发生顺序、主要人物和结果；
3. 游戏章节 ID、Origin/Shared/Optional 分类及固定世界时间线位置；
4. 地图、城镇、山岭、洞府、河流、关隘及可进入区域；
5. NPC、普通怪、精英、Boss 与遭遇 ID；
6. 对话、事件、选择、过场、失败/重试/返回路径；
7. 战斗机制、弱点/护盾/Break、奖励、装备与世界状态变化；
8. 美术提示词 ID、源资产、运行时资源路径、音频/UI/VFX；
9. 自动化测试、精确 SHA Runtime/Web 结果和玩家视角截图；
10. 当前状态、阻塞项、下一步和证据链接。

## 4. 已发现差异与修复方向

| 问题 | 证据 | 处理 |
|---|---|---|
| 81 难没有逐条台账 | 当前 README 只有总体哲学，没有 81 条逐项编号 | 本文先建立 81 个稳定槽位；逐条原著映射须基于可靠底本核对 |
| Bible 与数据目录不同步 | Bible 49 个 Origin 章节；Origin catalog 31 条 | 将 TANG-09、LONGMA-07、LONGMA-08 列为数据缺口，不虚报完成 |
| 章节数被误当成劫难数 | Origin 章节是人物前史，不等于取经路上的 81 难 | 分离 Origin、Shared Mainline、Optional Trial 三类 |
| 设计/数据/可玩/生产验收混为一谈 | 文档记录了多个不同验证层 | 使用本文件状态机与证据要求 |
| 共享章节映射不完整 | 共享章节并不天然等于单独一难；部分章节是过渡/招募节点 | 每条 Shared chapter 先做映射评估，允许一章覆盖多个连续小难，也允许一难跨多章，但必须解释 |

## 5. 序列目录交叉审计

对 main 上两个 JSON 目录进行解析与交叉检查：
- Origin catalog：31 条；Shared catalog：24 条；总计 55 条。
- Sequence ID 重复：0；chapter_id 重复：0。
- 前缀分布：WUK 15、TANG 8、BAJIE 9、WUJING 8、LONGMA 6、SHARED 9。
- 该结果证明两个目录当前没有重复 ID/chapter_id，但不证明所有 Bible 章节都已登记，也不证明 55 条都已通过当前精确 SHA Runtime。

## 6. 81 条追踪槽位

以下槽位先固定 ID，避免后续重编号。原著名称、回目和映射在完成底本核对前保持 UNMAPPED；不得凭记忆编造名称或顺序。

| ID | 原著劫难/回目 | 游戏映射 | 状态 | 证据/缺口 |
|---|---|---|---|---|
| TRIAL-001 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-002 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-003 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-004 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-005 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-006 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-007 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-008 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-009 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-010 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-011 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-012 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-013 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-014 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-015 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-016 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-017 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-018 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-019 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-020 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-021 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-022 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-023 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-024 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-025 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-026 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-027 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-028 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-029 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-030 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-031 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-032 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-033 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-034 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-035 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-036 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-037 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-038 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-039 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-040 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-041 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-042 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-043 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-044 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-045 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-046 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-047 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-048 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-049 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-050 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-051 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-052 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-053 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-054 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-055 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-056 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-057 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-058 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-059 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-060 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-061 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-062 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-063 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-064 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-065 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-066 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-067 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-068 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-069 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-070 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-071 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-072 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-073 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-074 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-075 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-076 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-077 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-078 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-079 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-080 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |
| TRIAL-081 | 待核对 | 待映射 | UNMAPPED | 需核对原著底本并建立证据 |

## 7. 当前已知游戏内容映射（不折算为劫难完成数）

| 内容组 | 已知范围 | 当前证据级别 | 说明 |
|---|---|---|---|
| Wukong Origin | WUK-01～WUK-15 | 15 条 Sequence 已登记在 event_sequences.json；进度回归已建立，需按当前 main 精确 CI 复核 | 人物前史，不直接计入 81 难 |
| Tang Origin | Bible TANG-01～09；Origin catalog TANG-01～08 | DATA_AUTHORED（01～08）；TANG-09 为缺口 | Bible 比数据多 1 章 |
| Bajie Origin | BAJIE-01～09 | DATA_AUTHORED | 人物前史 |
| Wujing Origin | WUJING-01～08 | DATA_AUTHORED | 人物前史 |
| Longma Origin | Bible LONGMA-01～08；Origin catalog LONGMA-01～06 | DATA_AUTHORED（01～06）；07～08 为缺口 | Bible 比数据多 2 章 |
| Shared Journey | 已登记 SHARED-01～09 等开篇节点 | DATA/RUNTIME 证据分散在历史日志 | 招募/过渡章节不能自动等同 81 难 |
| Yellow Wind arc | 黄风岭→黄风洞→黄风妖王 | 有较完整运行时纵向切片记录 | 可作为章节生产模板，不代表完成多个原著劫难 |
| Region exploration | 鹰愁涧、五行山两个数据驱动区域 | 各 3 个线索点，存档/回滚回归 | 可选探索，不推进主线劫难计数 |

## 8. 执行顺序

1. 先确定原著底本和“八十一难”采用的权威列表/版本，逐条记录回目与原文依据。
2. 把 81 难映射到 Origin / Shared Mainline / Optional Trial；明确人物前史不计入取经劫难，除非设计明确说明其叙事功能。
3. 对每个现有章节建立 crosswalk，找出缺章节、重复、错序、无地图、无遭遇、无奖励、无结局反馈等问题。
4. 先修复明确的数据缺口：TANG-09、LONGMA-07、LONGMA-08；实施前检查它们是否已在其他 catalog/branch 存在，避免重复 ID。
5. 按主线顺序推进一个完整劫难切片，测试入口、过程、失败、胜利、奖励、保存/读取、世界状态和返回路径。
6. 每次变更同步开发日志、AI_MEMORY、AI_HANDOFF、索引；只有精确 SHA Runtime 成功才能标 RUNTIME_READY。
7. 视觉资产必须遵循 ART_REVIEW_STANDARD；自动化路径测试不能代替截图和美术验收。

## 9. 当前下一步

- 先完成原著 81 难的来源核对与逐条 crosswalk；在这之前不填写虚构名称。
- 并行审查 Origin catalog 是否遗漏 Bible 定义章节，以及 Shared catalog 是否存在重复/孤儿/错误 namespace。
- 对每个发现的问题创建可验证的修复，不以“文档写了”代替运行时完成。
