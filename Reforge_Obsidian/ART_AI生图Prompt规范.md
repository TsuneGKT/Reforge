# Reforge（重锻）· AI 生图 Prompt 规范

> 美术规格 → [[ART_美术方向与资产规格]]
> 原型规范 → [[ART_原型表现规范与P0资源接入]]
> 攻击动画 → [[ART_攻击动画分层规范]]
> 世界观来源 → [[DESIGN_世界观设计文档]]

---

## 一、用途

本文记录 Reforge P0 美术资产的 AI 生图 Prompt 基准。当前目标是稳定生成玩家、锈犬、怪物和交互物的单帧基准图，再进入动作视频、分帧、修图和精灵图流程。

已确认的视觉方向：

```text
3/4 俯视简化手绘动作风
```

核心关键词：

- 人物 / 怪物形体简化。
- 强黑色外轮廓。
- 大色块上色。
- 暗幻想气质。
- 低细节但高辨识度。
- 武器、甲片、身体朝向清楚。
- 适合缩小成游戏内精灵。

---

## 二、通用 Prompt

用于生成角色、敌人、交互物时作为基础风格段落。

```text
Create a single 2D game sprite concept for Reforge, a top-down 3/4 dark fantasy action roguelike.

Style: simplified hand-painted action game sprite, strong readable silhouette, crisp dark outer outline, large clean color blocks, limited detail, minimal small ornaments, clear shape language, readable weapon or armor shapes, suitable to be reduced into an in-game sprite.

Camera and pose: top-down 3/4 view, full body visible, centered composition, neutral idle or ready stance, clear facing direction, visible foot contact point for gameplay positioning.

Visual tone: dark fantasy, muted dark colors, rusted metal, broken armor, worn materials, subtle supernatural accent color, high contrast between character and background.

Composition: one character only, neutral flat background, no UI, no text, no environment, no dramatic illustration framing, no portrait composition.

The image should function as a clean single-frame standard for a sprite pipeline.
```

---

## 三、玩家 Prompt

用于生成玩家角色单帧、动作首尾帧或后续动画参考。

```text
Create a single 2D game player character sprite concept for Reforge, a top-down 3/4 dark fantasy action roguelike.

Subject: a simplified dark fantasy melee player character, facing down-right at a 3/4 top-down angle, standing in a ready idle pose with a clear one-handed sword or reforged blade.

Style: simplified hand-painted action game sprite, strong readable silhouette, crisp dark outer outline, large clean color blocks, minimal small details, no complex patterns, no realistic rendering.

Design: dark humanoid body, simple broken armor plates on shoulders, forearms, and chest, bright readable metal weapon, compact action-game proportions, slightly larger upper body and head, simplified legs and feet, clear foot contact point.

Color: dark body, muted metal armor, bright weapon highlight, limited palette.

Composition: one full-body character only, centered, neutral flat background, no UI, no text, no environment.

The character should feel suitable to be reduced to about 72 px tall in-game.
```

当前玩家 P0 生产基准图：

![[附件/player_style_baseline_v1_idle_down_right_canvas512.png]]

```text
Reforge_Godot/art/player/sprites/player_style_baseline_v1_idle_down_right_canvas512.png
```

原始风格参考图：

![[附件/player_style_baseline_v1.png]]

---

## 四、锈犬 Prompt

用于生成锈犬单帧、动作首尾帧或后续动画参考。

```text
Create a single 2D game enemy sprite concept for Reforge, a top-down 3/4 dark fantasy action roguelike.

Subject: Rust Hound, a former border knight military dog reanimated by strange corrupting power; dog armor fused with its body, rusted metal plates, agile low body, patrol hound silhouette.

Pose: facing down-left or down-right at a 3/4 top-down angle, full body visible, low ready idle stance, prepared to lunge.

Style: simplified hand-painted action game sprite, strong readable silhouette, crisp dark outer outline, large clean color blocks, minimal small details, no realistic fur rendering, no busy texture.

Design: low horizontal quadruped body, clear head, armored shoulders and back plates, rusted metal accents, dark body, small sickly green or pale blue corruption accent.

Composition: one full-body enemy only, centered, neutral flat background, no UI, no text, no environment.

The enemy should feel suitable to be reduced to about 56-64 px long in-game and readable next to a 72 px tall player character.
```

当前锈犬 P0 生产基准图：

![[附件/rust_hound_style_baseline_v1_idle_canvas512.png]]

```text
Reforge_Godot/art/enemies/rust_hound/sprites/rust_hound_style_baseline_v1_idle_canvas512.png
```

原始风格参考图：

![[附件/rust_hound_style_baseline_v1.png]]

---

## 五、负面 Prompt

用于减少跑偏方向。

```text
no portrait, no side-scroller view, no realistic rendering, no anime detail overload, no tiny ornaments, no busy texture, no complex background, no UI, no text, no multiple characters, no cinematic lighting, no full illustration scene, no pixel art dithering
```

---

## 六、使用流程

每次生成新资产时按以下顺序组织 Prompt：

```text
通用 Prompt
→ 对象专用 Prompt
→ 尺寸 / 朝向 / 动作要求
→ 负面 Prompt
→ 附带已确认基准图作为参考
```

单帧图通过后，再进入动作流程：

```text
单帧基准
→ Codex / GPT 生成动作首帧、关键姿势或参考图
→ 即梦生成动作视频
→ 导出分帧图
→ PS 清理角色本体、统一脚底锚点和轮廓
→ Aseprite 合成精灵图
→ Godot 导入验证
```

---

## 七、攻击动画 Prompt 补充

玩家攻击动画先制作右下方向普攻样例。生图阶段可以生成带弧光的动作参考图，用来确认挥砍力度、身体姿势和画面感觉；正式接入时按 [[ART_攻击动画分层规范]] 拆分角色本体、弧光和 Hitbox。

攻击参考图 Prompt 补充：

```text
Create a key pose reference for a top-down 3/4 melee attack animation.

The player character is facing down-right, performing a one-handed sword slash.
Keep the same character design, proportions, camera angle, and foot anchor as the confirmed idle reference.
Use a clear readable attack pose with strong body weight shift, visible weapon path, and a broad slash arc as visual reference.

The frame should be suitable for extracting animation keyframes.
The character must remain centered on a transparent 512x512 canvas.
The feet / ground contact point should stay stable for gameplay positioning.
```

负面补充：

```text
no side view, no full illustration background, no camera change, no changing costume, no changing weapon length, no extra characters, no motion blur covering the body, no unreadable weapon pose
```

首个测试方向：

```text
player_attack_down_right
Idle → windup → slash_active → recovery
```

---

## 八、变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-06-01 | 创建 AI 生图 Prompt 规范，沉淀玩家与锈犬第一版美术基准 Prompt。 |
| 2026-06-02 | 补充攻击动画 Prompt 与分层流程，明确首个测试方向为玩家右下普攻。 |
