#!/usr/bin/env bash
# Pasang workflow-kit ke sebuah repo proyek. Tidak menimpa berkas yang sudah ada.
#
#   scripts/install.sh <folder-repo> --nama "Nama Proyek" --repo owner/repo --pemilik "Nama" [--apps a,b,c] [--migrasi]
#
# Tanpa --apps: mode satu aplikasi. Dengan --apps: multi-aplikasi (docs/apps/<app>/APP.md per aplikasi).
# --migrasi: repo punya alur kerja lama yang sudah dipindah ke docs-old/ (git mv docs docs-old); ditambah docs/MIGRASI.md.
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
VERSI="$(tr -d '[:space:]' < "$KIT/VERSION")"
TARGET="${1:-}"; shift || true
NAMA=""; REPO=""; PEMILIK=""; APPS=""; MIGRASI=0
while [ $# -gt 0 ]; do
  case "$1" in
    --nama) NAMA="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --pemilik) PEMILIK="$2"; shift 2 ;;
    --apps) APPS="$2"; shift 2 ;;
    --migrasi) MIGRASI=1; shift ;;
    *) echo "Argumen tidak dikenal: $1" >&2; exit 1 ;;
  esac
done
gagal() { echo "GAGAL: $*" >&2; exit 1; }
if [ -z "$TARGET" ] || [ -z "$NAMA" ] || [ -z "$REPO" ] || [ -z "$PEMILIK" ]; then sed -n '2,8p' "$0" >&2; exit 1; fi
[ -d "$TARGET" ] || gagal "folder tidak ditemukan: $TARGET (clone repo-nya dulu)"
[ -d "$TARGET/.git" ] || gagal "bukan repo git: $TARGET"

# --- Deteksi keadaan repo -------------------------------------------------------------------------------------------
KIT_ADA=0; ls "$TARGET"/docs/decisions/D-H000-01_adopsi-workflow-kit_* >/dev/null 2>&1 && KIT_ADA=1
LAMA=""
if [ "$KIT_ADA" = 0 ] && [ -d "$TARGET/docs" ]; then
  [ -d "$TARGET/docs/handoff" ] && LAMA="docs/handoff/"
  [ -z "$LAMA" ] && LAMA="$(cd "$TARGET" && find docs -name INDEX.md 2>/dev/null | head -1)"
fi
if [ "$KIT_ADA" = 1 ] && [ "$MIGRASI" = 1 ]; then gagal "workflow-kit sudah terpasang; --migrasi hanya untuk pemasangan pertama."; fi
if [ -n "$LAMA" ]; then
  gagal "repo sudah punya alur kerja lama di docs/ (mis. $LAMA). Pindahkan dulu lalu pasang ulang dengan --migrasi:
    git -C \"$TARGET\" mv docs docs-old && git -C \"$TARGET\" commit -m \"H000: pindahkan alur kerja lama ke docs-old\""
fi
if [ "$MIGRASI" = 1 ] && [ ! -d "$TARGET/docs-old" ]; then gagal "--migrasi butuh folder docs-old/ (git mv docs docs-old)."; fi
V1="$(cd "$TARGET" && ls -d PLAN_*.md progress_*.md PROGRESS*.md KEPUTUSAN_*.md SKILL_*.md GUIDELINES_*.md agent_* 2>/dev/null | tr '\n' ' ' || true)"

# --- Mode & isian -----------------------------------------------------------------------------------------------------
APPS="$(echo "$APPS" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
MODE=single; [ -n "$APPS" ] && MODE=multi
if [ "$MODE" = multi ]; then KEEP="multi-app"; DROP="single-app"; else KEEP="single-app"; DROP="multi-app"; fi
if [ "$MIGRASI" = 1 ]; then KEEP="$KEEP,migrasi"; DROP="$DROP,tanpa-migrasi"; else KEEP="$KEEP,tanpa-migrasi"; DROP="$DROP,migrasi"; fi
TANGGAL="$(TZ=Asia/Jakarta date '+%Y-%m-%d %H:%M') WIB"
TS="$(TZ=Asia/Jakarta date '+%Y%m%d-%H%M')"
BARIS_APP=""
if [ "$MODE" = multi ]; then
  IFS=',' read -ra _a <<< "$APPS"
  for a in "${_a[@]}"; do BARIS_APP+="| $a | <!-- folder kode --> | \`apps/$a/APP.md\` | <!-- aktif / direncanakan --> |"$'\n'; done
  BARIS_APP="${BARIS_APP%$'\n'}"
fi

# Proses penanda <!-- [tag] --> / # [tag] dan placeholder pada satu berkas .md (LF).
olah() {
  KEEP="$KEEP" DROP="$DROP" BARIS="$BARIS_APP" NAMA="$NAMA" REPO="$REPO" PEMILIK="$PEMILIK" VERSI="$VERSI" TANGGAL="$TANGGAL" \
  perl -0777 -i -pe '
    my %drop = map { $_ => 1 } split /,/, $ENV{DROP};
    s/\r\n/\n/g;
    s{^<!-- \[([a-z-]+)\] -->\n(.*?)^<!-- \[/\1\] -->\n}{ $drop{$1} ? "" : $2 }gmse;
    s{<!-- \[([a-z-]+)\] -->(.*?)<!-- \[/\1\] -->}{ $drop{$1} ? "" : $2 }ge;
    my @baris;
    for my $l (split /\n/, $_, -1) {
      my @tag = ($l =~ /(?:<!-- |# )\[([a-z-]+)\]/g);
      next if grep { $drop{$_} } @tag;
      $l =~ s/ ?<!-- \[[a-z-]+\] -->//g;
      $l =~ s/# \[[a-z-]+\] /# /g;
      push @baris, $l;
    }
    $_ = join "\n", @baris;
    s/^\| \{\{BARIS_APP\}\} \|$/$ENV{BARIS}/m;
    s/\{\{NAMA_PROYEK\}\}/$ENV{NAMA}/g; s/\{\{REPO\}\}/$ENV{REPO}/g; s/\{\{PEMILIK\}\}/$ENV{PEMILIK}/g;
    s/\{\{VERSI_KIT\}\}/$ENV{VERSI}/g; s/\{\{TANGGAL\}\}/$ENV{TANGGAL}/g;
  ' "$1"
}

dibuat=0; dilewati=0
salin_dari() {
  local sumber="$1"
  while IFS= read -r -d '' src; do
    local rel="${src#./}"
    case "$rel" in docs/apps/_contoh/*) continue ;; esac
    local dst="$TARGET/${rel//\{\{TS\}\}/$TS}"
    local id_d="" ; case "$rel" in docs/decisions/D-H000-0?_*) id_d="${rel#docs/decisions/}"; id_d="${id_d%%_*}" ;; esac
    if [ -e "$dst" ] || { [ -n "$id_d" ] && ls "$TARGET"/docs/decisions/"$id_d"_* >/dev/null 2>&1; }; then
      echo "  lewati (sudah ada): ${dst#$TARGET/}"; dilewati=$((dilewati+1)); continue
    fi
    mkdir -p "$(dirname "$dst")"; cp "$sumber/$rel" "$dst"
    case "$dst" in *.md) olah "$dst" ;; esac
    echo "  buat: ${dst#$TARGET/}"; dibuat=$((dibuat+1))
  done < <(cd "$sumber" && find . -type f -print0 | sort -z)
}
salin_dari "$KIT/template"
if [ "$MIGRASI" = 1 ]; then salin_dari "$KIT/template-migrasi"; fi

if [ "$MODE" = multi ]; then
  IFS=',' read -ra daftar <<< "$APPS"
  for app in "${daftar[@]}"; do
    dst="$TARGET/docs/apps/$app/APP.md"
    if [ -e "$dst" ]; then echo "  lewati (sudah ada): docs/apps/$app/APP.md"; dilewati=$((dilewati+1)); continue; fi
    mkdir -p "$(dirname "$dst")"
    APP="$app" perl -pe 's/\r\n/\n/; s/<app>/$ENV{APP}/g' "$KIT/template/docs/apps/_contoh/APP.md" > "$dst"
    echo "  buat: docs/apps/$app/APP.md"; dibuat=$((dibuat+1))
  done
fi

if [ ! -e "$TARGET/.worktree-copy" ]; then
  printf '# Berkas/folder yang disalin dari checkout utama ke worktree baru (scripts/new-worktree), satu per baris.\n# Contoh Laravel:\n# vendor\n# .env\n' > "$TARGET/.worktree-copy"
  echo "  buat: .worktree-copy"; dibuat=$((dibuat+1))
fi

echo
echo "workflow-kit $VERSI (mode $MODE$([ "$MIGRASI" = 1 ] && echo ', migrasi')): $dibuat berkas dibuat, $dilewati dilewati."
if [ "$MODE" = multi ]; then
  echo "Berikutnya: isi docs/PROJECT.md dan docs/apps/*/APP.md serta .worktree-copy, lalu commit."
  echo "Menambah aplikasi ke proyek yang sudah terpasang? Tambahkan juga barisnya di docs/PROJECT.md bagian 1a."
else
  echo "Berikutnya: isi docs/PROJECT.md serta .worktree-copy, lalu commit."
fi
if [ "$MIGRASI" = 1 ]; then
  echo "Migrasi: commit hasil pemasangan, lalu minta sesi Lead menjalankan docs/MIGRASI.md."
fi
if [ -n "$V1" ]; then
  echo "Catatan: berkas alur kerja v1 di root: $V1— pindahkan ke docs-old/v1/ dengan git mv (lihat docs/MIGRASI.md)."
fi
