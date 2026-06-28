$ErrorActionPreference = "Continue"
New-Item -ItemType Directory -Force -Path "evidence/buoi-01" | Out-Null

$toolFile = "evidence/buoi-01/tool-versions.txt"
"# Tool versions" | Out-File $toolFile
Get-Date | Out-File $toolFile -Append
git --version 2>&1 | Out-File $toolFile -Append
docker --version 2>&1 | Out-File $toolFile -Append
docker compose version 2>&1 | Out-File $toolFile -Append
node --version 2>&1 | Out-File $toolFile -Append
npm --version 2>&1 | Out-File $toolFile -Append
python --version 2>&1 | Out-File $toolFile -Append
pip --version 2>&1 | Out-File $toolFile -Append

docker --version 2>&1 | Out-File "evidence/buoi-01/docker-version.txt"
docker compose version 2>&1 | Out-File "evidence/buoi-01/compose-version.txt"
docker run --rm hello-world 2>&1 | Out-File "evidence/buoi-01/hello-world.txt"
docker image ls --format "table {{.Repository}}:{{.Tag}}`t{{.ID}}`t{{.Size}}" 2>&1 | Out-File "evidence/buoi-01/image-list.txt"
git log --oneline -5 2>&1 | Out-File "evidence/buoi-01/git-log.txt"

.\scripts\smoke_test.ps1

Write-Host "Evidence collected in evidence/buoi-01"
