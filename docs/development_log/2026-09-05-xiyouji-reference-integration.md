# Journey to the West Reference Integration — 2026-09-05

## Goal
将《西游记》原著从外部临时参考正式纳入本项目的剧情设计资料层，使后续 EventSequence、章节拆分、人物招募与世界时间线梳理都有稳定的原著依据。

## Source
- `gazhikaba/xiyouji_txt`
- pinned reference commit: `419a54fbaf368af463dd863b8271ec7bb176b3b3`
- repository description identifies the corpus as plain-text Journey to the West material and credits Chinese Text Project.

## Added
- `docs/source_materials/xiyouji_reference.md`
  - defines the separation between original-text reference and executable game narrative
  - records all 100 chapter titles
  - identifies the currently relevant early-pilgrimage range
  - defines an adaptation-note convention
- `data/narrative/reference/xiyouji_chapter_index.json`
  - machine-readable 100-chapter index
  - stores the pinned source repository and commit for traceability
- `docs/source_materials/xiyouji_game_mapping.md`
  - maps the current Origin/Shared design to the relevant canonical chapters
  - records the major causal chains that future RPG compression should preserve

## Design rule
原著资料层不直接驱动运行时。`data/narrative/*.json` 与 EventSequence 继续保存游戏化后的实现；设计文档逐步通过 `xiyouji_chapters` / `adaptation_type` 标记原著来源与改编原因。

## Immediate story impact
当前第一 Vertical Slice 应优先重新检查 1–22 回：

- 1–7：悟空起源、求道、天宫、五行山
- 8–14：玄奘前史、取经缘起、双叉岭、悟空入队
- 15：鹰愁涧与龙马
- 16–17：观音院、袈裟、黑风山
- 18–19：高老庄、云栈洞、八戒
- 20–21：黄风岭与早期护师危机
- 22：流沙河与悟净

## Verification
本次提交包含一个与剧情资料无关的并行 CI 链：Shared 03/05/07 BattleUI SceneTree bridge 正在进行最终 runtime 验证。原著参考文件本身不进入运行时测试路径。

## Next story pass
下一轮剧情开发不应只增加更多事件，而应对照原著 1–22 回检查：角色进入时机、地理移动顺序、战斗因果、人物关系、招募前后对白，以及哪些新增内容属于本项目独有的“五行路线”层。
