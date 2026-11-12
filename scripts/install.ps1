<#
  Pasang workflow-kit ke sebuah repo proyek. Tidak menimpa berkas yang sudah ada.

    .\scripts\install.ps1 -Target D:\repo\proyek -Nama "Nama Proyek" -Repo owner/repo -Pemilik "Nama" [-Apps a,b,c] [-Migrasi | -Upgrade | -Adopsi]

  Tanpa -Apps: mode satu aplikasi. Dengan -Apps: multi-aplikasi (docs\apps\<app>\APP.md per aplikasi).
  -Migrasi: repo punya alur kerja lama yang sudah dipindah ke docs-old\ (git mv docs docs-old); ditambah docs\MIGRASI.md.
  -Upgrade: kit sudah terpasang; timpa HANYA berkas generik kit (AGENTS/CLAUDE, file peran, _templates, scripts\workflow),
            buat berkas baru yang belum ada, dan catat decision upgrade. Berkas milik proyek tidak disentuh.
  -Adopsi:  seperti -Upgrade, untuk repo yang struktur docs\-nya SUDAH seperti kit (INDEX.md, dev-handoff\) tetapi
            tidak dipasang lewat installer (mis. repo asal kit). Decision adopsi diberi nomor D-H000 berikutnya.
#>
param(
  [Parameter(Mandatory)][string]$Target,
  [Parameter(Mandatory)][string]$Nama,
  [Parameter(Mandatory)][string]$Repo,
  [Parameter(Mandatory)][string]$Pemilik,
  [string[]]$Apps = @(),
  [switch]$Migrasi,
  [switch]$Upgrade,
  [switch]$Adopsi
)
$ErrorActionPreference = 'Stop'
function Gagal([string]$Pesan) { Write-Host "GAGAL: $Pesan" -ForegroundColor Red; exit 1 }

$Kit = Split-Path -Parent $PSScriptRoot
$Versi = (Get-Content (Join-Path $Kit 'VERSION') -Raw).Trim()
if (-not (Test-Path $Target -PathType Container)) { Gagal "folder tidak ditemukan: $Target (clone repo-nya dulu)" }
$Target = (Resolve-Path $Target).Path
if (-not (Test-Path (Join-Path $Target '.git'))) { Gagal "bukan repo git: $Target" }

# --- Deteksi keadaan repo -------------------------------------------------------------------------------------------
$KitAda = Test-Path (Join-Path $Target 'docs\decisions\D-H000-*_adopsi-workflow-kit_*')
if ($Adopsi) {
  if ($KitAda) { Gagal 'workflow-kit sudah terpasang; pakai -Upgrade.' }
  if (-not ((Test-Path (Join-Path $Target 'docs\INDEX.md')) -and (Test-Path (Join-Path $Target 'docs\dev-handoff')))) {
    Gagal '-Adopsi butuh docs\INDEX.md dan docs\dev-handoff\ (struktur kit); repo lain pakai -Migrasi.'
  }
  $KitAda = $true; $Upgrade = [switch]::Present
}
$Lama = ''
if (-not $KitAda -and (Test-Path (Join-Path $Target 'docs'))) {
  if (Test-Path (Join-Path $Target 'docs\handoff')) { $Lama = 'docs/handoff/' }
  else {
    $idx = Get-ChildItem (Join-Path $Target 'docs') -Recurse -Filter INDEX.md -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($idx) { $Lama = $idx.FullName.Substring($Target.Length + 1) }
  }
}
if ($KitAda -and $Migrasi) { Gagal 'workflow-kit sudah terpasang; -Migrasi hanya untuk pemasangan pertama.' }
if ($Lama -and (Test-Path (Join-Path $Target 'docs\INDEX.md')) -and (Test-Path (Join-Path $Target 'docs\dev-handoff'))) {
  Gagal 'docs\ sudah berstruktur seperti kit (INDEX.md, dev-handoff\) tetapi tidak dipasang lewat installer: pakai -Adopsi.'
}
if ($Lama) {
  Gagal ("repo sudah punya alur kerja lama di docs/ (mis. $Lama). Pindahkan dulu lalu pasang ulang dengan -Migrasi:`n" +
         "    git -C `"$Target`" mv docs docs-old; git -C `"$Target`" commit -m `"H000: pindahkan alur kerja lama ke docs-old`"")
}
$MigrasiAktif = [bool]$Migrasi
$VersiLama = ''
if ($Upgrade) {
  if (-not $KitAda) { Gagal '-Upgrade butuh workflow-kit yang sudah terpasang (docs\decisions\D-H000-*_adopsi-workflow-kit_*); repo asal kit: -Adopsi.' }
  if ($Migrasi) { Gagal '-Upgrade dan -Migrasi tidak bisa dipakai bersamaan.' }
  if (git -C $Target status --porcelain) { Gagal 'working tree belum bersih; commit/stash dulu supaya hasil upgrade bisa ditinjau dengan git diff.' }
  if (Test-Path (Join-Path $Target 'docs\MIGRASI.md')) { $MigrasiAktif = $true }
  if ($Apps.Count -eq 0 -and (Test-Path (Join-Path $Target 'docs\apps'))) { $Apps = @(Get-ChildItem (Join-Path $Target 'docs\apps') -Directory | ForEach-Object { $_.Name }) }
  $rd = Join-Path $Target 'docs\README.md'
  if (Test-Path $rd) { $mm = Select-String -Path $rd -Pattern '\*\*workflow-kit ([0-9.]+)\*\*' | Select-Object -First 1; if ($mm) { $VersiLama = $mm.Matches[0].Groups[1].Value } }
}
if ($Migrasi -and -not (Test-Path (Join-Path $Target 'docs-old'))) { Gagal '-Migrasi butuh folder docs-old\ (git mv docs docs-old).' }
$V1 = @('PLAN_*.md','progress_*.md','PROGRESS*.md','KEPUTUSAN_*.md','SKILL_*.md','GUIDELINES_*.md','agent_*') |
  ForEach-Object { Get-ChildItem (Join-Path $Target $_) -ErrorAction SilentlyContinue } | ForEach-Object { $_.Name }

# --- Mode & isian -----------------------------------------------------------------------------------------------------
$Apps = @($Apps | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ })
$Mode = if ($Apps.Count -gt 0) { 'multi' } else { 'single' }
$Drop = @()
if ($Mode -eq 'multi') { $Drop += 'single-app' } else { $Drop += 'multi-app' }
if ($MigrasiAktif) { $Drop += 'tanpa-migrasi' } else { $Drop += 'migrasi' }
try { $wib = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::UtcNow, 'SE Asia Standard Time') }
catch { $wib = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::UtcNow, 'Asia/Jakarta') }
$Tanggal = $wib.ToString('yyyy-MM-dd HH:mm') + ' WIB'
$Ts = $wib.ToString('yyyyMMdd-HHmm')
$Utf8 = New-Object System.Text.UTF8Encoding $false
$BarisApp = ($Apps | ForEach-Object { "| $_ | <!-- folder kode --> | ``apps/$_/APP.md`` | <!-- aktif / direncanakan --> |" }) -join "`n"

# Proses penanda <!-- [tag] --> / # [tag] dan placeholder pada isi satu berkas .md (hasil LF).
function Olah([string]$Teks) {
  $Teks = $Teks.Replace("`r`n", "`n")
  $evBlok = [System.Text.RegularExpressions.MatchEvaluator] { param($m) if ($Drop -contains $m.Groups[1].Value) { '' } else { $m.Groups[2].Value } }
  $Teks = [regex]::Replace($Teks, '(?ms)^<!-- \[([a-z-]+)\] -->\n(.*?)^<!-- \[/\1\] -->\n', $evBlok)
  $Teks = [regex]::Replace($Teks, '<!-- \[([a-z-]+)\] -->(.*?)<!-- \[/\1\] -->', $evBlok)
  $hasil = New-Object System.Collections.Generic.List[string]
  foreach ($l in ($Teks -split "`n")) {
    $tag = @([regex]::Matches($l, '(?:<!-- |# )\[([a-z-]+)\]') | ForEach-Object { $_.Groups[1].Value })
    if (@($tag | Where-Object { $Drop -contains $_ }).Count -gt 0) { continue }
    $l = [regex]::Replace($l, ' ?<!-- \[[a-z-]+\] -->', '')
    $l = [regex]::Replace($l, '# \[[a-z-]+\] ', '# ')
    $hasil.Add($l)
  }
  $Teks = $hasil -join "`n"
  $Teks = $Teks.Replace('| {{BARIS_APP}} |', $BarisApp)
  $Teks = $Teks.Replace('{{NAMA_PROYEK}}', $Nama).Replace('{{REPO}}', $Repo).Replace('{{PEMILIK}}', $Pemilik)
  $Teks = $Teks.Replace('{{VERSI_KIT}}', $Versi).Replace('{{TANGGAL}}', $Tanggal)
  return $Teks
}

$script:dibuat = 0; $script:dilewati = 0
function Generik([string]$rel) { return ($rel -in @('AGENTS.md','CLAUDE.md','docs/README.md','docs/LEAD.md','docs/DEVELOPER.md','docs/QA.md','docs/ARSITEK.md')) -or $rel.StartsWith('docs/_templates/') }
function SalinDari([string]$Sumber) {
  Get-ChildItem $Sumber -Recurse -File -Force | Sort-Object FullName | ForEach-Object {
    $rel = $_.FullName.Substring($Sumber.Length + 1).Replace('\', '/')
    if ($rel -like 'docs/apps/_contoh/*') { return }
    $relDst = $rel.Replace('{{TS}}', $Ts)
    $dst = Join-Path $Target $relDst
    $adaD = $false
    if ($rel -match '^docs/decisions/(D-H000-0\d)_') { $adaD = Test-Path (Join-Path $Target ("docs/decisions/" + $Matches[1] + "_*")) }
    if ($Upgrade -and (Test-Path $dst) -and (Generik $rel)) {
      $baru = if ($rel -like '*.md') { Olah ([System.IO.File]::ReadAllText($_.FullName, $Utf8)) } else { [System.IO.File]::ReadAllText($_.FullName, $Utf8) }
      $lamaIsi = [System.IO.File]::ReadAllText($dst, $Utf8)
      if ($baru -ne $lamaIsi) { [System.IO.File]::WriteAllText($dst, $baru, $Utf8); Write-Host "  perbarui: $relDst"; $script:dibuat++ }
      return
    }
    if ((Test-Path $dst) -or $adaD) { Write-Host "  lewati (sudah ada): $relDst"; $script:dilewati++; return }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
    if ($rel -like '*.md') {
      [System.IO.File]::WriteAllText($dst, (Olah ([System.IO.File]::ReadAllText($_.FullName, $Utf8))), $Utf8)
    } else { Copy-Item $_.FullName $dst }
    Write-Host "  buat: $relDst"; $script:dibuat++
  }
}
SalinDari (Join-Path $Kit 'template')
if ($Migrasi) { SalinDari (Join-Path $Kit 'template-migrasi') }

# Skrip alur kerja di dalam proyek (selalu versi kit terbaru).
New-Item -ItemType Directory -Force -Path (Join-Path $Target 'scripts\workflow') | Out-Null
foreach ($sk in 'check-docs.sh', 'check-docs.ps1', 'new-worktree.sh', 'new-worktree.ps1') {
  $src = Join-Path $Kit "scripts\$sk"; $dst = Join-Path $Target "scripts\workflow\$sk"
  if ((Test-Path $dst) -and ((Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash)) { continue }
  if ((Test-Path $dst) -and -not $Upgrade) { Write-Host "  lewati (sudah ada): scripts/workflow/$sk"; $script:dilewati++; continue }
  $aksi = if (Test-Path $dst) { 'perbarui' } else { 'buat' }
  Copy-Item $src $dst -Force
  Write-Host "  ${aksi}: scripts/workflow/$sk"; $script:dibuat++
}
if ($Upgrade) {
  $nums = @(Get-ChildItem (Join-Path $Target 'docs\decisions') -Filter 'D-H000-*_*' -File | ForEach-Object { if ($_.Name -match '^D-H000-(\d+)_') { [int]$Matches[1] } })
  $nn = '{0:D2}' -f ([int](($nums | Measure-Object -Maximum).Maximum) + 1)
  $lv = if ($VersiLama) { $VersiLama } else { '?' }
  if ($Adopsi) {
    $dst = Join-Path $Target "docs\decisions\D-H000-${nn}_adopsi-workflow-kit_${Ts}.md"
    $isiD = "---`nid: D-H000-$nn`ntype: decision`ntitle: Adopsi workflow-kit $Versi untuk struktur docs yang sudah ada`nhandoff: H000`nstatus: accepted`ncreated: $Tanggal`nproposed_by: Arsitek`ndecided_by: $Pemilik`naccepted_at: $Tanggal`nsupersedes: null`nsuperseded_by: null`nrelated: []`n---`n`n" +
            "# D-H000-$nn - Adopsi workflow-kit $Versi`n`n## Keputusan`nRepo ini sudah memakai struktur docs/ yang sama dengan workflow-kit. Berkas generik kit (AGENTS.md, CLAUDE.md, file peran,`n" +
            "``_templates/``, ``scripts/workflow/``) kini mengikuti workflow-kit $Versi; berkas milik proyek tidak diubah. Pembaruan berikutnya`nlewat installer ``-Upgrade``.`n`n" +
            "## Konsekuensi`nLead mendaftarkan decision ini di ``INDEX.md`` dan melengkapi ``PROJECT.md`` dengan bagian kit yang belum ada.`n"
  } else {
  $dst = Join-Path $Target "docs\decisions\D-H000-${nn}_upgrade-workflow-kit-${Versi}_${Ts}.md"
  $isiD = "---`nid: D-H000-$nn`ntype: decision`ntitle: Upgrade workflow-kit ke $Versi`nhandoff: H000`nstatus: accepted`ncreated: $Tanggal`nproposed_by: Arsitek`ndecided_by: $Pemilik`naccepted_at: $Tanggal`nsupersedes: null`nsuperseded_by: null`nrelated: [D-H000-01]`n---`n`n" +
          "# D-H000-$nn - Upgrade workflow-kit ke $Versi`n`n## Keputusan`nBerkas generik kit (AGENTS.md, CLAUDE.md, file peran, ``_templates/``, ``scripts/workflow/``) diperbarui dari versi $lv ke $Versi.`n" +
          "Berkas milik proyek tidak diubah. Perubahan aturan: lihat CHANGELOG workflow-kit $Versi.`n`n## Konsekuensi`nLead mendaftarkan decision ini di ``INDEX.md`` dan menyesuaikan ``PROJECT.md`` bila CHANGELOG meminta bagian baru.`n"
  }
  [System.IO.File]::WriteAllText($dst, $isiD, $Utf8)
  Write-Host "  buat: docs/decisions/$(Split-Path -Leaf $dst)"; $script:dibuat++
}

foreach ($app in $Apps) {
  $dst = Join-Path $Target "docs/apps/$app/APP.md"
  if (Test-Path $dst) { Write-Host "  lewati (sudah ada): docs/apps/$app/APP.md"; $script:dilewati++; continue }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
  $teks = [System.IO.File]::ReadAllText((Join-Path $Kit 'template/docs/apps/_contoh/APP.md'), $Utf8).Replace("`r`n", "`n").Replace('<app>', $app)
  [System.IO.File]::WriteAllText($dst, $teks, $Utf8)
  Write-Host "  buat: docs/apps/$app/APP.md"; $script:dibuat++
}

$wc = Join-Path $Target '.worktree-copy'
if (-not (Test-Path $wc)) {
  [System.IO.File]::WriteAllText($wc, "# Berkas/folder yang disalin dari checkout utama ke worktree baru (scripts/new-worktree), satu per baris.`n# Contoh Laravel:`n# vendor`n# .env`n", $Utf8)
  Write-Host '  buat: .worktree-copy'; $script:dibuat++
}

Write-Host ''
$label = $Mode; if ($MigrasiAktif) { $label += ', migrasi' }; if ($Adopsi) { $label += ', adopsi' } elseif ($Upgrade) { $label += ', upgrade' }
Write-Host "workflow-kit $Versi (mode $label): $($script:dibuat) berkas dibuat/diperbarui, $($script:dilewati) dilewati."
if ($Upgrade) { Write-Host 'Upgrade: tinjau git diff, sesuaikan docs/PROJECT.md bila CHANGELOG meminta bagian baru, lalu commit.' }
if ($Mode -eq 'multi') {
  Write-Host 'Berikutnya: isi docs/PROJECT.md dan docs/apps/*/APP.md serta .worktree-copy, lalu commit.'
  Write-Host 'Menambah aplikasi ke proyek yang sudah terpasang? Tambahkan juga barisnya di docs/PROJECT.md bagian 1a.'
} else {
  Write-Host 'Berikutnya: isi docs/PROJECT.md serta .worktree-copy, lalu commit.'
}
if ($Migrasi) { Write-Host 'Migrasi: commit hasil pemasangan, lalu minta sesi Lead menjalankan docs/MIGRASI.md.' }
if ($V1) { Write-Host ("Catatan: berkas alur kerja v1 di root: " + ($V1 -join ' ') + " - pindahkan ke docs-old/v1/ dengan git mv (lihat docs/MIGRASI.md).") }
