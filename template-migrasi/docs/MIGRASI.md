# MIGRASI — dari docs-old/ ke workflow-kit {{VERSI_KIT}}

Dokumen kerja **Lead** untuk memindahkan alur kerja lama ke kaidah workflow-kit (keputusan: D-H000-02). `docs-old/` adalah
**arsip bahan**, bukan aturan yang berlaku: jangan ikuti `LEAD.md`/`INDEX.md`/`README.md` di dalamnya. Hapus file ini dan
`docs-old/` saat checklist di bawah selesai.

## 1. Prinsip
- **Tulis ulang hanya yang masih hidup.** Riwayat yang sudah selesai cukup dicatat di tabel Peta (§4); isinya tetap ada di git.
- **Id baru, id lama tetap bisa dicari.** Item kerja baru melanjutkan dari nomor main tertinggi di `docs-old/` + 1
  (mis. lama sampai `H002.11` → mulai `H003`). Setiap file hasil migrasi mengisi `legacy_id` (mis. `H001.14`, `F-H001-19`).
  Commit dan komentar kode lama yang menyebut id lama **tidak** diubah.
- **Sub-handoff tidak ada lagi.** `H001.14` lama yang masih aktif menjadi item kerja sendiri (`H<nnn>` baru) dengan `depends_on`.
- Satu commit per langkah besar, awalan `H000: migrasi …`, langsung ke `main`. Jangan migrasi saat sesi alur lama masih berjalan.

## 2. Generasi alur kerja lama yang umum
| Generasi | Ciri | Bahan untuk |
|---|---|---|
| v1 | `PLAN_*.md`, `progress_*.md`, `SKILL_*.md`, `GUIDELINES_*.md`, `KEPUTUSAN_*.md` di root (dipindah ke `docs-old/v1/`) | `PROJECT.md`, `apps/<app>/APP.md`, decision rangkuman |
| v2 | `INDEX.md` + `handoff/` dengan main & sub (`H001.14`), `findings/`, `decisions/`, `assumptions/` per file, `LEAD.md` dengan papan status/log | item aktif, finding & asumsi terbuka, decision berlaku |
| lain | `agent_*/`, `question*.md`, catatan sesi | biasanya cukup dicatat di Peta |

## 3. Langkah
1. **Inventaris.** Daftar semua id di `docs-old/` ke tabel Peta (§4) dengan status lamanya. Cek `git status` bersih.
2. **Profil.** Isi `PROJECT.md` (repo, stack, jenis & cara QA, perintah test, lingkungan, larangan DB kerja, §7 Data, §8 Kontrak —
   mis. folder `contracts/` yang sudah ada) dan `apps/<app>/APP.md` dari bahan v1/v2.
   Dokumen hidup di root yang masih dipakai (mis. kontrak API, skema DB) boleh tetap di tempatnya — sebut di `PROJECT.md` §2.
3. **Id berikutnya.** Tetapkan di `INDEX.md`: item kerja = main lama tertinggi + 1; asumsi mulai `A-001`.
4. **Decision yang masih berlaku** → satu decision rangkuman `D-H000-03` "Keputusan yang dibawa dari alur kerja lama" (daftar ringkas:
   id lama, isi satu kalimat, file asal). Decision yang sering dirujuk atau masih `proposed` → decision sendiri `D-H000-<nn>` dengan `legacy_id`.
5. **Item aktif** → dev handoff baru dari `_templates/dev-handoff.md`, `legacy_id` diisi, nama branch baru. Status awal:
   `ready` (belum dikerjakan) · `qa` (kode sudah ada, belum diverifikasi — perlakukan seperti item lama tanpa laporan dev) ·
   `blocked` (menunggu pihak luar). Daftarkan di `INDEX.md`.
6. **Finding terbuka** → `findings/F-H000-<nn>` (tingkat proyek) atau `F-H<nnn>-<nn>` bila jelas milik item baru, dengan `legacy_id` dan `target`.
7. **Asumsi terbuka** → baris di `requirements/ASUMSI.md` (kolom Sumber: `migrasi A-H001-09`).
8. **Dokumen bukan alur kerja** (bukti uji, instrumen, mockup, paket pengguna) → pindahkan ke folder kit yang sesuai
   (`publications/_bukti/`, `user-guides/`, `requirements/`, `uiux/`) dengan `git mv`.
9. **Penutup.** Centang checklist §5, catat baris "Migrasi docs-old" di tabel Selesai `INDEX.md` dengan hash commit terakhir yang masih
   memuat `docs-old/`, lalu hapus `docs-old/`, file ini, dan blok "Migrasi berjalan" di `CLAUDE.md` dalam satu commit.

## 4. Peta id lama → nasib
| Id lama | Jenis | Status lama | Nasib | Id baru / tempat |
|---|---|---|---|---|
| | | | ditulis ulang · dirangkum · dicatat saja · dipindah | |

## 5. Checklist selesai
- [ ] Semua id di `docs-old/` tercatat di Peta
- [ ] `PROJECT.md` (dan `apps/*/APP.md`) terisi; tidak ada placeholder `<!-- isi -->` yang tersisa untuk bagian wajib
- [ ] Item aktif punya dev handoff baru dan baris INDEX
- [ ] Finding/asumsi terbuka dan decision berlaku sudah dipindah
- [ ] Dokumen bukan alur kerja sudah dipindah
- [ ] Tidak ada rujukan path `docs-old/` di `docs/` (kecuali file ini dan tabel Selesai)
- [ ] `docs-old/`, file ini, dan blok "Migrasi berjalan" di `CLAUDE.md` dihapus
