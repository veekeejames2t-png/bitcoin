$paths = @(
  'C:\Users\NKECHI OKOYE\Documents\GitHub\bitcoin\contracts\sip10-trait.clar',
  'C:\Users\NKECHI OKOYE\Documents\GitHub\bitcoin\contracts\bitcoin.clar'
)
foreach ($p in $paths) {
  $raw = Get-Content -Raw -Path $p
  $normalized = $raw -replace "`r`n", "`n"
  [System.IO.File]::WriteAllText($p, $normalized)
}
