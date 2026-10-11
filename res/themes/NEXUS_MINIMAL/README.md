# NEXUS MINIMAL

Tema limpo e objetivo para telas TURZX/Turing de 3,5 polegadas e resolução
480×320, com detalhes em verde, roxo, azul, laranja e amarelo. Todos os números
e pontos dos gráficos vêm de métricas reais do sistema; sensores indisponíveis
aparecem como `N/A`.

`CARGA` mostra a média de carga bruta de um minuto fornecida pelo sistema
operacional. `PROC.` mostra o total de processos e é identificado como `TOTAL`,
não como processos em execução.

## Prévia

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements-portable.txt
PYTHONPATH=. .venv/bin/python -m nexusminimal --preview preview.png
```

## macOS

```bash
./installers/install-macos.sh
```

O instalador cria um ambiente isolado em
`~/Library/Application Support/NEXUSMINIMAL` e registra
`com.nexusminimal.display`.

## Windows

Execute pelo PowerShell:

```powershell
.\installers\install-windows.ps1
```

O tema é instalado em `%LOCALAPPDATA%\NEXUSMINIMAL` e registrado como tarefa
agendada `NEXUSMINIMAL Display`.

## Configuração

- `device.transport: auto` usa libusb no macOS e serial/COM nos demais sistemas.
- `device.port: AUTO` procura dispositivos seriais compatíveis no Windows/Linux.
- `metrics.network_interface: auto` acompanha a rota de internet padrão.
- O número de série e os identificadores USB evitam selecionar outros
  dispositivos por padrão.

Consulte [METRICS.md](METRICS.md) para definições, unidades e alternativas de
leitura.

## Testes

```bash
PYTHONPATH=. python3 -m unittest discover -s tests -v
```
