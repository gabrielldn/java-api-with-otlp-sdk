#!/usr/bin/env bash

set -euo pipefail

API_BASE_URL="${INTEGRATION_API_BASE_URL:-http://localhost:8080/api/v1}"
INTERVAL_SECONDS="${INTEGRATION_INTERVAL_SECONDS:-1}"

request() {
  curl --silent --max-time 5 "$@" >/dev/null || true
}

counter=1

while true; do
  timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  name="load-user-${counter}"
  email="load-user-${counter}@example.com"

  create_response="$(curl --silent --max-time 5 \
    -X POST "${API_BASE_URL}/users" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"${name}\",\"email\":\"${email}\"}" || true)"

  user_id="$(printf "%s" "${create_response}" | sed -n 's/.*"id":[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -n 1)"

  request "${API_BASE_URL}/users"
  request "${API_BASE_URL}/hello"
  request "${API_BASE_URL}/health"
  request "${API_BASE_URL}/users/999999"

  if [ -n "${user_id}" ]; then
    request "${API_BASE_URL}/users/${user_id}"
    request -X PUT "${API_BASE_URL}/users/${user_id}" \
      -H "Content-Type: application/json" \
      -d "{\"name\":\"${name}-updated\",\"email\":\"updated-${email}\"}"
    request -X DELETE "${API_BASE_URL}/users/${user_id}"
  fi

  printf "[%s] cycle=%s created_user_id=%s interval=%ss\n" \
    "${timestamp}" "${counter}" "${user_id:-none}" "${INTERVAL_SECONDS}"

  counter=$((counter + 1))
  sleep "${INTERVAL_SECONDS}"
done
