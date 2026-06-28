# Docker Quickstart cho sinh viên

## 1. Kiểm tra Docker Desktop đã mở chưa

```bash
docker info
```

Nếu lệnh này lỗi, hãy mở Docker Desktop và đợi biểu tượng Docker chuyển sang trạng thái Running.

## 2. Kiểm tra Docker Compose

```bash
docker compose version
```

Yêu cầu dùng Docker Compose v2.

## 3. Chạy container đầu tiên

```bash
docker run --rm hello-world
```

Nếu thấy dòng `Hello from Docker!` là Docker đã hoạt động.

## 4. Chạy mini-stack kiểm tra Compose

```bash
docker compose -f compose/docker-compose.smoke.yml up -d
docker compose -f compose/docker-compose.smoke.yml ps
curl -s http://localhost:8081 | head -n 3
curl -s http://localhost:5000/v2/
docker compose -f compose/docker-compose.smoke.yml down
```

Mini-stack gồm:

- `nginx`: kiểm tra web container.
- `redis`: kiểm tra service nhẹ có healthcheck.
- `registry`: kiểm tra registry nội bộ trên máy sinh viên.

## 5. Lưu ý với Mac Apple Silicon

Một số image chỉ có kiến trúc `linux/amd64`. Nếu Docker báo khác platform, có thể chạy thêm cờ:

```bash
docker run --rm --platform linux/amd64 ultralytics/ultralytics:latest-cpu yolo version
```

Trong `docker-compose.yml`, có thể thêm:

```yaml
platform: linux/amd64
```
