$ErrorActionPreference = "Stop"

$ThemeDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$InstallDir = Join-Path $env:LOCALAPPDATA "NEXUSMINIMAL"
$TaskName = "NEXUSMINIMAL Display"
$OtherTaskNames = @("TRUEVIEW26 Display", "NEXUS26 Display", "NOVA01 Display", "TURZX_APEX_01")
$Python = if ($env:PYTHON_BIN) { $env:PYTHON_BIN } else { "py" }

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item -Path (Join-Path $ThemeDir "*") -Destination $InstallDir -Recurse -Force
$LhmSource = Join-Path $ThemeDir "..\..\..\external\LibreHardwareMonitor"
if (-not (Test-Path -Path $LhmSource -PathType Container)) {
    throw "LibreHardwareMonitor bundle not found at $LhmSource"
}
$LhmDestination = Join-Path $InstallDir "external"
New-Item -ItemType Directory -Force -Path $LhmDestination | Out-Null
Copy-Item -Path $LhmSource -Destination $LhmDestination -Recurse -Force
& $Python -3 -m venv (Join-Path $InstallDir ".venv")
$VenvPython = Join-Path $InstallDir ".venv\Scripts\pythonw.exe"
$VenvConsole = Join-Path $InstallDir ".venv\Scripts\python.exe"
& $VenvConsole -m pip install --upgrade pip
& $VenvConsole -m pip install -r (Join-Path $InstallDir "requirements-portable.txt")

$Action = New-ScheduledTaskAction `
    -Execute $VenvPython `
    -Argument "-m nexusminimal --config `"$InstallDir\config.yaml`"" `
    -WorkingDirectory $InstallDir
$Trigger = New-ScheduledTaskTrigger -AtLogOn
$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1)
foreach ($OtherTaskName in $OtherTaskNames) {
    Stop-ScheduledTask -TaskName $OtherTaskName -ErrorAction SilentlyContinue
    Disable-ScheduledTask -TaskName $OtherTaskName -ErrorAction SilentlyContinue | Out-Null
}
Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Force | Out-Null
Start-ScheduledTask -TaskName $TaskName
Write-Host "NEXUS MINIMAL installed and started from $InstallDir"
