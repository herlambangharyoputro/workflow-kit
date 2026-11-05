# Changelog

## [0.4.1] — 2026-11-05
### Ditambahkan
- **`--adopsi` / `-Adopsi`**: untuk repo yang struktur `docs/`-nya sudah seperti kit tetapi tidak dipasang lewat installer
  (SIMANTARA, asal kit). Berkas generik ditimpa seperti `--upgrade`; decision adopsi memakai nomor `D-H000` berikutnya.
### Diubah
- Deteksi "kit sudah terpasang" kini mengenali `D-H000-*_adopsi-workflow-kit_*` (tidak harus `D-H000-01`).

## [0.4.0] — 2026-11-05
### Ditambahkan
- **`AGENTS.md`** sebagai titik masuk semua agen (DeepSeek & klien lain); `CLAUDE.md` kini hanya `@AGENTS.md`.
- **Sesi panjang wajib serah terima** (Lead, Developer, QA): tanda-tanda, cara serah terima di titik aman, prompt pembuka sesi baru;
  bagian "Serah terima sesi Lead" di INDEX dan "Lanjutan untuk sesi berikutnya" di laporan dev.
- **Rubrik tingkat model** (tinggi/menengah/ringan) + pemetaan model di `PROJECT.md` §2; field `tingkat:` di handoff, `model:` di laporan;
  QA disarankan model berbeda dari developer.
- **Gerbang risiko** (`LEAD.md` §2a) + field `risiko: normal|tinggi`: decision, simulasi/dry-run, canary, langkah nyata dijalankan
  pemilik proyek, QA tingkat tinggi.
- **Label perintah per lingkungan** (`💻 LOKAL` / `🖥️ VPS`, `PROJECT.md` §3).
- **`scripts/workflow/check-docs`** (bash + PowerShell), disalin ke proyek bersama `new-worktree`.
- **`--upgrade` / `-Upgrade`**: perbarui berkas generik kit di proyek terpasang tanpa menyentuh berkas proyek; decision upgrade otomatis.
### Pelajaran
- solana-trading-bot (alur kerja sendiri): indeks dari skrip + `--check`, field `model`, label perintah per lingkungan, dan gerbang dana
  nyata (D-005 di proyek itu) diangkat ke kit. Mode workstream (id per jalur kerja) dicatat untuk dipertimbangkan.

## [0.3.0] — 2026-10-30
### Ditambahkan
- **Jenis aplikasi `ui` / `data` / `api`** (`PROJECT.md` §2, `APP.md` §2): `QA.md` §2 dipecah per jenis — `data` menguji validasi
  skema keluaran, metrik dataset uji vs baseline + toleransi, sampel manual, dapat diulang, dan kebocoran data ke git; `api` menguji
  kontrak endpoint & otorisasi. Kontrak antar aplikasi diuji di semua jenis.
- `PROJECT.md` §7 **Data** (RAW di luar git, data matang, dataset uji tetap, baseline metrik) dan §8 **Kontrak antar aplikasi**
  (produsen, konsumen, berkas skema, test; perubahan kontrak = satu handoff produsen+konsumen).
- Template QA handoff/laporan: bagian Data uji & metrik; bukti `data` = `metrik.md`/`.csv` di `publications/_bukti/`.
- DoD dibedakan per jenis; rubrik model: pipeline/NLP/kontrak data/desain evaluasi → kelas Opus high.
### Pelajaran
- indoskillmap (NLP → Agregator → Web): aturan kit sebelumnya hanya cocok untuk aplikasi web.

## [0.2.0] — 2026-10-30
### Ditambahkan
- **Mode migrasi** (`--migrasi` / `-Migrasi`) untuk proyek yang sudah punya alur kerja lama: syarat `docs-old/` (hasil `git mv docs docs-old`),
  `docs/MIGRASI.md` (prosedur & checklist Lead: tulis ulang hanya yang masih hidup, tabel Peta id lama, id baru lanjut dari main lama
  tertinggi), decision `D-H000-02`, baris migrasi di INDEX, field `legacy_id` di template, peringatan `docs-old/` di `CLAUDE.md`.
- Installer **menolak** memasang bila `docs/` berisi alur kerja lain (`docs/handoff/` atau `docs/**/INDEX.md`) dan menampilkan
  perintah `git mv`; menampilkan daftar berkas alur v1 di root (`PLAN_*`, `progress_*`, `SKILL_*`, …).
- Pesan "folder tidak ditemukan" yang jelas; `.gitattributes` (LF).
### Diperbaiki
- Template ber-CRLF (checkout Windows dengan `autocrlf`) membuat blok `[multi-app]` tidak terhapus di mode satu aplikasi.
  Installer kini menormalkan akhir baris ke LF sebelum memproses penanda.
### Diubah
- Pemroses penanda generik: tag `multi-app`, `single-app`, `migrasi`, `tanpa-migrasi` dalam bentuk baris, blok, span, dan YAML.
### Pelajaran
- Memasang kit di atas alur kerja lama (argopuro_walida, 30 Okt 2026) menghasilkan dua INDEX/LEAD dan `CLAUDE.md` yang mengalihkan
  sesi Lead lama yang masih berjalan → deteksi + mode migrasi.

## [0.1.2] — 2026-10-30
### Diperbaiki
- `new-worktree`: branch item baru dibuat dengan `--no-track`. Sebelumnya branch mengikuti `origin/main`, sehingga `git push`
  biasa ditolak atau — dengan `push.default=upstream` — mendorong commit item ke `main`. Skrip kini mencetak perintah push pertama.
- `DEVELOPER.md` DoD 8: push pertama `git push -u origin <branch>`.
- `new-worktree.ps1` diuji di Windows PowerShell 5.1.

## [0.1.1] — 2026-10-30
### Diperbaiki
- `install.ps1`, `new-worktree.ps1`: tanpa karakter non-ASCII di pesan skrip. Windows PowerShell 5.1 membaca skrip tanpa BOM
  sebagai ANSI sehingga `§`/`—` tampil rusak (`Â§`). Isi berkas yang dihasilkan tidak terdampak.
- `install.ps1` diuji di Windows (mode multi-aplikasi): 29 berkas, tanpa sisa penanda.

## [0.1.0] — 2026-10-30
Rilis pertama, diangkat dari alur kerja proyek SIMANTARA (D-H000-02, D-H000-03 di proyek itu) setelah dua siklus penuh
(H017–H028).

### Isi
- Peran Lead, Developer, QA, Arsitek (`template/docs/*.md`), template dev/QA handoff, laporan, finding, decision.
- Model git satu pemilik: Lead menulis dokumen langsung ke `main`; satu branch per item untuk dev, QA, dan semua putaran;
  status hanya di INDEX; penutupan lewat merge commit + commit penutupan Lead.
- Penutupan item: cek "yang diuji = yang di-merge" dan simulasi merge (`git merge-tree`) sebelum minta persetujuan.
- Register asumsi dua sumber (asumsi developer; keputusan sementara pemilik proyek = decision `provisional`).
- Mode multi-aplikasi: `docs/apps/<app>/APP.md`, field `app:`, kolom App, tag aplikasi di nama file.
- Skrip `install` (tanpa menimpa) dan `new-worktree` (branch dari frontmatter, salin `.worktree-copy`) untuk bash & PowerShell.

### Pelajaran yang dibawa dari SIMANTARA
- Sesi QA paralel di satu checkout saling menimpa DB dan berkas → satu folder per sesi, DB & port QA per item.
- Folder dependensi yang di-symlink ke checkout utama membuat test menjalankan kode branch lain → salin, jangan symlink.
- Dokumen Lead lewat PR yang belum di-merge membuat developer menyalin handoff dan QA membaca aturan dari `origin/main` → Lead
  menulis langsung ke `main`.
- Dua sesi bertindak sebagai Lead untuk laporan yang sama → satu sesi Lead, peran Arsitek terpisah.
