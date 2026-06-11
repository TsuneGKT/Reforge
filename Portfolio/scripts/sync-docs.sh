#!/bin/bash
# Sync public Obsidian documents into Quartz content by whitelist.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PORTFOLIO="$ROOT/Portfolio"
VAULT="$ROOT/Reforge_Obsidian"
DEST="${1:-$PORTFOLIO/quartz/content}"

WHITELIST=(
  "DESIGN_核心系统设计文档.md"
  "DESIGN_玩家行为系统.md"
  "DESIGN_能量系统.md"
  "DESIGN_天赋系统.md"
  "DESIGN_敌人系统.md"
  "DESIGN_世界观设计文档.md"
  "INDEX_开发路线图.md"
  "策划案_玩家行为系统.md"
  "策划案_能量系统.md"
  "策划案_锈犬.md"
  "策划案_光核与祭坛.md"
  "DESIGN_光核与祭坛.md"
  "策划案_天赋系统.md"
  "DESIGN_天赋池设计.md"
  "DATA_天赋池.md"
  "策划案_项目基建.md"
  "ART_美术失败复盘.md"
  "ART_美术方向与资产规格.md"
  "拆解_Dead Cells.md"
  "拆解_Sekiro.md"
)

mkdir -p "$DEST"
find "$DEST" -maxdepth 1 -name "*.md" ! -name "index.md" -delete

missing=0
for doc in "${WHITELIST[@]}"; do
  if [ -f "$VAULT/$doc" ]; then
    cp "$VAULT/$doc" "$DEST/"
    echo "sync: $doc"
  else
    echo "missing: $doc" >&2
    missing=1
  fi
done

"$PORTFOLIO/scripts/gen-graph.sh" "$DEST" "$PORTFOLIO/graph-data.js"

if [ "$missing" -ne 0 ]; then
  echo "Some whitelisted docs were not found. Build can continue, but public docs may be incomplete." >&2
fi
