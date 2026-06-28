# Consumer–Provider Handshake

## Thông tin chung

- Lab: FIT4110 Lab 03
- Ngày:16/06/2026
- Provider team:7A
- Consumer team:6A
- Provider service:Notification
- Consumer service:Core

## Contract

- Contract file: `lab02-ngocviphacker/openapi.yaml`
- Mock base URL: `http://localhost:4010`
- Auth method: Bearer token in `Authorization` header
- Endpoint được test: `POST /events/alert.created`

## Smoke test

### Request

```http
POST /events/alert.created HTTP/1.1
Host: localhost:4010
Authorization: Bearer lab-token
Content-Type: application/json
```

```json
{
  "eventId": "550e8400-e29b-41d4-a716-446655440000",
  "eventType": "alert.created",
  "alertId": "ALT-2026-05-19-001",
  "correlationId": "COR-2026-05-19-001",
  "severity": "HIGH",
  "timestamp": "2026-05-19T10:30:00Z",
  "payload": {
    "title": "Truy cập trái phép được phát hiện",
    "message": "Cố gắng truy cập không được phép tại cổng chính lúc 10:30",
    "source": "access-gate-01"
  },
  "channels": ["telegram", "email", "app"]
}
```

### Expected response

```json
{
  "eventId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "queued",
  "processedAt": "2026-05-19T10:30:01Z"
}
```

## Kết quả

- [x] Consumer gọi mock thành công.
- [x] Consumer parse được field cần dùng.
- [x] Consumer hiểu lỗi 4xx/5xx provider trả về.
- [x] Có Newman report hoặc screenshot.

## Ghi chú thay đổi hợp đồng

| Nội dung | Trước | Sau | Người đồng ý |
|---|---|---|---|
| Không có thay đổi hợp đồng trong lần test smoke | - | - | 7A / 6A |

## Xác nhận

- Provider representative: Team 7A
- Consumer representative: Team 6A
