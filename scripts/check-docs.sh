#!/usr/bin/env bash
# Pemeriksaan otomatis alur kerja (workflow-kit). Jalankan dari dalam repo proyek.
#
#   scripts/workflow/check-docs.sh                    # seluruh docs/: frontmatter, id, status
#   scripts/workflow/check-docs.sh H027               # + item: branch, file milik Lead, laporan, data/rahasia di diff
#   scripts/workflow/check-docs.sh H027 origin/h027-x # item di ref lain tanpa checkout (untuk Lead)
#
# Keluar dengan kode 1 bila ada GAGAL.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1
ID="$(echo "${1:-}" | tr '[:lower:]' '[:upper:]')"; REF="${2:-HEAD}"
gagal=0; peringatan=0
G() { echo "GAGAL: $*"; gagal=$((gagal+1)); }
W() { echo "PERINGATAN: $*"; peringatan=$((peringatan+1)); }
fm() { sed -n '1{/^---$/!q};2,/^---$/{/^---$/d;p}' "$2" | sed -n "s/^$1:[[:space:]]*\([^#]*\).*/\1/p" | head -1 | sed 's/[[:space:]]*$//'; }

# --- 1. Seluruh docs/ ------------------------------------------------------------------------------------------------
cek_folder() {
  local dir="$1" valid="$2" f id st base
  [ -d "$dir" ] || return 0
  for f in "$dir"/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    if [ "$(head -1 "$f")" != "---" ]; then G "$f: tanpa frontmatter"; continue; fi
    id="$(fm id "$f")"; st="$(fm status "$f" | awk '{print $1}')"
    [ -n "$id" ] || { G "$f: field id kosong"; continue; }
    case "$base" in "$id"_*) ;; *) G "$f: nama file tidak diawali id ($id)";; esac
    if [ -n "$valid" ] && ! echo " $valid " | grep -q " $st "; then G "$f: status '$st' tidak valid (boleh: $valid)"; fi
    echo "$id" >> "$TMP_IDS.$(basename "$dir")"
  done
  if [ -f "$TMP_IDS.$(basename "$dir")" ]; then
    sort "$TMP_IDS.$(basename "$dir")" | uniq -d | while read -r d; do echo "GAGAL: id ganda di $dir: $d"; done
    [ -z "$(sort "$TMP_IDS.$(basename "$dir")" | uniq -d)" ] || gagal=$((gagal+1))
  fi
}
TMP_IDS="$(mktemp)"; trap 'rm -f "$TMP_IDS"*' EXIT
cek_folder docs/dev-handoff "draft ready in-progress qa review closed blocked superseded"
cek_folder docs/qa-handoff "ready done"
cek_folder docs/findings "open confirmed resolved superseded"
cek_folder docs/decisions "proposed accepted provisional superseded"
if grep -rln '{{[A-Z_]*}}' docs --include=*.md >/dev/null 2>&1; then W "placeholder {{…}} tersisa: $(grep -rln '{{[A-Z_]*}}' docs --include=*.md | tr '\n' ' ')"; fi

# --- 2. Item --------------------------------------------------------------------------------------------------------
if [ -n "$ID" ]; then
  [[ "$ID" =~ ^H?[0-9]{3}$ ]] || { echo "Id tidak valid: $ID"; exit 1; }
  ID="H${ID#H}"
  git rev-parse -q --verify "$REF^{commit}" >/dev/null || { echo "Ref tidak ditemukan: $REF"; exit 1; }
  git rev-parse -q --verify origin/main >/dev/null || git fetch -q origin main 2>/dev/null
  BASE="$(git merge-base origin/main "$REF" 2>/dev/null || git merge-base main "$REF")"
  handoff="$(ls docs/dev-handoff/${ID}_*.md 2>/dev/null | head -1)"
  [ -n "$handoff" ] || W "dev handoff $ID tidak ada di checkout ini"
  if [ "$REF" = HEAD ] && [ -n "$handoff" ]; then
    br="$(fm branch "$handoff")"; cur="$(git branch --show-current)"
    if [ -n "$br" ] && [ "${br#<}" = "$br" ] && [ "$br" != "$cur" ]; then G "branch sekarang '$cur', handoff menetapkan '$br'"; fi
  fi
  diffnames="$(git diff --name-only "$BASE" "$REF")"
  [ "$REF" = HEAD ] && diffnames="$diffnames"$'\n'"$(git status --porcelain | awk '{print $NF}')"
  milik_lead='^(docs/INDEX\.md|docs/dev-handoff/|docs/qa-handoff/|docs/findings/|docs/decisions/|docs/requirements/ASUMSI\.md|docs/PROJECT\.md|docs/apps/)'
  echo "$diffnames" | grep -E "$milik_lead" | sort -u | while read -r f; do [ -n "$f" ] && echo "GAGAL: file milik Lead diubah di branch item: $f"; done
  [ -z "$(echo "$diffnames" | grep -E "$milik_lead")" ] || gagal=$((gagal+1))
  sensitif='(^|/)(\.env(\..+)?|id\.json|[^/]*keypair[^/]*\.json|[^/]*\.pem|[^/]*\.key)$'
  echo "$diffnames" | grep -E "$sensitif" | grep -v '\.env\.example$' | sort -u | while read -r f; do [ -n "$f" ] && echo "GAGAL: berkas rahasia di diff: $f"; done
  [ -z "$(echo "$diffnames" | grep -E "$sensitif" | grep -v '\.env\.example$')" ] || gagal=$((gagal+1))
  while read -r f; do
    [ -n "$f" ] || continue
    sz="$(git cat-file -s "$REF:$f" 2>/dev/null || echo 0)"
    [ "$sz" -le 5242880 ] || G "berkas besar (> 5 MB) di diff: $f ($((sz/1048576)) MB)"
  done <<< "$(git diff --name-only --diff-filter=AM "$BASE" "$REF")"
  if git diff -U0 "$BASE" "$REF" | grep -E '^\+' | grep -qE 'hf_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----'; then
    G "pola token/kunci rahasia ditemukan di baris yang ditambahkan (git diff $BASE $REF)"
  fi
  ada_laporan=0
  for jenis in dev qa; do
    path="docs/${jenis}-reports/${ID}_report.md"
    isi="$(git show "$REF:$path" 2>/dev/null || { [ "$REF" = HEAD ] && cat "$path" 2>/dev/null; })"
    [ -n "$isi" ] || continue
    ada_laporan=1
    if [ "$jenis" = dev ]; then wajib="### Ringkasan|### Kriteria selesai|### Asumsi pengerjaan"; else wajib="### Ringkasan|### Kriteria|### Bug"; fi
    IFS='|' read -ra hs <<< "$wajib"
    for h in "${hs[@]}"; do echo "$isi" | grep -qF "$h" || G "$path: bagian '$h' tidak ada"; done
    m="$(echo "$isi" | sed -n 's/^model:[[:space:]]*\([^#]*\).*/\1/p' | head -1)"
    { [ -n "$m" ] && [ "${m#<}" = "$m" ]; } || G "$path: field model: belum diisi"
  done
  [ "$ada_laporan" = 1 ] || G "belum ada laporan docs/dev-reports/${ID}_report.md atau docs/qa-reports/${ID}_report.md"
fi

echo
if [ "$gagal" -gt 0 ]; then echo "check-docs: $gagal GAGAL, $peringatan peringatan."; exit 1; fi
echo "check-docs: OK ($peringatan peringatan)."
