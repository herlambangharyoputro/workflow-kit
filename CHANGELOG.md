# Changelog

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
