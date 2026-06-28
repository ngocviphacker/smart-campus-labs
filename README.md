# Smart Campus Operations Platform — All Labs (1 - 5)

Kho lưu trữ (repository) tổng hợp toàn bộ các bài thực hành Lab (từ Lab 1 đến Lab 5) của học phần **Dịch vụ kết nối và Công nghệ nền tảng (FIT4110)**.

---

## 📁 Cấu trúc thư mục dự án

* **[lab1-ngocviphacker](file:///c:/Users/kise/ThayBaoThayKhuong/lab1-ngocviphacker)**: Thiết lập môi trường Docker, cài đặt Miniconda và chạy thử nghiệm smoke-test.
* **[lab02-ngocviphacker](file:///c:/Users/kise/ThayBaoThayKhuong/lab02-ngocviphacker)**: Thiết kế hợp đồng API OpenAPI, kiểm thử Spectral và thiết kế các kịch bản tích hợp dịch vụ.
* **[lab-3-ngocviphacker](file:///c:/Users/kise/ThayBaoThayKhuong/lab-3-ngocviphacker)**: Phát triển và cấu hình hạ tầng mạng kết nối các service.
* **[lab-04-ngocviphacker](file:///c:/Users/kise/ThayBaoThayKhuong/lab-04-ngocviphacker)**: Thiết lập bảo mật, xác thực API và quản lý cấu hình.
* **[lab-5-ngocviphacker](file:///c:/Users/kise/ThayBaoThayKhuong/lab-5-ngocviphacker)**: Tích hợp nghiệp vụ chi tiết, xử lý hàng đợi chạy nền, phân phối cảnh báo đa kênh (Telegram, Gmail, Webhook) và cơ chế thử lại (Retry) bền bỉ.
* **[Bao_Cao_Lab5_Notification.docx](file:///c:/Users/kise/ThayBaoThayKhuong/Bao_Cao_Lab5_Notification.docx)**: File báo cáo mẫu chính thức đã được điền đầy đủ nội dung kỹ thuật nghiệp vụ của nhóm 7.

---

## 🚀 Hướng dẫn khởi chạy & Kiểm thử Lab 5 (Notification Service)

Các thành viên thực hiện theo các bước sau để chạy thử nghiệm dịch vụ Thông báo Cảnh báo trên máy cá nhân:

### 1. Chuẩn bị
* Đảm bảo phần mềm **Docker Desktop** đã được mở và đang chạy bình thường.
* Chuyển vào thư mục Lab 5:
  ```bash
  cd lab-5-ngocviphacker
  ```

### 2. Thiết lập cấu hình môi trường (.env)
* Sao chép file `.env.example` thành file `.env` thực tế:
  ```bash
  copy .env.example .env
  ```
* Mở file `.env` vừa tạo và điền các tham số cấu hình kênh nhận thông báo của bạn:
  * **Gmail/Messenger:** Cấu hình qua webhook trung gian **Make.com** (dán link vào ô `WEBHOOK_URL`).
  * **Discord (Nhanh & Dễ nhất):** Copy link Webhook của kênh Discord dán trực tiếp vào ô `WEBHOOK_URL`.
  * *Nếu để trống, hệ thống sẽ mặc định gọi kiểm tra mạng tới `httpbin.org/post`.*

### 3. Chạy hệ thống bằng Docker Compose
* Chạy lệnh dựng và khởi động cụm microservices (FastAPI API, PostgreSQL Database, Local AI Service Mock):
  ```bash
  docker compose up -d --build
  ```
* Kiểm tra danh sách container đang chạy:
  ```bash
  docker compose ps
  ```
  *(Các container `fit4110-api-lab05`, `fit4110-db-lab05`, `fit4110-ai-lab05` phải có trạng thái STATUS là `healthy` hoặc `running`).*

### 4. Demo & Kiểm thử Nghiệp vụ
* Truy cập Web Dashboard quản trị tại: **`http://localhost:8000/`**
* Kiểm tra trạng thái sức khỏe các service trên giao diện (phải hiển thị màu xanh lá hoạt động).
* Cuộn xuống **Bảng điều khiển Bắn thử**:
  1. Nhập tiêu đề và nội dung cảnh báo.
  2. **Lưu ý ô Mã cảnh báo (Alert ID):** Hãy đặt tên mã dạng `ALT-001`, `ALT-002`... Mỗi lần bấm bắn thử **phải đổi mã số cuối** để tránh bị cơ chế "Chống gửi trùng" chặn lại.
  3. Bấm **Bắn thử Sự kiện Cảnh báo**.
  4. Mở Gmail/Messenger/Discord cá nhân để xác minh nhận tin nhắn báo động thành công!

---

## ⚙️ Quy tắc nghiệp vụ cốt lõi đã lập trình (Nhóm 7)

1. **Phân phối đa kênh theo mức độ (Severity):**
   * `critical` ➡️ Gửi đồng thời **3 kênh** (`telegram`, `email`, `app`).
   * `high` ➡️ Gửi **2 kênh** tức thời (`telegram`, `app`).
   * `medium` ➡️ Gửi **1 kênh** không gấp (`email`).
   * `low` ➡️ Chỉ ghi nhận vào Database/console (trạng thái `logged`), không làm phiền người dùng.
2. **Cơ chế chống gửi trùng lặp:** Tự động lọc trùng mã `alert_id` trong vòng **5 phút** để tránh spam (tin nhắn trùng sẽ chuyển trạng thái thành `TRÙNG LẶP` màu xám trên Dashboard).
3. **Cơ chế tự động thử lại (Retry Worker):** Khi kết nối mạng bị lỗi, luồng nền sẽ tự động lấy tin nhắn ra gửi lại tối đa **3 lần** (mỗi lần cách nhau **5 giây**) trước khi đánh dấu thất bại.
