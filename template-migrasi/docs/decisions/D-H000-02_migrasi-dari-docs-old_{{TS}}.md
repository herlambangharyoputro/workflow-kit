---
id: D-H000-02
type: decision
title: Migrasi alur kerja lama (docs-old/) ke workflow-kit {{VERSI_KIT}}
handoff: H000
status: accepted
created: {{TANGGAL}}
proposed_by: Arsitek
decided_by: {{PEMILIK}}
accepted_at: {{TANGGAL}}
waiting_on: null
supersedes: null
superseded_by: null
related: [D-H000-01]
---

# D-H000-02 — Migrasi dari docs-old/

## Konteks
Repo ini sudah memakai alur kerja lama sebelum workflow-kit. Memasang kit di atasnya akan menghasilkan dua sistem aktif
(dua INDEX, dua LEAD) yang dibaca sesi Claude Code secara bergantian.

## Keputusan
1. `docs/` lama dipindah utuh ke `docs-old/` (dan berkas alur kerja v1 di root ke `docs-old/v1/`) dengan `git mv`, lalu kit dipasang.
2. Lead menjalankan `docs/MIGRASI.md`: hanya yang masih hidup ditulis ulang (item aktif, finding & asumsi terbuka, decision berlaku);
   riwayat selesai cukup dicatat di tabel Peta. Id baru melanjutkan dari nomor main lama tertinggi; id lama dicatat di `legacy_id`.
3. `docs-old/` dihapus saat checklist migrasi selesai; isinya tetap tersedia di riwayat git (hash dicatat di INDEX).

## Konsekuensi
Selama migrasi, `docs-old/` hanya bahan bacaan Lead; `AGENTS.md` memuat peringatan agar sesi lain tidak mengikuti aturannya.
