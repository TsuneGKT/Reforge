#!/bin/bash
# Patch Quartz graph plugin so Chinese slugs match decoded browser paths.
set -euo pipefail

QUARTZ_DIR="${1:?Usage: patch-graph.sh /path/to/quartz}"
DIR="$QUARTZ_DIR/.quartz/plugins/graph/dist"

if [ ! -d "$DIR" ]; then
  echo "graph plugin not installed yet; skip patch"
  exit 0
fi

patched=0
for file in "$DIR/index.js" "$DIR/components/index.js"; do
  [ -f "$file" ] || continue
  if grep -q "let u=window.location.pathname" "$file"; then
    python3 - "$file" <<'PY'
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
text = text.replace("let u=window.location.pathname;", "let u=decodeURIComponent(window.location.pathname);")
open(path, "w", encoding="utf-8").write(text)
PY
    echo "patched graph: $file"
    patched=1
  fi
done

[ "$patched" = 1 ] && echo "graph patch applied" || echo "graph patch already present"
