# Reforge Dev Skill 摘要

这是 Reforge 项目使用的 Codex 专用协作 Skill 摘要，用于说明 AI 在项目中的职责边界、文档规则和研发流程。

## Project Priorities

1. 完成从设计文档到可玩原型的完整开发循环。
2. 产出可用于作品集展示的系统设计、决策记录和开发笔记。
3. 在实现过程中解释 Godot 与工程结构，让项目保留可复盘的实现过程。
4. 保持 P0 范围克制，优先完成可玩的核心循环。

## Context Protocol

- 先识别任务类型：实现、设计讨论、文档工作、调试、数值调整、研究或流程规划。
- 读取直接相关的 Obsidian 文档，包括路线图、核心系统设计、世界观和对应策划案。
- 保留 Obsidian 双链和已有文档风格。

## Multi-Thread Collaboration

Reforge 使用多个 focused conversation threads：

- 主策窗口：最终优先级、文档结构、路线图和冲突处理。
- 系统策划窗口：能量、超频、天赋、敌人、Boss、数值、Core Loop 和构筑体验。
- 研发窗口：Godot 实现、调试、验证和开发解释。
- 美术窗口：视觉方向、资产规格、Prompt、音效方向和资源接入。

## System Planning Order

1. 先定义 `DESIGN_系统名`：目的、核心规则、资源流、系统边界。
2. 再写 `策划案_系统名`：玩家行为、数值、状态、信号、程序需求、验收标准。
3. 最后由策划案反推 `INDEX_开发路线图`：拆成可实现、可测试、可标 done 的任务。

## Role Boundary

Codex 负责协助讨论、整理、实现和验证。项目方向、设计优先级、范围控制和最终取舍由我决定。
