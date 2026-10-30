# QA — prosedur QA

QA memverifikasi **secara independen** bahwa hasil developer memenuhi dev handoff, mengikuti rencana uji di
`docs/qa-handoff/H<nnn>_*.md`. Laporan developer dibaca untuk tahu apa yang berubah — **bukan** sebagai bukti
bahwa sesuatu berfungsi. QA tidak mengubah kode produksi; QA boleh menambah test untuk **membuktikan** kriteria —
melengkapi lingkup yang menjadi tugas developer hanya bila QA handoff memintanya.

## 1. Mulai
1. Baca QA handoff, lalu kriteria selesai dev handoff yang dirujuknya, laporan `docs/dev-reports/H<nnn>_report.md`,
   dan diff branch item terhadap `main`. Bekerja di **branch item yang sama dengan developer** (`branch:` di dev handoff),
   bukan branch baru; jalankan `git merge origin/main` di awal sesi. **Satu item = satu branch:** sebelum setiap commit,
   pastikan `git branch --show-current` adalah branch item ini. Jangan mengubah frontmatter handoff atau `INDEX.md`.
   Menjalankan beberapa sesi sekaligus: ikuti `docs/PROJECT.md` §4 (worktree, DB, dan port per item).
2. Siapkan aplikasi sesuai `docs/PROJECT.md` §4 (multi-aplikasi: `docs/apps/<app>/APP.md`) (suite test + menjalankan aplikasi dengan **database QA terpisah** —
   jangan pernah database kerja). Akun uji per peran: `docs/PROJECT.md` §5.

## 2. Yang diuji
1. **Setiap kriteria selesai** dev handoff → LULUS/GAGAL + bukti (perintah, output, screenshot).
2. **Matriks peran × aksi** dari QA handoff: server menolak (403) dan UI menyembunyikan aksi untuk peran yang tidak berhak.
3. **Regresi** di modul yang disebut QA handoff, plus suite test penuh.
4. **Responsif** di lebar 360, 768, 1280 dengan Playwright (pemasangan: `docs/PROJECT.md` §4; tanpa Playwright,
   cek manual lewat DevTools browser dan sebut di laporan):
   tanpa scroll horizontal halaman (`document.documentElement.scrollWidth <= window.innerWidth`),
   tombol bisa disentuh, tabel/form tidak terpotong, modal dan dropdown terbaca.
5. **Standar UI** (`docs/uiux/STANDAR-UI.md`): komponen yang benar, error per field + ringkasan, empty state,
   label tombol baku.
6. **Data & jejak**: jejak audit tercatat (bila proyek memilikinya), data lain tidak ikut berubah saat aksi ditolak.

## 3. Bug
Tulis di laporan dengan severity:
- **kritis** — data rusak/hilang, celah otorisasi, halaman error 500 pada alur utama.
- **tinggi** — kriteria selesai tidak terpenuhi, alur utama tidak bisa diselesaikan.
- **sedang** — alur bisa diselesaikan tapi salah/membingungkan; layout rusak di salah satu lebar.
- **rendah** — kosmetik, teks.
Setiap bug: langkah reproduksi, hasil yang diharapkan vs terjadi, peran, lebar layar, lampiran.
Bug yang terlihat di luar lingkup handoff tetap dicatat (bagian "Di luar lingkup") — Lead yang memutuskan.

**Verdict:** `LULUS` hanya bila tidak ada bug kritis/tinggi yang terbuka dan semua kriteria terpenuhi.

## 4. Laporan & bukti
- Laporan: `docs/qa-reports/H<nnn>_report.md` dari `docs/_templates/qa-report.md`; putaran ulang = bagian baru di file yang sama.
- Lampiran bug (screenshot, skrip Playwright): `docs/qa-reports/H<nnn>/` — ikut dihapus saat handoff ditutup.
- Saat `LULUS`: screenshot **final** halaman yang diminta QA handoff disimpan ke `docs/publications/_bukti/H<nnn>/`
  dengan nama `<halaman>_<lebar>.png` (mis. `pengguna-index_360.png`). Ini bahan panduan dan publikasi — tidak dihapus.
- Isi `verdict` dan `commit_diuji` (commit kode yang diuji) di frontmatter laporan QA, commit dengan awalan `H<nnn>:`, push, lalu beri tahu pemilik proyek: "H<nnn> selesai QA".
