# AI 美术交付规范（Gemini Banana / 其他图像模型）

> 本文件是《西游：五行之路》的 AI 美术交付契约。程序、美术模型、后续 Agent 都以本文件为接口，不允许临时改变资源目录和命名规则。

## 1. 总原则

本项目采用“程序先行、美术可替换”的生产方式：

```text
游戏规则 / 剧情 / 战斗 / 地图 / 存档
                ↓
       Presentation Asset Contract
                ↓
     AI 生成最终 PNG / WebP 素材
                ↓
        assets/art/.../final/
                ↓
     ArtAssetCatalog 自动优先加载
```

最终美术缺失时，程序回退到当前占位 SVG，因此美术制作不会阻塞玩法开发。

## 2. 角色素材

每个主要角色至少准备以下资产：

```text
assets/art/characters/final/wukong.png
assets/art/characters/final/tang.png
assets/art/characters/final/bajie.png
assets/art/characters/final/wujing.png
assets/art/characters/final/longma.png
assets/art/characters/final/yellow_wind.png
```

### 推荐交付规格

- 透明背景。
- 主视觉为清晰的 2D 像素角色，不要圆头方身体的几何占位感。
- 保持固定像素网格，不做软件式模糊边缘。
- 角色轮廓必须在缩小后仍然可识别。
- 武器、头饰、服装、颜色和体型必须具有角色识别度。
- 角色脚底不要带地面背景；地面阴影由程序或场景图统一处理。
- 最终 PNG 优先；WebP 可作为体积优化版本。

### 角色提示方向

**孙悟空**：猴面、金箍、红/赭色战衣、金箍棒、敏捷战斗姿态；不要做成普通人类武将。

**唐三藏**：僧袍、法器/禅意细节、克制的姿态；视觉重心是“僧人”和“取经者”，不是法师。

**猪八戒**：明显的猪头轮廓、厚重身形、九齿钉耙；强调力量与喜剧性，但不能卡通幼稚。

**沙悟净**：沙僧/卷帘大将特征、厚重衣甲或行脚装、沉稳姿态、月牙铲；避免与八戒轮廓相似。

**白龙马**：龙族血脉、白马形态、东方龙元素；需要能区分“普通马”和“神话龙马”。

**黄风怪**：大型妖王轮廓、土黄/褐色风沙主题、压迫感；需要在战斗画面中明显大于杂兵。

## 3. 场景素材

### 旅途场景

```text
assets/art/scenes/final/journey_scenery.png
```

要求：
- 横向 16:9 构图。
- 前景留出角色站立区域。
- 中景提供建筑、山体、道路等西游环境信息。
- 远景提供层次，不要把所有细节堆在角色脚下。
- 不要绘制任何 HUD、按钮、文字或血条。

### 黄风战斗场景

```text
assets/art/scenes/final/yellow_wind_battle.png
```

要求：
- 横向 16:9。
- 左侧保留玩家队伍战斗空间。
- 右侧保留 Boss 与杂兵战斗空间。
- 中央保留清晰的攻击/特效可读区域。
- 不要预画 UI。

### 世界地图

```text
assets/art/scenes/final/world_map.png
```

要求：
- 俯视/地图式构图。
- 主要地点有清晰形状差异。
- 路径和地标能够承载程序绘制的节点/路线。
- 不要把路线文字硬编码到图片里。

## 4. UI 与美术的边界

UI 框体、HP 条、Shield 条、Action Queue、Target/Weakness/Shield、Command、Frame Status 等由程序绘制并统一遵循：

- 45°切角。
- 双层描边。
- 青绿色主信息色。
- 金色/橙色用于重点与行动。
- 深蓝黑面板。
- 点阵、铆钉、扫描线式装饰。

AI 美术不要生成 UI 截图来替代程序 UI。AI 只负责角色、场景、怪物、道具、特效等视觉资产。

## 5. 动画素材（后续）

当进入动画阶段，优先采用 sprite sheet：

```text
assets/art/characters/final/wukong_idle.png
assets/art/characters/final/wukong_attack_01.png
assets/art/characters/final/wukong_hurt.png
```

程序定义动画帧和状态；AI 负责逐帧画面。

初期不要求动画资产，先完成静态角色与场景。

## 6. 特效素材（后续）

统一放到：

```text
assets/art/vfx/final/
```

例如：

```text
fire_break.png
metal_break.png
wind_slash.png
shield_break.png
critical_hit.png
heal.png
```

原则：透明背景、明确轮廓、像素化、高对比、单用途；不把文字和伤害数字画进特效图片。

## 7. 程序接入规则

程序代码不要直接散落硬编码最终图片路径。

推荐链：

```text
ArtAssetCatalog
      ↓
CharacterPortrait / VisualOverlay / BattleUI / WorldMap
```

`ArtAssetCatalog` 当前解析顺序：

1. `assets/art/<kind>/final/<id>.png`
2. `assets/art/<kind>/final/<id>.webp`
3. 现有 SVG fallback

因此以后只需要新增最终图片，不需要重写玩法代码。

## 8. 最终质量检查

一张 AI 图片交付前必须检查：

- 缩小后轮廓是否仍然清晰。
- 像素边缘是否干净。
- 是否和项目统一的西游东方美术语言匹配。
- 是否与其他角色有明显剪影差异。
- 是否误带背景、文字、UI 或水印。
- 是否适合程序固定位置使用。
- 是否需要单独裁切，而不是强行塞进现有图片。

## 9. 当前生产优先级

第一优先级：

1. 悟空 / 唐僧 / 八戒 / 悟净 / 龙马角色图
2. 黄风怪 Boss
3. 黄风战斗背景
4. 个人序章场景背景
5. 世界地图

第二优先级：

1. NPC
2. 杂兵
3. 道具
4. 战斗特效
5. 动画帧

## 10. 禁止事项

- 禁止返回“圆头 + 方身体”的占位人物作为最终美术。
- 禁止用普通现代插画替代像素 JRPG 视觉。
- 禁止 AI 图片直接包含 HUD/UI 文本。
- 禁止为了换图修改核心剧情或战斗规则。
- 禁止把一次性的 AI 图片直接散落到代码里而不登记 Asset Catalog。
