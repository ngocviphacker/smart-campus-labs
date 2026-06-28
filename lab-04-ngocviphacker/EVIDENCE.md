# Lab 04 – Evidence & Submission Artifacts

**Team:** ngocviphacker  
**Date:** June 2, 2026  
**Status:** ✅ COMPLETE

---

## 1. Dockerfile Verification

**File:** [Dockerfile](Dockerfile)

✅ **Requirements met:**
- Multi-stage build (builder + runtime)
- Uses Python 3.11-slim for minimal footprint
- Non-root user: `appuser` (created in line 25-26)
- HEALTHCHECK configured (line 37-39):
  ```dockerfile
  HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=3).read()" || exit 1
  ```
- Proper environment variables:
  - `PYTHONDONTWRITEBYTECODE=1`
  - `PYTHONUNBUFFERED=1`
  - `APP_HOST=0.0.0.0`
  - `APP_PORT=8000`

---

## 2. Docker Image Build & Run

**Image Tag:** `fit4110/iot-ingestion:lab04` (also `v0.1.0-lab04`)  
**Image ID:** `d33014454813`  
**Size:** 268MB (compressed: 63.4MB)

**Build Output:**
```
[+] Building 3.9s (19/19) FINISHED
=> naming to docker.io/fit4110/iot-ingestion:lab04
```

✅ Build successful

---

## 3. Container Runtime & Health Check

**Container Name:** `fit4110-iot-lab04`  
**Port Mapping:** 8000:8000  
**User:** appuser (non-root)

**Health Endpoint Test:**
```
GET http://localhost:8000/health

StatusCode        : 200 ✅
StatusDescription : OK
Content           : {"status":"ok","service":"iot-ingestion","version":"0.4.0"}
Server            : uvicorn
Date              : Mon, 01 Jun 2026 19:05:39 GMT
```

✅ Health check PASS

---

## 4. Configuration Files

| File | Status | Purpose |
|------|--------|---------|
| [.env.example](.env.example) | ✅ | Environment template (no secrets) |
| [.dockerignore](.dockerignore) | ✅ | Build context optimization |
| [.gitignore](.gitignore) | ✅ | Git exclusions |

**Environment Variables (.env.example):**
```env
APP_HOST=0.0.0.0
APP_PORT=8000
AUTH_TOKEN=local-dev-token
SERVICE_NAME=iot-ingestion
SERVICE_VERSION=0.4.0
ENV=local
```

✅ No sensitive secrets in repo

---

## 5. Newman Test Results

**Collection:** [FIT4110_lab04_iot_docker.postman_collection.json](postman/collections/FIT4110_lab04_iot_docker.postman_collection.json)

**Environment:** [FIT4110_lab04_local.postman_environment.json](postman/environments/FIT4110_lab04_local.postman_environment.json)

**Test Execution Summary:**
```
Total Run Duration: 1057ms
Total Data Received: 1.68kB

Assertions: 19 executed, 0 failed ✅
Requests: 11 executed, 0 failed ✅
Test Scripts: 11 executed, 0 failed ✅
```

**Test Categories:**

### 01_Functional (4 tests)
- ✅ GET /health returns 200
- ✅ POST valid temperature reading returns 201
- ✅ GET latest readings returns items array
- ✅ GET reading by ID returns 200

### 02_Auth (2 tests)
- ✅ POST without token returns 401 (Unauthorized)
- ✅ POST with wrong token returns 401 (Unauthorized)

### 03_Negative (2 tests)
- ✅ POST missing device_id returns 422
- ✅ POST value as string returns 422

### 04_Boundary_Reliability (3 tests)
- ✅ POST temperature 80°C returns 201 (with X-Warning header)
- ✅ POST temperature 81°C returns 422 (out of range)
- ✅ GET health responds under 1000ms

**Reports Generated:**
- ✅ [reports/newman-lab04-local.html](reports/newman-lab04-local.html)
- ✅ [reports/newman-lab04-local.xml](reports/newman-lab04-local.xml)

---

## 6. Error Response Format (ProblemDetails)

**Example Error Response (401 Unauthorized):**
```json
{
  "type": "https://smart-campus.local/problems/unauthorized",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Missing Authorization header",
  "instance": "/readings"
}
```

✅ RFC 7807 ProblemDetails format implemented correctly

---

## 7. API Endpoints Implementation

| Method | Endpoint | Auth | Status | Tests |
|--------|----------|------|--------|-------|
| GET | `/health` | ❌ | 200 OK | ✅ Pass |
| POST | `/readings` | ✅ Bearer | 201/422/401 | ✅ Pass |
| GET | `/readings/latest` | ✅ Bearer | 200 OK | ✅ Pass |
| GET | `/readings/{id}` | ✅ Bearer | 200/404 | ✅ Pass |

**Source:** [src/iot_app/main.py](src/iot_app/main.py)

---

## 8. OpenAPI Contract

**File:** [contracts/iot-ingestion.openapi.yaml](contracts/iot-ingestion.openapi.yaml)

✅ Contract aligned with Lab 03  
✅ Payload schema defined:
- `device_id` (required, min length 3)
- `metric` (enum: temperature, humidity, motion, smoke)
- `value` (required, boundary: -40 to 80)
- `unit` (optional)
- `timestamp` (required, ISO 8601 format)

---

## 9. Documentation

| File | Status | Purpose |
|------|--------|---------|
| [README.md](README.md) | ✅ | Lab overview & requirements |
| [RUN_LOCAL.md](RUN_LOCAL.md) | ✅ | Step-by-step run guide (3-5 steps) |
| [LAB04_COMPLETION_GUIDE.md](LAB04_COMPLETION_GUIDE.md) | ✅ | Full Lab 04 documentation |
| [EVIDENCE.md](EVIDENCE.md) | ✅ | This file – submission evidence |

---

## 10. Artifacts Checklist

### Required Files
- ✅ `Dockerfile`
- ✅ `.dockerignore`
- ✅ `.env.example`
- ✅ `RUN_LOCAL.md`
- ✅ `contracts/iot-ingestion.openapi.yaml`
- ✅ `postman/collections/FIT4110_lab04_iot_docker.postman_collection.json`
- ✅ `postman/environments/FIT4110_lab04_local.postman_environment.json`
- ✅ `reports/newman-lab04-local.xml`
- ✅ `reports/newman-lab04-local.html`

### Evidence
- ✅ Container health check output: **200 OK** (section 3)
- ✅ Docker image tag: **v0.1.0-lab04** (section 2)
- ✅ GitHub Actions workflow: `.github/workflows/docker-newman.yml`

---

## 11. Lab 04 Completion Rubric

| Criterion | Points | Evidence |
|-----------|--------|----------|
| Dockerfile correct, builds image | 2.0 | ✅ Section 2 |
| Container runs & /health passes | 2.0 | ✅ Section 3 |
| Non-root, .dockerignore, .env.example | 2.0 | ✅ Sections 1, 4 |
| Newman/Postman tests pass on container | 2.0 | ✅ Section 5 (19/19 PASS) |
| RUN_LOCAL.md clear & reproducible | 1.0 | ✅ Section 9 |
| Evidence complete: logs/reports/tag | 1.0 | ✅ Sections 2, 3, 10 |
| **TOTAL** | **10.0** | ✅ **ALL COMPLETE** |

---

## 12. GitHub Repository & CI/CD

**Repository:** https://github.com/Connectivity-services-ad-PT/lab-04-ngocviphacker

**Latest Commits:**
- `480231b` - fix: remove spectral lint from workflow
- `c03b79b` - lab04: fix auth handling and complete Lab 04 Docker verification

**GitHub Actions Workflow:**
- Workflow file: [.github/workflows/docker-newman.yml](.github/workflows/docker-newman.yml)
- Triggers on: push, pull_request
- Steps:
  1. Checkout code
  2. Setup Node.js 20.x
  3. Install npm dependencies
  4. Build Docker image
  5. Run Docker container
  6. Wait for /health endpoint
  7. Execute Newman tests
  8. Upload reports as artifacts

---

## 13. Local Execution Instructions

**Quick Start (3 steps):**

```bash
# Step 1: Build
docker build -t fit4110/iot-ingestion:lab04 .

# Step 2: Run (Terminal 1)
docker run --rm -p 8000:8000 --env-file .env.example fit4110/iot-ingestion:lab04

# Step 3: Test (Terminal 2)
npm run test:local
```

**Full instructions:** See [RUN_LOCAL.md](RUN_LOCAL.md)

---

## 14. Key Implementation Details

### Authentication (Bearer Token)
- All endpoints except `/health` require `Authorization: Bearer {TOKEN}` header
- Token defined in `.env.example`: `local-dev-token`
- Invalid/missing tokens return **401 Unauthorized**

### Boundary Validation
- Temperature value boundary: **-40°C to 80°C**
- Values outside range return **422 Unprocessable Entity**
- Values at boundary (80°C) return **201 Created** with `X-Warning: high-temperature` header

### Error Handling
- All errors use **ProblemDetails** format (RFC 7807)
- Status codes:
  - 200: Success
  - 201: Resource created
  - 401: Unauthorized (auth errors)
  - 404: Not found
  - 422: Validation error

### Container Security
- Runs as non-root user: `appuser`
- No secrets in image
- Health checks every 30 seconds
- Multi-stage build reduces attack surface

---

## 15. Submission Package

**Files to Submit:**
```
✅ Dockerfile
✅ .dockerignore
✅ .env.example
✅ RUN_LOCAL.md
✅ src/iot_app/main.py
✅ contracts/iot-ingestion.openapi.yaml
✅ postman/collections/FIT4110_lab04_iot_docker.postman_collection.json
✅ postman/environments/FIT4110_lab04_local.postman_environment.json
✅ reports/newman-lab04-local.html
✅ reports/newman-lab04-local.xml
✅ EVIDENCE.md (this file)
✅ GitHub repository link
```

**All artifacts ready for submission.** ✅

---

**Lab 04 Status:** 🎉 **COMPLETE & VERIFIED**  
**Date Completed:** June 2, 2026  
**Next Step:** Lab 05 – Docker Compose & Multi-Service Orchestration
