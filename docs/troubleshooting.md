# Troubleshooting

## `make setup` com warning de `sun.misc.Unsafe`

Causa:

- Maven do sistema usando dependencias antigas no Java 25.

Status no projeto:

- Mitigado por `.mvn/jvm.config`.

## Swagger/ReDoc retorna erro

Checklist:

- API ativa em `http://localhost:8080/api/v1/health`
- URLs corretas:
  - `http://localhost:8080/api/v1/swagger-ui/index.html`
  - `http://localhost:8080/api/v1/redoc`
  - `http://localhost:8080/api/v1/api-docs`

## Dashboards do Grafana em `No data`

Checklist:

- `make observability-smoke`
- `make integration-status`
- Use dashboards compativeis do projeto:
  - `java-api-red-micrometer-classic`
  - `java-api-red-micrometer-native`
- Reaplique patch:

```bash
make observability-dashboards
```

## `make integration` nao gera trafego

Checklist:

- API rodando na porta correta
- `make integration-status` para confirmar PID ativo
- verifique `.runtime/integration.log`

## Porta 8080 ocupada

```bash
make down
make run
```

Ou rode em outra porta:

```bash
make run APP_PORT=8081
```
