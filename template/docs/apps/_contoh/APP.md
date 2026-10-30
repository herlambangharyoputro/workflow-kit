# APP — <app>

Profil khusus aplikasi `<app>` (nilai `app:` di handoff). Yang dipakai bersama (`app: shared`) tetap di `docs/PROJECT.md`;
tulis di sini hanya yang berbeda. Aplikasi baru ditambahkan dengan menjalankan ulang `scripts/install` workflow-kit dengan `--apps`.

## 1. Identitas
| | |
|---|---|
| App | `<app>` |
| Jenis | <!-- ui / data / api --> |
| Folder kode | <!-- mis. apps/<app>/ atau <app>/ --> |
| Pengguna | <!-- --> |
| Status | <!-- aktif / direncanakan (tahun) --> |

## 2. Jenis & cara QA
<!-- Sesuai jenis di QA.md §2. ui: halaman utama untuk cek responsif & peran. data: perintah menjalankan tahap ini, dataset uji,
     metrik & cara menghitungnya, toleransi, jumlah sampel manual. api: daftar endpoint & kontraknya. -->

## 3. Stack & konvensi (yang berbeda dari PROJECT.md)
- <!-- -->

## 4. Perintah
| Tujuan | Perintah |
|---|---|
| Suite test aplikasi ini | <!-- --> |
| Menjalankan tahap ini (data) | <!-- input → output, seed --> |
| Jalankan untuk QA | <!-- DB QA & port per item; rentang port berbeda per aplikasi bila sering paralel --> |

## 5. Peran & akun uji
| Peran | Akun uji |
|---|---|
| | |

## 6. UI
Pemakaian template UI khusus aplikasi ini (bila berbeda dari `docs/uiux/STANDAR-UI.md`).
