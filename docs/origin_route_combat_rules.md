# Origin Route Combat Rules

个人起始路线战斗遵循以下固定规则：

1. 个人战斗使用 `BountyEncounterState.start_narrative_encounter()` 建立临时战斗 handoff，类型固定为 `origin`。
2. 起始角色在正式招募之前就可以独自参战。`CombatPartyBuilder` 在 `origin` handoff 下只构建当前存档的 `starting_character`，不会要求该角色已经进入 recruited roster。
3. 个人战斗胜利后，`BattleUI` 校验 `source_chapter_id` 与当前 Origin Chapter 一致，随后才调用 `OriginRouteManager.complete_current()`。
4. 个人战斗失败不会完成章节，也不会推进共享西游时间线。
5. 起始角色已经做出的 Origin 选择可以在战斗初始化时转化为小幅、确定性的战斗特性。当前悟空路线：
   - `WUK-03 / SEEK_POWER`：攻击 +2
   - `WUK-08 / REJECT_BINDING`：速度 +1
   - `WUK-13 / ENDURE`：防御 +2
6. 这些战斗加成只影响当前个人路线玩法，不改变固定共享时间线，不修改招募顺序。
7. 未来唐僧、白龙马、八戒、沙僧路线可以复用同一 handoff 机制，但每个角色的选择效果必须保持角色主题一致，并通过独立测试覆盖。
