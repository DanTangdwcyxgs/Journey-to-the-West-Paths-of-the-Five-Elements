# 2026-09-05 — Shared-05 / Shared-06 EventSequence Migration

## Goal

继续 Batch B 的 Shared Journey Migration，在不扩张 Runner 抽象的前提下，把高老庄招募战和四人西行章节正式接入现有 EventSequence → SceneTree → Battle Handoff 链。

## What changed

### Shared-04 reward 去重

移除 `SHARED-04-EARLY-DEMON-TALES-SEQUENCE` 中的 `reward(HERB)` 节点。

原因：章节数据已经声明 `rewards:["HERB"]`，无战斗 Shared chapter 在 EventSequence END 时会调用 `SharedJourneyManager.complete()`，章节完成本身会发放奖励。保留 sequence reward 会造成重复发奖。

### Shared-05

新增 `SHARED-05-GAOJIAZHUANG-SEQUENCE`：

`arrival dialogue → BAJIE_ENCOUNTER choice → SHARED_GAOJIAZHUANG battle → after-battle dialogue → end`

保留 BattleResolutionService 作为招募战的唯一原子结算边界。Sequence 只负责流程和 Battle Handoff，不重复完成章节。

### Shared-06

新增 `SHARED-06-FOUR-PERSON-JOURNEY-SEQUENCE`：

`depart dialogue → wait → resolve dialogue → end`

该章节没有战斗，因此最终 END 会由现有 Journey sequence completion 逻辑提交 Shared chapter，并由章节数据负责奖励与世界推进。

### Regression

扩展 `combat/test_event_sequence_validator.gd`：

- 验证 Shared-05 sequence 存在且 cross-reference 有效；
- 验证 Shared-06 sequence 存在且结构有效；
- 保留 Shared-03 / Shared-04 回归及故意错误 sequence 的拒绝测试。

## Why

Shared Journey Migration 的目标不是把旧章节换成另一套按钮，而是验证同一套数据驱动执行链可以连续覆盖：

- 战斗招募章节；
- 无战斗章节；
- BattleUI 跨场景恢复；
- Shared chapter 原子推进；
- 章节奖励唯一来源。

这轮特别处理了“sequence reward 与 chapter reward 重复”的一致性问题，避免迁移后出现隐藏经济错误。

## Systems affected

- Narrative：新增 Shared-05 / Shared-06 sequence；
- Presentation：继续复用 Journey Event Presentation，无新增 Runner/UI 耦合；
- Battle：Shared-05 继续走现有 BattleResolutionService；
- Reward：Shared-04 改为只由章节完成发放 HERB；
- Progression：Shared-06 END 依赖既有无战斗 chapter completion。

## Files

- `data/narrative/event_sequences.json`
- `combat/test_event_sequence_validator.gd`
- `docs/development_log/2026-09-05-shared05-shared06-migration.md`
- `docs/AI_MEMORY.md`（本轮完成后同步）

## Validation

- 静态内容结构：已按 `EventSequenceValidator` 设计检查。
- GitHub commit status / workflow：截至本记录生成时，最新测试提交没有返回 workflow run，combined status 为 `statuses: []`；因此不能声明 Godot Runtime 已通过。
- 本轮没有本地 Godot 可执行环境可用于替代 CI。

## Known issues

- MOVE 仍主要是逻辑 world action，没有角色路径动画；
- WAIT 仍不会推进独立世界时钟；
- `BountyEncounterState` 仍是临时 Scene Handoff 兼容层；
- Shared-07/08/09 尚未迁移；
- Event UI 仍是基础 presentation 壳，镜头、角色演出和更完整 SceneTree 动画仍待后续完善。

## Next step

继续 `SHARED-07-FLOWING-SANDS` 与 `SHARED-08-PARTY-FULL`，验证第二场招募战和五人集齐后的非战斗过场，再迁移 `SHARED-09-FULL-PILGRIMAGE`。

## Handoff point

下一位 Agent 先检查：

`AI_MEMORY.md → 本日志 → event_sequences.json → shared_chapters.json → Journey / BattleResolutionService`

重点验证 Shared-05 的 battle resume 后 END 不会重复完成章节；Shared-06 END 应只完成一次章节并拿到章节奖励。
