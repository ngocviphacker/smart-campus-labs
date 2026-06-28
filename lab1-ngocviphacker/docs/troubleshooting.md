# Troubleshooting · Buổi 1

## 1. Docker không chạy

Lỗi thường gặp:

```text
Cannot connect to the Docker daemon
```

Cách xử lý:

- Windows/macOS: mở Docker Desktop, đợi Docker chạy xong.
- Linux: chạy `sudo systemctl start docker`.

## 2. Windows báo lỗi WSL2

Kiểm tra:

```powershell
wsl -l -v
```

Ubuntu nên ở VERSION 2. Nếu chưa có WSL2, cài:

```powershell
wsl --install -d Ubuntu-22.04
wsl --set-default-version 2
```

## 3. Port bị chiếm

Nếu mini-stack báo port đã dùng, kiểm tra:

macOS/Linux:

```bash
lsof -i :8081
lsof -i :5000
```

Windows:

```powershell
netstat -ano | findstr :8081
netstat -ano | findstr :5000
```

## 4. Pull image chậm

Chạy trước ở nhà:

```bash
./scripts/pull_all.sh
```

Hoặc Windows:

```powershell
.\scripts\pull_all.ps1
```

## 5. Mac Apple Silicon báo platform mismatch

Không phải lỗi nghiêm trọng. Có thể thêm:

```bash
--platform linux/amd64
```

Ví dụ:

```bash
docker run --rm --platform linux/amd64 ultralytics/ultralytics:latest-cpu yolo version
```

## 6. Hết dung lượng Docker

Kiểm tra:

```bash
docker system df
```

Dọn các image/container không dùng:

```bash
docker system prune -a
```

Cẩn thận: lệnh này xóa các image/container không dùng.
