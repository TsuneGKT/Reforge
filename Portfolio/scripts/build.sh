#!/bin/bash
# Build the public portfolio site into Portfolio/dist.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PORTFOLIO="$ROOT/Portfolio"
BUILD_ROOT="${PORTFOLIO_BUILD_ROOT:-$ROOT/.portfolio-build}"
QUARTZ_DIR="${QUARTZ_DIR:-$BUILD_ROOT/quartz}"
DIST="$PORTFOLIO/dist"
QUARTZ_BASE_URL="${QUARTZ_BASE_URL:-tsunegkt.github.io/Reforge/docs}"
QUARTZ_REPO="${QUARTZ_REPO:-https://github.com/jackyzha0/quartz.git}"
QUARTZ_REF="${QUARTZ_REF:-v5}"

echo "== Sync Obsidian docs =="
"$PORTFOLIO/scripts/sync-docs.sh" "$PORTFOLIO/quartz/content"

echo "== Prepare Quartz =="
mkdir -p "$BUILD_ROOT"
if [ ! -d "$QUARTZ_DIR/.git" ]; then
  rm -rf "$QUARTZ_DIR"
  git clone --depth 1 --branch "$QUARTZ_REF" "$QUARTZ_REPO" "$QUARTZ_DIR"
else
  git -C "$QUARTZ_DIR" fetch --depth 1 origin "$QUARTZ_REF"
  git -C "$QUARTZ_DIR" checkout -q "$QUARTZ_REF"
  git -C "$QUARTZ_DIR" reset --hard -q "origin/$QUARTZ_REF"
fi

rm -rf "$QUARTZ_DIR/content"
mkdir -p "$QUARTZ_DIR/content"
rsync -a "$PORTFOLIO/quartz/content/" "$QUARTZ_DIR/content/"
cp "$PORTFOLIO/quartz/quartz.config.yaml" "$QUARTZ_DIR/quartz.config.yaml"

python3 - "$QUARTZ_DIR/quartz.config.yaml" "$QUARTZ_BASE_URL" <<'PY'
import re, sys
path, base = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
text = re.sub(r"^(\s*baseUrl:\s*).*$", rf"\1{base}", text, flags=re.M)
open(path, "w", encoding="utf-8").write(text)
PY

echo "== Build Quartz docs =="
cd "$QUARTZ_DIR"
npm ci
npx quartz plugin install
"$PORTFOLIO/scripts/patch-graph.sh" "$QUARTZ_DIR"
npx quartz build

echo "== Assemble portfolio dist =="
rm -rf "$DIST"
mkdir -p "$DIST"
touch "$DIST/.nojekyll"
rsync -a \
  --exclude "dist" \
  --exclude "quartz" \
  --exclude "scripts" \
  "$PORTFOLIO/" "$DIST/"
mkdir -p "$DIST/docs"
rsync -a "$QUARTZ_DIR/public/" "$DIST/docs/"

echo "Portfolio build complete -> $DIST"
