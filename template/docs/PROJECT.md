# PROJECT — profil proyek {{NAMA_PROYEK}}

Semua hal **khusus proyek ini** yang dirujuk oleh `LEAD.md`, `DEVELOPER.md`, dan `QA.md`.
<!-- [multi-app] -->
Proyek ini **multi-aplikasi**: file ini memuat yang berlaku untuk seluruh repo dan yang dipakai bersama (`app: shared`);
hal khusus tiap aplikasi ada di `apps/<app>/APP.md`.
<!-- [/multi-app] -->

## 1. Identitas
| | |
|---|---|
| Nama | {{NAMA_PROYEK}} |
| Repo | `{{REPO}}` (branch utama `main`) |
| Pemilik proyek | {{PEMILIK}} |
| Mitra / pengguna | <!-- isi --> |
| Acuan lingkup | <!-- mis. proposal/kontrak di proposal/ --> |
| Bahasa & zona waktu | Dokumen dan commit dalam Bahasa Indonesia; waktu dalam WIB |
<!-- [multi-app] -->

## 1a. Aplikasi
| App | Folder kode | Profil | Status |
|---|---|---|---|
| {{BARIS_APP}} |

**Dipakai bersama (`app: shared`):** <!-- mis. login, database, template UI -->
<!-- [/multi-app] -->

## 2. Stack & konvensi kode
- **Jenis & cara QA:** <!-- ui | data | api; cara uji khusus proyek ini --> (`QA.md` §2) <!-- [single-app] -->
- **Jenis & cara QA:** per aplikasi di `apps/<app>/APP.md` §2 (`QA.md` §2) <!-- [multi-app] -->
- <!-- framework, bahasa, template UI -->
- Konvensi kode & aturan domain: <!-- file, mis. SKILL.md -->
- Pemakaian template UI: `uiux/STANDAR-UI.md`.
- Panduan pengguna di aplikasi bersumber dari: <!-- isi, atau "tidak ada" -->

## 3. Lingkungan
| Lingkungan | Keterangan |
|---|---|
| Lokal | <!-- OS, DB kerja, DB test --> |
| Demo / staging | <!-- --> |
| Produksi | <!-- --> |

## 4. Perintah
| Tujuan | Perintah |
|---|---|
| Pasang dependensi | <!-- --> |
| Suite test | <!-- --> |
| Database yang didukung | <!-- perubahan skema wajib lulus di semua yang disebut --> |
| Jalankan aplikasi untuk QA | <!-- DB QA per item (mis. qa_H<nnn>), port per item (mis. 8<nnn>), flag data demo --> |

**Dilarang:** perintah yang menghapus/mengosongkan database kerja (mis. `migrate:fresh`, `db:wipe`) — selalu pakai DB QA terpisah.

**Sesi paralel:** satu folder repo = satu sesi; sesi bersamaan memakai `scripts/new-worktree` (folder `../<repo>-h<nnn>`),
DB dan port QA sendiri. Berkas yang perlu disalin ke worktree (mis. dependensi terpasang, `.env`): <!-- isi `.worktree-copy` -->.
Jangan symlink folder dependensi ke checkout utama — autoloader/interpreter bisa memuat kode dari branch lain.

## 5. Peran aplikasi & akun uji
Peran: <!-- daftar peran, urutan ini dipakai untuk kolom matriks peran × aksi di QA handoff -->

| Peran | Akun uji |
|---|---|
| | |

## 6. Luaran
- **Software:** <!-- -->
- **Publikasi** (`publications/`): <!-- atau "tidak ada" -->

## 7. Data
| | |
|---|---|
| Data mentah (RAW) | <!-- lokasi di luar git, ukuran, cara mendapatkan; "tidak ada" bila bukan proyek data --> |
| Data antara / matang | <!-- lokasi, format, siapa yang memakai --> |
| Dataset uji tetap | <!-- path (kecil, boleh di git), versi/hash; mengganti dataset uji = decision baru --> |
| Baseline metrik | <!-- publications/_bukti/H<nnn>/metrik.md terakhir yang LULUS --> |

**Dilarang commit:** data RAW, data besar, kredensial. Pastikan `.gitignore` memuatnya sebelum commit pertama.

## 8. Kontrak antar aplikasi
| Kontrak | Produsen | Konsumen | Berkas skema | Test |
|---|---|---|---|---|
| | | | <!-- mis. contracts/… --> | |

Perubahan kontrak dikerjakan dalam **satu** handoff yang menyentuh produsen dan konsumen (`app: [produsen, konsumen]`),
termasuk memperbarui berkas skema dan test konsumennya.
