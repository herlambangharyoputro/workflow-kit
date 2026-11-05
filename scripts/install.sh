#!/usr/bin/env bash
# Pasang workflow-kit ke sebuah repo proyek. Tidak menimpa berkas yang sudah ada.
#
#   scripts/install.sh <folder-repo> --nama "Nama Proyek" --repo owner/repo --pemilik "Nama" [--apps a,b,c] [--migrasi | --upgrade]
#
# Tanpa --apps: mode satu aplikasi. Dengan --apps: multi-aplikasi (docs/apps/<app>/APP.md per aplikasi).
# --migrasi: repo punya alur kerja lama yang sudah dipindah ke docs-old/ (git mv docs docs-old); ditambah docs/MIGRASI.md.
# --upgrade: kit sudah terpasang; timpa HANYA berkas generik kit (AGENTS/CLAUDE, file peran, _templates, scripts/workflow),
#            buat berkas baru yang belum ada, dan catat decision upgrade. Berkas milik proyek tidak disentuh.
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
VERSI="$(tr -d '[:space:]' < "$KIT/VERSION")"
TARGET="${1:-}"; shift || true
NAMA=""; REPO=""; PEMILIK=""; APPS=""; MIGRASI=0; UPGRADE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --nama) NAMA="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --pemilik) PEMILIK="$2"; shift 2 ;;
    --apps) APPS="$2"; shift 2 ;;
    --migrasi) MIGRASI=1; shift ;;
    --upgrade) UPGRADE=1; shift ;;
    *) echo "Argumen tidak dikenal: $1" >&2; exit 1 ;;
  esac
done
gagal() { echo "GAGAL: $*" >&2; exit 1; }
if [ -z "$TARGET" ] || [ -z "$NAMA" ] || [ -z "$REPO" ] || [ -z "$PEMILIK" ]; then sed -n '2,10p' "$0" >&2; exit 1; fi
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
if [ "$UPGRADE" = 1 ]; then
  [ "$KIT_ADA" = 1 ] || gagal "--upgrade butuh workflow-kit yang sudah terpasang (docs/decisions/D-H000-01_adopsi-workflow-kit_*)."
  [ "$MIGRASI" = 0 ] || gagal "--upgrade dan --migrasi tidak bisa dipakai bersamaan."
  [ -z "$(git -C "$TARGET" status --porcelain)" ] || gagal "working tree belum bersih; commit/stash dulu supaya hasil upgrade bisa ditinjau dengan git diff."
  [ -f "$TARGET/docs/MIGRASI.md" ] && MIGRASI=1   # migrasi masih berjalan: pertahankan blok migrasi
  lama="$(sed -n 's/.*\*\*workflow-kit \([0-9.]*\)\*\*.*/\1/p' "$TARGET/docs/README.md" | head -1)"
  if [ -z "$APPS" ] && [ -d "$TARGET/docs/apps" ]; then APPS="$(ls -1 "$TARGET/docs/apps" | tr '\n' ',' | sed 's/,$//')"; fi
fi
if [ -n "$LAMA" ]; then
  gagal "repo sudah punya alur kerja lama di docs/ (mis. $LAMA). Pindahkan dulu lalu pasang ulang dengan --migrasi:
    git -C \"$TARGET\" mv docs docs-old && git -C \"$TARGET\" commit -m \"H000: pindahkan alur kerja lama ke docs-old\""
fi
if [ "$MIGRASI" = 1 ] && [ "$UPGRADE" = 0 ] && [ ! -d "$TARGET/docs-old" ]; then gagal "--migrasi butuh folder docs-old/ (git mv docs docs-old)."; fi
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
generik() { case "$1" in AGENTS.md|CLAUDE.md|docs/README.md|docs/LEAD.md|docs/DEVELOPER.md|docs/QA.md|docs/ARSITEK.md|docs/_templates/*) return 0 ;; esac; return 1; }
salin_dari() {
  local sumber="$1"
  while IFS= read -r -d '' src; do
    local rel="${src#./}"
    case "$rel" in docs/apps/_contoh/*) continue ;; esac
    local dst="$TARGET/${rel//\{\{TS\}\}/$TS}"
    local id_d="" ; case "$rel" in docs/decisions/D-H000-0?_*) id_d="${rel#docs/decisions/}"; id_d="${id_d%%_*}" ;; esac
    if [ "$UPGRADE" = 1 ] && [ -e "$dst" ] && generik "$rel"; then
      local baru; baru="$(mktemp)"; cp "$sumber/$rel" "$baru"; case "$rel" in *.md) olah "$baru" ;; esac
      if cmp -s "$baru" "$dst"; then rm -f "$baru"; else mv "$baru" "$dst"; echo "  perbarui: ${dst#$TARGET/}"; dibuat=$((dibuat+1)); fi
      continue
    fi
    if [ -e "$dst" ] || { [ -n "$id_d" ] && ls "$TARGET"/docs/decisions/"$id_d"_* >/dev/null 2>&1; }; then
      echo "  lewati (sudah ada): ${dst#$TARGET/}"; dilewati=$((dilewati+1)); continue
    fi
    mkdir -p "$(dirname "$dst")"; cp "$sumber/$rel" "$dst"
    case "$dst" in *.md) olah "$dst" ;; esac
    echo "  buat: ${dst#$TARGET/}"; dibuat=$((dibuat+1))
  done < <(cd "$sumber" && find . -type f -print0 | sort -z)
}
salin_dari "$KIT/template"
if [ "$MIGRASI" = 1 ] && [ "$UPGRADE" = 0 ]; then salin_dari "$KIT/template-migrasi"; fi

# Skrip alur kerja di dalam proyek (selalu versi kit terbaru).
mkdir -p "$TARGET/scripts/workflow"
for sk in check-docs.sh check-docs.ps1 new-worktree.sh new-worktree.ps1; do
  dst="$TARGET/scripts/workflow/$sk"
  if [ -e "$dst" ] && cmp -s "$KIT/scripts/$sk" "$dst"; then continue; fi
  if [ -e "$dst" ] && [ "$UPGRADE" = 0 ]; then echo "  lewati (sudah ada): scripts/workflow/$sk"; dilewati=$((dilewati+1)); continue; fi
  [ -e "$dst" ] && aksi="perbarui" || aksi="buat"
  cp "$KIT/scripts/$sk" "$dst"; case "$sk" in *.sh) chmod +x "$dst" ;; esac
  echo "  $aksi: scripts/workflow/$sk"; dibuat=$((dibuat+1))
done

if [ "$UPGRADE" = 1 ]; then
  n="$(ls "$TARGET"/docs/decisions/D-H000-*_* 2>/dev/null | sed 's#.*/D-H000-\([0-9]*\)_.*#\1#' | sort -n | tail -1)"
  nn="$(printf '%02d' $((10#${n:-0} + 1)))"
  dst="$TARGET/docs/decisions/D-H000-${nn}_upgrade-workflow-kit-${VERSI}_${TS}.md"
  printf -- '---\nid: D-H000-%s\ntype: decision\ntitle: Upgrade workflow-kit ke %s\nhandoff: H000\nstatus: accepted\ncreated: %s\nproposed_by: Arsitek\ndecided_by: %s\naccepted_at: %s\nsupersedes: null\nsuperseded_by: null\nrelated: [D-H000-01]\n---\n\n# D-H000-%s — Upgrade workflow-kit ke %s\n\n## Keputusan\nBerkas generik kit (AGENTS.md, CLAUDE.md, file peran, `_templates/`, `scripts/workflow/`) diperbarui dari versi %s ke %s.\nBerkas milik proyek tidak diubah. Perubahan aturan: lihat CHANGELOG workflow-kit %s.\n\n## Konsekuensi\nLead mendaftarkan decision ini di `INDEX.md` dan menyesuaikan `PROJECT.md` bila CHANGELOG meminta bagian baru.\n' \
    "$nn" "$VERSI" "$TANGGAL" "$PEMILIK" "$TANGGAL" "$nn" "$VERSI" "${lama:-?}" "$VERSI" "$VERSI" > "$dst"
  echo "  buat: docs/decisions/$(basename "$dst")"; dibuat=$((dibuat+1))
fi

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
echo "workflow-kit $VERSI (mode $MODE$([ "$MIGRASI" = 1 ] && echo ', migrasi')$([ "$UPGRADE" = 1 ] && echo ', upgrade')): $dibuat berkas dibuat/diperbarui, $dilewati dilewati."
if [ "$UPGRADE" = 1 ]; then echo "Upgrade: tinjau git diff, sesuaikan docs/PROJECT.md bila CHANGELOG meminta bagian baru, lalu commit."; fi
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
