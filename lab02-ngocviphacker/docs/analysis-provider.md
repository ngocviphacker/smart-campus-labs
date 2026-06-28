# Phân tích yêu cầu — vai Provider

- Cặp đàm phán: 6A / 7A
- Product: A / A
- Provider service: Notification Service
- Consumer service: Core Business Service
- Người viết:Nguyễn Thế Ngọc
- Ngày:20/05/2026

---

## 1. Resource chính

| Resource | Mô tả | Thuộc tính bắt buộc | Thuộc tính tùy chọn |
|---|---|---|---|
| Alert Event | Event cảnh báo do Core Business gửi sang Notification | eventId, eventType, alertId, correlationId, occurredAt, source, severity, alertVersion, data | channels, channelDetails, metadata |
| Notification Delivery | Kết quả xử lý nội bộ theo từng channel | deliveryId, alertId, eventId, channel, status | errorMessage, processedAt |
| Dead Letter Message | Event không xử lý được sau retry hoặc sai schema | eventId, reason, failedAt, originalPayload | retryCount, lastError |

---

## 2. Action/API dự kiến

| Event | Topic/queue | Mục đích | Consumer publish khi nào? |
|---|---|---|---|
| `alert.created` | `campus.alert.notification.v1` | Nhận event tạo alert mới | Khi phát sinh cảnh báo |
| `alert.escalated` | `campus.alert.notification.v1` | Nhận event nâng mức cảnh báo | Khi severity hoặc priority tăng |
| `alert.resolved` | `campus.alert.notification.v1` | Nhận event đóng alert | Khi sự cố được xử lý |
| Invalid/DLQ | `campus.alert.notification.v1.dlq` | Lưu event lỗi sau retry | Khi sai schema, duplicate không xử lý được hoặc downstream lỗi kéo dài |

---

## 3. Error case

Tối thiểu 5 case.

| Case | Tình huống | Cách xử lý dự kiến |
|---|---|---|
| Invalid schema | Payload sai định dạng hoặc thiếu required field | Đưa vào DLQ với reason `invalid_schema` |
| Missing correlation | Thiếu `correlationId` hoặc `eventId` | Không gửi notification, ghi log trace và DLQ |
| Duplicate event | `eventId` đã xử lý do retry | Ack message, không gửi lại notification |
| Out-of-order | `alertVersion` thấp hơn version đã xử lý | Ack và bỏ qua event cũ |
| Downstream failure | Telegram/Email/App lỗi tạm thời | Retry 3 lần với backoff rồi DLQ |
| Queue overload | Consumer lag hoặc broker quá tải | Scale consumer, theo dõi lag và giữ retention 7 ngày |

---

## 4. Giả định bổ sung

Ghi rõ những điểm user story chưa nói nhưng Provider cần giả định.

- Giả định 1: Mỗi event phải có `eventId` duy nhất và Provider dùng làm idempotency key.
- Giả định 2: Queue delivery theo cơ chế at-least-once; Notification service retry tối đa 3 lần.
- Giả định 3: Severity dùng enum `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`.
- Giả định 4: Topic chính là `campus.alert.notification.v1`, DLQ là `campus.alert.notification.v1.dlq`.

---

## 5. Câu hỏi cho Consumer

1. Event `alert.created` có bắt buộc field severity không?
2. Consumer có gửi danh sách channels hay Notification tự routing?
3. Retry sẽ do Queue xử lý hay Notification tự retry?
4. Core Business có thể gửi `alertVersion` để xử lý out-of-order không?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Field name không thống nhất | Consumer parse lỗi | Chốt schema chung |
| Duplicate event do retry | Gửi notification lặp | Dùng eventId để check |
| Severity hiểu khác nhau | Sai mức cảnh báo | Chuẩn hóa enum severity |
| Queue delay | Alert đến chậm | Theo dõi consumer lag, retention 7 ngày |
| Downstream lỗi | Mất notification | Retry policy |
| Event sai thứ tự | Gửi thông báo không đúng trạng thái | Dùng `alertVersion` và `occurredAt` |
