# Docker & local dev

Quick notes to run the backend in Docker for local development.

Build the backend image:

```bash
docker build -t cybersentinel-backend:local -f backend/Dockerfile backend
```

Run with docker-compose (recommended for local dev):

```bash
# create backend/.env from backend/.env.example with real values (DO NOT COMMIT)
docker compose up --build
```

Kubernetes:

- Update the image in `k8s/backend-deployment.yaml` to your registry (e.g., ghcr.io/org/name:tag) and apply:

```bash
kubectl apply -f k8s/backend-deployment.yaml
```

Notes:
- Secrets must be provided through Kubernetes Secrets or your cloud provider's secret store.
- The repo includes `backend/.env.example` — copy it to `backend/.env` locally and populate real secrets.
