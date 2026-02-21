# Pre-requisitos

## Minimo obrigatorio

Para evitar configuracao manual extensa, o minimo exigido e:

- `make` (GNU Make)

Com isso, rode:

```bash
make setup
```

`make setup` valida ambiente e baixa dependencias Maven.

## Setup manual (quando necessario)

- `JDK 25+`
- `Maven 3.6+`
- `Docker Engine`
- `Docker Compose` (plugin `docker compose` ou binario `docker-compose`)
- `jq` (necessario para `make observability-dashboards`)

## Versoes do projeto (pinadas)

- Spring Boot: `3.5.11`
- OpenTelemetry Collector: `0.146.1`
- Grafana LGTM: `0.19.0`

## Validacao rapida

```bash
make check-deps
make check-docker
```
