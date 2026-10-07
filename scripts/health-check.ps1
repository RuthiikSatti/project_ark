# ARK Health Check
# Checks core services and triggers recovery when appropriate.

$ServicesPath = "C:\ARK\services"
$RecoveryScript = "C:\ARK\scripts\service-recovery.ps1"
$NotificationScript = "C:\ARK\scripts\send-notification.ps1"
$AlertStateFile = "C:\ARK\scripts\ark-alert.state"

$Healthy = $true
$RecoveryAllowed = $true

# 1. Storage
if ((Test-Path "D:\Services\Nextcloud") -and
    (Test-Path "D:\Services\Database")) {

    Write-Host "[OK] ARK Storage is connected."
}
else {
    Write-Host "[FAIL] ARK Storage is unavailable."
    $Healthy = $false
    $RecoveryAllowed = $false
}

# 2. Docker
if ($RecoveryAllowed) {

    docker info *> $null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Docker is running."
    }
    else {
        Write-Host "[FAIL] Docker is unavailable."
        $Healthy = $false
        $RecoveryAllowed = $false
    }
}

# 3. Services
if ($RecoveryAllowed) {

    Set-Location $ServicesPath

    # MariaDB
    docker compose exec -T database mariadb-admin ping --silent *> $null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] MariaDB is responding."
    }
    else {
        Write-Host "[FAIL] MariaDB is not responding."
        $Healthy = $false
    }

    # Nextcloud container
    $RunningServices = docker compose ps --status running --services

    if ($RunningServices -contains "nextcloud") {
        Write-Host "[OK] Nextcloud container is running."
    }
    else {
        Write-Host "[FAIL] Nextcloud container is not running."
        $Healthy = $false
    }

    # Nextcloud web service
    curl.exe -s -f http://localhost:8081/status.php > $null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Nextcloud web service is responding."
    }
    else {
        Write-Host "[FAIL] Nextcloud web service is unreachable."
        $Healthy = $false
    }
}

# 4. Healthy
# 4. Healthy
if ($Healthy) {

    Write-Host "[SUCCESS] ARK is healthy."

    if (Test-Path $AlertStateFile) {
        Remove-Item $AlertStateFile -Force
    }

    exit 0
}

# 5. Unsafe recovery conditions
if (-not $RecoveryAllowed) {

    Write-Host "[ABORT] Automatic recovery is unsafe."

    if (-not (Test-Path $AlertStateFile)) {

        powershell.exe -NoProfile -ExecutionPolicy Bypass -File $NotificationScript -Message "[ALERT] ARK has a critical infrastructure failure. Automatic recovery was blocked."

        New-Item $AlertStateFile -ItemType File -Force | Out-Null
    }

    exit 1
}

# 6. Attempt recovery
Write-Host "[ACTION] ARK detected a service failure. Starting recovery..."

powershell.exe -NoProfile -ExecutionPolicy Bypass -File $RecoveryScript

if ($LASTEXITCODE -eq 0) {
    Write-Host "[RECOVERED] ARK recovered successfully."
    exit 0
}
else {
    Write-Host "[FAIL] ARK recovery was unsuccessful."
    exit 1
}