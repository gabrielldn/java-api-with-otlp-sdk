# API

## Base URL

- `http://localhost:8080/api/v1`

## Endpoints principais

- `GET /api/v1/health`
- `GET /api/v1/hello`
- `GET /api/v1/users`
- `GET /api/v1/users/{id}`
- `POST /api/v1/users`
- `PUT /api/v1/users/{id}`
- `DELETE /api/v1/users/{id}`

## Documentacao OpenAPI

- Swagger UI: `http://localhost:8080/api/v1/swagger-ui/index.html`
- Swagger UI (atalho): `http://localhost:8080/api/v1/swagger-ui`
- ReDoc: `http://localhost:8080/api/v1/redoc`
- OpenAPI JSON: `http://localhost:8080/api/v1/api-docs`

## Exemplos de chamada

Listar usuarios:

```bash
curl -sS http://localhost:8080/api/v1/users
```

Criar usuario:

```bash
curl -sS -X POST http://localhost:8080/api/v1/users \
  -H 'Content-Type: application/json' \
  -d '{"name":"Alice","email":"alice@example.com"}'
```

Buscar por ID:

```bash
curl -sS http://localhost:8080/api/v1/users/1
```
