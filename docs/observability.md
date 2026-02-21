# Observabilidade

## Subir stack local

```bash
make observability-up
make observability-smoke
```

Acesso:

- Grafana: `http://localhost:3000` (`admin/admin`)
- Collector health: `http://localhost:13133`

## Dashboards recomendados

Use os dashboards compativeis com Micrometer OTLP:

- `http://localhost:3000/d/java-api-red-micrometer-classic`
- `http://localhost:3000/d/java-api-red-micrometer-native`

Se necessario, reaplique:

```bash
make observability-dashboards
```

## Gerar sinais observaveis

Com API ativa, rode:

```bash
make integration
make integration-status
```

O loop gera:

- chamadas validas (`/users`, `/hello`, `/health`)
- chamadas 404 controladas (`/users/999999`)
- operacoes CRUD para produzir traces, metricas e logs

## Validar sinais no Grafana

No Explore:

- Prometheus: consulte `http_server_requests_milliseconds_count`, `jvm_threads_live`, `users_created_total`
- Tempo: filtre spans do servico `java-api-with-otlp-sdk`
- Loki: busque logs do servico com mensagens de `UserService`

## Notas

- Metricas OTLP do Micrometer sao publicadas periodicamente (nao em tempo real por request).
- Pode levar alguns segundos ate aparecerem series novas apos restart da API.
