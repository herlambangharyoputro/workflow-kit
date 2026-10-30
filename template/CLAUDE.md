# CLAUDE.md — {{NAMA_PROYEK}}

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

## Aturan yang selalu berlaku
- Bahasa Indonesia untuk dokumen dan commit; commit untuk item kerja diawali `H<nnn>:`.
- Jangan pernah menghapus/mengosongkan database kerja; pakai database QA terpisah (`docs/PROJECT.md` §4).
- Minta izin sebelum aksi yang tidak bisa dibalik (hapus/timpa file, ubah koneksi DB, pasang paket sistem).
- Lead menulis dokumen langsung ke `main`; developer & QA bekerja di satu branch item. Merge dengan merge commit, bukan squash.
