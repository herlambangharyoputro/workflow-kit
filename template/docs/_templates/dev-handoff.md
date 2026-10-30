---
id: H000
type: dev-handoff
title: <judul pekerjaan>
status: draft             # diubah Lead saja: draft | ready | in-progress | qa | review | closed | blocked | superseded
priority: P1              # P0 kritis | P1 kontrak inti | P2 pelengkap/mitra/publikasi | P3 lanjutan
created: YYYY-MM-DD HH:MM WIB
closed: null
author: Lead
model: <kelas Opus|Sonnet|Haiku>
effort: <low|medium|high>
model_reason: <satu kalimat: mengapa model/effort ini>
branch: h000-<slug>       # satu branch untuk dev, QA, dan semua putaran (docs/README.md §5)
app: <app|[app1, app2]|shared>   # [multi-app] aplikasi yang tersentuh (docs/apps/)
legacy_id: null   # [migrasi] id di docs-old (mis. H001.14, F-H001-19), bila item ini hasil migrasi
depends_on: []            # H… yang harus closed dulu
blocked_on: null          # A-… atau pihak yang ditunggu, bila status blocked
related: []               # F-/D-/A-/H lain
source: []                # Proposal / requirements / finding asal
riset: <sumbangan untuk publikasi: fitur untuk bab hasil, metrik, data sebelum–sesudah — atau "tidak ada">
supersedes: null
superseded_by: null
---

# H000 — <judul pekerjaan>

## Wajib baca
<!-- ≤ 5 file/id. Developer tidak perlu membaca hal lain. -->
- `docs/DEVELOPER.md`
-

## Tujuan
<!-- 1–3 kalimat: hasil yang terlihat pengguna. -->

## Latar belakang

## Ruang lingkup
**Termasuk:**
-
**Bukan lingkup:**
-

## Kontrak teknis
<!-- Rute/endpoint + izin, skema/migrasi & kolom, komponen template UI yang dipakai, config. -->

## Langkah kerja (checkpoint)
1. … ⏸
2. …

## Kriteria selesai
<!-- Bisa diuji. Diberi nomor karena QA handoff merujuknya (K1, K2, …). -->
- [ ] K1 …
- [ ] K2 Test otorisasi: positif untuk <peran>, 403 untuk <peran>
- [ ] K3 Definition of Done `docs/DEVELOPER.md` §3

## Risiko / pertanyaan terbuka

## Hasil
<!-- Diisi Lead saat menutup: ringkasan 5–10 baris, jumlah test, putaran QA, asumsi yang disahkan,
     finding/decision baru, dan "Laporan lengkap: git show <hash>:docs/dev-reports/H000_report.md". -->
