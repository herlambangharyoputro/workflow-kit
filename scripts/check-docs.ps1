<#
  Pemeriksaan otomatis alur kerja (workflow-kit). Jalankan dari dalam repo proyek.

    .\scripts\workflow\check-docs.ps1                    # seluruh docs: frontmatter, id, status
    .\scripts\workflow\check-docs.ps1 H027               # + item: branch, file milik Lead, laporan, data/rahasia di diff
    .\scripts\workflow\check-docs.ps1 H027 origin/h027-x # item di ref lain tanpa checkout (untuk Lead)

  Keluar dengan kode 1 bila ada GAGAL.
#>
param([string]$Id = '', [string]$Ref = 'HEAD')
$ErrorActionPreference = 'Continue'
$root = (git rev-parse --show-toplevel).Trim()
Set-Location $root
$script:gagal = 0; $script:peringatan = 0
function G([string]$m) { Write-Host "GAGAL: $m"; $script:gagal++ }
function W([string]$m) { Write-Host "PERINGATAN: $m"; $script:peringatan++ }
function Fm([string]$field, [string[]]$lines) {
  if ($lines.Count -lt 2 -or $lines[0] -ne '---') { return $null }
  for ($i = 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -eq '---') { break }
    if ($lines[$i] -match ("^" + [regex]::Escape($field) + ":\s*([^#]*)")) { return $Matches[1].Trim() }
  }
  return ''
}

# --- 1. Seluruh docs ----------------------------------------------------------------------------------------------
$folders = [ordered]@{
  'docs/dev-handoff' = 'draft ready in-progress qa review closed blocked superseded'
  'docs/qa-handoff'  = 'ready done'
  'docs/findings'    = 'open confirmed resolved superseded'
  'docs/decisions'   = 'proposed accepted provisional superseded'
}
foreach ($dir in $folders.Keys) {
  if (-not (Test-Path $dir)) { continue }
  $valid = $folders[$dir] -split ' '
  $ids = @()
  foreach ($f in Get-ChildItem $dir -Filter *.md -File) {
    $lines = [System.IO.File]::ReadAllLines($f.FullName)
    $rel = "$dir/$($f.Name)"
    if ($lines.Count -eq 0 -or $lines[0] -ne '---') { G "${rel}: tanpa frontmatter"; continue }
    $fid = Fm 'id' $lines
    if (-not $fid) { G "${rel}: field id kosong"; continue }
    if (-not $f.Name.StartsWith("${fid}_")) { G "${rel}: nama file tidak diawali id ($fid)" }
    $st = ((Fm 'status' $lines) -split '\s+')[0]
    if ($valid -notcontains $st) { G "${rel}: status '$st' tidak valid (boleh: $($folders[$dir]))" }
    $ids += $fid
  }
  $ids | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { G "id ganda di ${dir}: $($_.Name)" }
}
$ph = Get-ChildItem docs -Recurse -File -Filter *.md -ErrorAction SilentlyContinue | Select-String -Pattern '\{\{[A-Z_]*\}\}' -List
if ($ph) { W ("placeholder {{...}} tersisa: " + (($ph | ForEach-Object { $_.Path.Substring($root.Length + 1) }) -join ' ')) }

# --- 2. Item ------------------------------------------------------------------------------------------------------
if ($Id) {
  $Id = $Id.ToUpper()
  if ($Id -notmatch '^H?(\d{3})$') { Write-Host "Id tidak valid: $Id"; exit 1 }
  $Id = 'H' + $Matches[1]
  git rev-parse -q --verify "$Ref^{commit}" | Out-Null
  if ($LASTEXITCODE -ne 0) { Write-Host "Ref tidak ditemukan: $Ref"; exit 1 }
  git rev-parse -q --verify origin/main | Out-Null
  if ($LASTEXITCODE -ne 0) { git fetch -q origin main 2>$null }
  $base = (git merge-base origin/main $Ref 2>$null)
  if (-not $base) { $base = (git merge-base main $Ref) }
  $handoff = Get-ChildItem docs/dev-handoff -Filter "${Id}_*.md" -File -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $handoff) { W "dev handoff $Id tidak ada di checkout ini" }
  if ($Ref -eq 'HEAD' -and $handoff) {
    $br = Fm 'branch' ([System.IO.File]::ReadAllLines($handoff.FullName))
    $cur = (git branch --show-current).Trim()
    if ($br -and -not $br.StartsWith('<') -and $br -ne $cur) { G "branch sekarang '$cur', handoff menetapkan '$br'" }
  }
  $names = @(git diff --name-only $base $Ref)
  if ($Ref -eq 'HEAD') { $names += @(git status --porcelain | ForEach-Object { ($_.Substring(3) -split ' -> ')[-1] }) }
  $names = $names | Where-Object { $_ } | Sort-Object -Unique
  $milikLead = '^(docs/INDEX\.md|docs/dev-handoff/|docs/qa-handoff/|docs/findings/|docs/decisions/|docs/requirements/ASUMSI\.md|docs/PROJECT\.md|docs/apps/)'
  $names | Where-Object { $_ -match $milikLead } | ForEach-Object { G "file milik Lead diubah di branch item: $_" }
  $sensitif = '(^|/)(\.env(\..+)?|id\.json|[^/]*keypair[^/]*\.json|[^/]*\.pem|[^/]*\.key)$'
  $names | Where-Object { $_ -match $sensitif -and $_ -notmatch '\.env\.example$' } | ForEach-Object { G "berkas rahasia di diff: $_" }
  foreach ($f in @(git diff --name-only --diff-filter=AM $base $Ref)) {
    if (-not $f) { continue }
    $sz = [int64](git cat-file -s "${Ref}:$f" 2>$null)
    if ($sz -gt 5242880) { G ("berkas besar (> 5 MB) di diff: $f (" + [math]::Round($sz / 1MB) + " MB)") }
  }
  $tambah = git diff -U0 $base $Ref | Where-Object { $_.StartsWith('+') }
  if ($tambah | Select-String -Pattern 'hf_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----' -Quiet) {
    G "pola token/kunci rahasia ditemukan di baris yang ditambahkan (git diff $base $Ref)"
  }
  $adaLaporan = $false
  foreach ($jenis in 'dev', 'qa') {
    $path = "docs/$jenis-reports/${Id}_report.md"
    $isi = @(git show "${Ref}:$path" 2>$null)
    if ($LASTEXITCODE -ne 0 -or $isi.Count -eq 0) {
      if ($Ref -eq 'HEAD' -and (Test-Path $path)) { $isi = [System.IO.File]::ReadAllLines((Join-Path $root $path)) } else { continue }
    }
    $adaLaporan = $true
    $wajib = if ($jenis -eq 'dev') { @('### Ringkasan', '### Kriteria selesai', '### Asumsi pengerjaan') } else { @('### Ringkasan', '### Kriteria', '### Bug') }
    foreach ($h in $wajib) { if (-not ($isi | Where-Object { $_.Contains($h) })) { G "${path}: bagian '$h' tidak ada" } }
    $m = Fm 'model' $isi
    if (-not $m -or $m.StartsWith('<')) { G "${path}: field model: belum diisi" }
  }
  if (-not $adaLaporan) { G "belum ada laporan docs/dev-reports/${Id}_report.md atau docs/qa-reports/${Id}_report.md" }
}

Write-Host ''
if ($script:gagal -gt 0) { Write-Host "check-docs: $($script:gagal) GAGAL, $($script:peringatan) peringatan."; exit 1 }
Write-Host "check-docs: OK ($($script:peringatan) peringatan)."
