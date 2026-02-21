# Java API with OTLP SDK + Local Observability Stack

![Java](https://img.shields.io/badge/Java-25-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.11-brightgreen)
![OpenTelemetry](https://img.shields.io/badge/OpenTelemetry-OTLP-blue)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

Projeto de referencia para API Java com Spring Boot, com exportacao OTLP de **traces, metricas e logs**, e stack local de observabilidade com **OpenTelemetry Collector + Grafana LGTM**.

A API funcional permanece versionada em `http://localhost:8080/api/v1/...`.

## Objetivo

- Expor endpoints REST em `/api/v1`
- Exportar telemetria OTLP (traces, metricas, logs)
- Subir stack local de observabilidade com Docker
- Gerar carga continua para visualizacao dos sinais

## Requisitos

### Setup automatico (recomendado)

Minimo necessario para nao configurar tudo manualmente:

- `make` (GNU Make)

Com isso, rode:

```bash
make setup
```

`make setup` valida Java, Maven, Docker e Docker Compose.

### Setup manual

- JDK 25+
- Maven 3.6+
- Docker Engine
- Docker Compose (plugin `docker compose` ou binario `docker-compose`)

## Como rodar

### 1) Subir observabilidade

```bash
make observability-up
make observability-smoke
```

Acesso:

- Grafana: `http://localhost:3000` (`admin` / `admin`)
- Collector health: `http://localhost:13133`

### 2) Subir API

```bash
make run
```

### 3) Iniciar trafego continuo

```bash
make integration
make integration-status
```

Para parar:

```bash
make integration-stop
make down
make observability-down
```

## Endpoints da API

Base URL:

- `http://localhost:8080/api/v1`

Principais endpoints:

- `GET /api/v1/health`
- `GET /api/v1/hello`
- `GET /api/v1/users`
- `GET /api/v1/users/{id}`
- `POST /api/v1/users`
- `PUT /api/v1/users/{id}`
- `DELETE /api/v1/users/{id}`

Documentacao:

- Swagger UI: `http://localhost:8080/api/v1/swagger-ui/index.html`
- Swagger UI (atalho): `http://localhost:8080/api/v1/swagger-ui`
- ReDoc: `http://localhost:8080/api/v1/redoc`
- OpenAPI JSON: `http://localhost:8080/api/v1/api-docs`

## Configuracao OTLP da API

Variaveis publicas suportadas:

- `OTLP_TRACES_ENDPOINT` (default: `http://localhost:4318/v1/traces`)
- `OTLP_METRICS_ENDPOINT` (default: `http://localhost:4318/v1/metrics`)
- `OTLP_LOGS_ENDPOINT` (default: `http://localhost:4318/v1/logs`)
- `APP_ENV` (default: `local`)
- `APP_VERSION` (default: `0.0.1-SNAPSHOT`)

A API envia:

- traces via OTLP HTTP
- metricas via OTLP
- logs via Logback OTLP appender

## Comandos Make

```bash
make help
```

Alvos principais:

- `make setup` - valida dependencias (Java/Maven/Docker/Compose) e baixa deps Maven
- `make run` - sobe API (clean start)
- `make down` - derruba API na porta configurada
- `make observability-up` - sobe Collector + LGTM
- `make observability-down` - derruba stack observability
- `make observability-logs` - acompanha logs da stack
- `make observability-smoke` - valida health da stack
- `make integration` - inicia carga continua em background
- `make integration-stop` - para carga continua
- `make integration-status` - mostra status e ultimas linhas do log
- `make test` - roda testes

Variaveis uteis:

- `APP_PORT` (default: `8080`)
- `INTEGRATION_API_BASE_URL` (default: `http://localhost:${APP_PORT}/api/v1`)
- `INTEGRATION_INTERVAL_SECONDS` (default: `1`)

Exemplo com porta customizada:

```bash
make run APP_PORT=8081
make integration INTEGRATION_API_BASE_URL=http://localhost:8081/api/v1
```

## Estrutura do projeto

```text
java-api-with-otlp-sdk/
├── docker/
│   ├── compose.observability.yml
│   └── otel-collector-config.yaml
├── scripts/
│   └── integration-loop.sh
├── src/
│   ├── main/
│   │   ├── java/
│   │   └── resources/
│   └── test/
├── Makefile
├── pom.xml
└── README.md
```

## Validacao esperada (checklist)

1. `make test` passa
2. `make observability-up && make observability-smoke` passa
3. `make run` e `GET /api/v1/health` retorna `200`
4. `make integration` gera trafego continuo
5. Collector mostra recebimento de traces/metricas/logs (via `make observability-logs`)
6. Grafana acessivel em `http://localhost:3000`

## Troubleshooting

### Docker nao encontrado / sem permissao

- Rode `make check-docker`
- Verifique se o daemon Docker esta ativo
- Verifique permissao do usuario para usar Docker

### API nao sobe na porta 8080

- Rode `make down`
- Suba novamente com `make run`
- Ou use outra porta: `make run APP_PORT=8081`

### Integracao nao gera trafego

- Confirme API ativa em `/api/v1/health`
- Verifique `make integration-status`
- Confira log em `.runtime/integration.log`

### Sem dados no Grafana

- Confirme Collector em `http://localhost:13133`
- Confira `make observability-logs`
- Confirme endpoints OTLP da API apontando para `http://localhost:4318`

## Licenca

MIT - veja `LICENSE`.
