$ErrorActionPreference = "Stop"
Unregister-ScheduledTask -TaskName "NOVA01 Display" -Confirm:$false -ErrorAction SilentlyContinue
Write-Host "Autostart removed. Theme files remain in %LOCALAPPDATA%\NOVA01."
