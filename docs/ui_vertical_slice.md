# Narrative UI Vertical Slice

## Goal

把已经建立的叙事状态规则落到第一层可操作 UI，形成从启动到存档的最小垂直切片。

## Current flow

`启动游戏 -> 主菜单 -> 选择五人之一 -> 开始新旅程 -> 写入存档 -> 显示当前西游状态`

主菜单同时展示：

- 五位起始主角与个人主题
- 当前起始主角
- 世界时间线索引
- 当前共享章节
- 已招募人物
- 已解锁/已完成的人物回忆
- 读取存档
- 原有战斗演示入口

## Narrative rules represented by the UI

1. 任意五人都可以作为新游戏第一位主角。
2. 起始角色只决定玩家从哪条个人路线进入，不重写世界时间线。
3. 人物个人故事不是 `PARTY_FULL` 后才开放。
4. 回忆播放使用独立的 memory 状态，不应该推进 `current_global_timeline`。
5. 存档只保存 narrative state，后续可继续叠加队伍、装备、世界悬赏和战斗状态。

## Implementation boundary

当前 UI 是纯 Godot Control + GDScript 生成，不依赖外部素材，因此可以先稳定交互与状态，再替换为正式 HD-2D 美术界面。

## Next slice

下一层应把“共享章节”真正做成可点击的章节节点：

`主菜单 -> 当前章节 -> 进入章节 -> 触发招募 -> 立即增加个人回忆 -> 返回当前章节`

随后再接五人队伍编成、前后排轮换与正式战斗 HUD。
