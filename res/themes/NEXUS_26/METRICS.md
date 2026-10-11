# Auditoria das métricas

O NEXUS 26 separa a coleta de dados da renderização. Por padrão, uma amostra é
coletada a cada 0,5 segundo; os cartões são atualizados aproximadamente uma
vez por segundo para respeitar a largura de banda USB de alta velocidade.

| Exibição | Origem | Definição e unidade |
|---|---|---|
| Exibição | Origem | Definição e unidade |
|---|---|---|
| CPU % | `psutil.cpu_percent` | Média do tempo ativo das CPUs lógicas durante o intervalo de amostragem. |
| CPU °C | `macmon` no Apple Silicon | Temperatura média do sensor da CPU. Exibe `N/A` se a plataforma não fornecer um sensor real. |
| GPU % | Apple `AGXAccelerator` via `ioreg` | `Device Utilization %` informado pelo driver. O uso efetivo da GPU no `macmon` é a alternativa no macOS. |
| GPU °C | `macmon` no Apple Silicon | Temperatura média do sensor da GPU. |
| RAM | `macmon` no Apple Silicon | Bytes usados, no padrão do Monitor de Atividade, divididos pela memória física; exibidos em GiB. Nas demais plataformas, usa-se `total - available` tanto para o valor quanto para o percentual. |
| SSD | Contêiner APFS via `diskutil` no macOS | Tamanho do contêiner menos o espaço livre, em GB decimais. Isso evita o erro do snapshot de sistema selado. Nas demais plataformas, usa-se a unidade do diretório pessoal. Atualizado a cada 30 segundos. |
| Ventoinha | `macmon` no Apple Silicon | Rotação real em RPM. A rotação de várias ventoinhas é calculada pela média porque o cartão mostra um único valor. |
| Rede | Interface da rota padrão via `psutil` | Diferença dos contadores de bytes dividida pelo tempo monotônico decorrido, em MB/s decimais. Loopback, AWDL, VPN e outras interfaces são excluídas, salvo seleção explícita. |
| Tempo ligado | `psutil.boot_time` | Segundos de relógio desde a inicialização do sistema, incluindo suspensão. |
| Clima | wttr.in | Observação atual em Celsius. Sem localidade configurada, usa geolocalização por IP; defina `weather.location` para resultados consistentes. Descrições longas são convertidas em condições compactas. |
| Hora/data | Hora local do sistema | Usa o fuso horário do sistema operacional; os nomes de dias e meses são exibidos em português. |
| Modelo/SO | `system_profiler` / APIs da plataforma | Detectados na inicialização; modelo e versão do sistema operacional não são fixados no código. |

## Indicador de integridade

O anel é uma interpretação dos dados, não um sensor adicional. As regras são
avaliadas nesta ordem:

1. `HOT` (quente): temperatura da CPU ou GPU de pelo menos 95 °C.
2. `HEAVY` (carga alta): utilização da CPU ou GPU de pelo menos 95%.
3. `MEMORY` (memória): uso da RAM de pelo menos 95%.
4. `DISK` (disco): uso do armazenamento de pelo menos 90%.
5. `GOOD` (bom): nenhuma das condições anteriores.

As duas linhas menores indicam o motivo, evitando classificar um disco quase
cheio como uma carga genérica de recursos.

## Observações por plataforma

Os sensores aprimorados do Apple Silicon usam o comando opcional `macmon`,
licenciado sob MIT. O instalador do macOS adiciona essa ferramenta pelo
Homebrew, quando disponível. No Windows e Linux, temperatura e rotação das
ventoinhas só aparecem se um backend de sensores da plataforma fornecer esses
valores; o renderizador nunca estima temperatura ou RPM a partir do uso da CPU.
