# Phân tích yêu cầu — vai Consumer

- Cặp đàm phán: 6A / 7A
- Product: A / A
- Consumer service: Core Business Service
- Provider service: Notification Service
- Người viết: Nguyễn Thế Ngọc
- Ngày: 20/05/2026

---

## 1. Resource Consumer cần nhận/gửi

| Resource | Consumer dùng để làm gì? | Field bắt buộc với Consumer | Field có thể tùy chọn |
|---|---|---|---|
| Alert Event | Publish thông tin cảnh báo đến Notification service | eventId, eventType, alertId, correlationId, occurredAt, source, severity, alertVersion, data | channels, channelDetails, metadata |
| Delivery Trace | Đối soát log giữa Core Business và Notification | eventId, alertId, correlationId, channel, status | deliveredAt, errorMessage |
| Dead Letter Message | Điều tra event bị lỗi sau retry | eventId, reason, failedAt, originalPayload | retryCount, lastError |

---

## 2. API Consumer cần gọi

| Event | Topic/queue | Lúc nào publish? | Kỳ vọng xử lý |
|---|---|---|---|
| `alert.created` | `campus.alert.notification.v1` | Khi tạo alert mới trong Core Business | Notification gửi thông báo theo severity và channel |
| `alert.escalated` | `campus.alert.notification.v1` | Khi alert được nâng cấp severity | Notification gửi thông báo ưu tiên cao hơn |
| `alert.resolved` | `campus.alert.notification.v1` | Khi alert đã được giải quyết | Notification gửi thông báo đóng sự cố nếu policy yêu cầu |
| DLQ monitor | `campus.alert.notification.v1.dlq` | Khi cần đối soát event lỗi | Core/Notification kiểm tra nguyên nhân và quyết định replay thủ công |

---

## 3. Error case Consumer cần xử lý

| Case | Consumer hiểu là gì? | Consumer sẽ xử lý thế nào? |
|---|---|---|
| Invalid schema | Payload không đúng contract | Validate trước publish, sửa schema rồi gửi event mới |
| Missing correlation | Không trace được event end-to-end | Chặn publish nếu thiếu `correlationId` |
| Duplicate event | Broker retry lại message cũ | Không tạo event mới; Provider idempotent theo `eventId` |
| Out-of-order | Notification nhận version cũ sau version mới | Tăng `alertVersion` theo mỗi thay đổi trạng thái |
| Downstream failure | Notification gửi channel thất bại | Theo dõi DLQ/log, replay thủ công sau khi downstream ổn định |
| Queue overload | Message xử lý chậm | Không tự spam retry; theo dõi broker ack/lag |

---

## 4. Giả định bổ sung

- Giả định 1: Core Business có trách nhiệm sinh `eventId` duy nhất cho mỗi event.
- Giả định 2: Notification service có thể nhận 3 lần retry tại tầng queue trước khi đưa vào DLQ.
- Giả định 3: Nếu `channelDetails` không được cung cấp, Notification service sẽ dùng `channels` list hoặc default routing theo severity.
- Giả định 4: Topic chính là `campus.alert.notification.v1`; retention topic chính 7 ngày, DLQ 14 ngày.

---

## 5. Câu hỏi cho Provider

1. Notification service có thể chấp nhận event với `channels` rỗng và tự chọn default như thế nào?
2. `correlationId` có được phép trùng giữa các event khác nhau trong cùng một business transaction không?
3. Có nên support `sms` mặc định nếu severity = CRITICAL, hoặc chỉ dùng khi consumer explicit gửi `sms`?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Tên field không thống nhất | Consumer gửi sai, provider reject payload | Dùng contract chung, fix trong `openapi.yaml` |
| Severity enum khác nhau | Gửi notification không đúng mức | Chốt enum `LOW/MEDIUM/HIGH/CRITICAL` |
| Không xử lý duplicate event | Gửi thông báo lặp | Dùng `eventId` để idempotency |
| Response error không chuẩn | Consumer không parse được lỗi | Dùng `Problem Details` chung |
| Queue retry vượt quá | Gửi nhiều notification lặp | Giới hạn retry và trả 409 nếu duplicate |
