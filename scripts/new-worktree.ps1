<#
  Siapkan worktree untuk satu item kerja agar sesi Developer/QA bisa berjalan paralel.

    .\scripts\new-worktree.ps1 H027 [-Branch h027-layout-360]

  Jalankan dari dalam repo proyek (path skrip boleh absolut, mis. D:\workflow-kit\scripts\new-worktree.ps1).
  Branch diambil dari frontmatter `branch:` di docs\dev-handoff\H027_*.md bila tidak diberikan.
  Folder: ..\<nama-repo>-h027. Berkas/folder di .worktree-copy disalin dari checkout utama.
#>
param(
  [Parameter(Mandatory, Position = 0)][string]$Id,
  [string]$Branch = ''
)
$ErrorActionPreference = 'Stop'
$Id = $Id.ToUpper()
if ($Id -notmatch '^H?(\d{3})$') { throw "Id tidak valid: $Id (contoh: H027)" }
$Nnn = $Matches[1]; $Id = "H$Nnn"
$Root = (git rev-parse --show-toplevel).Trim().Replace('/', '\')
$NamaRepo = Split-Path -Leaf $Root
$Wt = Join-Path (Split-Path -Parent $Root) "$NamaRepo-h$Nnn"

if (-not $Branch) {
  $handoff = Get-ChildItem (Join-Path $Root 'docs\dev-handoff') -Filter "${Id}_*.md" -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $handoff) { throw "Dev handoff $Id tidak ditemukan; sebutkan -Branch." }
  $baris = Select-String -Path $handoff.FullName -Pattern '^branch:\s*([^\s#]+)' | Select-Object -First 1
  if (-not $baris) { throw "Frontmatter branch: kosong di $($handoff.Name); sebutkan -Branch." }
  $Branch = $baris.Matches[0].Groups[1].Value
}
if (Test-Path $Wt) { throw "Folder sudah ada: $Wt" }

git -C $Root fetch -q origin
git -C $Root show-ref -q --verify "refs/remotes/origin/$Branch"
if ($LASTEXITCODE -eq 0) {
  git -C $Root worktree add -B $Branch $Wt "origin/$Branch"
} else {
  Write-Host "Branch $Branch belum ada di origin; dibuat dari origin/main."
  git -C $Root worktree add -b $Branch $Wt origin/main
}
if ($LASTEXITCODE -ne 0) { throw 'git worktree add gagal.' }

$daftar = Join-Path $Root '.worktree-copy'
if (Test-Path $daftar) {
  Get-Content $daftar | Where-Object { $_.Trim() -and -not $_.Trim().StartsWith('#') } | ForEach-Object {
    $p = $_.Trim(); $src = Join-Path $Root $p; $dst = Join-Path $Wt $p
    if ((Test-Path $src) -and -not (Test-Path $dst)) {
      if ((Get-Item $src).PSIsContainer) {
        robocopy $src $dst /E /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy gagal menyalin $p" }
      } else {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
        Copy-Item $src $dst
      }
      Write-Host "  salin: $p"
    }
  }
}

Write-Host ''
Write-Host "Worktree siap: $Wt (branch $Branch)"
Write-Host "Saran untuk QA: DB qa_$Id, port 8$Nnn (lihat docs\PROJECT.md bagian 4)."
Write-Host "Hapus setelah item ditutup: git worktree remove --force `"$Wt`"; git branch -D $Branch"
