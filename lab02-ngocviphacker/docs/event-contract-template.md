# Event Contract sơ bộ — dùng cho dependency Queue async

> File này chỉ dùng cho các cặp Queue async ở Lab 02 để ghi nhận thỏa thuận ban đầu. Đặc tả chi tiết bằng AsyncAPI sẽ chuyển sang Lab 03.

## 1. Thông tin dependency

- Dependency số: 4
- Cặp đàm phán: 6A / 7A
- Product: A / A
- Producer: Core Business Service
- Consumer: Notification Service
- Cơ chế: Queue async
- Event/topic dự kiến: `campus.alert.notification.v1`
- Dead-letter queue dự kiến: `campus.alert.notification.v1.dlq`
- Người ghi: Nguyễn Thế Ngọc
- Ngày: 20/05/2026

## 2. Mục đích nghiệp vụ

Core Business phát event khi alert được tạo, nâng cấp mức độ hoặc được giải quyết. Notification Service nhận event để gửi thông báo đa kênh như Telegram, email, app message hoặc SMS tùy theo `severity`, `channels` và policy nội bộ.

## 3. Event name / topic

| Mục | Giá trị |
|---|---|
| Event name | `alert.created`, `alert.escalated`, `alert.resolved` |
| Topic/queue | `campus.alert.notification.v1` |
| Dead-letter queue | `campus.alert.notification.v1.dlq` |
| Producer | Core Business Service |
| Consumer | Notification Service |
| Delivery assumption | At-least-once |
| Retention | Topic chính 7 ngày, DLQ 14 ngày |

## 4. Payload tối thiểu

```json
{
  "eventId": "550e8400-e29b-41d4-a716-446655440000",
  "eventType": "alert.created",
  "occurredAt": "2026-05-20T08:30:00Z",
  "correlationId": "COR-2026-05-20-001",
  "source": "core-business-service",
  "alertId": "ALT-2026-05-20-001",
  "alertVersion": 1,
  "severity": "HIGH",
  "channels": ["telegram", "email", "app"],
  "channelDetails": [
    {
      "type": "email",
      "email": "security-office@campus.local"
    }
  ],
  "data": {
    "title": "Truy cập trái phép được phát hiện",
    "message": "Cố gắng truy cập không được phép tại cổng chính.",
    "sourceDeviceId": "access-gate-01",
    "location": "Main Gate"
  },
  "metadata": {
    "priority": "security",
    "createdBy": "core-business"
  }
}
```

### Field contract sơ bộ

| Field | Bắt buộc | Kiểu | Ràng buộc |
|---|---|---|---|
| `eventId` | Có | string uuid | Duy nhất cho từng event, dùng làm idempotency key |
| `eventType` | Có | string | Một trong `alert.created`, `alert.escalated`, `alert.resolved` |
| `occurredAt` | Có | string date-time | ISO 8601 UTC |
| `correlationId` | Có | string | Dùng trace end-to-end |
| `source` | Có | string | Giá trị mặc định `core-business-service` |
| `alertId` | Có | string | ID alert trong Core Business |
| `alertVersion` | Có | integer | Tăng dần theo mỗi thay đổi trạng thái alert |
| `severity` | Có | string | `LOW`, `MEDIUM`, `HIGH`, `CRITICAL` |
| `channels` | Không | array | `telegram`, `email`, `app`, `sms`; nếu rỗng Provider tự routing |
| `channelDetails` | Không | array | Cấu hình target chi tiết theo channel |
| `data` | Có | object | Có `title`, `message`, `sourceDeviceId`; có thể bổ sung `location` |
| `metadata` | Không | object | Context mở rộng cho audit/debug |

## 5. Ràng buộc cần thống nhất

| Vấn đề | Quyết định tạm thời |
|---|---|
| Event id có bắt buộc không? | Có |
| Có cần correlationId không? | Có |
| Có cho phép gửi trùng event không? | Có thể, consumer phải idempotent |
| Retry khi lỗi | Retry tối đa 3 lần với backoff 10s, 30s, 60s |
| Dead-letter queue | Dùng `campus.alert.notification.v1.dlq` sau khi hết retry hoặc sai schema |
| Ordering | Không giả định queue đảm bảo ordering tuyệt đối; dùng `alertVersion` và `occurredAt` |
| Default routing | Nếu `channels` rỗng hoặc thiếu, Notification routing theo `severity` |
| Duplicate handling | Provider ack nhưng không gửi notification lại nếu `eventId` đã xử lý |

## 6. Issue chuyển sang Lab 03

1. Viết AsyncAPI đầy đủ cho topic `campus.alert.notification.v1` và DLQ.
2. Chốt broker cụ thể, ví dụ RabbitMQ, Kafka hoặc cloud queue.
3. Mô tả schema evolution cho event version `v1`.
4. Định nghĩa chính sách replay DLQ và quyền truy cập DLQ.
5. Bổ sung SLA cho notification latency theo từng severity.
6. Làm rõ cách Notification publish delivery result nếu Core Business cần nhận trạng thái ngược lại.
