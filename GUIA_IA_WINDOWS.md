# Guia para assistentes de IA: executar temas no Windows

Este guia descreve como um assistente de IA deve preparar, executar e configurar a inicialização automática de um dos temas desta coleção em uma tela TURZX/Turing de 3,5" (480 × 320).

## Regras para o assistente

- Leia o README e o instalador do tema escolhido antes de agir; preserve configurações e arquivos existentes.
- Confirme com o usuário qual tema deseja usar e se a tela pode ser assumida agora.
- Feche apenas processos de temas que pertençam a esta coleção, identificados pelo caminho do executável/linha de comando. Não encerre processos por nome genérico nem mate processos do Windows.
- Só um programa pode usar a conexão da tela por vez. Feche o aplicativo do fabricante e qualquer outro monitor de tela antes de iniciar o tema.
- Não solicite senhas, tokens de acesso ou credenciais do GitHub. Não execute comandos como administrador, instale programas ou altere políticas persistentes sem autorização.
- Prefira o atalho na pasta de Inicialização do usuário para iniciar sem janela de terminal. Se a política da máquina bloquear essa opção, explique o bloqueio e peça orientação; não silencie o erro.

## 1. Escolher o tema e conferir os arquivos

Execute o PowerShell na raiz do repositório clonado. Use o nome exato da pasta:

| Pasta do tema | Módulo Python | Pasta de instalação sugerida | Argumentos para iniciar |
|---|---|---|---|
| `APEX_01` | `apex01` | `%LOCALAPPDATA%\APEX01` | `-m apex01` |
| `NOVA_01` | `nova01` | `%LOCALAPPDATA%\NOVA01` | `-m nova01 --config config.yaml` |
| `NEXUS_26` | `nexus26` | `%LOCALAPPDATA%\NEXUS26` | `-m nexus26 --config config.yaml` |
| `NEXUS_MINIMAL` | `nexusminimal` | `%LOCALAPPDATA%\NEXUSMINIMAL` | `-m nexusminimal --config config.yaml` |
| `TRUE_VIEW_26` | `trueview26` | `%LOCALAPPDATA%\TRUEVIEW26` | `-m trueview26 --config config.yaml` |

Confirme que o tema existe e que o computador enxerga a tela:

```powershell
$RepoRoot = (Get-Location).Path
$ThemeName = "APEX_01" # Troque pelo tema escolhido
$ThemeSource = Join-Path $RepoRoot "res\themes\$ThemeName"
if (-not (Test-Path $ThemeSource)) { throw "Tema não encontrado: $ThemeSource" }

Get-CimInstance Win32_PnPEntity |
  Where-Object { $_.PNPDeviceID -match 'USB\\VID_1A86&PID_5722' } |
  Select-Object Name, PNPDeviceID
```

Se não houver dispositivo correspondente, pare e peça ao usuário para verificar o cabo USB, o modelo/revisão da tela e os drivers. Não presuma uma porta COM diferente.

## 2. Preparar uma instalação isolada

Use `%LOCALAPPDATA%` para manter arquivos do tema e seu ambiente Python separados. Se a pasta de instalação já existir, preserve `config.yaml`, logs e alterações do usuário; faça backup antes de sobrescrever qualquer configuração.

```powershell
$InstallName = "APEX01" # Use o nome da tabela
$InstallDir = Join-Path $env:LOCALAPPDATA $InstallName
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item -Path (Join-Path $ThemeSource '*') -Destination $InstallDir -Recurse -Force

$LhmSource = Join-Path $RepoRoot "external\LibreHardwareMonitor"
if (-not (Test-Path $LhmSource -PathType Container)) {
  throw "Dependência de sensores não encontrada: $LhmSource"
}
$ExternalDir = Join-Path $InstallDir "external"
New-Item -ItemType Directory -Force -Path $ExternalDir | Out-Null
Copy-Item -Path $LhmSource -Destination $ExternalDir -Recurse -Force
```

Use o launcher `py -3` se estiver instalado; caso contrário, use `python`. Não passe `-3` diretamente para `python.exe`.

```powershell
$PyLauncher = Get-Command py -ErrorAction SilentlyContinue
if ($PyLauncher) {
  & $PyLauncher.Source -3 --version
  if ($LASTEXITCODE -ne 0) { throw "O launcher py não conseguiu localizar o Python 3." }
  & $PyLauncher.Source -3 -m venv (Join-Path $InstallDir ".venv")
} else {
  $Python = (Get-Command python -ErrorAction Stop).Source
  & $Python --version
  if ($LASTEXITCODE -ne 0) { throw "Python não está disponível." }
  & $Python -m venv (Join-Path $InstallDir ".venv")
}
if ($LASTEXITCODE -ne 0) { throw "Não foi possível criar o ambiente virtual." }

$VenvPython = Join-Path $InstallDir ".venv\Scripts\python.exe"
& $VenvPython -m pip install -r (Join-Path $InstallDir "requirements-portable.txt")
if ($LASTEXITCODE -ne 0) { throw "A instalação das dependências falhou." }
```

## 3. Testar no console antes de ativar o início automático

O teste no console torna os erros visíveis. Feche o software original da tela antes do teste. Use o módulo e os argumentos da tabela; para APEX 01, o `theme.yaml` é carregado automaticamente.

```powershell
Set-Location $InstallDir
.\.venv\Scripts\python.exe -m apex01
```

Confirme que há conexão à tela e que o tema está sendo renderizado. Encerre o teste com `Ctrl+C` antes de criar o atalho. Se houver falha, leia a mensagem completa, verifique a porta COM no Gerenciador de Dispositivos e não configure início automático até corrigir o problema.

## 4. Configurar início automático sem terminal

`pythonw.exe` inicia o módulo sem abrir uma janela de console. O atalho fica na pasta de Inicialização do usuário, sem exigir uma tarefa agendada ou privilégios administrativos:

```powershell
$Pythonw = Join-Path $InstallDir ".venv\Scripts\pythonw.exe"
$StartupDir = [Environment]::GetFolderPath("Startup")
$ShortcutPath = Join-Path $StartupDir "$ThemeName.lnk"

# Use os argumentos da tabela; para o APEX 01:
$Arguments = "-m apex01"
# Para os demais temas, acrescente --config e o caminho absoluto:
# $Arguments = "-m nexus26 --config `"$InstallDir\config.yaml`""

$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $Pythonw
$Shortcut.Arguments = $Arguments
$Shortcut.WorkingDirectory = $InstallDir
$Shortcut.Description = "Iniciar $ThemeName na tela TURZX"
$Shortcut.Save()

Start-Process -FilePath $Pythonw -ArgumentList $Arguments -WorkingDirectory $InstallDir
```

Verifique se o processo Python continua em execução, se a tela mostra o tema e se o atalho aponta para o `pythonw.exe` do ambiente virtual. O usuário pode testar o início automático no próximo logon. Para trocar de tema, encerre o atual, remova ou atualize o atalho antigo e crie apenas um atalho para o novo tema.

Se o atalho ou a inicialização forem bloqueados por política do Windows, explique o erro ao usuário. Não declare que o início automático está configurado sem verificar o atalho.

## 5. Diagnóstico

- Para capturar erros, execute temporariamente pelo `python.exe` no PowerShell, com o diretório de trabalho apontando para a pasta de instalação.
- O dispositivo TURZX desta coleção normalmente informa VID/PID `1A86:5722` e número de série `USB35INCHIPSV2`; confirme esses dados no próprio PC.
- A leitura de uso/temperatura da GPU e de ventoinhas depende dos sensores expostos pelo driver/hardware. Se não houver sensor, o tema deve mostrar `N/A`, não inventar um valor.
- Os temas são aplicativos independentes; não são selecionados dentro do Turing System Monitor.
- Para desligar ou trocar de tema, pare somente o processo identificado pelo caminho dentro da pasta de instalação daquele tema.

## Créditos e licenças

Os temas foram publicados originalmente por [thairc-dev](https://github.com/thairc-dev) como uma coleção para telas TURZX/Turing. O projeto-base de monitoramento é [turing-smart-screen-python](https://github.com/mathoudebine/turing-smart-screen-python). Os avisos de copyright e arquivos de licença dos autores originais devem ser mantidos.
