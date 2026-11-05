# DEVELOPER — prosedur Developer

Developer mengerjakan satu dev handoff (`docs/dev-handoff/H<nnn>_*.md`) sampai kriteria selesainya terpenuhi,
lalu menulis laporan untuk Lead. Perintah, lingkungan, database yang didukung, dan konvensi kode proyek ada di
`docs/PROJECT.md` (proyek multi-aplikasi: juga `docs/apps/<app>/APP.md` sesuai `app:` di handoff); pola UI di `docs/uiux/STANDAR-UI.md`.

## 1. Mulai
1. Baca handoff yang disebut di prompt beserta daftar "Wajib baca"-nya. Mulai hanya bila semua `depends_on`
   sudah `closed` dan handoff berstatus `ready`.
2. Bila checkpoint 1 adalah gerbang decision, jangan menulis kode sebelum decision itu `accepted`
   (bila pemilik proyek menyatakan accept di prompt, lanjutkan dan catat di laporan — Lead yang mengubah file decision).
3. Kerjakan di branch `branch:` dari frontmatter handoff: buat dari `main` bila belum ada, dan selalu jalankan
   `git merge origin/main` di awal sesi. **Jangan** mengubah frontmatter handoff/decision atau `INDEX.md` (`docs/README.md` §5).

## 2. Selama bekerja
- **Berhenti ⏸ dan tanya** bila handoff tidak menjawab sesuatu yang menyentuh skema DB, izin/peran, alur status,
  lingkup, atau data riil. Item `risiko: tinggi`: ikuti gerbang risiko (`LEAD.md` §2a) — jangan pernah menjalankan langkah
  nyata (dana, kunci produksi, deploy) sendiri; tulis perintahnya untuk pemilik proyek. **Boleh berasumsi** hanya untuk hal kecil yang mudah dibalik (label, urutan kolom,
  nilai default di config) — dan setiap asumsi wajib ditulis di laporan.
- Menemukan masalah di luar lingkup? Jangan diperbaiki diam-diam: tulis sebagai **draf temuan** di laporan.
  Lead yang memutuskan apakah jadi finding.
- Kode yang bergantung pada baris `A-…` di `requirements/ASUMSI.md` diberi komentar id-nya (mis. `// A-022`).
- Jangan menulis file di `findings/`, `decisions/`, `requirements/ASUMSI.md`, atau `INDEX.md` — itu milik Lead.
- Commit kecil per checkpoint, Bahasa Indonesia, awalan `H<nnn>:`. Sebelum commit, pastikan `git branch --show-current`
  adalah branch item ini.

## 3. Definition of Done (berlaku untuk setiap handoff kode)
1. Semua kriteria selesai di handoff terpenuhi; yang tidak terpenuhi disebut jujur di laporan.
2. Suite test lulus. Bila skema berubah: lulus di semua database yang didukung (`docs/PROJECT.md` §4).
3. Setiap rute/aksi/endpoint baru punya test otorisasi: positif untuk peran yang berhak, **403** untuk yang tidak.
4. Bila ada migrasi skema: idempotent dan bisa di-rollback; tidak menimpa data yang sudah diubah pengguna.
5. Aplikasi `ui`: UI mengikuti `docs/uiux/STANDAR-UI.md` (komponen template UI proyek, tanpa style inline baru untuk layout,
   tanpa scroll horizontal halaman di lebar 360px); fitur yang terlihat pengguna → panduan pengguna diperbarui.
6. Aplikasi `data`: keluaran sesuai kontrak; perubahan kontrak memperbarui berkas kontrak **dan** test konsumennya dalam
   handoff yang sama; metrik dataset uji dilaporkan (sebelum/sesudah) di laporan; data RAW/besar tidak di-commit.
7. Tidak ada perubahan di luar lingkup, rahasia, atau file sementara yang ikut ter-commit.
8. `scripts/workflow/check-docs H<nnn>` lulus. Laporan `docs/dev-reports/H<nnn>_report.md` (field `model:` = model yang benar-benar
   mengerjakan) ditulis, di-commit, dan branch di-push (push pertama: `git push -u origin <branch>` —
   branch item tidak boleh mengikuti `origin/main`).

## 4. Laporan
Sesi sudah panjang (`AGENTS.md`)? Tutup putaran dengan `status: sebagian` dan bagian "Lanjutan untuk sesi berikutnya", lalu beri
pemilik proyek prompt pembuka sesi Developer baru.

Tulis `docs/dev-reports/H<nnn>_report.md` dari `docs/_templates/dev-report.md`. Ringkas: detail teknis panjang
(daftar file, alasan implementasi) masuk ke **deskripsi PR**, bukan laporan. Putaran perbaikan dari QA
ditambahkan sebagai bagian "Putaran n" di file yang sama — jangan membuat file baru.
Setelah itu, beri tahu pemilik proyek: "H<nnn> selesai dev".

## 5. Lingkungan
Perintah test, catatan container cloud, dan lingkungan lokal: `docs/PROJECT.md` §3–§4. Kendala lingkungan baru
yang Anda temui ditulis di bagian "Catatan lingkungan" laporan; Lead memindahkannya ke `PROJECT.md`.
