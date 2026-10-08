$ErrorActionPreference = "Stop"
Set-Location "C:\ARK\services"

docker compose exec -T --user www-data nextcloud php -f cron.php
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
