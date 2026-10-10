@echo off
setlocal

set "STOP_DIR=%LOCALAPPDATA%\APEX01"
set "STOP_FILE=%STOP_DIR%\stop.request"
if not exist "%STOP_DIR%" mkdir "%STOP_DIR%"
if errorlevel 1 (
    echo Nao foi possivel criar o pedido de desligamento do APEX 01.
    exit /b 1
)

> "%STOP_FILE%" echo stop
if errorlevel 1 (
    echo Nao foi possivel solicitar o desligamento do APEX 01.
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; $target = [regex]::Escape((Join-Path '%~dp0res\themes\APEX_01' 'run_apex01.py')); $deadline = (Get-Date).AddSeconds(20); do { $running = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match $target }; if (-not $running) { Write-Output 'APEX 01 encerrado; a tela foi desligada.'; exit 0 }; Start-Sleep -Milliseconds 500 } while ((Get-Date) -lt $deadline); Write-Error 'O APEX 01 ainda esta ativo. Verifique a conexao serial e tente novamente.'; exit 1"
exit /b %ERRORLEVEL%
