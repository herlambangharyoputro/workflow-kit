# ASUMSI — register asumsi & pertanyaan ke pihak luar

> Satu-satunya tempat untuk hal yang **belum pasti**: pertanyaan ke mitra/pengguna beserta jawaban sementara yang dipakai
> selama menunggu. Hanya **Lead** yang menulis file ini. Id berikutnya: **A-001**. Aturan: `docs/LEAD.md` §7.

## Cara membaca
- **Status:** `terbuka` (belum ada jawaban sementara) · `asumsi` (ada jawaban sementara yang dipakai) ·
  `terkonfirmasi` · `dibantah` (jawaban berbeda → decision baru + handoff perubahan).
- **Sumber:** `H<nnn>` = asumsi developer yang disahkan Lead; `<pemilik proyek> (D-…)` = keputusan sementara pemilik proyek
  (decision `provisional`).
- Kode yang bergantung pada sebuah asumsi diberi komentar id-nya (mis. `// A-001`) agar mudah dicari bila jawabannya berbeda.
- Daftar pertanyaan per pihak: saring bagian "Tanya ke" di bawah.

## Tanya ke: <pihak>

| Id | Asumsi / pertanyaan (*yang berlaku sekarang*) | Sumber | Dipakai di | Dampak bila salah | Status | <!-- [single-app] -->
|---|---|---|---|---|---| <!-- [single-app] -->
| Id | App | Asumsi / pertanyaan (*yang berlaku sekarang*) | Sumber | Dipakai di | Dampak bila salah | Status | <!-- [multi-app] -->
|---|---|---|---|---|---|---| <!-- [multi-app] -->
