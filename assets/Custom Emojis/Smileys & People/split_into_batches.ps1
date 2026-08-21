# Splits all files in this folder into "Batch NN" subfolders of at most $BatchSize files each.
# Originals are copied (not moved) - nothing in this folder is deleted except any leftover
# "Batch *" subfolders from a previous run of this script, which get cleared and rebuilt fresh.

$Source = $PSScriptRoot   # the folder this script is sitting in
$BatchSize = 99

Write-Host "Source folder: $Source"

# Clear out any old "Batch *" folders from a previous run, so numbering stays clean
$oldBatches = Get-ChildItem -Path $Source -Directory -Filter "Batch *" -ErrorAction SilentlyContinue
if ($oldBatches) {
    Write-Host "Removing $($oldBatches.Count) existing 'Batch *' folder(s) from a previous run..."
    $oldBatches | Remove-Item -Recurse -Force
}

# Only files directly in this folder (ignores subfolders, so it won't re-scan its own output)
$files = Get-ChildItem -Path $Source -File | Sort-Object Name

$total = $files.Count
if ($total -eq 0) {
    Write-Host "No files found directly in $Source - nothing to do."
    exit
}
Write-Host "Found $total files. Splitting into batches of $BatchSize..."

$batchNum = 1
for ($i = 0; $i -lt $total; $i += $BatchSize) {
    $endIndex = [Math]::Min($i + $BatchSize - 1, $total - 1)
    $batchFiles = $files[$i..$endIndex]
    $batchFolderName = "Batch {0:D2}" -f $batchNum
    $batchPath = Join-Path $Source $batchFolderName
    New-Item -ItemType Directory -Path $batchPath -Force | Out-Null

    foreach ($f in $batchFiles) {
        Copy-Item -Path $f.FullName -Destination $batchPath -Force
    }

    Write-Host ("{0}: {1} files" -f $batchFolderName, $batchFiles.Count)
    $batchNum++
}

$batchCount = $batchNum - 1
Write-Host ""
Write-Host "Done. Created $batchCount batch folder(s) covering $total files."
Write-Host "Press Enter to close..."
Read-Host | Out-Null