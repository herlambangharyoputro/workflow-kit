# CLAUDE.md — workflow-kit

Repo ini adalah **kit alur kerja**, bukan proyek aplikasi. Sesi yang bekerja di sini berperan **Arsitek**
(`template/docs/ARSITEK.md`).

- Yang disalin ke proyek ada di `template/` (+ `template-migrasi/` bila `--migrasi`); placeholder `{{NAMA_PROYEK}}`, `{{REPO}}`, `{{PEMILIK}}`, `{{VERSI_KIT}}`,
  `{{TANGGAL}}`, `{{TS}}`, `{{BARIS_APP}}` diisi installer.
- Penanda mode di berkas `.md` template — tag `multi-app`, `single-app`, `migrasi`, `tanpa-migrasi`: baris berakhiran `<!-- [tag] -->`,
  YAML `# [tag]`, dan blok/span `<!-- [tag] -->` … `<!-- [/tag] -->`. Installer menghapus yang tidak sesuai mode.
- Setiap perubahan template/skrip: uji `scripts/install.sh` untuk mode satu, multi, dan migrasi, pastikan tidak ada sisa
  penanda/placeholder (`grep -rn "\[multi-app\]\|\[migrasi\]\|{{"`), dan sesuaikan `install.ps1`/`new-worktree.ps1` secara setara.
- Skrip `.ps1` hanya berisi karakter ASCII (Windows PowerShell 5.1 membaca skrip tanpa BOM sebagai ANSI).
- Naikkan `VERSION` dan tulis `CHANGELOG.md` untuk setiap rilis. Bahasa Indonesia untuk dokumen dan commit.
