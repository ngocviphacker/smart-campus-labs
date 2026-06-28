#!/usr/bin/env bash
set -u

mkdir -p evidence/buoi-01
LOG="evidence/buoi-01/smoke-test-result.txt"
: > "$LOG"

pass(){ printf "[PASS] %s\n" "$1" | tee -a "$LOG"; }
warn(){ printf "[WARN] %s\n" "$1" | tee -a "$LOG"; }
fail(){ printf "[FAIL] %s\n" "$1" | tee -a "$LOG"; }

run_check(){
  local label="$1"
  shift
  if "$@" >> "$LOG" 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_cmd(){
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    pass "$cmd installed"
  else
    fail "$cmd missing"
  fi
}

echo "== Tool checks ==" | tee -a "$LOG"
require_cmd git
require_cmd docker
require_cmd node
if command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
  pass "python installed"
else
  warn "python not found; use Miniconda or install Python 3.11"
fi

echo "\n== Docker checks ==" | tee -a "$LOG"
run_check "docker CLI" docker --version
run_check "docker compose v2" docker compose version
run_check "docker daemon ready" docker info
run_check "hello-world container" docker run --rm hello-world

echo "\n== Image checks ==" | tee -a "$LOG"
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
for img in "${IMAGES[@]}"; do
  if docker image inspect "$img" >/dev/null 2>&1; then
    pass "image $img"
  else
    warn "missing image $img; run scripts/pull_all.sh"
  fi
done

echo "\n== Ultralytics check ==" | tee -a "$LOG"
if docker image inspect "ultralytics/ultralytics:latest-cpu" >/dev/null 2>&1; then
  if docker run --rm ultralytics/ultralytics:latest-cpu yolo version >> "$LOG" 2>&1; then
    pass "ultralytics yolo version"
  else
    warn "ultralytics image exists but yolo version failed. On Mac Apple Silicon, try: docker run --rm --platform linux/amd64 ultralytics/ultralytics:latest-cpu yolo version"
  fi
else
  warn "skip ultralytics check because image is missing"
fi

echo "\n== Compose mini-stack check ==" | tee -a "$LOG"
if docker compose -f compose/docker-compose.smoke.yml up -d >> "$LOG" 2>&1; then
  sleep 5
  docker compose -f compose/docker-compose.smoke.yml ps >> "$LOG" 2>&1 || true
  if curl -fsS http://localhost:8081 >/dev/null 2>&1; then
    pass "nginx reachable on localhost:8081"
  else
    warn "nginx not reachable on localhost:8081"
  fi
  if curl -fsS http://localhost:5000/v2/ >/dev/null 2>&1; then
    pass "local registry reachable on localhost:5000"
  else
    warn "local registry not reachable on localhost:5000"
  fi
  docker compose -f compose/docker-compose.smoke.yml down >> "$LOG" 2>&1 || true
else
  warn "compose mini-stack could not start; maybe ports 8081/5000 are in use"
fi

echo "\nALL CHECKS FINISHED. Read $LOG for details." | tee -a "$LOG"
