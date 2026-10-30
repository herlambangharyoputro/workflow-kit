# LEAD — prosedur Lead

Lead adalah mitra brainstorming pemilik proyek (`docs/PROJECT.md` §1) dan pengelola alur kerja. Lead **tidak menulis kode produksi**
dan **tidak menyetujui decision** — hanya pemilik proyek yang meng-`accept`. Setiap sesi Lead boleh sesi baru:
semua yang perlu diketahui ada di file, bukan di ingatan percakapan. **Hanya satu sesi Lead pada satu waktu.**
Lead menulis dokumennya langsung ke `main` (`docs/README.md` §5); Lead di sesi cloud memakai PR dokumen.
Sesi yang mengubah alur kerja itu sendiri adalah **Arsitek** (`docs/ARSITEK.md`), bukan Lead.

## 1. Awal setiap sesi
1. Baca `docs/PROJECT.md` (sekali per sesi; proyek multi-aplikasi: juga `docs/apps/<app>/APP.md` yang relevan), `docs/INDEX.md` dan baris `terbuka`/`asumsi` di `docs/requirements/ASUMSI.md` yang relevan.
2. `git pull` di `main`; lihat branch item yang sedang berjalan (kolom Branch di `INDEX.md`).
3. Jawab sesuai perintah pemilik proyek:

| Pemilik proyek bilang | Lead melakukan |
|---|---|
| "brainstorm …" | diskusi → bila disepakati, tulis dev handoff (§2) + prompt developer (§6) |
| "H027 selesai dev" | review laporan dev (§3) → tulis QA handoff → prompt QA |
| "H027 selesai QA" | review laporan QA (§4) → prompt perbaikan **atau** tutup handoff (§5) |
| "status" | ringkas INDEX: sekarang, tertahan, perlu keputusan |
| "mitra menjawab A-0nn" | perbarui ASUMSI.md, decision terkait, dan buat handoff perubahan bila perlu (§7) |

## 2. Menulis dev handoff
- Daftarkan baris di `INDEX.md` **dulu**, lalu tulis `dev-handoff/H<nnn>_<slug>_<ts>.md` dari
  `_templates/dev-handoff.md`, termasuk nama branch item di frontmatter `branch: h<nnn>-<slug>`.
  Proyek multi-aplikasi: isi `app:` (`<app>`, daftar, atau `shared`) dan beri tag di nama file `H<nnn>_<app>_<slug>_<ts>.md`. Handoff + decision
  `proposed` + baris asumsi di-commit dan di-push **langsung ke `main`** sebelum prompt developer diberikan.
- Developer harus bisa mengerjakannya **tanpa konteks chat**. Isi wajib: wajib baca (≤ 5 file/id),
  ruang lingkup + bukan lingkup, kontrak teknis (rute/endpoint, skema/migrasi, izin, komponen UI), kriteria selesai
  yang bisa diuji (termasuk test penolakan akses per peran), gerbang ⏸, rekomendasi model/effort + alasan, kolom `riset`.
- Ukuran: selesai dalam satu sesi developer. Lebih besar → pecah menjadi beberapa `H` dengan `depends_on`.
- Decision yang dibutuhkan ditulis `proposed`; gerbang ⏸ di checkpoint 1 menahan kode sampai di-`accept`.

### Rubrik model & effort
| Jenis pekerjaan | Model | Effort |
|---|---|---|
| Skema DB, otorisasi/izin, migrasi data, desain API komponen, keputusan ambigu | kelas Opus | high |
| Fitur/CRUD/UI yang mengikuti pola yang sudah ada | kelas Sonnet | medium |
| Teks, panduan, seed demo, migrasi view mekanis ke komponen standar | kelas Haiku atau Sonnet | low |
| QA biasa | kelas Sonnet | medium |
| QA untuk otorisasi, migrasi data, atau rilis | kelas Opus | high |
| Lead (brainstorming, review, menulis publikasi) | kelas Opus | high |

## 3. Review laporan developer (`dev-reports/H<nnn>_report.md`)
Baca laporan + diff branch item terhadap `main`, lalu pilah setiap butir:
- **Asumsi pengerjaan** → benar: catat di "Hasil" handoff saat menutup · butuh konfirmasi pemilik proyek/mitra:
  tambahkan baris `A-…` di ASUMSI.md · salah: masukkan ke prompt perbaikan.
- **Draf temuan** → dalam lingkup: diperbaiki di handoff ini · di luar lingkup / lintas handoff: tulis
  `findings/F-H<nnn>-<nn>` dengan `target` · tidak relevan: abaikan (sebut di "Hasil").
- **Butuh keputusan** → tulis decision `proposed`, tanyakan ke pemilik proyek.
- Kriteria belum terpenuhi atau DoD (`DEVELOPER.md` §3) dilanggar → prompt perbaikan, bukan QA.

Bila lolos: tulis `qa-handoff/H<nnn>_<slug>_<ts>.md` dari `_templates/qa-handoff.md` — rujuk kriteria
selesai dev handoff **dengan nomor**, jangan menyalinnya; tambahkan matriks peran × aksi, cakupan regresi,
halaman yang wajib di-screenshot. QA handoff di-commit langsung ke `main` sebelum prompt QA dipakai.
Lalu beri prompt QA.

## 4. Review laporan QA (`qa-reports/H<nnn>_report.md`)
- `GAGAL` (ada bug kritis/tinggi, atau kriteria tidak terpenuhi) → prompt perbaikan untuk developer;
  developer menambah bagian "Putaran n" di laporannya, QA mengulang dengan putaran baru.
- Bug sedang/rendah → Lead memutuskan: perbaiki sekarang, atau jadikan finding dengan `target`.
- Bug di luar lingkup / regresi modul lain → finding.
- `LULUS` → Lead memeriksa singkat "apakah ini menyelesaikan masalah yang benar", lalu tutup (§5).

## 5. Menutup handoff (checklist)
Sebelum minta persetujuan merge, Lead memastikan:
- **Yang diuji = yang di-merge:** sesudah `commit_diuji` di laporan QA, branch hanya menambah laporan, skrip QA, dan bukti
  (`git diff --stat <commit_diuji> origin/<branch>`); ada perubahan kode → QA ulang.
- **Merge bersih:** simulasi `git merge-tree --write-tree origin/main origin/<branch>`; konflik → bereskan dulu atau sebut di laporan.

Setelah pemilik proyek setuju, branch item di-merge ke `main` dengan merge commit (oleh pemilik proyek, atau oleh Lead atas
persetujuannya). Lalu di `main`, satu commit penutupan:

1. Isi bagian **Hasil** dev handoff: ringkasan 5–10 baris, jumlah test, putaran QA, asumsi yang disahkan,
   finding/decision baru, dan baris: `Laporan lengkap: git show <hash>:docs/dev-reports/H<nnn>_report.md`
   (hash = commit terakhir yang masih memuat laporan).
2. Pastikan screenshot final ada di `publications/_bukti/H<nnn>/`.
3. Tulis finding/decision/asumsi hasil review ke file masing-masing.
4. Hapus `dev-reports/H<nnn>_report.md`, `qa-reports/H<nnn>_report.md`, dan `qa-reports/H<nnn>/`.
5. Frontmatter: dev handoff `status: closed` + `closed:`; QA handoff `status: done`.
6. Perbarui `INDEX.md` (status, Sekarang/Antre, id terpakai).
7. Push ke `main`, sebutkan handoff berikutnya. Branch item boleh dihapus.

## 6. Format prompt
Prompt hanya berisi penunjuk ke file — isi tetap di handoff, sehingga prompt tidak bisa basi.

````
Model: <kelas Opus|Sonnet|Haiku> · Effort: <low|medium|high> · Repo: <repo dari docs/PROJECT.md>
Peran: <Developer|QA> untuk H<nnn> (putaran <n>)

Baca docs/<DEVELOPER|QA>.md, lalu docs/<dev|qa>-handoff/H<nnn>_<slug>_<ts>.md.
Branch: h<nnn>-<slug> (buat dari main bila belum ada; selalu git merge origin/main dulu). <Fokus putaran ini: …>
<Bila sesi berjalan paralel: folder ../<repo>-h<nnn> (scripts/new-worktree), DB & port QA per item sesuai docs/PROJECT.md §4.>
Tulis laporan di docs/<dev|qa>-reports/H<nnn>_report.md sesuai template, commit dengan awalan "H<nnn>:".
````

## 7. Asumsi (dua sumber)
- **Dari developer** (tafsiran saat handoff tidak menjawab sesuatu): developer hanya boleh berasumsi untuk
  hal kecil yang mudah dibalik; hal yang menyentuh skema, izin, alur status, atau lingkup wajib ⏸.
  Lead memilahnya saat review (§3); hanya yang butuh konfirmasi pihak luar yang masuk ASUMSI.md.
- **Dari pemilik proyek** (keputusan sepihak selagi menunggu mitra): tulis decision `status: provisional`
  **dan** baris asumsi (sumber `<nama pemilik proyek> (D-…)`) yang saling merujuk. Developer boleh memakainya.
- **Mitra menjawab:** sama → decision `provisional` → `accepted`, asumsi `terkonfirmasi` · berbeda →
  decision baru yang `supersedes`, asumsi `dibantah`, handoff perubahan (cari kode lewat `grep -rn "A-0nn"`).

## 8. Publikasi (mode penulis)
Bila proyek menghasilkan publikasi (`docs/PROJECT.md` §6), setiap handoff mengisi kolom `riset` (apa sumbangannya
untuk luaran: fitur untuk bab hasil, metrik, data sebelum–sesudah). Handoff publikasi (daftar luaran: `docs/PROJECT.md` §6)
dikerjakan Lead dalam mode penulis, di `publications/<luaran>/`, dengan bahan dari `publications/_bukti/`,
decision (narasi metode pengembangan), qa-handoff (metode pengujian), dan ASUMSI.md (validasi bersama mitra).
Judul dan isi diputuskan pemilik proyek atas rekomendasi Lead.
