$ErrorActionPreference = "Continue"

$images = @(
  "registry:2",
  "python:3.11-slim",
  "node:20-alpine",
  "postgres:15-alpine",
  "rabbitmq:3-management",
  "eclipse-mosquitto:2",
  "nginx:alpine",
  "traefik:v3.1",
  "prom/prometheus:v2.54.1",
  "grafana/grafana:11.2.0",
  "redis:7-alpine",
  "swaggerapi/swagger-ui:v5.17.14",
  "hello-world:latest",
  "ultralytics/ultralytics:latest-cpu"
)

New-Item -ItemType Directory -Force -Path "evidence/buoi-01" | Out-Null
$log = "evidence/buoi-01/pull-images-result.txt"
"" | Out-File $log

foreach ($img in $images) {
  "==> Pulling $img" | Tee-Object -FilePath $log -Append
  docker pull $img 2>&1 | Tee-Object -FilePath $log -Append
  if ($LASTEXITCODE -eq 0) {
    "[PASS] $img" | Tee-Object -FilePath $log -Append
  } else {
    "[WARN] Failed to pull $img" | Tee-Object -FilePath $log -Append
  }
  "" | Tee-Object -FilePath $log -Append
}

"==> Current images" | Tee-Object -FilePath $log -Append
docker image ls --format "table {{.Repository}}:{{.Tag}}`t{{.ID}}`t{{.Size}}" | Tee-Object -FilePath $log -Append
