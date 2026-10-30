<#
  Pasang workflow-kit ke sebuah repo proyek. Tidak menimpa berkas yang sudah ada.

    .\scripts\install.ps1 -Target D:\repo\proyek -Nama "Nama Proyek" -Repo owner/repo -Pemilik "Nama" [-Apps a,b,c] [-Migrasi]

  Tanpa -Apps: mode satu aplikasi. Dengan -Apps: multi-aplikasi (docs\apps\<app>\APP.md per aplikasi).
  -Migrasi: repo punya alur kerja lama yang sudah dipindah ke docs-old\ (git mv docs docs-old); ditambah docs\MIGRASI.md.
#>
param(
  [Parameter(Mandatory)][string]$Target,
  [Parameter(Mandatory)][string]$Nama,
  [Parameter(Mandatory)][string]$Repo,
  [Parameter(Mandatory)][string]$Pemilik,
  [string[]]$Apps = @(),
  [switch]$Migrasi
)
$ErrorActionPreference = 'Stop'
function Gagal([string]$Pesan) { Write-Host "GAGAL: $Pesan" -ForegroundColor Red; exit 1 }

$Kit = Split-Path -Parent $PSScriptRoot
$Versi = (Get-Content (Join-Path $Kit 'VERSION') -Raw).Trim()
if (-not (Test-Path $Target -PathType Container)) { Gagal "folder tidak ditemukan: $Target (clone repo-nya dulu)" }
$Target = (Resolve-Path $Target).Path
if (-not (Test-Path (Join-Path $Target '.git'))) { Gagal "bukan repo git: $Target" }

# --- Deteksi keadaan repo -------------------------------------------------------------------------------------------
$KitAda = Test-Path (Join-Path $Target 'docs\decisions\D-H000-01_adopsi-workflow-kit_*')
$Lama = ''
if (-not $KitAda -and (Test-Path (Join-Path $Target 'docs'))) {
  if (Test-Path (Join-Path $Target 'docs\handoff')) { $Lama = 'docs/handoff/' }
  else {
    $idx = Get-ChildItem (Join-Path $Target 'docs') -Recurse -Filter INDEX.md -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($idx) { $Lama = $idx.FullName.Substring($Target.Length + 1) }
  }
}
if ($KitAda -and $Migrasi) { Gagal 'workflow-kit sudah terpasang; -Migrasi hanya untuk pemasangan pertama.' }
if ($Lama) {
  Gagal ("repo sudah punya alur kerja lama di docs/ (mis. $Lama). Pindahkan dulu lalu pasang ulang dengan -Migrasi:`n" +
         "    git -C `"$Target`" mv docs docs-old; git -C `"$Target`" commit -m `"H000: pindahkan alur kerja lama ke docs-old`"")
}
if ($Migrasi -and -not (Test-Path (Join-Path $Target 'docs-old'))) { Gagal '-Migrasi butuh folder docs-old\ (git mv docs docs-old).' }
$V1 = @('PLAN_*.md','progress_*.md','PROGRESS*.md','KEPUTUSAN_*.md','SKILL_*.md','GUIDELINES_*.md','agent_*') |
  ForEach-Object { Get-ChildItem (Join-Path $Target $_) -ErrorAction SilentlyContinue } | ForEach-Object { $_.Name }

# --- Mode & isian -----------------------------------------------------------------------------------------------------
$Apps = @($Apps | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ })
$Mode = if ($Apps.Count -gt 0) { 'multi' } else { 'single' }
$Drop = @()
if ($Mode -eq 'multi') { $Drop += 'single-app' } else { $Drop += 'multi-app' }
if ($Migrasi) { $Drop += 'tanpa-migrasi' } else { $Drop += 'migrasi' }
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
function SalinDari([string]$Sumber) {
  Get-ChildItem $Sumber -Recurse -File -Force | Sort-Object FullName | ForEach-Object {
    $rel = $_.FullName.Substring($Sumber.Length + 1).Replace('\', '/')
    if ($rel -like 'docs/apps/_contoh/*') { return }
    $relDst = $rel.Replace('{{TS}}', $Ts)
    $dst = Join-Path $Target $relDst
    $adaD = $false
    if ($rel -match '^docs/decisions/(D-H000-0\d)_') { $adaD = Test-Path (Join-Path $Target ("docs/decisions/" + $Matches[1] + "_*")) }
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
$label = $Mode; if ($Migrasi) { $label += ', migrasi' }
Write-Host "workflow-kit $Versi (mode $label): $($script:dibuat) berkas dibuat, $($script:dilewati) dilewati."
if ($Mode -eq 'multi') {
  Write-Host 'Berikutnya: isi docs/PROJECT.md dan docs/apps/*/APP.md serta .worktree-copy, lalu commit.'
  Write-Host 'Menambah aplikasi ke proyek yang sudah terpasang? Tambahkan juga barisnya di docs/PROJECT.md bagian 1a.'
} else {
  Write-Host 'Berikutnya: isi docs/PROJECT.md serta .worktree-copy, lalu commit.'
}
if ($Migrasi) { Write-Host 'Migrasi: commit hasil pemasangan, lalu minta sesi Lead menjalankan docs/MIGRASI.md.' }
if ($V1) { Write-Host ("Catatan: berkas alur kerja v1 di root: " + ($V1 -join ' ') + " - pindahkan ke docs-old/v1/ dengan git mv (lihat docs/MIGRASI.md).") }
