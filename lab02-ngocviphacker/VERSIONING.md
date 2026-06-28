# Versioning Strategy

## Purpose
Tài liệu này mô tả chiến lược versioning cho contract API và event contract trong Lab 02.

## OpenAPI contract
- File `openapi.yaml` dùng version `1.0.0` trong `info.version`.
- Mỗi lần thay đổi backward-compatible thì tăng `minor`.
- Mỗi lần thay đổi breaking contract thì tăng `major`.
- Patch chỉ dùng cho sửa lỗi tài liệu nhỏ, không thay đổi schema hoặc path.

## Event contract
- Các event `alert.created`, `alert.escalated`, `alert.resolved` được xem là part của API contract.
- Nếu thay đổi schema event hoặc enum `severity`, thì đây là breaking change và cần cập nhật version lớn.
- Topic version hiện tại là `campus.alert.notification.v1`.
- Thêm field optional có thể tăng minor version nếu consumer/provider cũ vẫn xử lý được.
- Đổi tên event, bỏ required field, đổi meaning của `severity`, hoặc đổi idempotency key là breaking change.

## Changelog
- `1.0.0`: Bản đầu tiên cho cặp 6A/7A, Product A/A, Core Business → Notification.
