#!/usr/bin/env bash

set -euo pipefail

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_USER="${GRAFANA_USER:-admin}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-admin}"

TEMPLATE_CLASSIC_UID="f543a537-cb96-470d-a349-660ad1513136"
TEMPLATE_NATIVE_UID="f543a537-cb96-470d-a349-660ad1513135"
COMPAT_CLASSIC_UID="java-api-red-micrometer-classic"
COMPAT_NATIVE_UID="java-api-red-micrometer-native"

COUNT_METRICS='http_server_request_duration_seconds_count|http_server_request_duration_count|http_server_duration_milliseconds_count|http_server_duration_seconds_count|http_server_duration_count|http_server_requests_milliseconds_count|http_server_requests_seconds_count|http_server_requests_count'
BUCKET_METRICS='http_server_request_duration_seconds_bucket|http_server_request_duration_bucket|http_server_duration_milliseconds_bucket|http_server_duration_seconds_bucket|http_server_duration_bucket|http_server_requests_milliseconds_bucket|http_server_requests_seconds_bucket|http_server_requests_bucket'
SECONDS_BUCKET_METRICS='http_server_request_duration_seconds_bucket|http_server_request_duration_bucket|http_server_duration_seconds_bucket|http_server_duration_bucket|http_server_requests_seconds_bucket'
MILLISECONDS_BUCKET_METRICS='http_server_duration_milliseconds_bucket|http_server_requests_milliseconds_bucket|http_server_requests_bucket'
REQUEST_RATE_EXPR="sum(rate({__name__=~\"${COUNT_METRICS}\", job=~\"\$job\", instance=~\"\$instance\"}[5m]))"
ERROR_RATE_EXPR="((sum(rate({__name__=~\"${COUNT_METRICS}\", job=~\"\$job\", instance=~\"\$instance\", http_response_status_code=~\"5..\"}[5m])) or sum(rate({__name__=~\"${COUNT_METRICS}\", job=~\"\$job\", instance=~\"\$instance\", http_status_code=~\"5..\"}[5m])) or sum(rate({__name__=~\"http_server_requests_milliseconds_count|http_server_requests_seconds_count|http_server_requests_count\", job=~\"\$job\", instance=~\"\$instance\", outcome=\"SERVER_ERROR\"}[5m])) or vector(0))) / sum(rate({__name__=~\"${COUNT_METRICS}\", job=~\"\$job\", instance=~\"\$instance\"}[5m]))"
BUCKET_EXPR="sum by (le) (rate({__name__=~\"${BUCKET_METRICS}\", job=~\"\$job\", instance=~\"\$instance\"}[5m]))"
P95_EXPR="(histogram_quantile(0.95, sum by (le) (rate({__name__=~\"${SECONDS_BUCKET_METRICS}\", job=~\"\$job\", instance=~\"\$instance\"}[5m])))) or (histogram_quantile(0.95, sum by (le) (rate({__name__=~\"${MILLISECONDS_BUCKET_METRICS}\", job=~\"\$job\", instance=~\"\$instance\"}[5m]))) / 1000)"
P50_EXPR="(histogram_quantile(0.5, sum by (le) (rate({__name__=~\"${SECONDS_BUCKET_METRICS}\", job=~\"\$job\", instance=~\"\$instance\"}[5m])))) or (histogram_quantile(0.5, sum by (le) (rate({__name__=~\"${MILLISECONDS_BUCKET_METRICS}\", job=~\"\$job\", instance=~\"\$instance\"}[5m]))) / 1000)"
HEATMAP_EXPR="${BUCKET_EXPR}"

wait_for_grafana() {
  local attempt
  for attempt in $(seq 1 60); do
    if curl -fsS -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" "${GRAFANA_URL}/api/health" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Grafana is not reachable at ${GRAFANA_URL}" >&2
  return 1
}

create_compat_dashboard() {
  local template_uid="$1"
  local target_uid="$2"
  local target_title="$3"
  local target_description="$4"
  local payload
  local dashboard

  payload="$(curl -fsS -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" "${GRAFANA_URL}/api/dashboards/uid/${template_uid}")"
  dashboard="$(
    printf "%s" "${payload}" | jq \
      --arg request_rate "${REQUEST_RATE_EXPR}" \
      --arg error_rate "${ERROR_RATE_EXPR}" \
      --arg bucket_expr "${BUCKET_EXPR}" \
      --arg heatmap_expr "${HEATMAP_EXPR}" \
      --arg p95_expr "${P95_EXPR}" \
      --arg p50_expr "${P50_EXPR}" \
      --arg target_uid "${target_uid}" \
      --arg target_title "${target_title}" \
      --arg target_description "${target_description}" \
      '
      .dashboard
      | .id = null
      | .uid = $target_uid
      | .title = $target_title
      | .description = $target_description
      | .version = 0
      | .panels |= map(
          if .title == "Request Rate" then
            .targets[0].expr = $request_rate
          elif .title == "Error Rate" then
            .targets[0].expr = $error_rate
          elif .title == "Duration histogram (s)" then
            .targets[0].expr = $bucket_expr
          elif .title == "Duration Heatmap" then
            .targets[0].expr = $heatmap_expr
          elif .title == "Duration percentiles" then
            .targets |= map(
              if .refId == "A" then
                .expr = $p95_expr
              elif .refId == "B" then
                .expr = $p50_expr
              else
                .
              end
            )
          else
            .
          end
        )
      '
  )"

  jq -n \
    --argjson dashboard "${dashboard}" \
    '{
      dashboard: $dashboard,
      folderId: 0,
      overwrite: true,
      message: "Create/update compatibility dashboard for Micrometer OTLP metric names and labels"
    }' \
    | curl -fsS \
      -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
      -H "Content-Type: application/json" \
      -X POST \
      "${GRAFANA_URL}/api/dashboards/db" \
      -d @- >/dev/null
}

wait_for_grafana

create_compat_dashboard \
  "${TEMPLATE_CLASSIC_UID}" \
  "${COMPAT_CLASSIC_UID}" \
  "RED Metrics (Micrometer OTLP - classic)" \
  "Compatibility dashboard for Spring Boot + Micrometer OTLP metrics."

create_compat_dashboard \
  "${TEMPLATE_NATIVE_UID}" \
  "${COMPAT_NATIVE_UID}" \
  "RED Metrics (Micrometer OTLP - native compatibility)" \
  "Compatibility dashboard emulating RED native view from classic histogram metrics."

echo "Grafana compatibility dashboards created/updated."
