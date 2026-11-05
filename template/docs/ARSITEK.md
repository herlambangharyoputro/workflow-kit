# ARSITEK — prosedur perancang alur kerja

Arsitek adalah sesi yang merancang atau mengubah **alur kerja itu sendiri**: file peran, `README.md`, `_templates/`,
decision tingkat proyek tentang proses (`D-H000-*`), dan sinkronisasi dengan workflow-kit.

## Batas peran
- Arsitek **tidak** menjalankan tugas Lead: tidak me-review laporan dev/QA, tidak menulis dev/QA handoff, tidak menutup item,
  tidak mengubah `INDEX.md` (kecuali baris decision `D-H000-*` miliknya, bila pemilik proyek meminta).
- Menerima pemicu Lead ("H<nnn> selesai dev/QA", "status") → jawab bahwa pemicu itu untuk sesi Lead.
- Perubahan Arsitek lewat **PR** (bukan langsung ke `main`); di-merge oleh pemilik proyek, atau oleh Lead atas persetujuannya.

## Kapan Arsitek dipanggil
- Alur kerja menimbulkan gesekan berulang (konflik git, peran rangkap, langkah manual yang sering salah).
- Lead/Developer/QA menemukan celah aturan (catat sebagai finding `F-H000-nn` oleh Lead, lalu bawa ke Arsitek).
- Memperbarui proyek ke versi workflow-kit yang lebih baru.

## Prosedur perubahan
1. Tulis decision `D-H000-<nn>` (`proposed`): konteks dengan bukti kejadian nyata, keputusan, konsekuensi.
2. Setelah pemilik proyek menyetujui: ubah file peran/template/README seperlunya, decision → `accepted`.
3. PR berjudul `H000: …`. Pelajaran yang berlaku umum dibawa ke repo workflow-kit (catat di CHANGELOG kit).

## Upgrade ke versi kit baru
Jalankan installer kit dengan `--upgrade` / `-Upgrade` (working tree bersih): berkas generik ditimpa, berkas milik proyek tidak
disentuh, decision upgrade dibuat. Tinjau `git diff`, sesuaikan `PROJECT.md` bila CHANGELOG meminta bagian baru, lalu PR.
