# Auditoria das métricas

O NEXUS MINIMAL exibe somente valores coletados do sistema operacional ou de
sensores. Não acrescenta percentuais, temperaturas, RPM, tráfego ou pontos de
gráfico decorativos.

| Exibição | Origem | Definição e unidade |
|---|---|---|
| Exibição | Origem | Definição e unidade |
|---|---|---|
| Carga da CPU | `psutil.cpu_percent` | Média do tempo ativo das CPUs lógicas durante o intervalo de amostragem. |
| Gráfico da CPU | Histórico das amostras de carga da CPU | Usa os mesmos valores reais exibidos numericamente, guardados por até 60 atualizações. |
| Frequência da CPU | `psutil.cpu_freq` | Frequência atual normalizada em GHz. Exibe `N/A` quando indisponível. |
| Temperatura | `macmon` no Apple Silicon | Temperatura da CPU; usa a temperatura real da GPU somente como alternativa. Nunca é estimada pelo uso da CPU. |
| RAM | `macmon` no Apple Silicon | Bytes usados, no padrão do Monitor de Atividade, divididos pela memória física e exibidos em GiB. Nas demais plataformas, usa-se `total - available`. |
| SSD | Contêiner APFS via `diskutil` no macOS | Tamanho do contêiner menos o espaço livre, em GB decimais. Nas demais plataformas, usa-se a unidade do diretório pessoal. O resultado fica em cache por 30 segundos. |
| Ventoinha | `macmon` no Apple Silicon | Rotação real em RPM. A rotação das ventoinhas é calculada pela média porque o layout mostra um único valor. |
| Rede | Interface da rota padrão via `psutil` | Diferença dos contadores dividida pelo tempo monotônico decorrido, em MB/s decimais. |
| Carga do sistema | `psutil.getloadavg()[0]` | Média de carga bruta de um minuto fornecida pelo sistema operacional; não é uma pontuação inventada para a CPU. |
| Processos | `psutil.pids()` | Quantidade total de processos, identificada como `TOTAL` para não sugerir incorretamente que todos estão em execução. |
| Tempo ligado | `psutil.boot_time` | Tempo de relógio desde a inicialização, incluindo suspensão. |
| Hora/data | Hora local do sistema | Usa o fuso horário do sistema operacional; os nomes de dias e meses são exibidos em português. |
| Modelo/SO | `system_profiler` / APIs da plataforma | Detectados na inicialização; nome do computador e versão do sistema operacional não são fixados no código. |

## Observações por plataforma

Os sensores aprimorados do Apple Silicon usam o comando opcional `macmon`,
licenciado sob MIT. O instalador do macOS adiciona essa ferramenta pelo
Homebrew, quando disponível. No Windows e Linux, temperatura e rotação das
ventoinhas só aparecem se um backend de sensores da plataforma fornecer esses
valores; caso contrário, o tema exibe `N/A`.
