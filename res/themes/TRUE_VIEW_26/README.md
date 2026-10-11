# TRUE VIEW 26

Tema monocromático que prioriza informações, feito para telas TURZX/Turing de
3,5 polegadas e resolução 480×320. Todos os números e pontos dos gráficos vêm
de métricas reais do sistema; sensores indisponíveis aparecem como `N/A`.

## Prévia

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements-portable.txt
PYTHONPATH=. .venv/bin/python -m trueview26 --preview preview.png
```

## macOS

```bash
./installers/install-macos.sh
```

O instalador cria um ambiente isolado em
`~/Library/Application Support/TRUEVIEW26` e registra
`com.trueview26.display`.

## Windows

Execute pelo PowerShell:

```powershell
.\installers\install-windows.ps1
```

O tema é instalado em `%LOCALAPPDATA%\TRUEVIEW26` e registrado como tarefa
agendada `TRUEVIEW26 Display`.

## Configuração

- `device.transport: auto` usa libusb no macOS e serial/COM nos demais sistemas.
- `device.port: AUTO` procura dispositivos seriais compatíveis no Windows/Linux.
- `metrics.network_interface: auto` acompanha a rota de internet padrão.
- O número de série e os identificadores USB evitam selecionar outros
  dispositivos por padrão.

Consulte [METRICS.md](METRICS.md) para definições, unidades e alternativas de
leitura.

### Diagnóstico dos sensores no Windows

A utilização da GPU e a rotação das ventoinhas só aparecem quando um backend de
sensores compatível e o driver do hardware fornecem esses valores. Leituras
indisponíveis permanecem como `N/A`. Execute pelo PowerShell para consultar o
diagnóstico:

```powershell
Set-Location "$env:LOCALAPPDATA\TRUEVIEW26"
Stop-ScheduledTask -TaskName "TRUEVIEW26 Display" -ErrorAction SilentlyContinue
.\.venv\Scripts\python.exe -m trueview26 --config .\config.yaml
```

Se alguma leitura continuar indisponível, consulte as mensagens de aviso em
`logs\trueview26.log`, os modelos da GPU e da placa-mãe e verifique se o
LibreHardwareMonitor mostra esses sensores nesse computador.

## Testes

```bash
PYTHONPATH=. python3 -m unittest discover -s tests -v
```
