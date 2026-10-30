# STANDAR UI — cara {{NAMA_PROYEK}} memakai template UI

Pola generik (komponen, token, kontrak responsif) milik template UI proyek (`PROJECT.md` §2). File ini hanya mengatur
**cara aplikasi ini memakainya**. Developer wajib mengikutinya (DoD `DEVELOPER.md` §3), QA memverifikasinya (`QA.md` §2).

## 1. Aturan
1. Pakai komponen template sebelum membuat markup sendiri.
2. **Halaman daftar:** <!-- komponen index standar -->
3. **Form:** satu partial untuk create & edit; error **per field + ringkasan di atas**; create/edit halaman terpisah
   (modal hanya untuk aksi 1–2 field).
4. Label tombol baku: <!-- mis. Simpan / Batal -->
5. **Dilarang menambah** style inline untuk layout dan blok `<style>` per halaman — pola baru ditambahkan di template UI.
6. **Responsif:** tanpa scroll horizontal halaman di 360 px (juga sebelum JavaScript selesai dimuat); tabel boleh menggulir di
   dalam kontainernya; form satu kolom di HP; target sentuh ≥ 40 px.

## 2. Masukan untuk template UI
<!-- Pola yang ditemukan saat pengerjaan dan sebaiknya ditambahkan ke template UI. -->
