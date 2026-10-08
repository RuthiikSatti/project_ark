# ARK Service Recovery
# Safely attempts to recover Nextcloud and MariaDB.

$ServicesPath = "C:\ARK\services"

$NotificationScript = "C:\ARK\scripts\send-notification.ps1"

# 1. Make sure ARK Storage exists
if (-not (Test-Path "D:\Services\Nextcloud") -or
    -not (Test-Path "D:\Services\Database")) {

    Write-Host "[ABORT] ARK Storage is unavailable."
    exit 1
}

Write-Host "[OK] ARK Storage is available."

# 2. Make sure Docker is available
docker info *> $null

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ABORT] Docker is unavailable."
    exit 1
}

Write-Host "[OK] Docker is available."

# 3. Move to Compose directory
Set-Location $ServicesPath

# 4. Check MariaDB
docker compose exec -T database mariadb-admin ping --silent *> $null

if ($LASTEXITCODE -ne 0) {

    Write-Host "[RECOVERY] MariaDB is not responding. Restarting database..."

    docker compose restart database

    Start-Sleep -Seconds 15

    docker compose exec -T database mariadb-admin ping --silent *> $null

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[FAIL] MariaDB recovery failed."
        exit 1
    }

    Write-Host "[RECOVERED] MariaDB is responding."
}
else {
    Write-Host "[OK] MariaDB is responding."
}

# 5. Check Nextcloud container
$RunningServices = docker compose ps --status running --services

if ($RunningServices -notcontains "nextcloud") {

    Write-Host "[RECOVERY] Nextcloud container is stopped. Starting Nextcloud..."

    docker compose up -d nextcloud

    Start-Sleep -Seconds 15
}

# 6. Check actual Nextcloud web service
curl.exe -s -f http://localhost:8081/status.php > $null

if ($LASTEXITCODE -ne 0) {

    Write-Host "[RECOVERY] Nextcloud web service is not responding. Restarting Nextcloud..."

    docker compose restart nextcloud

    Start-Sleep -Seconds 15

    curl.exe -s -f http://localhost:8081/status.php > $null

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[FAIL] Nextcloud recovery failed."
        exit 1
    }

    Write-Host "[RECOVERED] Nextcloud web service recovered."
}
else {
    Write-Host "[OK] Nextcloud web service is responding."
}

Write-Host "[SUCCESS] ARK services are healthy."

powershell.exe -NoProfile -ExecutionPolicy Bypass -File $NotificationScript -Message "[RECOVERED] ARK automatically recovered its services."
exit 0