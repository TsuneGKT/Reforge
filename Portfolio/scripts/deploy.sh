#!/bin/bash
# Local helper: build the same artifact that GitHub Pages deploys.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
"$ROOT/Portfolio/scripts/build.sh"

cat <<'MSG'

Local build finished.

To publish through GitHub Pages:
  git add Portfolio .github .gitignore
  git commit -m "Add portfolio auto deploy"
  git push

After that, future Obsidian edits update the website after:
  git add Reforge_Obsidian
  git commit -m "Update public docs"
  git push
MSG
