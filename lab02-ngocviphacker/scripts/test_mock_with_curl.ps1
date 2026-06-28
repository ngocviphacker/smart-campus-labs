$ErrorActionPreference = "Stop"

$BaseUrl = if ($env:BASE_URL) { $env:BASE_URL } else { "http://localhost:4010" }
$AuthHeader = "Authorization: Bearer test-token"
$CreatedPayloadFile = Join-Path $env:TEMP "lab02-alert-created.json"
$EscalatedPayloadFile = Join-Path $env:TEMP "lab02-alert-escalated.json"
$ResolvedPayloadFile = Join-Path $env:TEMP "lab02-alert-resolved.json"
$InvalidPayloadFile = Join-Path $env:TEMP "lab02-alert-invalid.json"

Write-Host "[Lab02] Testing Prism mock server at $BaseUrl"
Write-Host ""

Write-Host "[1/5] Happy path: POST /events/alert.created"
$createdPayload = '{"eventId":"550e8400-e29b-41d4-a716-446655440000","eventType":"alert.created","alertId":"ALT-2026-05-20-001","correlationId":"COR-2026-05-20-001","source":"core-business-service","severity":"HIGH","alertVersion":1,"occurredAt":"2026-05-20T08:30:00Z","data":{"title":"Truy cap trai phep duoc phat hien","message":"Co gang truy cap khong duoc phep tai cong chinh","source":"access-gate-01","alertLevel":"HIGH"},"channels":["telegram","email","app"]}'
Set-Content -Path $CreatedPayloadFile -Value $createdPayload -Encoding ascii
curl.exe -sS -i -X POST "$BaseUrl/events/alert.created" -H "$AuthHeader" -H "Content-Type: application/json" --data-binary "@$CreatedPayloadFile"
Write-Host "`n---"

Write-Host "[2/5] Happy path: POST /events/alert.escalated"
$escalatedPayload = '{"eventId":"550e8400-e29b-41d4-a716-446655440002","eventType":"alert.escalated","alertId":"ALT-2026-05-20-001","correlationId":"COR-2026-05-20-001","source":"core-business-service","severity":"CRITICAL","alertVersion":2,"occurredAt":"2026-05-20T08:35:00Z","data":{"title":"Canh bao nghiem trong","message":"Nhieu co gang xam nhap lien tiep duoc ghi nhan","source":"access-gate-01","alertLevel":"CRITICAL"},"channels":["telegram","email","app","sms"]}'
Set-Content -Path $EscalatedPayloadFile -Value $escalatedPayload -Encoding ascii
curl.exe -sS -i -X POST "$BaseUrl/events/alert.escalated" -H "$AuthHeader" -H "Content-Type: application/json" --data-binary "@$EscalatedPayloadFile"
Write-Host "`n---"

Write-Host "[3/5] Happy path: POST /events/alert.resolved"
$resolvedPayload = '{"eventId":"550e8400-e29b-41d4-a716-446655440003","eventType":"alert.resolved","alertId":"ALT-2026-05-20-001","correlationId":"COR-2026-05-20-001","source":"core-business-service","severity":"HIGH","alertVersion":3,"occurredAt":"2026-05-20T09:00:00Z","data":{"title":"Canh bao da duoc xu ly","message":"Su co tai cong chinh da duoc xu ly","source":"access-gate-01","alertLevel":"RESOLVED"},"channels":["telegram","email","app"]}'
Set-Content -Path $ResolvedPayloadFile -Value $resolvedPayload -Encoding ascii
curl.exe -sS -i -X POST "$BaseUrl/events/alert.resolved" -H "$AuthHeader" -H "Content-Type: application/json" --data-binary "@$ResolvedPayloadFile"
Write-Host "`n---"

Write-Host "[4/5] Error case: POST /events/alert.created without token"
curl.exe -sS -i -X POST "$BaseUrl/events/alert.created" -H "Content-Type: application/json" --data-binary "@$CreatedPayloadFile"
Write-Host "`n---"

Write-Host "[5/5] Error case: POST /events/alert.created invalid payload"
Set-Content -Path $InvalidPayloadFile -Value '{ "eventType": 12345 }' -Encoding ascii
curl.exe -sS -i -X POST "$BaseUrl/events/alert.created" -H "$AuthHeader" -H "Content-Type: application/json" --data-binary "@$InvalidPayloadFile"
Write-Host ""
