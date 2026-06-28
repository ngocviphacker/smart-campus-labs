# Lab 04 Completion Guide

**Status:** ✅ **Lab 04 Ready for Testing**  
**Date:** June 2, 2026  
**Team:** ngocviphacker  

---

## Overview

Lab 04 extends Lab 03 by adding Docker containerization. The IoT Ingestion API that was tested with Postman/Mock Server in Lab 03 is now packaged into a Docker container for reproducible execution across different environments.

**Lab 03 Flow:**
```
OpenAPI Contract → Mock Server → Postman Test → Newman Report
```

**Lab 04 Flow (Extension):**
```
OpenAPI Contract 
  → FastAPI Service 
  → Dockerfile 
  → Docker Image 
  → Docker Container 
  → Postman/Newman Test on Container 
  → Evidence Report
```

---

## 📋 Checklist: All Lab 04 Requirements

| # | Requirement | Status | File |
|---|---|:---:|---|
| 1 | Dockerfile exists and builds | ✅ | [Dockerfile](Dockerfile) |
| 2 | Container runs without error | ✅ | (Run manually) |
| 3 | GET /health returns 200 OK | ✅ | [src/iot_app/main.py](src/iot_app/main.py#L165) |
| 4 | Service runs as non-root user | ✅ | [Dockerfile](Dockerfile#L23-24) |
| 5 | HEALTHCHECK configured | ✅ | [Dockerfile](Dockerfile#L35-37) |
| 6 | .dockerignore present | ✅ | [.dockerignore](.dockerignore) |
| 7 | .env.example present | ✅ | [.env.example](.env.example) |
| 8 | RUN_LOCAL.md complete | ✅ | [RUN_LOCAL.md](RUN_LOCAL.md) |
| 9 | Bearer token auth implemented | ✅ | [src/iot_app/main.py](src/iot_app/main.py#L155-180) |
| 10 | ProblemDetails error format | ✅ | [src/iot_app/main.py](src/iot_app/main.py#L73-77) |
| 11 | Boundary validation (-40 to 80) | ✅ | [src/iot_app/main.py](src/iot_app/main.py#L61-63) |
| 12 | Postman Collection exists | ✅ | [postman/collections/](postman/collections/) |
| 13 | Environments configured | ✅ | [postman/environments/](postman/environments/) |
| 14 | npm scripts configured | ✅ | [package.json](package.json) |
| 15 | Newman can run tests | ✅ | (Run `npm run test:local`) |

---

## 📁 Project Structure

```
lab-04-ngocviphacker/
├── Dockerfile                      # Multi-stage build, non-root user, HEALTHCHECK
├── .dockerignore                   # Optimize build context
├── .env.example                    # Environment variables template
├── RUN_LOCAL.md                    # Complete run instructions
├── package.json                    # npm scripts for testing tools
├── requirements.txt                # Python dependencies
├── src/
│   └── iot_app/
│       ├── __init__.py
│       └── main.py                 # FastAPI app with all endpoints
├── contracts/
│   └── iot-ingestion.openapi.yaml  # OpenAPI spec
├── postman/
│   ├── collections/
│   │   └── FIT4110_lab04_iot_docker.postman_collection.json
│   └── environments/
│       ├── FIT4110_lab04_local.postman_environment.json
│       └── FIT4110_lab04_mock.postman_environment.json
├── mock-data/
│   ├── sensor-reading-valid.json
│   ├── sensor-reading-boundary-high-temp.json
│   └── sensor-reading-invalid-missing-device.json
├── scripts/
│   ├── run-newman.sh
│   ├── start-prism-mock.sh
│   └── wait-for-health.sh
├── reports/
│   └── (Newman HTML/XML reports generated here)
├── docs/
│   ├── DOCKER_LAB_GUIDE.md
│   └── TEAM_TASKS.md
└── README.md                       # Lab overview
```

---

## 🚀 Quick Start (3-5 Steps)

### Step 1: Clone & Setup
```bash
git clone https://github.com/your-org/lab-04-ngocviphacker
cd lab-04-ngocviphacker
npm install
```

### Step 2: Build Docker Image
```bash
docker build -t fit4110/iot-ingestion:lab04 .
```

### Step 3: Run Container
```bash
docker run --rm \
  --name fit4110-iot-lab04 \
  -p 8000:8000 \
  --env-file .env.example \
  fit4110/iot-ingestion:lab04
```

### Step 4: Verify Health (New Terminal)
```bash
curl http://localhost:8000/health
# Expected: {"status":"ok","service":"iot-ingestion","version":"0.4.0"}
```

### Step 5: Run Tests (Another Terminal)
```bash
npm run test:local
# Reports in: reports/newman-lab04-local.html
```

---

## 🔧 Key Implementation Details

### Dockerfile Structure

**Multi-stage build for optimization:**
- **Builder stage:** Creates Python venv, installs dependencies
- **Runtime stage:** Copies venv only (reduces image size)
- Uses `python:3.11-slim` for minimal footprint

**Security:**
```dockerfile
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser
USER appuser
```

**Health Check:**
```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=3).read()" || exit 1
```

### Environment Configuration

**File:** [.env.example](.env.example)
```env
APP_HOST=0.0.0.0
APP_PORT=8000
AUTH_TOKEN=local-dev-token
SERVICE_NAME=iot-ingestion
SERVICE_VERSION=0.4.0
ENV=local
```

No secrets committed to repo! `AUTH_TOKEN` is for local development only.

### API Endpoints

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| GET | `/health` | ❌ | Health check (no auth needed) |
| POST | `/readings` | ✅ | Create sensor reading |
| GET | `/readings/latest` | ✅ | List latest readings |
| GET | `/readings/{id}` | ✅ | Get single reading |

**Authentication:** Bearer token via `Authorization` header
```
Authorization: Bearer local-dev-token
```

### Error Handling

All errors return `ProblemDetails` format (RFC 7807):
```json
{
  "type": "about:blank",
  "title": "Validation error",
  "status": 422,
  "detail": "value.value: ensure this value is greater than or equal to -40",
  "instance": "/readings"
}
```

---

## 📊 Postman Test Suite

**Collection:** [FIT4110_lab04_iot_docker.postman_collection.json](postman/collections/)

**Test Categories:**
1. **Functional** - Core endpoint behavior
2. **Auth** - Bearer token validation
3. **Negative** - Invalid payloads
4. **Boundary** - Min/max values (-40 to 80 for temperature)
5. **Schema** - Response structure validation

**Environments:**
- **mock** - Test against Prism mock server
- **local** - Test against real container

---

## 🧪 Test Execution

### Run Against Mock Server
```bash
npm run mock:iot          # Terminal 1: Start Prism mock
npm run test:mock         # Terminal 2: Run tests
```

### Run Against Docker Container
```bash
make run                  # Terminal 1: Start container
npm run test:local        # Terminal 2: Run tests
```

### Run All Checks
```bash
make install              # Install dependencies
make lint                 # Lint OpenAPI contract
make build                # Build Docker image
make run-detached         # Start container
sleep 5
npm run test:local        # Run tests
make stop                 # Stop container
```

---

## 📈 Expected Test Results

**Summary (example):**
```
✓ GET health returns 200
✓ POST valid temperature reading returns 201
✓ POST missing auth token returns 401
✓ POST boundary high temp (80) returns 201
✓ POST out-of-range temp (100) returns 422
✓ Response has correct error format
... 20+ more tests ...
```

**Report Location:**
```
reports/newman-lab04-local.html
reports/newman-lab04-local.xml
```

Open `.html` in browser for visual report.

---

## 🐳 Docker Commands Reference

```bash
# Build
docker build -t fit4110/iot-ingestion:lab04 .

# Run interactive
docker run --rm -it -p 8000:8000 --env-file .env.example fit4110/iot-ingestion:lab04

# Run detached
docker run -d --name fit4110-iot-lab04 -p 8000:8000 --env-file .env.example fit4110/iot-ingestion:lab04

# View logs
docker logs fit4110-iot-lab04
docker logs -f fit4110-iot-lab04  # Follow

# Stop container
docker stop fit4110-iot-lab04

# View running containers
docker ps

# View all containers
docker ps -a

# Remove image
docker rmi fit4110/iot-ingestion:lab04

# Inspect health
docker inspect fit4110-iot-lab04 | grep -A 5 Health
```

---

## 🛠️ Makefile Commands

```bash
make install          # Install npm dependencies
make lint             # Lint OpenAPI contract
make mock             # Run Prism mock server
make test-mock        # Run tests against mock
make build            # Build Docker image
make run              # Run container (foreground)
make run-detached     # Run container (background)
make health           # Check container health
make test-docker      # Run tests against container
make stop             # Stop container
make clean-reports    # Clean report artifacts
```

---

## 📚 Lab 03 vs Lab 04 Comparison

| Aspect | Lab 03 | Lab 04 |
|--------|--------|--------|
| **Scope** | API contract & mock testing | Docker containerization |
| **Service** | Mock server (Prism) | Real FastAPI app |
| **Deployment** | localhost:4010 | Docker container |
| **Testing** | Postman/Newman | Same, but on container |
| **Evidence** | Newman report | Newman + Docker logs |
| **New Skills** | Postman, Mock Server | Docker, non-root user |

**Lab 04 builds on Lab 03:**
- Same OpenAPI contract from Lab 03
- Same Postman Collection (updated for container)
- Same test logic, but runs on containerized service
- Evidence: service actually runs elsewhere reproducibly

---

## ✅ Completion Criteria

Lab 04 is **COMPLETE** when:

✅ Dockerfile builds image successfully  
✅ Image runs container without errors  
✅ Container responds to `GET /health` with 200 OK  
✅ Service runs as non-root user (`appuser`)  
✅ `HEALTHCHECK` is configured  
✅ `.dockerignore` file exists and optimizes build context  
✅ `.env.example` provided (no secrets in repo)  
✅ `RUN_LOCAL.md` allows others to reproduce in 3-5 steps  
✅ Newman tests pass against containerized service  
✅ Error responses return `ProblemDetails` format  
✅ Report files generated in `reports/`  
✅ All endpoints tested: functional, auth, negative, boundary, schema

---

## 🎯 Artifacts to Submit

```
Dockerfile                                              ✅
.dockerignore                                           ✅
.env.example                                            ✅
RUN_LOCAL.md                                            ✅
src/iot_app/main.py                                     ✅
contracts/iot-ingestion.openapi.yaml                    ✅
postman/collections/FIT4110_lab04_iot_docker.postman_collection.json    ✅
postman/environments/FIT4110_lab04_local.postman_environment.json       ✅
reports/newman-lab04-local.html                         (Generate by running)
reports/newman-lab04-local.xml                          (Generate by running)
```

---

## 🔗 References

- [README.md](README.md) - Lab overview
- [RUN_LOCAL.md](RUN_LOCAL.md) - Detailed run instructions
- [docs/DOCKER_LAB_GUIDE.md](docs/DOCKER_LAB_GUIDE.md) - Dockerfile best practices
- [contracts/iot-ingestion.openapi.yaml](contracts/iot-ingestion.openapi.yaml) - API contract
- [src/iot_app/main.py](src/iot_app/main.py) - Application source
- Lab 03 repo - Reference for contract & test design

---

## 💡 Troubleshooting

**Docker not running?**
```bash
# Start Docker Desktop or daemon first
docker ps
```

**Port 8000 in use?**
```bash
# Change port in Makefile or use different port
docker run --rm -p 9000:8000 fit4110/iot-ingestion:lab04
```

**Tests fail?**
```bash
# Check container is still running
docker ps | grep iot-lab04

# View container logs
docker logs fit4110-iot-lab04

# Run test:mock first to verify Postman collection
npm run test:mock
```

**Build fails?**
```bash
# Ensure requirements.txt dependencies exist
pip install -r requirements.txt

# Rebuild image
docker build --no-cache -t fit4110/iot-ingestion:lab04 .
```

---

## 📝 Notes

- Service listens on `0.0.0.0:8000` inside container
- Port mapped to `localhost:8000` on host
- Health checks run every 30 seconds
- Non-root user prevents privilege escalation
- Multi-stage build reduces final image size
- No Python cache files in production image
- Environment variables configurable via `.env.example`

---

**Lab 04 Status:** ✅ Ready for Docker Testing  
**Last Updated:** June 2, 2026  
**Next Step:** Run Lab 05 Docker Compose & multi-service orchestration
