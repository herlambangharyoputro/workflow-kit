#!/usr/bin/env bash
# Pasang workflow-kit ke sebuah repo proyek. Tidak menimpa berkas yang sudah ada.
#
#   scripts/install.sh <folder-repo> --nama "Nama Proyek" --repo owner/repo --pemilik "Nama" [--apps produksi,gis,darkroom]
#
# Tanpa --apps: mode satu aplikasi. Dengan --apps: mode multi-aplikasi, dibuat docs/apps/<app>/APP.md per aplikasi.
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
VERSI="$(tr -d '[:space:]' < "$KIT/VERSION")"
TARGET="${1:-}"; shift || true
NAMA=""; REPO=""; PEMILIK=""; APPS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --nama) NAMA="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --pemilik) PEMILIK="$2"; shift 2 ;;
    --apps) APPS="$2"; shift 2 ;;
    *) echo "Argumen tidak dikenal: $1" >&2; exit 1 ;;
  esac
done
if [ -z "$TARGET" ] || [ -z "$NAMA" ] || [ -z "$REPO" ] || [ -z "$PEMILIK" ]; then
  sed -n '2,6p' "$0" >&2; exit 1
fi
[ -d "$TARGET/.git" ] || { echo "Bukan repo git: $TARGET" >&2; exit 1; }

MODE=single; [ -n "$APPS" ] && MODE=multi
APPS="$(echo "$APPS" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
BARIS_APP=""
if [ "$MODE" = multi ]; then
  IFS=',' read -ra _a <<< "$APPS"
  for a in "${_a[@]}"; do BARIS_APP+="| $a | <!-- folder kode --> | \`apps/$a/APP.md\` | <!-- aktif / direncanakan --> |"$'\n'; done
  BARIS_APP="${BARIS_APP%$'\n'}"
fi
TANGGAL="$(TZ=Asia/Jakarta date '+%Y-%m-%d %H:%M') WIB"
TS="$(TZ=Asia/Jakarta date '+%Y%m%d-%H%M')"

# Proses penanda mode + isi placeholder pada satu berkas teks.
olah() {
  local f="$1"
  if [ "$MODE" = single ]; then
    perl -0pi -e 's/<!-- \[multi-app\] -->.*?<!-- \[\/multi-app\] -->//g; s/^<!-- \[multi-app\] -->\n.*?^<!-- \[\/multi-app\] -->\n//gms' "$f"
    perl -ni -e 'print unless /\[multi-app\]/' "$f"
    perl -pi -e 's/ ?<!-- \[single-app\] -->//g' "$f"
  else
    perl -ni -e 'print unless /^<!-- \[\/?multi-app\] -->$/ or /\[single-app\]/' "$f"
    perl -pi -e 's/<!-- \[\/?multi-app\] -->//g; s/ +$// if /\|\s+$/; s/# \[multi-app\] /# /' "$f"
  fi
  BARIS="$BARIS_APP" NAMA="$NAMA" REPO="$REPO" PEMILIK="$PEMILIK" VERSI="$VERSI" TANGGAL="$TANGGAL" \
    perl -pi -e 's/^\| \{\{BARIS_APP\}\} \|$/$ENV{BARIS}/; ' -e 's/\{\{NAMA_PROYEK\}\}/$ENV{NAMA}/g; s/\{\{REPO\}\}/$ENV{REPO}/g; s/\{\{PEMILIK\}\}/$ENV{PEMILIK}/g; s/\{\{VERSI_KIT\}\}/$ENV{VERSI}/g; s/\{\{TANGGAL\}\}/$ENV{TANGGAL}/g' "$f"
}

dibuat=0; dilewati=0
cd "$KIT/template"
while IFS= read -r -d '' src; do
  rel="${src#./}"
  case "$rel" in docs/apps/_contoh/*) continue ;; esac
  dst="$TARGET/${rel//\{\{TS\}\}/$TS}"
  if [ -e "$dst" ] || { [ "${rel#docs/decisions/D-H000-01_}" != "$rel" ] && ls "$TARGET"/docs/decisions/D-H000-01_* >/dev/null 2>&1; }; then
    echo "  lewati (sudah ada): ${dst#$TARGET/}"; dilewati=$((dilewati+1)); continue
  fi
  mkdir -p "$(dirname "$dst")"; cp "$src" "$dst"
  case "$dst" in *.md) olah "$dst" ;; esac
  echo "  buat: ${dst#$TARGET/}"; dibuat=$((dibuat+1))
done < <(find . -type f -print0 | sort -z)

if [ "$MODE" = multi ]; then
  IFS=',' read -ra daftar <<< "$APPS"
  for app in "${daftar[@]}"; do
    dst="$TARGET/docs/apps/$app/APP.md"
    if [ -e "$dst" ]; then echo "  lewati (sudah ada): docs/apps/$app/APP.md"; dilewati=$((dilewati+1)); continue; fi
    mkdir -p "$(dirname "$dst")"
    APP="$app" perl -pe 's/<app>/$ENV{APP}/g' "$KIT/template/docs/apps/_contoh/APP.md" > "$dst"
    echo "  buat: docs/apps/$app/APP.md"; dibuat=$((dibuat+1))
  done
fi

[ -e "$TARGET/.worktree-copy" ] || {
  printf '# Berkas/folder yang disalin dari checkout utama ke worktree baru (scripts/new-worktree), satu per baris.\n# Contoh Laravel:\n# vendor\n# .env\n' > "$TARGET/.worktree-copy"
  echo "  buat: .worktree-copy"; dibuat=$((dibuat+1)); }

echo
echo "workflow-kit $VERSI (mode $MODE): $dibuat berkas dibuat, $dilewati dilewati."
echo "Berikutnya: isi docs/PROJECT.md$([ "$MODE" = multi ] && echo ' dan docs/apps/*/APP.md') serta .worktree-copy, lalu commit."
if [ "$MODE" = multi ]; then
  echo "Menambah aplikasi ke proyek yang sudah terpasang? Tambahkan juga barisnya di docs/PROJECT.md §1a."
fi
