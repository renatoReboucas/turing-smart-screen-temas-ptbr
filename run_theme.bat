@echo off
setlocal

set "THEME=%~1"
if /I "%THEME%"=="APEX_01" (
    set "LAUNCHER=run_apex01.py"
    set "INSTALL_NAME=APEX01"
)
if /I "%THEME%"=="NEXUS_26" (
    set "LAUNCHER=run_nexus26.py"
    set "INSTALL_NAME=NEXUS26"
)
if /I "%THEME%"=="NEXUS_MINIMAL" (
    set "LAUNCHER=run_nexusminimal.py"
    set "INSTALL_NAME=NEXUSMINIMAL"
)
if /I "%THEME%"=="NOVA_01" (
    set "LAUNCHER=run_nova01.py"
    set "INSTALL_NAME=NOVA01"
)
if /I "%THEME%"=="TRUE_VIEW_26" (
    set "LAUNCHER=run_trueview26.py"
    set "INSTALL_NAME=TRUEVIEW26"
)

if not defined LAUNCHER (
    echo Tema invalido. Consulte os arquivos run_*.bat na raiz.
    exit /b 2
)

set "THEME_DIR=%~dp0res\themes\%THEME%"
set "VENV_PYTHON=%LOCALAPPDATA%\%INSTALL_NAME%\.venv\Scripts\python.exe"
pushd "%THEME_DIR%" || exit /b 1

if exist "%VENV_PYTHON%" (
    "%VENV_PYTHON%" "%LAUNCHER%"
) else (
    where py >nul 2>nul
    if errorlevel 1 (
        echo Python 3 nao encontrado. Instale Python ou configure o ambiente do APEX01.
        popd
        exit /b 1
    )
    py -3 "%LAUNCHER%"
)

set "EXIT_CODE=%ERRORLEVEL%"
popd
exit /b %EXIT_CODE%
