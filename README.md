# Java API with OTLP SDK

![Java](https://img.shields.io/badge/Java-25-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.11-brightgreen)
![OpenTelemetry](https://img.shields.io/badge/OpenTelemetry-OTLP-blue)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

API REST em Spring Boot com exportacao OTLP de traces, metricas e logs, stack local de observabilidade com OpenTelemetry Collector + Grafana LGTM, e automacao de carga continua para gerar sinais observaveis.

## Objetivo do projeto

Entregar um laboratorio local reproduzivel para:

- Expor endpoints REST em `http://localhost:8080/api/v1/...`.
- Exportar traces, metricas e logs via OTLP HTTP.
- Visualizar sinais em Grafana/Prometheus/Tempo/Loki.
- Gerar trafego continuo com `make integration`.

## Stack principal

- Runtime/API: `Java 25`, `Spring Boot 3.5.11`, `Maven`.
- Persistencia local: `H2` em memoria.
- Telemetria: `Micrometer + OpenTelemetry (OTLP)`.
- Logs OTLP: `Logback OpenTelemetry appender`.
- Observabilidade local: `otel/opentelemetry-collector-contrib:0.146.1` + `grafana/otel-lgtm:0.19.0`.
- Automacao operacional: `Makefile`.

## Requisitos

Minimo para nao configurar tudo manualmente:

- `make` (GNU Make)

Com isso, execute:

```bash
make setup
```

Se for seguir setup manual completo, veja `docs/prerequisites.md`.

## Enderecos principais

- API base: `http://localhost:8080/api/v1`
- Swagger UI: `http://localhost:8080/api/v1/swagger-ui/index.html`
- ReDoc: `http://localhost:8080/api/v1/redoc`
- OpenAPI JSON: `http://localhost:8080/api/v1/api-docs`
- Grafana: `http://localhost:3000` (`admin/admin`)
- Collector health: `http://localhost:13133`
- Dashboard compativel RED classic: `http://localhost:3000/d/java-api-red-micrometer-classic`
- Dashboard compativel RED native: `http://localhost:3000/d/java-api-red-micrometer-native`

## Contratos do repositorio

- Operacao local: `Makefile`.
- Stack docker observability: `docker/compose.observability.yml`.
- Config do collector: `docker/otel-collector-config.yaml`.
- Carga continua: `scripts/integration-loop.sh`.
- Compatibilidade de dashboards Grafana: `scripts/grafana-dashboard-compat.sh`.
- Codigo da API: `src/main/java`.
- Configuracoes: `src/main/resources`.
- Documentacao detalhada: `docs/`.

## Comecando rapido (fluxo recomendado)

1. Preparar ambiente:

```bash
make setup
```

2. Subir observabilidade:

```bash
make observability-up
make observability-smoke
```

3. Subir API:

```bash
make run
```

4. Em outro terminal, iniciar carga continua:

```bash
make integration
make integration-status
```

5. Abrir Grafana e usar os dashboards compativeis do projeto:

- `RED Metrics (Micrometer OTLP - classic)`
- `RED Metrics (Micrometer OTLP - native compatibility)`

6. Encerrar ambiente:

```bash
make integration-stop
make down
make observability-down
```

## Comandos make

- `make setup`: valida Java/Maven/Docker/Compose e baixa dependencias Maven.
- `make run`: sobe API local (foreground).
- `make down`: derruba processo da API na porta configurada.
- `make observability-up`: sobe Collector + LGTM e aplica dashboards compativeis.
- `make observability-down`: derruba stack de observabilidade.
- `make observability-logs`: tail dos logs de `otel-collector` e `lgtm`.
- `make observability-smoke`: valida health de Collector e Grafana.
- `make observability-dashboards`: cria/atualiza dashboards compativeis RED.
- `make integration`: inicia loop de trafego em background.
- `make integration-stop`: para loop de trafego.
- `make integration-status`: status do loop e ultimas linhas de log.
- `make test`: executa testes.

Variaveis uteis:

- `APP_PORT` (default: `8080`)
- `INTEGRATION_API_BASE_URL` (default: `http://localhost:${APP_PORT}/api/v1`)
- `INTEGRATION_INTERVAL_SECONDS` (default: `1`)
- `OTLP_TRACES_ENDPOINT` (default: `http://localhost:4318/v1/traces`)
- `OTLP_METRICS_ENDPOINT` (default: `http://localhost:4318/v1/metrics`)
- `OTLP_LOGS_ENDPOINT` (default: `http://localhost:4318/v1/logs`)
- `APP_ENV` (default: `local`)
- `APP_VERSION` (default: `0.0.1-SNAPSHOT`)
- `APP_INSTANCE_ID` (default: `${HOSTNAME}` ou `random UUID`)

## Documentacao

- Indice: `docs/README.md`
- Pre-requisitos: `docs/prerequisites.md`
- Arquitetura: `docs/architecture.md`
- Operacoes: `docs/operations.md`
- API e contratos HTTP: `docs/api.md`
- Observabilidade e dashboards: `docs/observability.md`
- Troubleshooting: `docs/troubleshooting.md`

## Estrutura do projeto

```text
java-api-with-otlp-sdk/
|-- docker/
|   |-- compose.observability.yml
|   `-- otel-collector-config.yaml
|-- docs/
|   |-- README.md
|   |-- api.md
|   |-- architecture.md
|   |-- observability.md
|   |-- operations.md
|   |-- prerequisites.md
|   `-- troubleshooting.md
|-- scripts/
|   |-- grafana-dashboard-compat.sh
|   `-- integration-loop.sh
|-- src/
|   |-- main/
|   `-- test/
|-- Makefile
|-- pom.xml
`-- README.md
```

## Escopo e seguranca

- Escopo focado em desenvolvimento local e testes.
- Credenciais padrao do Grafana (`admin/admin`) sao aceitaveis apenas para ambiente local.
- Nao usar esta composicao como baseline de producao.

## Licenca

MIT - veja `LICENSE`.
