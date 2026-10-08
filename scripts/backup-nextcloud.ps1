# ARK Nextcloud Backup

$NotificationScript = "C:\ARK\scripts\send-notification.ps1"

# 1. Check ARK Storage
if (-not (Test-Path "D:\Services\Nextcloud\data")) {
    Write-Error "ARK Storage is unavailable. Backup cancelled."

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File $NotificationScript -Message "[BACKUP FAILED] ARK Storage is unavailable. Backup cancelled."

    exit 1
}

# 2. Create timestamped backup folder
$Date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$BackupRoot = "C:\ARK\Backups"
$BackupFolder = "$BackupRoot\$Date"

New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null

# 3. Load database password
Set-Location "C:\ARK\services"

$EnvFile = "C:\ARK\services\.env"
$DbPassword = (Get-Content $EnvFile | Where-Object { $_ -match '^MYSQL_PASSWORD=' }) -replace '^MYSQL_PASSWORD=', ''

# 4. Backup database
docker compose exec -T database mariadb-dump -u nextcloud "-p$DbPassword" nextcloud > "$BackupFolder\nextcloud-db.sql"

$DatabaseBackupOK = (Test-Path "$BackupFolder\nextcloud-db.sql") -and ((Get-Item "$BackupFolder\nextcloud-db.sql").Length -gt 0)

# 5. Backup Nextcloud files
robocopy "D:\Services\Nextcloud\data" "$BackupFolder\nextcloud-files" /E /COPY:DAT /DCOPY:DAT /R:2 /W:2

$RobocopyExitCode = $LASTEXITCODE

# Robocopy exit codes 0-7 are successful.
$FileBackupOK = $RobocopyExitCode -lt 8

# 6. Verify backup
if ($DatabaseBackupOK -and $FileBackupOK) {

    Write-Host "ARK backup completed successfully: $BackupFolder"
    exit 0
}

# 7. Failure notification
if (-not $DatabaseBackupOK) {
    Write-Error "ARK backup failed: database backup is missing or empty."

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File $NotificationScript -Message "[BACKUP FAILED] ARK database backup failed."
}

if (-not $FileBackupOK) {
    Write-Error "ARK backup failed: Nextcloud file copy failed. Robocopy exit code: $RobocopyExitCode"

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File $NotificationScript -Message "[BACKUP FAILED] ARK Nextcloud file backup failed."
}

exit 1