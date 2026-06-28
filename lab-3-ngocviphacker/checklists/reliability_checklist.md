# Reliability Checklist — FIT4110 Lab 03

Điền checklist này trước khi nộp Lab 03.

## 1. Functional tests

 - [x] Có test cho endpoint health.
 - [x] Có test happy path cho endpoint chính (POST /events/*).
 - [x] Có kiểm tra status code 2xx.
 - [x] Có kiểm tra field quan trọng trong response (eventId, status).
 - [ ] Có ít nhất 1 test đọc dữ liệu danh sách hoặc chi tiết.

## 2. Auth tests

 - [x] Có test thiếu token.
 - [ ] Có test sai token hoặc token rỗng.
 - [x] Endpoint public được khai báo rõ nếu không cần auth.
 - [x] Test thể hiện đúng expected status 401/403.

## 3. Negative tests

 - [x] Có test thiếu field bắt buộc.
 - [ ] Có test sai kiểu dữ liệu.
 - [x] Có test sai enum hoặc giá trị ngoài miền.
 - [x] Lỗi trả về theo cùng một error model (Problem Details).

## 4. Boundary tests

 - [x] Có test min/max hoặc dữ liệu sát ngưỡng (ví dụ channels > 4).
 - [ ] Có test limit/pagination nếu endpoint có danh sách.
 - [ ] Có test payload lớn hoặc metadata thiếu.
 - [x] Có ghi chú kỳ vọng xử lý dữ liệu biên.

## 5. Reliability tests cơ bản

 - [ ] Có kiểm tra response time.
 - [x] Có mô tả timeout mong muốn (documented retry policy in OpenAPI).
 - [x] Có test hoặc ghi chú retry/idempotency nếu phù hợp (retry policy noted).
 - [x] Có consumer-side smoke test với ít nhất 1 mock của nhóm khác.

## 6. Evidence

 - [x] Collection export JSON. (`postman/collections/team-notify.postman_collection.json`)
 - [x] Environment mock export JSON. (`postman/environments/team-notify_mock.postman_environment.json`)
 - [ ] Environment local export JSON. (`postman/environments/team-notify_local.postman_environment.json`)
 - [x] Newman report XML/HTML. (`reports/newman-report-notify-mock.xml`)
 - [x] Test-case matrix đã điền. (`templates/test-case-matrix.csv`)
 - [ ] Biên bản handshake đã điền.

## Notes
- Newman report generated against Prism mock and saved at `reports/newman-report-notify-mock.xml`.
- Local environment and biên bản handshake cần hoàn thiện trước khi nộp nếu bạn muốn chạy local tests.
