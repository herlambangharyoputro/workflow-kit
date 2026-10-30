# CLAUDE.md — workflow-kit

Repo ini adalah **kit alur kerja**, bukan proyek aplikasi. Sesi yang bekerja di sini berperan **Arsitek**
(`template/docs/ARSITEK.md`).

- Yang disalin ke proyek ada di `template/`; placeholder `{{NAMA_PROYEK}}`, `{{REPO}}`, `{{PEMILIK}}`, `{{VERSI_KIT}}`,
  `{{TANGGAL}}`, `{{TS}}`, `{{BARIS_APP}}` diisi installer.
- Penanda mode di berkas `.md` template: baris berakhiran `<!-- [multi-app] -->` / `<!-- [single-app] -->`, YAML `# [multi-app]`,
  dan blok/span `<!-- [multi-app] -->` … `<!-- [/multi-app] -->`. Installer menghapus yang tidak sesuai mode.
- Setiap perubahan template/skrip: uji `scripts/install.sh` di dua repo kosong (mode satu & multi), pastikan tidak ada sisa
  penanda/placeholder (`grep -rn "multi-app\|single-app\|{{"`), dan sesuaikan `install.ps1`/`new-worktree.ps1` secara setara.
- Naikkan `VERSION` dan tulis `CHANGELOG.md` untuk setiap rilis. Bahasa Indonesia untuk dokumen dan commit.
