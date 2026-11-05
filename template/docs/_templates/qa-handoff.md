---
id: H000
type: qa-handoff
title: Rencana uji — <judul pekerjaan>
status: ready             # ready | done
created: YYYY-MM-DD HH:MM WIB
author: Lead
tingkat: <menengah|tinggi>   # sebaiknya model berbeda dari developer item ini
effort: <medium|high>
dev_handoff: H000
app: <app|[app1, app2]|shared>   # [multi-app] aplikasi yang tersentuh (docs/apps/)
branch: <branch PR yang diuji>
---

# H000 — Rencana uji: <judul pekerjaan>

## Wajib baca
- `docs/QA.md`
- Dev handoff H000 bagian "Kriteria selesai"; `docs/dev-reports/H000_report.md`; diff PR.

## Kriteria yang diverifikasi
<!-- Rujuk nomor K di dev handoff; tambahkan cara uji bila tidak jelas. Jangan menyalin isinya. -->
| Kriteria | Cara uji / data uji |
|---|---|
| K1 | |

## Matriks peran × aksi (aplikasi `ui`/`api`; hapus bila tidak relevan)
<!-- Kolom = peran aplikasi di docs/PROJECT.md §5, dengan urutan yang sama. -->
| Aksi | <peran 1> | <peran 2> | <peran 3> | … |
|---|---|---|---|---|
| | ✅ | ✅ | 403 | |

## Data uji & metrik (aplikasi `data`; hapus bila tidak relevan)
<!-- Dataset uji (versi/hash), metrik yang dihitung, baseline terakhir + commit-nya, toleransi penurunan, jumlah sampel manual. -->
| Metrik | Baseline (commit) | Toleransi |
|---|---|---|
| | | |

## Regresi
<!-- Modul/halaman lain yang bisa terdampak. -->
-

## Responsif & bukti
<!-- ui: halaman yang wajib dicek di 360/768/1280; data: metrik.md. Disimpan ke publications/_bukti/H000/ bila LULUS. -->
-

## Di luar cakupan uji
-
