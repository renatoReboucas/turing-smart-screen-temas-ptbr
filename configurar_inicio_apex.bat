@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0configurar_inicio_apex.ps1"
if errorlevel 1 (
    echo Falha ao configurar a inicializacao elevada do APEX 01.
    pause
    exit /b 1
)
echo Tarefa elevada do APEX 01 configurada.
pause
