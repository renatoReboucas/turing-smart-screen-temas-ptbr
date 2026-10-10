# Temas para tela TURZX/Turing de 3,5 polegadas

Coleção de cinco temas independentes para telas USB de 480 × 320: **APEX 01**, **NOVA 01**, **NEXUS 26**, **NEXUS MINIMAL** e **TRUE VIEW 26**. Os temas se comunicam diretamente com a tela e não aparecem na lista do aplicativo Turing System Monitor.

Este repositório é uma adaptação de [turing-smart-screen-custom-themes](https://github.com/thairc-dev/turing-smart-screen-custom-themes). Os créditos e avisos de licença dos autores originais foram mantidos. Este projeto não é afiliado à Turing/TURZX.

## Executar no Windows 11

Abra o PowerShell na pasta do repositório. Feche o Turing System Monitor e qualquer outro programa que esteja usando a tela. Execute apenas um tema por vez:

| Tema | Comando |
|---|---|
| APEX 01 | `.\run_APEX_01.bat` |
| NEXUS 26 | `.\run_NEXUS_26.bat` |
| NEXUS MINIMAL | `.\run_NEXUS_MINIMAL.bat` |
| NOVA 01 | `.\run_NOVA_01.bat` |
| TRUE VIEW 26 | `.\run_TRUE_VIEW_26.bat` |

Para iniciar usando o lançador genérico: `.\run_theme.bat APEX_01` (substitua `APEX_01` por `NEXUS_26`, `NEXUS_MINIMAL`, `NOVA_01` ou `TRUE_VIEW_26`). Para encerrar o APEX 01 e solicitar que a tela desligue: `.\parar_tela.bat`. Para parar outro tema, pressione `Ctrl+C` no terminal em que ele está rodando.

Consulte o [guia de execução dos arquivos BAT no Windows 11](EXECUTAR_BATS_WINDOWS_11.md) para comandos copiáveis, preparação e diagnóstico.

## Temas

| Tema | Destaque | Prévia |
|---|---|---|
| **APEX 01** | Data e clima em português; GPU e temperatura no lugar do cartão SSD, além de rede e Wi-Fi/Ethernet. | ![Prévia do APEX 01](res/themes/APEX_01/preview_demo.gif) |
| **NOVA 01** | Interface escura, clima e previsão de cinco dias. | ![Prévia do NOVA 01](res/themes/NOVA_01/preview_demo.gif) |
| **NEXUS 26** | Indicadores de saúde do sistema e gráficos de CPU/GPU. | ![Prévia do NEXUS 26](res/themes/NEXUS_26/preview_demo.gif) |
| **NEXUS MINIMAL** | Layout minimalista com relógio e métricas essenciais. | ![Prévia do NEXUS MINIMAL](res/themes/NEXUS_MINIMAL/preview_demo.gif) |
| **TRUE VIEW 26** | Painel de CPU, memória, disco, ventoinha e rede. | ![Prévia do TRUE VIEW 26](res/themes/TRUE_VIEW_26/preview_demo.gif) |

Leituras de GPU, temperatura e ventoinha dependem dos sensores e drivers disponíveis; valores indisponíveis podem aparecer como `N/A`.

## Instalação e créditos

Os instaladores do Windows ficam em `res\themes\<TEMA>\installers\install-windows.ps1` e configuram a inicialização do tema no logon. Para esse procedimento, consulte o [guia para assistentes de IA](GUIA_IA_WINDOWS.md). O projeto-base de comunicação com a tela é [turing-smart-screen-python](https://github.com/mathoudebine/turing-smart-screen-python). As licenças e atribuições dos componentes estão nos arquivos incluídos; consulte `LICENSE` para a licença principal.
