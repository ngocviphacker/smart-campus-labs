$ErrorActionPreference = "Continue"
New-Item -ItemType Directory -Force -Path "evidence/buoi-01" | Out-Null
$log = "evidence/buoi-01/smoke-test-result.txt"
"" | Out-File $log

function Pass($msg) { "[PASS] $msg" | Tee-Object -FilePath $log -Append }
function Warn($msg) { "[WARN] $msg" | Tee-Object -FilePath $log -Append }
function Fail($msg) { "[FAIL] $msg" | Tee-Object -FilePath $log -Append }
function Run-Check($label, $cmd) {
  Invoke-Expression $cmd *> temp_smoke_output.txt
  Get-Content temp_smoke_output.txt | Out-File $log -Append
  if ($LASTEXITCODE -eq 0) { Pass $label } else { Fail $label }
  Remove-Item temp_smoke_output.txt -ErrorAction SilentlyContinue
}
function Require-Cmd($cmd) {
  if (Get-Command $cmd -ErrorAction SilentlyContinue) { Pass "$cmd installed" } else { Fail "$cmd missing" }
}

"== Tool checks ==" | Tee-Object -FilePath $log -Append
Require-Cmd git
Require-Cmd docker
Require-Cmd node
if (Get-Command python -ErrorAction SilentlyContinue) { Pass "python installed" } else { Warn "python not found; use Miniconda or install Python 3.11" }

"`n== Docker checks ==" | Tee-Object -FilePath $log -Append
Run-Check "docker CLI" "docker --version"
Run-Check "docker compose v2" "docker compose version"
Run-Check "docker daemon ready" "docker info"
Run-Check "hello-world container" "docker run --rm hello-world"

"`n== Image checks ==" | Tee-Object -FilePath $log -Append
$images = @(
  "registry:2","python:3.11-slim","node:20-alpine","postgres:15-alpine",
  "rabbitmq:3-management","eclipse-mosquitto:2","nginx:alpine","traefik:v3.1",
  "prom/prometheus:v2.54.1","grafana/grafana:11.2.0","redis:7-alpine",
  "swaggerapi/swagger-ui:v5.17.14","hello-world:latest","ultralytics/ultralytics:latest-cpu"
)
foreach ($img in $images) {
  docker image inspect $img *> $null
  if ($LASTEXITCODE -eq 0) { Pass "image $img" } else { Warn "missing image $img; run scripts/pull_all.ps1" }
}

"`n== Ultralytics check ==" | Tee-Object -FilePath $log -Append
docker image inspect "ultralytics/ultralytics:latest-cpu" *> $null
if ($LASTEXITCODE -eq 0) {
  docker run --rm ultralytics/ultralytics:latest-cpu yolo version *> temp_yolo.txt
  Get-Content temp_yolo.txt | Out-File $log -Append
  if ($LASTEXITCODE -eq 0) { Pass "ultralytics yolo version" } else { Warn "ultralytics image exists but yolo version failed" }
  Remove-Item temp_yolo.txt -ErrorAction SilentlyContinue
} else {
  Warn "skip ultralytics check because image is missing"
}

"`n== Compose mini-stack check ==" | Tee-Object -FilePath $log -Append
docker compose -f compose/docker-compose.smoke.yml up -d *> temp_compose.txt
Get-Content temp_compose.txt | Out-File $log -Append
if ($LASTEXITCODE -eq 0) {
  Start-Sleep -Seconds 5
  docker compose -f compose/docker-compose.smoke.yml ps | Out-File $log -Append
  try {
    Invoke-WebRequest -UseBasicParsing http://localhost:8081 | Out-Null
    Pass "nginx reachable on localhost:8081"
  } catch { Warn "nginx not reachable on localhost:8081" }
  try {
    Invoke-WebRequest -UseBasicParsing http://localhost:5000/v2/ | Out-Null
    Pass "local registry reachable on localhost:5000"
  } catch { Warn "local registry not reachable on localhost:5000" }
  docker compose -f compose/docker-compose.smoke.yml down | Out-File $log -Append
} else {
  Warn "compose mini-stack could not start; maybe ports 8081/5000 are in use"
}
Remove-Item temp_compose.txt -ErrorAction SilentlyContinue

"`nALL CHECKS FINISHED. Read $log for details." | Tee-Object -FilePath $log -Append
