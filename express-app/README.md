# express-app

[![Build, Push, and Deploy](https://github.com/mosetemi/tv-devops-assessment/actions/workflows/deploy.yml/badge.svg)](https://github.com/mosetemi/tv-devops-assessment/actions/workflows/deploy.yml)

---

## Table of Contents

- [Local Development](#local-development)
- [Docker Setup](#docker-setup)
- [CI/CD Pipeline](#cicd-pipeline)
- [Design Decisions](#design-decisions)

---

## Local Development

**1. Install dependencies:**
```bash
npm install
```

**2. Run in development mode:**
```bash
npm run dev
```

**3. Verify the app is running:**
```bash
curl http://localhost:3000/health
# Expected: {"status":"ok"}
```

---

## Docker Setup

### Running with Docker directly

```bash
docker build -t express-ts-app .
```
```bash
docker run -d -p 3000:3000 --name express-ts-app express-ts-app
```

**Test the health endpoint:**
```bash
curl http://localhost:3000/health
# Expected: {"status":"ok"}
```
### Running with Docker Compose (recommended)
**Build and start the container:**
```bash
docker compose up
```

**Verify the health endpoint:**
```bash
curl http://localhost:3000/health
# Expected: {"status":"ok"}
```

**Stop the container:**
```bash
docker compose down
```
### Dockerfile overview

The Dockerfile uses a **multi-stage build** to keep the final production image small/lite:

- **Stage 1 (build):** Installs all dependencies and compiles `src/` → `dist/`
- **Stage 2 (production):** Starts fresh from a clean base image, installs only production dependencies, and copies only the compiled `dist/` output — no source files, no TypeScript compiler, no dev tooling in the final image

---

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) triggers automatically on every push to `main`

---

## Design Decisions

### Multi-stage Dockerfile
The Dockerfile uses a two-stage build so the final production image contains only compiled JavaScript and production `node_modules` — no TypeScript compiler, no source files, no dev tooling. This keeps the image small and reduces the attack surface.

### Separate `express-app` and `express-app-iac` repositories
The application code and infrastructure code are intentionally kept in separate repositories, following the principle that application deployments and infrastructure changes should be independently versioned and auditable. The CI/CD workflow in `express-app` checks out `express-app-iac` at deploy time using a scoped Personal Access Token.