# AGENTS.md — {{NAMA_PROYEK}}

Instruksi untuk **semua** agen AI (Claude Code, DeepSeek, dan klien lain) yang bekerja di repo ini.

Repo ini memakai alur kerja **Lead → Developer → QA** (workflow-kit {{VERSI_KIT}}) dengan semua catatan di `docs/`
(peta: `docs/README.md`). Profil proyek (stack, perintah, lingkungan, akun uji): `docs/PROJECT.md`.
<!-- [multi-app] -->
Repo multi-aplikasi: profil tiap aplikasi di `docs/apps/<app>/APP.md`; field `app:` di handoff menentukan profil yang dibaca.
<!-- [/multi-app] -->

<!-- [migrasi] -->
**Migrasi berjalan:** `docs-old/` adalah arsip alur kerja lama — bahan migrasi untuk Lead (`docs/MIGRASI.md`), **bukan aturan
yang berlaku**. Jangan ikuti `LEAD.md`, `INDEX.md`, atau `README.md` di dalamnya. Blok ini dihapus Lead saat migrasi selesai.

<!-- [/migrasi] -->
## Tentukan peran dari prompt
| Prompt berisi | Peran | Baca dulu |
|---|---|---|
| "Kamu Lead", "brainstorm …", "H<nnn> selesai dev", "H<nnn> selesai QA", "status", "mitra menjawab A-…" | Lead | `docs/LEAD.md` |
| "Peran: Developer" / "Kamu Developer" | Developer | `docs/DEVELOPER.md` |
| "Peran: QA" / "Kamu QA" | QA | `docs/QA.md` |
| "Kamu Arsitek" / merancang atau mengubah alur kerja itu sendiri | Arsitek | `docs/ARSITEK.md` |

**Hanya satu sesi Lead pada satu waktu.** Sesi Arsitek tidak menjalankan tugas Lead: bila menerima pemicu Lead
("H<nnn> selesai dev/QA", "status"), jawab bahwa pemicu itu untuk sesi Lead dan jangan me-review laporan atau menulis handoff.

Tanpa peran (permintaan biasa): kerjakan dengan konvensi di `docs/PROJECT.md` §2, dan jangan mengubah `docs/INDEX.md`,
`docs/findings/`, `docs/decisions/`, atau `docs/requirements/ASUMSI.md` kecuali diminta.

## Batas sesi
Semua yang perlu diketahui ada di file, bukan di riwayat chat — sesi baru tidak perlu membaca percakapan lama. Setiap giliran
mengirim ulang seluruh konteks sesi, jadi sesi pendek lebih murah dan lebih teliti daripada sesi panjang.
- **Developer dan QA: satu handoff = satu sesi.** Setelah melapor "H<nnn> selesai dev/QA", sesi berhenti; handoff berikutnya
  dikerjakan di sesi baru (tab baru atau `/clear`), walau untuk peran yang sama. Putaran perbaikan untuk handoff yang **sama**
  boleh lanjut di sesi itu selama konteksnya masih pendek.
- **Lead: beberapa handoff per sesi**, sesi baru setelah ±2–3 handoff ditutup.
- **Model dan effort dipilih sebelum pesan pertama** dan tidak diganti di tengah sesi (ganti model = cache konteks hilang dan
  seluruh konteks diproses ulang dengan harga penuh). Butuh model lain → sesi baru.
- Prompt dari Lead ditempel **apa adanya**, termasuk baris "Baca docs/<PERAN>.md".

## Hemat token
- Baca bagian yang perlu (`grep -n`, rentang baris, § yang dirujuk), bukan seluruh file; jangan membaca ulang file yang sudah dibaca di sesi ini.
- Test: jalankan dengan output ringkas dan tampilkan yang gagal saja (mode quiet, `| tail -n 40`); output penuh hanya untuk test yang diselidiki.
- Diff: mulai dari `git diff --stat`, lalu buka file yang relevan saja. Log, dump DB, dan file data tidak ditampilkan utuh (`head`, `tail`, `grep`, hitungan).
- Screenshot disimpan sebagai bukti, tidak dibuka ulang kecuali untuk memeriksa bug tertentu.
- Lapor ke pemilik proyek secara ringkas; isi lengkap ada di file laporan. Pemilik proyek cukup meneruskan pemicu ke Lead
  ("H<nnn> selesai dev"), tidak menempel jawaban sesi Developer/QA.

## Sesi panjang — wajib serah terima
Sesi yang terlalu panjang mulai lupa keputusan awal dan mengulang pekerjaan. **Lead, Developer, dan QA wajib memberi tahu
pemilik proyek dan menyerahkan pekerjaan ke sesi baru** bila salah satu tanda ini muncul:
- klien memadatkan/meringkas konteks (mis. pesan *context compacted*, *summarized*), atau konteks terasa hampir penuh;
- Anda membaca ulang berkas yang sudah dibaca, atau ragu tentang keputusan yang dibuat di awal sesi;
- batas sesi di atas tercapai (Lead ±2–3 handoff ditutup; Developer/QA: handoff berikutnya, atau putaran perbaikan ke-3 di sesi yang sama);
- pemilik proyek meminta.

Cara serah terima (di titik aman — jangan di tengah suntingan):
1. Commit semua yang sudah jadi; tidak ada perubahan yang belum di-commit.
2. Tulis catatan serah terima: Lead → bagian **Serah terima sesi Lead** di `docs/INDEX.md` (≤ 10 baris, ditimpa);
   Developer/QA (pekerjaan belum selesai) → bagian putaran di laporan dengan `status: sebagian` + "Lanjutan untuk sesi
   berikutnya" (≤ 8 baris: apa yang selesai, yang belum, langkah pertama). Rujuk file/commit, jangan salin isinya.
3. Beri pemilik proyek **prompt pembuka sesi baru** yang siap tempel (peran, file yang dibaca, langkah pertama) — hanya penunjuk ke file.

## Aturan yang selalu berlaku
- Bahasa Indonesia untuk dokumen dan commit; commit untuk item kerja diawali `H<nnn>:`.
- Jangan pernah menghapus/mengosongkan database kerja; pakai database QA terpisah (`docs/PROJECT.md` §4).
- Minta izin sebelum aksi yang tidak bisa dibalik (hapus/timpa file, ubah koneksi DB, pasang paket sistem).
- Item ber-`risiko: tinggi` (dana nyata, kunci/rahasia, data produksi, deploy) mengikuti **gerbang risiko** (`docs/LEAD.md` §2a).
- Perintah untuk pemilik proyek ditulis siap salin-tempel dengan label lingkungan (`docs/PROJECT.md` §3), satu blok per perintah.
- Sebelum melapor selesai: jalankan `scripts/workflow/check-docs` (Developer/QA: dengan id item).
- Lead menulis dokumen langsung ke `main`; developer & QA bekerja di satu branch item. Merge dengan merge commit, bukan squash.
