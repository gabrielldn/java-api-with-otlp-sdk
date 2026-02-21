# Documentacao

Este diretorio concentra os guias tecnicos e operacionais do projeto.

## Indice

- `prerequisites.md`: requisitos minimos e setup local.
- `architecture.md`: componentes e fluxo OTLP de ponta a ponta.
- `operations.md`: operacao completa com `make`.
- `api.md`: endpoints, convencoes de path e documentacao Swagger/ReDoc.
- `observability.md`: uso de Grafana/Explore e dashboards compativeis.
- `troubleshooting.md`: problemas comuns e resolucao.

## Fluxo sugerido de leitura

1. Leia `prerequisites.md`.
2. Execute o passo a passo de `operations.md`.
3. Entenda o fluxo de sinais em `architecture.md`.
4. Consulte `api.md` para contrato HTTP e exemplos de chamada.
5. Use `observability.md` para validar traces/metricas/logs no Grafana.
6. Em caso de falha, siga `troubleshooting.md`.
