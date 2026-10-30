#!/usr/bin/env bash
# Siapkan worktree untuk satu item kerja agar sesi Developer/QA bisa berjalan paralel.
#
#   scripts/new-worktree.sh H027 [branch]
#
# Branch diambil dari frontmatter `branch:` di docs/dev-handoff/H027_*.md bila tidak diberikan.
# Folder: ../<nama-repo>-h027. Berkas di .worktree-copy disalin dari checkout utama.
set -euo pipefail

ID="$(echo "${1:-}" | tr '[:lower:]' '[:upper:]')"; BRANCH="${2:-}"
[[ "$ID" =~ ^H?[0-9]{3}$ ]] || { sed -n '2,7p' "$0" >&2; exit 1; }
ID="H${ID#H}"; NNN="${ID#H}"
ROOT="$(git rev-parse --show-toplevel)"; NAMA_REPO="$(basename "$ROOT")"
WT="$(dirname "$ROOT")/$NAMA_REPO-h$NNN"

if [ -z "$BRANCH" ]; then
  HANDOFF="$(ls "$ROOT"/docs/dev-handoff/${ID}_*.md 2>/dev/null | head -1 || true)"
  [ -n "$HANDOFF" ] || { echo "Dev handoff $ID tidak ditemukan; sebutkan branch: $0 $ID <branch>" >&2; exit 1; }
  BRANCH="$(sed -n 's/^branch:[[:space:]]*\([^[:space:]#]*\).*/\1/p' "$HANDOFF" | head -1)"
  [ -n "$BRANCH" ] || { echo "Frontmatter branch: kosong di $HANDOFF; sebutkan branch secara eksplisit." >&2; exit 1; }
fi
[ ! -e "$WT" ] || { echo "Folder sudah ada: $WT" >&2; exit 1; }

git -C "$ROOT" fetch -q origin
if git -C "$ROOT" show-ref -q --verify "refs/remotes/origin/$BRANCH"; then
  git -C "$ROOT" worktree add -B "$BRANCH" "$WT" "origin/$BRANCH"
else
  echo "Branch $BRANCH belum ada di origin — dibuat dari origin/main."
  git -C "$ROOT" worktree add -b "$BRANCH" "$WT" origin/main
fi

if [ -f "$ROOT/.worktree-copy" ]; then
  grep -v '^[[:space:]]*\(#\|$\)' "$ROOT/.worktree-copy" | while IFS= read -r p; do
    p="${p%$'\r'}"
    if [ -e "$ROOT/$p" ] && [ ! -e "$WT/$p" ]; then
      mkdir -p "$(dirname "$WT/$p")"; cp -a "$ROOT/$p" "$WT/$p"; echo "  salin: $p"
    fi
  done
fi

echo
echo "Worktree siap: $WT (branch $BRANCH)"
echo "Saran untuk QA: DB qa_$ID, port 8$NNN — lihat docs/PROJECT.md §4."
echo "Hapus setelah item ditutup: git worktree remove --force \"$WT\" && git branch -D $BRANCH"
