# Operacoes

## Fluxo E2E recomendado

### 1) Preparacao

```bash
make setup
```

### 2) Subir observabilidade

```bash
make observability-up
make observability-smoke
```

### 3) Subir API

```bash
make run
```

Observacao:

- `make run` roda em foreground.
- Use outro terminal para os proximos comandos.

### 4) Gerar carga continua

```bash
make integration
make integration-status
```

### 5) Validar API

```bash
curl -sS http://localhost:8080/api/v1/health
curl -sS http://localhost:8080/api/v1/hello
```

### 6) Encerrar ambiente

```bash
make integration-stop
make down
make observability-down
```

## Operacoes auxiliares

- Reaplicar dashboards compativeis:

```bash
make observability-dashboards
```

- Tail da stack de observabilidade:

```bash
make observability-logs
```

- Rodar testes:

```bash
make test
```

## Execucao com porta customizada

```bash
make run APP_PORT=8081
make integration INTEGRATION_API_BASE_URL=http://localhost:8081/api/v1
```
