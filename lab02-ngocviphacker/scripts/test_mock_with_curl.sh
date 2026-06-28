#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:4010}"
AUTH_HEADER="Authorization: Bearer test-token"

echo "[Lab02] Testing Prism mock server at $BASE_URL"
echo

echo "[1/5] Happy path: POST /events/alert.created"
curl -sS -i -X POST "$BASE_URL/events/alert.created" \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "550e8400-e29b-41d4-a716-446655440000",
    "eventType": "alert.created",
    "alertId": "ALT-2026-05-20-001",
    "correlationId": "COR-2026-05-20-001",
    "source": "core-business-service",
    "severity": "HIGH",
    "alertVersion": 1,
    "occurredAt": "2026-05-20T08:30:00Z",
    "data": {
      "title": "Truy cap trai phep duoc phat hien",
      "message": "Co gang truy cap khong duoc phep tai cong chinh",
      "source": "access-gate-01",
      "alertLevel": "HIGH"
    },
    "channels": ["telegram", "email", "app"]
  }'
echo "
---"

echo "[2/5] Happy path: POST /events/alert.escalated"
curl -sS -i -X POST "$BASE_URL/events/alert.escalated" \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "550e8400-e29b-41d4-a716-446655440002",
    "eventType": "alert.escalated",
    "alertId": "ALT-2026-05-20-001",
    "correlationId": "COR-2026-05-20-001",
    "source": "core-business-service",
    "severity": "CRITICAL",
    "alertVersion": 2,
    "occurredAt": "2026-05-20T08:35:00Z",
    "data": {
      "title": "Canh bao nghiem trong",
      "message": "Nhieu co gang xam nhap lien tiep duoc ghi nhan",
      "source": "access-gate-01",
      "alertLevel": "CRITICAL"
    },
    "channels": ["telegram", "email", "app", "sms"]
  }'
echo "
---"

echo "[3/5] Happy path: POST /events/alert.resolved"
curl -sS -i -X POST "$BASE_URL/events/alert.resolved" \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "550e8400-e29b-41d4-a716-446655440003",
    "eventType": "alert.resolved",
    "alertId": "ALT-2026-05-20-001",
    "correlationId": "COR-2026-05-20-001",
    "source": "core-business-service",
    "severity": "HIGH",
    "alertVersion": 3,
    "occurredAt": "2026-05-20T09:00:00Z",
    "data": {
      "title": "Canh bao da duoc xu ly",
      "message": "Su co tai cong chinh da duoc xu ly",
      "source": "access-gate-01",
      "alertLevel": "RESOLVED"
    },
    "channels": ["telegram", "email", "app"]
  }'
echo "
---"

echo "[4/5] Error case: POST /events/alert.created without token"
curl -sS -i -X POST "$BASE_URL/events/alert.created" \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "550e8400-e29b-41d4-a716-446655440000",
    "eventType": "alert.created",
    "alertId": "ALT-2026-05-20-001",
    "correlationId": "COR-2026-05-20-001",
    "source": "core-business-service",
    "severity": "HIGH",
    "alertVersion": 1,
    "occurredAt": "2026-05-20T08:30:00Z",
    "data": {
      "title": "Truy cap trai phep duoc phat hien",
      "message": "Co gang truy cap khong duoc phep tai cong chinh",
      "source": "access-gate-01"
    }
  }'
echo "
---"

echo "[5/5] Error case: POST /events/alert.created invalid payload"
curl -sS -i -X POST "$BASE_URL/events/alert.created" \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  -d '{ "eventType": 12345 }'
echo
