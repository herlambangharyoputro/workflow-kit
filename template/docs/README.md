# docs/ — peta dokumentasi {{NAMA_PROYEK}}

Semua catatan kerja proyek tinggal di sini sebagai file Markdown. Temuan, keputusan, dan asumsi
**tidak cukup disebut di chat** — kalau belum ada filenya, ia belum tercatat.

Alur kerja: **workflow-kit {{VERSI_KIT}}** (adopsi & upgrade: decision `D-H000-*` di `decisions/`). File peran (`LEAD.md`, `DEVELOPER.md`, `QA.md`, `ARSITEK.md`),
`_templates/`, dan aturan di file ini generik; semua hal khusus proyek ada di `PROJECT.md`<!-- [multi-app] --> dan `apps/<app>/APP.md`<!-- [/multi-app] -->.

## 1. Mulai dari mana
| Saya… | Baca |
|---|---|
| Lead | `LEAD.md` → `PROJECT.md` → `INDEX.md` → `requirements/ASUMSI.md` |
| Developer | `DEVELOPER.md` → `PROJECT.md` → `dev-handoff/H<nnn>_*.md` yang disebut di prompt |
| QA | `QA.md` → `PROJECT.md` → `qa-handoff/H<nnn>_*.md` yang disebut di prompt |
| Arsitek (mengubah alur kerja) | `ARSITEK.md` → file ini |
| Agen selain Claude Code | `AGENTS.md` di root repo (titik masuk semua agen; `CLAUDE.md` hanya mengimpornya) |
| Ingin tahu status | `INDEX.md` (item lama yang sudah ditutup: `INDEX-arsip.md`, tidak wajib dibaca) |

## 2. Folder
| Folder | Isi | Penulis | Saat handoff `closed` |
|---|---|---|---|
| `PROJECT.md` | profil proyek: repo, stack, perintah, lingkungan, peran & akun uji, luaran | Lead | — |
| `apps/<app>/APP.md` | profil per aplikasi | Lead | — | <!-- [multi-app] -->
| `dev-handoff/` | alur kerja untuk developer | Lead | disimpan; Lead mengisi bagian "Hasil" |
| `dev-reports/` | laporan pengerjaan, draf temuan, asumsi pengerjaan | Developer | **dihapus** setelah isinya diekstrak |
| `qa-handoff/` | rencana uji untuk QA | Lead | disimpan (rencana regresi) |
| `qa-reports/` | laporan hasil uji & bug | QA | **dihapus** setelah isinya diekstrak |
| `findings/` | temuan (fakta, bug lintas handoff) | Lead | disimpan |
| `decisions/` | keputusan | Lead mengusulkan, pemilik proyek menyetujui | disimpan |
| `requirements/` | dokumen dari mitra/pengguna + `ASUMSI.md` | Lead | disimpan |
| `proposal/` | dokumen lingkup/kontrak | — | — |
| `publications/` | luaran publikasi + `_bukti/` | Lead (mode penulis), QA (`_bukti/`) | disimpan |
| `uiux/` | cara aplikasi memakai template UI | Lead | disimpan |
| `user-guides/` | panduan aplikasi untuk mitra / end-user | Developer / Lead | disimpan |
| `deployment-guides/` | panduan deploy & konfigurasi server | Developer | disimpan |
| `_templates/` | template semua jenis dokumen | Arsitek | — |

## 3. Id
| Jenis | Format | Contoh | Lokasi |
|---|---|---|---|
| Item kerja | `H` + 3 digit, **nomor sama** untuk dev & QA | `H012` | `dev-handoff/H012_<slug>_<YYYYMMDD-HHMM>.md`, `qa-handoff/H012_<slug>_<YYYYMMDD-HHMM>.md` |
| Laporan | — | — | `dev-reports/H012_report.md`, `qa-reports/H012_report.md` (+ folder `qa-reports/H012/` untuk lampiran) |
| Finding | `F-H<nnn>-<nn>` | `F-H012-01` | `findings/F-H012-01_<slug>_<YYYYMMDD-HHMM>.md` |
| Decision | `D-H<nnn>-<nn>` | `D-H012-01` | `decisions/D-H012-01_<slug>_<YYYYMMDD-HHMM>.md` |
| Asumsi | `A-` + 3 digit, global | `A-001` | baris di `requirements/ASUMSI.md` |

- `H000` = tingkat proyek (proses, lingkup) — dipakai untuk F/D yang tidak lahir dari satu handoff.
- Satu urutan id untuk seluruh repo. Pekerjaan yang terlalu besar dipecah menjadi beberapa `H` dengan `depends_on`.
- QA tanpa handoff dev (mis. regresi sebelum rilis) tetap dibuatkan item kerja `H<nnn>` untuk rilisnya.
- **Id tidak pernah berubah; rujuk dengan id, bukan nama file.** `INDEX.md` adalah satu-satunya sumber id
  berikutnya — Lead mendaftarkan barisnya **sebelum** menulis file.
- `_` hanya pemisah kolom; slug kebab-case ASCII ≤ ~50 karakter; timestamp = waktu dibuat (zona waktu di `PROJECT.md`).
<!-- [multi-app] -->
- **Multi-aplikasi:** frontmatter `app:` di handoff, finding, dan decision (`<app>`, daftar, atau `shared` untuk yang dipakai
  bersama — login, database, template UI); tag aplikasi di nama file handoff: `H012_<app>_<slug>_<ts>.md`;
  `INDEX.md` punya kolom App. Developer & QA membaca `apps/<app>/APP.md` sesuai `app:`.
<!-- [/multi-app] -->

## 4. Status
| Dokumen | Status |
|---|---|
| Dev handoff (status item kerja) | `draft` → `ready` → `in-progress` → `qa` → `review` → `closed`; juga `blocked`, `superseded` |
| QA handoff | `ready` → `done` |
| Finding | `open` · `confirmed` (fakta terverifikasi, tak perlu tindakan) · `resolved` · `superseded` |
| Decision | `proposed` · `accepted` · `provisional` (diputuskan pemilik proyek, menunggu konfirmasi mitra) · `superseded` |
| Asumsi | `terbuka` · `asumsi` · `terkonfirmasi` · `dibantah` |

- Decision **tidak pernah diedit** setelah `accepted`; perubahan = decision baru dengan `supersedes`.
  Pengecualian: `provisional` → `accepted` saat mitra mengonfirmasi (ubah `status` saja).
- Saat sebuah file di-supersede, ubah hanya `status` dan `superseded_by` di file lama.
- Finding wajib punya `target`: handoff yang akan menanganinya, atau `belum dijadwalkan`.

## 5. Git (model satu pemilik)
- **Satu penulis per file.** Lead menulis dokumennya **langsung ke `main`** (dev/QA handoff, finding, decision, ASUMSI,
  INDEX, PROJECT, uiux). Hanya **satu sesi Lead** pada satu waktu; Lead di sesi cloud (tidak bisa push ke `main`) memakai PR dokumen.
- **Satu item = satu branch** `h<nnn>-<slug>` (nama dari frontmatter `branch:` dev handoff). Developer, QA, dan semua putaran
  perbaikan bekerja di branch itu; setiap sesi dimulai dengan `git merge origin/main`. Commit diawali id: `H012: …`.
- Developer & QA hanya menulis kode, test, laporan, dan bukti — **tidak** mengubah frontmatter handoff/decision atau `INDEX.md`.
  Status item hanya di `INDEX.md`.
- **Penutupan:** branch item di-merge ke `main` dengan **merge commit, bukan squash** (laporan yang dihapus tetap ada di
  riwayat), lalu Lead membuat satu commit penutupan di `main` (`LEAD.md` §5).
- **Sesi paralel:** satu folder repo = satu sesi. Sesi yang berjalan bersamaan memakai worktree sendiri
  (`scripts/workflow/new-worktree`) dengan DB dan port QA sendiri (`PROJECT.md` §4).
- Perubahan alur kerja dikerjakan sesi **Arsitek** lewat PR (`ARSITEK.md`).
- **Pemeriksaan otomatis:** `scripts/workflow/check-docs` (frontmatter, id, status; dengan id item: branch, file milik Lead,
  laporan & field `model`, berkas rahasia/besar di diff). Developer/QA menjalankannya sebelum melapor; Lead sebelum merge dan setelah menutup.
