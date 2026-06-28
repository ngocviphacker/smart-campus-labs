# Biên bản đàm phán hợp đồng API

- Cặp đàm phán: 6A / 7A
- Product: A / A
- Provider: Notification Service
- Consumer: Core Business Service
- Cơ chế: Queue async
- Phiên: v1.0
- Người viết: Nguyễn Thế Ngọc
- Ngày: 20/05/2026

Phạm vi Lab 02: thống nhất event contract sơ bộ cho luồng Core Business phát alert event để Notification gửi thông báo đa kênh. Đặc tả AsyncAPI chi tiết sẽ chuyển sang Lab 03.

---

## Issue #1

- Raised by: Consumer
- Event/topic: `campus.alert.notification.v1`
- Concern: Event chưa thống nhất field `severity`, có thể gây Notification xử lý sai mức cảnh báo và chọn sai channel.
- Proposal: Bổ sung field `severity` bắt buộc với enum `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`.
- Resolution: Accepted
- Rationale: Notification cần severity để quyết định mức ưu tiên và channel gửi phù hợp.
- Impact: Consumer phải luôn gửi severity trong payload event.

---

## Issue #2

- Raised by: Provider
- Event/topic: `alert.created`, `alert.escalated`, `alert.resolved`
- Concern: Retry từ queue có thể gây duplicate event và gửi notification lặp.
- Proposal: Mỗi event phải có `eventId` duy nhất để Notification kiểm tra idempotency.
- Resolution: Accepted
- Rationale: Queue async sử dụng cơ chế at-least-once delivery nên duplicate có thể xảy ra.
- Impact: Consumer cần sinh `eventId` duy nhất cho từng event; Provider lưu idempotency key tối thiểu 7 ngày.

---

## Issue #3

- Raised by: Provider
- Event/topic: `alert.created`, `alert.escalated`, `alert.resolved`
- Concern: Consumer có thể gửi `channels` rỗng, provider không biết phải route theo kênh nào.
- Proposal: Nếu `channels` rỗng thì Notification service sẽ dùng cấu hình mặc định; nếu muốn chi tiết thì Consumer dùng `channelDetails`.
- Resolution: Accepted
- Rationale: Giúp consumer giữ payload tối giản khi không cần tùy chỉnh từng channel.
- Impact: Consumer có thể gửi `channels` rỗng hoặc `channelDetails` với cấu hình chi tiết.

---

## Issue #4

- Raised by: Provider
- Event/topic: `campus.alert.notification.v1`
- Concern: Chưa thống nhất tên topic/queue nên Lab 03 dễ tạo topic khác nhau giữa Producer và Consumer.
- Proposal: Dùng topic chính `campus.alert.notification.v1`; dead-letter queue là `campus.alert.notification.v1.dlq`.
- Resolution: Accepted
- Rationale: Topic có domain, mục đích nghiệp vụ và version để mở rộng được khi sang AsyncAPI.
- Impact: Core Business publish mọi alert notification event vào topic này; Notification subscribe topic chính và theo dõi DLQ.

---

## Issue #5

- Raised by: Provider
- Event/topic: `alert.created`, `alert.escalated`, `alert.resolved`
- Concern: Thiếu rule xử lý event sai schema, thiếu field bắt buộc hoặc không parse được timestamp.
- Proposal: Reject ở consumer-side trước khi publish nếu có thể; nếu Provider nhận message không hợp lệ thì ghi vào DLQ kèm reason `invalid_schema`.
- Resolution: Accepted
- Rationale: Queue async không có response HTTP trực tiếp; DLQ giúp trace lỗi mà không làm nghẽn topic chính.
- Impact: Consumer phải validate payload theo event contract; Provider phải log `eventId`, `correlationId`, `reason`.

---

## Issue #6

- Raised by: Consumer
- Event/topic: `alert.created`, `alert.escalated`, `alert.resolved`
- Concern: Không rõ retry policy nên consumer không biết khi nào nên gửi lại event.
- Proposal: Queue retry tối đa 3 lần với backoff 10s, 30s, 60s; sau đó chuyển DLQ. Duplicate event không gửi notification lại.
- Resolution: Accepted
- Rationale: Queue async sử dụng at-least-once delivery; cần tránh duplicate notification.
- Impact: Consumer không tự publish lại nếu chưa biết kết quả từ broker; Provider phải idempotent theo `eventId`.

---

## Issue #7

- Raised by: Provider
- Event/topic: `alert.escalated`
- Concern: Event đến không đúng thứ tự có thể làm Notification gửi thông báo resolved trước escalated.
- Proposal: Dùng `occurredAt` và `alertVersion` để Provider bỏ qua event cũ hơn version đã xử lý.
- Resolution: Accepted
- Rationale: Queue không đảm bảo ordering tuyệt đối khi scale nhiều consumer.
- Impact: Consumer phải tăng `alertVersion` theo từng thay đổi trạng thái alert; Provider lưu version mới nhất theo `alertId`.

---

## Issue #8

- Raised by: Consumer
- Event/topic: `alert.created`, `alert.escalated`, `alert.resolved`
- Concern: Chưa thống nhất retention và thông tin trace nên khó điều tra sự cố sau khi notification thất bại.
- Proposal: Broker giữ topic chính 7 ngày, DLQ 14 ngày; mọi event bắt buộc có `correlationId`, `source`, `occurredAt`.
- Resolution: Accepted
- Rationale: Đủ thời gian đối soát trong phạm vi lab và vẫn không giữ message quá lâu.
- Impact: Cả hai bên dùng `correlationId` trong log; Lab 03 sẽ đưa retention vào AsyncAPI/broker config.

---

# Chốt hợp đồng v1.0

Provider sign-off: Notification Service representative - agreed v1.0  
Consumer sign-off: Core Business Service representative - agreed v1.0  
Witness (GV/TA): Nguyễn Thế Ngọc ghi nhận để trình GV/TA xác nhận  
Date: 20/05/2026

---

## Ghi chú warning nếu Spectral còn cảnh báo

| Warning | Lý do chấp nhận tạm thời | Kế hoạch sửa |
|---|---|---|
|  |  |  |
