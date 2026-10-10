# Executar os arquivos BAT no Windows 11

Este guia explica como iniciar manualmente os temas desta coleção pelo PowerShell ou pelo Prompt de Comando.

## Antes de iniciar

- Conecte a tela TURZX/Turing e feche o Turing System Monitor e outros programas que possam estar usando a tela.
- Abra o terminal na pasta raiz do repositório, onde ficam os arquivos `run_*.bat`.
- Tenha Python 3 instalado. O lançador usa o ambiente virtual do tema em `%LOCALAPPDATA%`, se existir; caso contrário, procura o Python pelo comando `py -3`.
- As dependências do tema precisam estar instaladas no ambiente usado. O instalador do tema prepara um ambiente virtual próprio; consulte `res\themes\<TEMA>\installers\install-windows.ps1`.
- Execute somente um tema por vez, pois a tela só pode ser usada por um programa de cada vez.

Se o PowerShell abrir em outra pasta, vá para a raiz do repositório substituindo o caminho pelo local onde ele está:

```powershell
Set-Location "C:\caminho\para\turing-smart-screen-temas-ptbr"
```

## Iniciar um tema

No PowerShell, execute o comando do tema desejado:

| Tema | Comando |
|---|---|
| APEX 01 | `.\run_APEX_01.bat` |
| NEXUS 26 | `.\run_NEXUS_26.bat` |
| NEXUS MINIMAL | `.\run_NEXUS_MINIMAL.bat` |
| NOVA 01 | `.\run_NOVA_01.bat` |
| TRUE VIEW 26 | `.\run_TRUE_VIEW_26.bat` |

No Prompt de Comando (`cmd.exe`), os comandos equivalentes são:

| Tema | Comando |
|---|---|
| APEX 01 | `run_APEX_01.bat` |
| NEXUS 26 | `run_NEXUS_26.bat` |
| NEXUS MINIMAL | `run_NEXUS_MINIMAL.bat` |
| NOVA 01 | `run_NOVA_01.bat` |
| TRUE VIEW 26 | `run_TRUE_VIEW_26.bat` |

Também é possível iniciar um tema pelo lançador genérico do PowerShell. Troque o argumento pelo tema escolhido:

| Tema | Comando |
|---|---|
| APEX 01 | `.\run_theme.bat APEX_01` |
| NEXUS 26 | `.\run_theme.bat NEXUS_26` |
| NEXUS MINIMAL | `.\run_theme.bat NEXUS_MINIMAL` |
| NOVA 01 | `.\run_theme.bat NOVA_01` |
| TRUE VIEW 26 | `.\run_theme.bat TRUE_VIEW_26` |

Mantenha o terminal aberto enquanto usa o tema. Para interromper, pressione `Ctrl+C` nesse terminal.

## Parar o APEX 01

`parar_tela.bat` solicita o encerramento do APEX 01 e o desligamento da tela. Ele não é um comando genérico para parar os outros temas.

No PowerShell:

```powershell
.\parar_tela.bat
```

No Prompt de Comando:

```bat
parar_tela.bat
```

Para parar outro tema, use `Ctrl+C` no terminal em que ele está rodando.

## Problemas comuns

- **`py` não foi encontrado:** instale Python 3 e habilite o Python Launcher, ou ajuste a instalação para disponibilizar `py` no PATH.
- **Módulo Python ausente:** instale as dependências do tema escolhido no ambiente utilizado pelo lançador. Para o Python global chamado por `py -3`, por exemplo, execute `py -3 -m pip install -r .\res\themes\APEX_01\requirements-portable.txt`, trocando `APEX_01` pelo tema escolhido.
- **A tela não conecta:** feche outros programas que estejam usando a conexão USB/serial e verifique o dispositivo e a porta no Gerenciador de Dispositivos.
- **O tema fecha imediatamente:** execute o comando em um terminal aberto para ler a mensagem de erro; não inicie outro tema até resolver a falha.