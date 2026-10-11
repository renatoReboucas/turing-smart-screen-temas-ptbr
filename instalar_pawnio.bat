@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0verificar_pawnio.ps1" -InstallIfMissing
if errorlevel 1 (
    echo Falha ao validar ou instalar o PawnIO.
    pause
    exit /b 1
)
echo PawnIO esta instalado e o driver esta em execucao.
pause
