param(
    [Parameter(Mandatory=$true)]
    [string]$Message
)

$ConfigPath = "C:\ARK\scripts\telegram.env"

if (-not (Test-Path $ConfigPath)) {
    Write-Error "Telegram configuration not found."
    exit 1
}

$Config = Get-Content $ConfigPath

$Token = ($Config | Where-Object { $_ -match '^TELEGRAM_BOT_TOKEN=' }) -replace '^TELEGRAM_BOT_TOKEN=', ''
$ChatId = ($Config | Where-Object { $_ -match '^TELEGRAM_CHAT_ID=' }) -replace '^TELEGRAM_CHAT_ID=', ''

if (-not $Token -or -not $ChatId) {
    Write-Error "Telegram configuration is incomplete."
    exit 1
}

$Body = @{
    chat_id = $ChatId
    text = $Message
}

try {
    Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/sendMessage" -Method Post -Body $Body | Out-Null
    Write-Host "[OK] Notification sent."
    exit 0
}
catch {
    Write-Error "Failed to send Telegram notification."
    exit 1
}
