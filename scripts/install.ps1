<#
  Pasang workflow-kit ke sebuah repo proyek. Tidak menimpa berkas yang sudah ada.

    .\scripts\install.ps1 -Target D:\repo\proyek -Nama "Nama Proyek" -Repo owner/repo -Pemilik "Nama" [-Apps produksi,gis,darkroom]

  Tanpa -Apps: mode satu aplikasi. Dengan -Apps: mode multi-aplikasi, dibuat docs\apps\<app>\APP.md per aplikasi.
#>
param(
  [Parameter(Mandatory)][string]$Target,
  [Parameter(Mandatory)][string]$Nama,
  [Parameter(Mandatory)][string]$Repo,
  [Parameter(Mandatory)][string]$Pemilik,
  [string[]]$Apps = @()
)
$ErrorActionPreference = 'Stop'
$Kit = Split-Path -Parent $PSScriptRoot
$Versi = (Get-Content (Join-Path $Kit 'VERSION') -Raw).Trim()
$Target = (Resolve-Path $Target).Path
if (-not (Test-Path (Join-Path $Target '.git'))) { throw "Bukan repo git: $Target" }

$Apps = @($Apps | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ })
$Mode = if ($Apps.Count -gt 0) { 'multi' } else { 'single' }
try { $wib = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::UtcNow, 'SE Asia Standard Time') }
catch { $wib = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::UtcNow, 'Asia/Jakarta') }
$Tanggal = $wib.ToString('yyyy-MM-dd HH:mm') + ' WIB'
$Ts = $wib.ToString('yyyyMMdd-HHmm')
$Utf8 = New-Object System.Text.UTF8Encoding $false
$BarisApp = ($Apps | ForEach-Object { "| $_ | <!-- folder kode --> | ``apps/$_/APP.md`` | <!-- aktif / direncanakan --> |" }) -join "`n"

function Olah([string]$Teks) {
  if ($Mode -eq 'single') {
    $Teks = [regex]::Replace($Teks, '<!-- \[multi-app\] -->.*?<!-- \[/multi-app\] -->', '')
    $Teks = [regex]::Replace($Teks, '(?ms)^<!-- \[multi-app\] -->\n.*?^<!-- \[/multi-app\] -->\n', '')
    $Teks = (($Teks -split "`n") | Where-Object { $_ -notmatch '\[multi-app\]' }) -join "`n"
    $Teks = [regex]::Replace($Teks, ' ?<!-- \[single-app\] -->', '')
  } else {
    $Teks = (($Teks -split "`n") | Where-Object { $_ -notmatch '^<!-- \[/?multi-app\] -->$' -and $_ -notmatch '\[single-app\]' }) -join "`n"
    $Teks = [regex]::Replace($Teks, '<!-- \[/?multi-app\] -->', '')
    $Teks = [regex]::Replace($Teks, '(?m)\|[ ]+$', '|')
    $Teks = $Teks.Replace('# [multi-app] ', '# ')
  }
  $Teks = $Teks.Replace('| {{BARIS_APP}} |', $BarisApp)
  $Teks = $Teks.Replace('{{NAMA_PROYEK}}', $Nama).Replace('{{REPO}}', $Repo).Replace('{{PEMILIK}}', $Pemilik)
  $Teks = $Teks.Replace('{{VERSI_KIT}}', $Versi).Replace('{{TANGGAL}}', $Tanggal)
  return $Teks
}

$dibuat = 0; $dilewati = 0
$Sumber = Join-Path $Kit 'template'
Get-ChildItem $Sumber -Recurse -File -Force | Sort-Object FullName | ForEach-Object {
  $rel = $_.FullName.Substring($Sumber.Length + 1).Replace('\', '/')
  if ($rel -like 'docs/apps/_contoh/*') { return }
  $relDst = $rel.Replace('{{TS}}', $Ts)
  $dst = Join-Path $Target $relDst
  $adaD1 = ($rel -like 'docs/decisions/D-H000-01_*') -and (Test-Path (Join-Path $Target 'docs/decisions/D-H000-01_*'))
  if ((Test-Path $dst) -or $adaD1) { Write-Host "  lewati (sudah ada): $relDst"; $script:dilewati++; return }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
  if ($rel -like '*.md') {
    $teks = [System.IO.File]::ReadAllText($_.FullName, $Utf8)
    [System.IO.File]::WriteAllText($dst, (Olah $teks), $Utf8)
  } else { Copy-Item $_.FullName $dst }
  Write-Host "  buat: $relDst"; $script:dibuat++
}

foreach ($app in $Apps) {
  $dst = Join-Path $Target "docs/apps/$app/APP.md"
  if (Test-Path $dst) { Write-Host "  lewati (sudah ada): docs/apps/$app/APP.md"; $dilewati++; continue }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
  $teks = [System.IO.File]::ReadAllText((Join-Path $Sumber 'docs/apps/_contoh/APP.md'), $Utf8).Replace('<app>', $app)
  [System.IO.File]::WriteAllText($dst, $teks, $Utf8)
  Write-Host "  buat: docs/apps/$app/APP.md"; $dibuat++
}

$wc = Join-Path $Target '.worktree-copy'
if (-not (Test-Path $wc)) {
  [System.IO.File]::WriteAllText($wc, "# Berkas/folder yang disalin dari checkout utama ke worktree baru (scripts/new-worktree), satu per baris.`n# Contoh Laravel:`n# vendor`n# .env`n", $Utf8)
  Write-Host '  buat: .worktree-copy'; $dibuat++
}

Write-Host ''
Write-Host "workflow-kit $Versi (mode $Mode): $dibuat berkas dibuat, $dilewati dilewati."
if ($Mode -eq 'multi') {
  Write-Host 'Berikutnya: isi docs/PROJECT.md dan docs/apps/*/APP.md serta .worktree-copy, lalu commit.'
  Write-Host 'Menambah aplikasi ke proyek yang sudah terpasang? Tambahkan juga barisnya di docs/PROJECT.md bagian 1a.'
} else {
  Write-Host 'Berikutnya: isi docs/PROJECT.md serta .worktree-copy, lalu commit.'
}
