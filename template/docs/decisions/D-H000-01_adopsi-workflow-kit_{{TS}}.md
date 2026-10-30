---
id: D-H000-01
type: decision
title: Adopsi workflow-kit {{VERSI_KIT}} (Lead–Developer–QA, model git satu pemilik)
handoff: H000
status: accepted
created: {{TANGGAL}}
proposed_by: Arsitek
decided_by: {{PEMILIK}}
accepted_at: {{TANGGAL}}
waiting_on: null
supersedes: null
superseded_by: null
related: []
---

# D-H000-01 — Adopsi workflow-kit {{VERSI_KIT}}

## Keputusan
Proyek ini memakai alur kerja dari workflow-kit {{VERSI_KIT}} (`https://github.com/herlambangharyoputro/workflow-kit`):
peran Lead, Developer, QA, dan Arsitek; dokumen di `docs/`; model git satu pemilik (`docs/README.md` §5).
Hal khusus proyek dicatat di `docs/PROJECT.md`<!-- [multi-app] --> dan `docs/apps/<app>/APP.md`<!-- [/multi-app] -->.

## Konsekuensi
- Pembaruan ke versi kit berikutnya dikerjakan sesi Arsitek sebagai decision `D-H000-<nn>` baru.
- Penyimpangan dari aturan kit yang khusus proyek ini ditulis sebagai decision, bukan dengan menyunting file peran diam-diam.
