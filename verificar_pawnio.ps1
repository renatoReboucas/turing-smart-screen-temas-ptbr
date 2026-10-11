param(
    [switch]$InstallIfMissing
)

$ErrorActionPreference = "Stop"
$PawnIOKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PawnIO"

if ($InstallIfMissing) {
    $Identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = [System.Security.Principal.WindowsPrincipal]::new($Identity)
    if (-not $Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $PowerShell = (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source
        if (-not $PowerShell) {
            $PowerShell = (Get-Command pwsh.exe -ErrorAction Stop).Source
        }
        try {
            $Elevated = Start-Process `
                -FilePath $PowerShell `
                -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -InstallIfMissing" `
                -Verb RunAs `
                -Wait `
                -PassThru
            exit $Elevated.ExitCode
        } catch {
            Write-Error "A instalacao do PawnIO exige permissao de administrador. Aprove o aviso do Windows e tente novamente."
            exit 1
        }
    }
}

$Installed = Test-Path $PawnIOKey
if (-not $Installed -and $InstallIfMissing) {
    $Winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if (-not $Winget) {
        Write-Error "winget nao foi encontrado. Instale o App Installer do Windows e tente novamente."
        exit 1
    }

    Write-Host "Instalando o driver PawnIO..."
    & $Winget.Source install --id namazso.PawnIO --exact --source winget --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Error "A instalacao do PawnIO falhou (codigo $LASTEXITCODE)."
        exit 1
    }
    $Installed = Test-Path $PawnIOKey
}

if (-not $Installed) {
    Write-Error "PawnIO nao esta instalado."
    exit 1
}

$Version = (Get-ItemProperty -Path $PawnIOKey).DisplayVersion
$Driver = Get-CimInstance Win32_SystemDriver -Filter "Name='PawnIO'"
if ($Driver.State -ne "Running" -and $InstallIfMissing) {
    try {
        Start-Service -Name "PawnIO" -ErrorAction Stop
    } catch {
        Write-Error "PawnIO $Version esta instalado, mas o driver nao esta em execucao. Reinicie o Windows e execute verificar_pawnio.ps1 novamente."
        exit 1
    }
    $Driver = Get-CimInstance Win32_SystemDriver -Filter "Name='PawnIO'"
}

if ($Driver.State -ne "Running") {
    Write-Error "PawnIO $Version esta instalado, mas o driver nao esta em execucao."
    exit 1
}

Write-Host "PawnIO instalado: versao $Version"
Write-Host "Driver PawnIO: em execucao"
exit 0
