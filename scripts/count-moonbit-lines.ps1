param(
  [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")),
  [int]$MinimumProductionLines = 8000
)

$sourceRoots = @(
  (Join-Path $ProjectRoot "src"),
  (Join-Path $ProjectRoot "cmd")
)

$files = @(
  Get-ChildItem -LiteralPath $sourceRoots -Recurse -File -Filter "*.mbt" |
    Where-Object {
      $_.Name -notlike "*_test.mbt" -and
      $_.Name -notlike "*_wbtest.mbt" -and
      $_.Name -notlike "deprecated.mbt"
    }
)

$effectiveLines = 0
foreach ($file in $files) {
  foreach ($line in Get-Content -LiteralPath $file.FullName) {
    $trimmed = $line.Trim()
    if ($trimmed.Length -eq 0) { continue }
    if ($trimmed.StartsWith("//")) { continue }
    $effectiveLines++
  }
}

Write-Output ("MoonBit production files: {0}" -f $files.Count)
Write-Output ("MoonBit effective production lines: {0}" -f $effectiveLines)

if ($effectiveLines -lt $MinimumProductionLines) {
  Write-Error ("Production source is below the required minimum of {0} effective lines." -f $MinimumProductionLines)
  exit 1
}
