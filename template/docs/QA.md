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
Jenis aplikasi menentukan cara uji: lihat **Jenis & cara QA** di `docs/PROJECT.md` §2 (multi-aplikasi: `apps/<app>/APP.md` §2).
Satu handoff bisa menyentuh lebih dari satu jenis — uji semuanya.

**Semua jenis**
1. **Setiap kriteria selesai** dev handoff → LULUS/GAGAL + bukti (perintah, output, screenshot/metrik).
2. **Regresi** di modul yang disebut QA handoff, plus suite test penuh.
3. **Kontrak antar aplikasi** (`PROJECT.md` §8): keluaran masih sesuai skema kontrak; konsumen kontrak tidak rusak.

**`ui` — aplikasi ber-antarmuka**
4. **Matriks peran × aksi** dari QA handoff: server menolak (403) dan UI menyembunyikan aksi untuk peran yang tidak berhak.
5. **Responsif** di lebar 360, 768, 1280 dengan Playwright (pemasangan: `docs/PROJECT.md` §4; tanpa Playwright,
   cek manual lewat DevTools browser dan sebut di laporan): tanpa scroll horizontal halaman
   (`document.documentElement.scrollWidth <= window.innerWidth`), tombol bisa disentuh, tabel/form tidak terpotong.
6. **Standar UI** (`docs/uiux/STANDAR-UI.md`): komponen yang benar, error per field + ringkasan, empty state, label tombol baku.
7. **Data & jejak**: jejak audit tercatat (bila ada), data lain tidak ikut berubah saat aksi ditolak.

**`data` — pipeline / NLP / agregasi**
4. **Validasi skema keluaran** terhadap kontrak (kolom, tipe, nilai wajib, rentang) di seluruh keluaran, bukan sampel saja.
5. **Metrik pada dataset uji tetap** (`PROJECT.md` §7) dibandingkan baseline terakhir yang tercatat; penurunan di luar
   toleransi QA handoff = bug `tinggi`.
6. **Cek sampel manual**: ≥ 20 baris acak (atau jumlah di QA handoff) dibaca langsung — salah klasifikasi/ekstraksi yang mencolok dicatat.
7. **Dapat diulang**: menjalankan ulang tahap yang sama dengan input & seed yang sama menghasilkan keluaran yang sama (atau selisih yang dijelaskan).
8. **Data tidak bocor ke git**: data RAW/besar dan rahasia tidak ada di diff branch.

**`api` — layanan / endpoint**
4. **Kontrak endpoint**: status code, bentuk respons, dan pesan error sesuai kontrak; input tidak valid ditolak dengan rapi.
5. **Otorisasi**: endpoint terlindungi menolak tanpa kredensial/izin; data pengguna lain tidak bisa dibaca.

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
- Saat `LULUS`: bukti **final** disimpan ke `docs/publications/_bukti/H<nnn>/` — screenshot `<halaman>_<lebar>.png`
  (mis. `pengguna-index_360.png`) untuk `ui`, dan `metrik.md` / `metrik.csv` (metrik dataset uji + baseline + commit) untuk `data`.
  Ini bahan panduan dan publikasi — tidak dihapus.
- Isi `verdict` dan `commit_diuji` (commit kode yang diuji) di frontmatter laporan QA, commit dengan awalan `H<nnn>:`, push, lalu beri tahu pemilik proyek: "H<nnn> selesai QA".
