# INDEX — status item kerja {{NAMA_PROYEK}}

> Satu-satunya sumber id berikutnya dan status antrean. **Hanya Lead yang mengubah file ini**, langsung di `main`.
> Aturan: `README.md`. Urutan ditentukan prioritas + `depends_on`, bukan nomor id.

## Id berikutnya
- Item kerja: **H001**
- Asumsi: **A-001** (`requirements/ASUMSI.md`)
- Finding/decision: `nn` terbesar di `findings/F-H<nnn>-*` atau `decisions/D-H<nnn>-*` + 1 (belum ada → `01`).
  `H000` = tingkat proyek (terpakai: D-H000-01). <!-- [tanpa-migrasi] -->
  `H000` = tingkat proyek (terpakai: D-H000-01, D-H000-02). <!-- [migrasi] -->
- Migrasi dari `docs-old/`: item kerja baru melanjutkan dari nomor main lama tertinggi + 1 — Lead menetapkannya di sini (`MIGRASI.md` §3). <!-- [migrasi] -->

## Sekarang
| Id | App | Task | Prio | Status | Branch | Langkah berikutnya | <!-- [multi-app] -->
|---|---|---|---|---|---|---| <!-- [multi-app] -->
| — | shared | Migrasi `docs-old/` ke workflow-kit | P0 | in-progress | `main` | Lead menjalankan `MIGRASI.md` | <!-- [multi-app] --> <!-- [migrasi] -->
| Id | Task | Prio | Status | Branch | Langkah berikutnya | <!-- [single-app] -->
|---|---|---|---|---|---| <!-- [single-app] -->
| — | Migrasi `docs-old/` ke workflow-kit | P0 | in-progress | `main` | Lead menjalankan `MIGRASI.md` | <!-- [single-app] --> <!-- [migrasi] -->

## Tertahan (`blocked`)
| Id | Task | Prio | Menunggu |
|---|---|---|---|

## Antre (`ready`)
| Id | Task | Prio | Depends on | Catatan |
|---|---|---|---|---|

## Serah terima sesi Lead
<!-- Ditimpa setiap kali sesi Lead berpindah (AGENTS.md "Sesi panjang"), ≤ 10 baris: tanggal, yang sedang dikerjakan, langkah pertama sesi baru. -->
—

## Perlu keputusan pemilik proyek
-

## Finding terbuka
| Id | Judul | Status | Target |
|---|---|---|---|

## Decision
| Id | Judul | Status |
|---|---|---|
| D-H000-01 | Adopsi workflow-kit {{VERSI_KIT}} | accepted |
| D-H000-02 | Migrasi alur kerja lama (`docs-old/`) ke workflow-kit | accepted | <!-- [migrasi] -->

## Selesai (`closed`)
<!-- Hanya 10 baris terakhir; yang lebih lama dipindah ke INDEX-arsip.md (LEAD.md §5). -->
| Id | Task | Catatan penutupan |
|---|---|---|
