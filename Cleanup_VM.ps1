# Requires Administrator privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as an Administrator!"
    break
}

# ---------------------------------------------------------
# 1. Delete Temp Folders
# ---------------------------------------------------------
Write-Host "[1/5] Cleaning Temp folders..." -ForegroundColor Cyan
$tempFolders = @($env:TEMP, "$env:SystemRoot\Temp")

foreach ($folder in $tempFolders) {
    if (Test-Path $folder) {
        # Silently continue on errors because some temp files will be in use by Windows
        Remove-Item -Path "$folder\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "Temp folders cleaned." -ForegroundColor Green

# ---------------------------------------------------------
# 2. Clean the Recycle Bin
# ---------------------------------------------------------
Write-Host "`n[2/5] Emptying the Recycle Bin..." -ForegroundColor Cyan
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Host "Recycle Bin emptied." -ForegroundColor Green

# ---------------------------------------------------------
# 3. Defragment the Disk (C: Drive)
# ---------------------------------------------------------
Write-Host "`n[3/5] Defragmenting the C: Drive..." -ForegroundColor Cyan
# Optimize-Volume defragments the drive. We use -Defrag to ensure it performs a standard defrag.
Optimize-Volume -DriveLetter C -Defrag -Verbose
Write-Host "Defragmentation complete." -ForegroundColor Green

# ---------------------------------------------------------
# 4. SDelete: Download, Extract, and Fill Zeros
# ---------------------------------------------------------
Write-Host "`n[4/5] Setting up SDelete..." -ForegroundColor Cyan

$customTempDir = "C:\CustomSDeleteTemp"
$zipPath = "$customTempDir\SDelete.zip"
$sdeleteUrl = "https://download.sysinternals.com/files/SDelete.zip"

# Create Custom Temp Folder
if (Test-Path $customTempDir) { Remove-Item -Path $customTempDir -Recurse -Force }
New-Item -Path $customTempDir -ItemType Directory -Force | Out-Null

# Download SDelete
Write-Host "Downloading SDelete from Sysinternals..."
Invoke-WebRequest -Uri $sdeleteUrl -OutFile $zipPath

# Extract SDelete
Write-Host "Extracting SDelete..."
Expand-Archive -Path $zipPath -DestinationPath $customTempDir -Force

# Determine if the OS is 64-bit to use the correct executable
$sdeleteExe = if ([Environment]::Is64BitOperatingSystem) { "$customTempDir\sdelete64.exe" } else { "$customTempDir\sdelete.exe" }

# Execute SDelete
# -z = Zero free space (good for virtual disk optimization as requested)
# -accepteula = Silently accepts the Sysinternals license agreement
Write-Host "Running SDelete to zero out free space on C: Drive (This may take a while)..." -ForegroundColor Yellow
& $sdeleteExe -z C: -accepteula

Write-Host "Zeroing complete." -ForegroundColor Green

# ---------------------------------------------------------
# 5. Cleanup Custom Temp Folder
# ---------------------------------------------------------
Write-Host "`n[5/5] Cleaning up custom SDelete temp folder..." -ForegroundColor Cyan
Remove-Item -Path $customTempDir -Recurse -Force
Write-Host "Cleanup finished. Script completed successfully!" -ForegroundColor Green