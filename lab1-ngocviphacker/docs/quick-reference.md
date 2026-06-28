# Quick Reference · Buổi 1

## Lệnh kiểm tra nhanh

```bash
git --version
docker --version
docker compose version
node --version
python --version || python3 --version
```

## Docker chạy thử

```bash
docker run --rm hello-world
```

## Pull image chuẩn

```bash
./scripts/pull_all.sh
```

Windows:

```powershell
.\scripts\pull_all.ps1
```

## Smoke test

```bash
./scripts/smoke_test.sh
```

Windows:

```powershell
.\scripts\smoke_test.ps1
```

## Thu minh chứng

```bash
./scripts/collect_session01_evidence.sh
```

Windows:

```powershell
.\scripts\collect_session01_evidence.ps1
```

## Nộp minh chứng bằng Git

```bash
git add evidence/buoi-01
git commit -m "Add session 01 setup evidence"
git push
```
