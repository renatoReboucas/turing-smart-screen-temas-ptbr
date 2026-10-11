param(
    [string]$ExpectedUserSid,
    [string]$ExpectedUserName
)

$ErrorActionPreference = "Stop"

$Identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$TargetUserSid = if ($ExpectedUserSid) { $ExpectedUserSid } else { $Identity.User.Value }
$TargetUserName = if ($ExpectedUserName) { $ExpectedUserName } else { $Identity.Name }

$Principal = [System.Security.Principal.WindowsPrincipal]::new($Identity)
if (-not $Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $PowerShell = (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source
    if (-not $PowerShell) {
        $PowerShell = (Get-Command pwsh.exe -ErrorAction Stop).Source
    }
    $Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ExpectedUserSid $TargetUserSid -ExpectedUserName `"$TargetUserName`""
    try {
        $Elevated = Start-Process -FilePath $PowerShell -ArgumentList $Arguments -Verb RunAs -Wait -PassThru
        exit $Elevated.ExitCode
    } catch {
        Write-Error "A tarefa precisa de permissao de administrador. Aprove o aviso do Windows e tente novamente."
        exit 1
    }
}

$AdministratorsSid = [System.Security.Principal.SecurityIdentifier]::new("S-1-5-32-544")
$Repository = $PSScriptRoot
$ThemeDir = Join-Path $Repository "res\themes\APEX_01"
$Launcher = Join-Path $ThemeDir "run_apex01.py"
$PawnIOKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PawnIO"
$TargetProfile = Get-CimInstance Win32_UserProfile -Filter "SID='$TargetUserSid'"
if (-not $TargetProfile) {
    throw "O perfil Windows nao foi encontrado para a conta $TargetUserName."
}

if (-not (Test-Path $PawnIOKey)) {
    $Winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if (-not $Winget) {
        throw "O PawnIO e necessario para ler a temperatura do Ryzen. Instale-o pelo winget (namazso.PawnIO) e execute este configurador novamente."
    }

    Write-Host "Instalando PawnIO, o driver de acesso aos sensores do processador..."
    & $Winget.Source install --id namazso.PawnIO --exact --source winget --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $PawnIOKey)) {
        throw "Nao foi possivel instalar o PawnIO. Instale o pacote namazso.PawnIO e execute este configurador novamente."
    }
}

$TargetLocalAppData = Join-Path $TargetProfile.LocalPath "AppData\Local"
$TargetAppData = Join-Path $TargetProfile.LocalPath "AppData\Roaming"
$Python = Join-Path $TargetLocalAppData "APEX01\.venv\Scripts\pythonw.exe"
$TaskName = "TURZX_APEX_01"
$StopRequest = Join-Path $TargetLocalAppData "APEX01\stop.request"
$StartupShortcut = Join-Path $TargetAppData "Microsoft\Windows\Start Menu\Programs\Startup\APEX 01.lnk"
$LauncherPattern = [regex]::Escape($Launcher)

if (-not (Test-Path $Launcher -PathType Leaf)) {
    throw "Nao foi encontrado o launcher do APEX 01: $Launcher"
}
if (-not (Test-Path $Python -PathType Leaf)) {
    throw "Nao foi encontrado o ambiente Python do APEX 01: $Python. Configure o ambiente antes de instalar a inicializacao."
}

$Running = Get-CimInstance Win32_Process | Where-Object {
    $_.CommandLine -and $_.CommandLine -match $LauncherPattern
}
if ($Running) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $StopRequest) | Out-Null
    Set-Content -Path $StopRequest -Value "stop" -Encoding Ascii
    $Deadline = (Get-Date).AddSeconds(20)
    do {
        Start-Sleep -Milliseconds 500
        $Running = Get-CimInstance Win32_Process | Where-Object {
            $_.CommandLine -and $_.CommandLine -match $LauncherPattern
        }
    } while ($Running -and (Get-Date) -lt $Deadline)
    if ($Running) {
        throw "O APEX 01 nao encerrou; feche-o antes de configurar a tarefa elevada."
    }
}

$AdministratorMembers = Get-LocalGroupMember -SID $AdministratorsSid
$AddedToAdministrators = $false
if (-not ($AdministratorMembers | Where-Object { $_.SID.Value -eq $TargetUserSid })) {
    Add-LocalGroupMember -SID $AdministratorsSid -Member $TargetUserName
    $AddedToAdministrators = $true
}

$Action = New-ScheduledTaskAction `
    -Execute $Python `
    -Argument "`"$Launcher`"" `
    -WorkingDirectory $ThemeDir
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User $TargetUserName
$TaskPrincipal = New-ScheduledTaskPrincipal `
    -UserId $TargetUserName `
    -LogonType Interactive `
    -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -RestartCount 999 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -MultipleInstances IgnoreNew `
    -StartWhenAvailable

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Principal $TaskPrincipal `
    -Settings $Settings `
    -Description "Inicia o APEX 01 com privilegios elevados para ler a temperatura do processador." `
    -Force | Out-Null

if (Test-Path $StartupShortcut) {
    Remove-Item -LiteralPath $StartupShortcut -Force
}

if ($AddedToAdministrators) {
    Write-Host "A conta $TargetUserName foi adicionada ao grupo Administradores."
    Write-Host "Saia da conta do Windows e entre novamente para atualizar os privilegios."
    Write-Host "O APEX 01 sera iniciado automaticamente nesse proximo logon."
} else {
    Start-ScheduledTask -TaskName $TaskName
    Write-Host "A conta $TargetUserName ja e administradora; a tarefa elevada foi iniciada."
}
