# INDEX — status item kerja {{NAMA_PROYEK}}

> Satu-satunya sumber id berikutnya dan status antrean. **Hanya Lead yang mengubah file ini**, langsung di `main`.
> Aturan: `README.md`. Urutan ditentukan prioritas + `depends_on`, bukan nomor id.

## Id berikutnya
- Item kerja: **H001**
- Asumsi: **A-001** (`requirements/ASUMSI.md`)
- Finding/decision: `nn` terbesar di `findings/F-H<nnn>-*` atau `decisions/D-H<nnn>-*` + 1 (belum ada → `01`).
  `H000` = tingkat proyek (terpakai: D-H000-01).

## Sekarang
| Id | App | Task | Prio | Status | Branch | Langkah berikutnya | <!-- [multi-app] -->
|---|---|---|---|---|---|---| <!-- [multi-app] -->
| Id | Task | Prio | Status | Branch | Langkah berikutnya | <!-- [single-app] -->
|---|---|---|---|---|---| <!-- [single-app] -->

## Tertahan (`blocked`)
| Id | Task | Prio | Menunggu |
|---|---|---|---|

## Antre (`ready`)
| Id | Task | Prio | Depends on | Catatan |
|---|---|---|---|---|

## Perlu keputusan pemilik proyek
-

## Finding terbuka
| Id | Judul | Status | Target |
|---|---|---|---|

## Decision
| Id | Judul | Status |
|---|---|---|
| D-H000-01 | Adopsi workflow-kit {{VERSI_KIT}} | accepted |

## Selesai (`closed`)
| Id | Task | Catatan penutupan |
|---|---|---|
