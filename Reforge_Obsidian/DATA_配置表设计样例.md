# DATA_配置表设计样例

> 展示重点：配置表维护、基础数值调试、系统需求拆分、功能测试。
> 关联文档 → [[DESIGN_核心系统设计文档]] [[策划案_能量系统]] [[策划案_锈犬]] [[DATA_天赋池]]

---

## 1. 文档目的

本文件用于展示《Reforge》P0 系统如何拆分为可维护、可测试、可交付给程序读取的配置数据。

配置表不是单纯记录数值，而是把系统规则转化为结构化字段。策划通过配置表维护内容条目、数值参数、文案 key、触发条件和验收检查项，程序通过字段读取数据并在游戏中生成对应表现。

---

## 2. 配置表设计原则

1. 每条配置必须有唯一 id，用于程序读取、测试定位和版本追踪。
2. 玩家可见文本使用 localization key，不在表内直接写死展示文案。
3. 数值字段必须标明单位，例如秒、像素、点数、比例。
4. 规则字段与备注字段分离，程序字段保持稳定，策划说明用于协作理解。
5. 每张表保留 source_doc 字段，链接到对应 DESIGN、策划案或 DATA 文档。
6. 每条关键配置保留 check_rule 字段，用于说明测试时如何验证该条配置生效。

---

## 3. 表结构总览

| 表名 | 作用 | 对应系统 | 对应文档 |
|------|------|----------|----------|
| talent_config.csv | 维护天赋条目、触发条件、关键词和效果参数 | 天赋系统 | [[DATA_天赋池]] |
| enemy_config.csv | 维护敌人基础参数、攻击节奏和教学定位 | 敌人系统 | [[策划案_锈犬]] |
| energy_config.csv | 维护能量、超频、光核兑换等核心参数 | 能量系统 | [[策划案_能量系统]] |

---

## 4. talent_config 字段说明

| 字段 | 含义 | 示例 |
|------|------|------|
| talent_id | 天赋唯一 id | talent_deflect_resonance |
| name_key | 天赋名称多语言 key | talent.deflect_resonance.name |
| desc_key | 天赋描述多语言 key | talent.deflect_resonance.desc |
| tier | 天赋层级 | 1 / 2 / 3 |
| main_build | 主流派 | 弹反 |
| keyword | 关键词 | 共振 |
| trigger | 触发条件 | parry_success |
| effect_param | 效果参数 | next_attack_overclock |
| cost_rule | 消耗或代价规则 | requires_overclock_energy |
| status | 当前状态 | candidate |
| source_doc | 来源文档 | DATA_天赋池 |
| check_rule | 验收检查 | 弹反成功后下一次普攻获得超频效果 |

---

## 5. enemy_config 字段说明

| 字段 | 含义 | 示例 |
|------|------|------|
| enemy_id | 敌人唯一 id | rust_hound |
| name_key | 敌人名称多语言 key | enemy.rust_hound.name |
| role | 敌人定位 | 弹反教学 |
| max_hp | 生命值 | 40 |
| attack_damage | 攻击伤害 | 8 |
| move_speed | 移动速度，单位 px/s | 110 |
| detect_range | 检测范围，单位 px | 220 |
| windup_sec | 攻击前摇，单位秒 | 0.45 |
| parry_window_sec | 可弹反窗口，单位秒 | 0.27 |
| source_doc | 来源文档 | 策划案_锈犬 |
| check_rule | 验收检查 | 玩家能看见前摇并通过弹反获得反击窗口 |

---

## 6. energy_config 字段说明

| 字段 | 含义 | 示例 |
|------|------|------|
| param_id | 参数唯一 id | perfect_parry_gain |
| system | 所属系统 | energy |
| value | 参数值 | 12 |
| unit | 单位 | energy |
| usage | 参数用途 | 完美弹反回能 |
| source_doc | 来源文档 | 策划案_能量系统 |
| check_rule | 验收检查 | 完美弹反后能量增加 12 点 |

---

## 7. 与程序实现关系

P0 当前以 Godot Resource、脚本常量和局部数据文件完成原型验证。正式配置表用于展示策划字段拆分能力，并为后续数据驱动实现预留结构。

后续如果推进到更完整的数据驱动流程，配置表可以按以下方向接入：

1. CSV 或表格文件维护原始配置。
2. 导出为 Godot 可读取的 Resource、JSON 或 Dictionary。
3. 系统初始化时读取配置并注册到对应 Manager。
4. 测试用例根据 id 和字段值验证配置是否生效。

---
