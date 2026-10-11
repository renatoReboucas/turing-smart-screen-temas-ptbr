# NEXUS 26

Tema portátil em paisagem (480×320) para telas TURZX/Turing/UsbMonitor de
3,5 polegadas com VID/PID `1a86:5722`.

## Portabilidade

- Nome de usuário, diretório pessoal, caminho do Python, porta USB, interface e
  endpoint não são fixados no código.
- No macOS, o padrão usa gravação direta com `libusb` para atualizações parciais
  mais suaves.
- No Windows, o padrão usa a porta serial/COM; não é necessário instalar
  Zadig/WinUSB.
- O tema continua ativo quando a tela é desconectada e tenta reconectar quando
  ela volta.
- Recursos, fontes, configuração, testes e instaladores estão neste diretório.
- CPU, memória, disco, rede, tempo ligado e identificação do sistema são
  detectados durante a execução.
- No Apple Silicon, o instalador usa o backend `macmon` (licença MIT) para
  temperatura da CPU/GPU, rotação das ventoinhas e uso de memória semelhante
  ao Monitor de Atividade, sem `sudo`. O uso da GPU vem de `Device Utilization %`
  do driver Apple via `ioreg`, usando o valor efetivo do `macmon` somente como
  alternativa. O tema não inventa valores.
- No APFS, o armazenamento é calculado pelo tamanho e espaço livre do
  contêiner, em vez do snapshot de sistema somente para leitura; assim, os
  valores correspondem ao contêiner físico do SSD.

## Hardware compatível

O layout foi projetado para telas de 3,5 polegadas em paisagem, com resolução
480×320. A verificação padrão do número de série (`USB35INCHIPSV2`) evita enviar
acidentalmente o formato de imagem de 3,5 polegadas a uma tela de 5 ou 7
polegadas com o mesmo VID/PID.

Se uma tela compatível de 3,5 polegadas tiver outro número de série, defina
`allow_unverified_device: true` somente depois de confirmar a resolução e o
protocolo.

### Diagnóstico dos sensores no Windows

A utilização da GPU e a rotação das ventoinhas só aparecem quando um backend de
sensores compatível e o driver do hardware fornecem esses valores. Leituras
indisponíveis permanecem como `N/A`. Execute pelo PowerShell para consultar o
diagnóstico:

```powershell
Set-Location "$env:LOCALAPPDATA\NEXUS26"
Stop-ScheduledTask -TaskName "NEXUS26 Display" -ErrorAction SilentlyContinue
.\.venv\Scripts\python.exe -m nexus26 --config .\config.yaml
```

Se alguma leitura continuar indisponível, consulte as mensagens de aviso em
`logs\nexus26.log`, os modelos da GPU e da placa-mãe e verifique se o
LibreHardwareMonitor mostra esses sensores nesse computador.

## Orientação da tela

O NEXUS 26 renderiza apenas no formato paisagem de 480×320. O formato retrato
exige um layout separado de 320×480 e ainda não é compatível. Não há opção de
interface para inverter a paisagem: os valores de rotação podem variar conforme
a revisão da tela. Confirme a revisão antes de alterar o comando de orientação.

## Prévia rápida

A partir deste diretório:

```bash
python3 -m pip install -r requirements-portable.txt
python3 -m nexus26 --preview preview.png
```

## Instalação no macOS

É necessário ter o Python 3.10 ou mais recente.

```bash
chmod +x installers/install-macos.sh installers/uninstall-macos.sh
./installers/install-macos.sh
```

O instalador copia o tema para `~/Library/Application Support/NEXUS26`, cria um
ambiente virtual isolado e registra `com.nexus26.display` como LaunchAgent do
usuário.

Para remover a inicialização automática sem apagar configurações nem registros:

```bash
./installers/uninstall-macos.sh
```

## Instalação no Windows

Instale o Python 3.10 ou mais recente e confirme que o lançador `py` está
disponível. Abra o PowerShell neste diretório:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\installers\install-windows.ps1
```

O instalador copia o tema para `%LOCALAPPDATA%\NEXUS26`, cria um ambiente
virtual isolado e registra a tarefa agendada do usuário `NEXUS26 Display`.

Para remover a inicialização automática:

```powershell
.\installers\uninstall-windows.ps1
```

## Configuração

Edite `config.yaml` antes da instalação ou altere depois a cópia instalada.

- `device.transport`: `auto`, `libusb` ou `serial`
- `device.port`: `AUTO` ou uma porta específica, como `COM4`
- `display.fps`: limitado a 15; esta é uma tela USB de alta velocidade, não um
  monitor HDMI/DisplayPort comum
- `device.chunk_size`: `4096` funciona de forma estável em hubs USB compartilhados típicos
- `weather.location`: cidade/localidade opcional usada pelo wttr.in
- `metrics.network_interface`: `auto` ou uma interface específica, como `en1`
- `logging.file`: arquivo de registro rotativo (1 MB × 4 arquivos, incluindo o atual)

Consulte [METRICS.md](METRICS.md) para ver a origem, definição, unidade,
frequência de atualização e ressalvas de cada valor exibido.

Para executar uma vez, sem tentar reconectar:

```bash
python3 -m nexus26 --config config.yaml --once
```

## Testes

```bash
PYTHONPATH=. python3 -m unittest discover -s tests -v
```

Os testes não exigem que uma tela esteja conectada.

## Notas de distribuição

O código do renderizador é distribuído sob a licença GPL-3.0 ou posterior, pois
deriva do projeto `turing-smart-screen-python`. A licença Apache 2.0 da fonte
Roboto está incluída em `fonts/LICENSE-Roboto.txt`.

Os nomes e logotipos Apple e Windows são marcas registradas de seus respectivos
proprietários e aparecem apenas para identificar a plataforma; não representam
endosso. Antes de publicar o pacote, consulte as regras de uso de marcas do
canal de distribuição escolhido.
