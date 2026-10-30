# workflow-kit

Alur kerja **Lead → Developer → QA** (+ Arsitek) untuk proyek software yang dikerjakan satu pemilik bersama sesi-sesi
Claude Code, dengan luaran publikasi bila ada. Lahir dan diuji di proyek SIMANTARA (Okt 2026).

## Isi
| Path | Isi |
|---|---|
| `template/` | berkas yang disalin ke root repo proyek: `CLAUDE.md` dan `docs/` (file peran, template, INDEX, PROJECT, ASUMSI, …) |
| `scripts/install.sh`, `scripts/install.ps1` | memasang `template/` ke repo proyek tanpa menimpa berkas yang sudah ada |
| `scripts/new-worktree.sh`, `scripts/new-worktree.ps1` | menyiapkan worktree per item kerja untuk sesi paralel |
| `VERSION`, `CHANGELOG.md` | versi kit |

## Konsep singkat
- **Peran** (satu sesi Claude Code per peran): Lead (brainstorming, menulis handoff, review, menutup item), Developer, QA
  (independen dari developer), Arsitek (mengubah alur kerja itu sendiri). Hanya satu sesi Lead pada satu waktu.
- **Dokumen di `docs/`**, satu penulis per file: Lead menulis handoff/finding/decision/INDEX langsung ke `main`;
  Developer & QA hanya menulis kode, test, laporan, dan bukti di **satu branch per item** `h<nnn>-<slug>`.
- **Satu urutan id** `H<nnn>` untuk seluruh repo; dev & QA handoff memakai nomor yang sama.
- **Laporan dev/QA dihapus saat item ditutup** setelah isinya diekstrak; riwayat lengkap tetap ada karena merge commit.
- **Register asumsi** (`docs/requirements/ASUMSI.md`) untuk hal yang belum pasti dari mitra.
- Peta lengkap: `template/docs/README.md`.

## Mode
| Mode | Kapan | Bedanya |
|---|---|---|
| Satu aplikasi | satu repo = satu aplikasi | `docs/PROJECT.md` saja |
| Multi-aplikasi | satu repo berisi beberapa aplikasi yang berbagi login/database/template UI | + `docs/apps/<app>/APP.md` per aplikasi, field `app:` (`<app>`, daftar, atau `shared`), kolom App di INDEX & ASUMSI, tag aplikasi di nama file handoff |

Tetap satu alur kerja, satu urutan id, dan satu INDEX untuk semua aplikasi. Aplikasi yang menyusul (mis. tahun berikutnya)
ditambahkan dengan menjalankan ulang installer dengan `--apps`/`-Apps` berisi daftar lengkap; berkas yang sudah ada dilewati.

## Memasang ke proyek
Windows (PowerShell), dari folder kit:
```powershell
.\scripts\install.ps1 -Target D:\repo\proyek -Nama "Nama Proyek" -Repo owner/repo -Pemilik "Nama"
```
Multi-aplikasi:
```powershell
.\scripts\install.ps1 -Target D:\repo\proyek -Nama "Nama Proyek" -Repo owner/repo -Pemilik "Nama" -Apps produksi
```
Bash (Linux/macOS/Git Bash):
```bash
scripts/install.sh /path/repo --nama "Nama Proyek" --repo owner/repo --pemilik "Nama" [--apps produksi,gis]
```
Lalu di repo proyek: isi `docs/PROJECT.md` (dan `docs/apps/*/APP.md`), isi `.worktree-copy`, commit ke `main`.
Proyek yang sudah punya `docs/` dengan isi lain: installer hanya menambah berkas yang belum ada dan melaporkan yang dilewati —
sesi Arsitek di proyek itu yang menyelaraskan sisanya.

## Sesi paralel
Dari dalam repo proyek:
```powershell
D:\workflow-kit\scripts\new-worktree.ps1 H027
```
Membuat `..\<repo>-h027` di branch dari frontmatter `branch:` dev handoff H027 (dari `origin` bila sudah ada, atau baru dari
`origin/main`), lalu menyalin berkas di `.worktree-copy` (mis. `vendor`, `.env`). Satu folder = satu sesi.

## Memperbarui proyek ke versi kit baru
Sesi Arsitek di proyek: baca `CHANGELOG.md` kit, terapkan perubahan ke file peran/template proyek, catat sebagai decision
`D-H000-<nn>` (lihat `template/docs/ARSITEK.md`). Pelajaran dari proyek yang berlaku umum dibawa balik ke kit.

## Status pengujian
- `install.sh` dan `new-worktree.sh`: diuji (mode satu & multi aplikasi, penambahan aplikasi, branch baru & yang sudah ada di origin).
- `install.ps1`: diuji di Windows PowerShell 5.1 (mode multi-aplikasi).
- `new-worktree.ps1`: **belum diuji** di Windows — uji dulu di repo percobaan sebelum dipakai di proyek nyata.
- Skrip `.ps1` sengaja hanya berisi karakter ASCII (PowerShell 5.1 membaca skrip tanpa BOM sebagai ANSI).
