# RUN_LOCAL.md – Hướng dẫn chạy Lab 04

Tài liệu này giúp người khác clone repo sạch và chạy lại service trong Docker container.

---

## Yêu cầu

- **Git:** Để clone repo
- **Docker:** Docker Desktop hoặc Docker Engine  
- **Node.js 20.x LTS:** Cho npm, Prism, Newman, Spectral
- **npm:** Quản lý dependencies

Kiểm tra cài đặt:

```bash
git --version
docker --version
node --version
npm --version
```

---

## Bước 1: Clone repo

```bash
git clone <repo-url>
cd lab-04-ngocviphacker
```

---

## Bước 2: Cài Node.js dependencies

Cài Newman, Prism, Spectral:

```bash
npm install
```

---

## Bước 3: Build Docker image

```bash
docker build -t fit4110/iot-ingestion:lab04 .
```

**Giải thích:**
- Dockerfile dùng multi-stage build để giảm kích thước image
- User không phải root (appuser) cho security
- Có HEALTHCHECK tự động

---

## Bước 4: Chạy container

Mở terminal thứ nhất và chạy container:

```bash
docker run --rm \
  --name fit4110-iot-lab04 \
  -p 8000:8000 \
  --env-file .env.example \
  fit4110/iot-ingestion:lab04
```

**Tham số:**
- `--rm`: Tự động xóa container khi dừng
- `-p 8000:8000`: Map port 8000 từ container ra localhost
- `--env-file .env.example`: Nạp biến môi trường từ file

**Kết quả:**
```text
INFO:     Application startup complete [uvicorn]
INFO:     Uvicorn running on http://0.0.0.0:8000
```

---

## Bước 5: Kiểm tra health (terminal thứ 2)

```bash
curl http://localhost:8000/health
```

**Kết quả mong đợi:**

```json
{
  "status": "ok",
  "service": "iot-ingestion",
  "version": "0.4.0"
}
```

---

## Bước 6: Chạy Postman/Newman test

Mở terminal thứ 3, chạy test suite:

```bash
npm run test:local
```

**Giải thích:**
- Script sẽ chạy Postman Collection lên container đang chạy
- Kiểm tra: Functional, Auth, Negative, Boundary cases
- Output: HTML + XML report

**Report tại:**

```text
reports/newman-lab04-local.html
reports/newman-lab04-local.xml
```

Mở file `.html` bằng browser để xem chi tiết test results.

---

## Bước 7: Dừng container

Quay lại terminal thứ nhất, nhấn `Ctrl+C` hoặc từ terminal khác:

```bash
docker stop fit4110-iot-lab04
```

---

## Các lệnh nhanh (Makefile)

```bash
make install       # npm install
make build         # docker build
make run           # docker run (foreground)
make run-detached  # docker run -d (background)
make health        # curl /health
make test-docker   # npm run test:local
make stop          # docker stop
make mock          # prism mock server
make test-mock     # test lên mock server
make lint          # spectral lint openapi.yaml
```

---

## Troubleshooting

### Docker container không chạy

```bash
# Kiểm tra Docker daemon
docker ps

# Xem log container
docker logs fit4110-iot-lab04

# Kiểm tra port 8000 đã bị chiếm
netstat -tuln | grep 8000
```

### Newman test fail

```bash
# Kiểm tra container còn chạy không
docker ps | grep iot-lab04

# Kiểm tra environment variables
cat .env.example

# Chạy test ở mock server trước
npm run test:mock
```

### Image build fail

```bash
# Xóa image cũ
docker rmi fit4110/iot-ingestion:lab04

# Build lại
docker build -t fit4110/iot-ingestion:lab04 .
```

---

## Điều kiện hoàn thành

Lab 04 được xem là pass khi:

✅ Docker image build được  
✅ Container chạy được  
✅ `/health` trả 200 OK  
✅ Service chạy với non-root user  
✅ Có `.dockerignore` và `.env.example`  
✅ Newman test pass trên container  
✅ Report được sinh trong `reports/`  

---

## Artefact nộp bài

```text
Dockerfile
.dockerignore
.env.example
RUN_LOCAL.md (file này)
src/iot_app/main.py
contracts/iot-ingestion.openapi.yaml
postman/collections/FIT4110_lab04_iot_docker.postman_collection.json
postman/environments/FIT4110_lab04_local.postman_environment.json
reports/newman-lab04-local.html
reports/newman-lab04-local.xml
```

---

## Tham khảo

- README.md - Tổng quan Lab 04
- DOCKER_LAB_GUIDE.md - Chi tiết Dockerfile best practices
- contracts/iot-ingestion.openapi.yaml - API contract
- postman/collections/ - Postman test suite
