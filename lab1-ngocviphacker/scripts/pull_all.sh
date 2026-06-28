#!/usr/bin/env bash
set -u

IMAGES=(
  "registry:2"
  "python:3.11-slim"
  "node:20-alpine"
  "postgres:15-alpine"
  "rabbitmq:3-management"
  "eclipse-mosquitto:2"
  "nginx:alpine"
  "traefik:v3.1"
  "prom/prometheus:v2.54.1"
  "grafana/grafana:11.2.0"
  "redis:7-alpine"
  "swaggerapi/swagger-ui:v5.17.14"
  "hello-world:latest"
  "ultralytics/ultralytics:latest-cpu"
)

mkdir -p evidence/buoi-01
LOG="evidence/buoi-01/pull-images-result.txt"
: > "$LOG"

for img in "${IMAGES[@]}"; do
  echo "==> Pulling $img" | tee -a "$LOG"
  if docker pull "$img" 2>&1 | tee -a "$LOG"; then
    echo "[PASS] $img" | tee -a "$LOG"
  else
    echo "[WARN] Failed to pull $img" | tee -a "$LOG"
  fi
  echo "" | tee -a "$LOG"
done

echo "==> Current images" | tee -a "$LOG"
docker image ls --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}" | tee -a "$LOG"
