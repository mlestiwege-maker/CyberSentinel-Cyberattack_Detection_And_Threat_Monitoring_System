#!/usr/bin/env bash
set -euo pipefail

# Ensure we use the system Python, not any virtualenv
unset VIRTUAL_ENV
export PATH="/usr/bin:/usr/local/bin:$PATH"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
BACKEND_OWNED=false
PYTHON="/usr/bin/python3"

cleanup() {
	if [[ "$BACKEND_OWNED" == "true" ]] && [[ -n "${BACKEND_PID:-}" ]] && kill -0 "$BACKEND_PID" 2>/dev/null; then
		kill "$BACKEND_PID" 2>/dev/null || true
	fi

	# Kill frontend server if we started one
	if [[ -n "${FRONTEND_PID:-}" ]] && kill -0 "$FRONTEND_PID" 2>/dev/null; then
		kill "$FRONTEND_PID" 2>/dev/null || true
	fi
}

trap cleanup EXIT INT TERM

if curl -fsS http://127.0.0.1:8000/health >/dev/null 2>&1; then
	echo "[CyberSentinel] Backend already running on :8000, reusing it."
else
	echo "[CyberSentinel] Starting backend API..."
	cd "$BACKEND_DIR"
	PYTHONPATH="$BACKEND_DIR" $PYTHON -m uvicorn main:app --host 127.0.0.1 --port 8000 &
	BACKEND_PID=$!
	BACKEND_OWNED=true
fi

echo "[CyberSentinel] Waiting for backend health check..."
for _ in {1..30}; do
	if curl -fsS http://127.0.0.1:8000/health >/dev/null; then
		echo "[CyberSentinel] Backend is ready."
		break
	fi
	sleep 1
done

if [[ "$BACKEND_OWNED" == "true" ]] && ! kill -0 "$BACKEND_PID" 2>/dev/null; then
	echo "[CyberSentinel] Backend stopped unexpectedly."
	exit 1
fi

# Seed the database with the default admin user
echo "[CyberSentinel] Seeding database with default admin user..."
cd "$BACKEND_DIR"
PYTHONPATH="$BACKEND_DIR" $PYTHON seed_db.py

cd "$ROOT_DIR"
echo "[CyberSentinel] Installing Flutter dependencies..."
flutter pub get

# If a prebuilt web build exists, serve it as a static site (safe and fast).
if [[ -d "$ROOT_DIR/build/web" ]]; then
	echo "[CyberSentinel] Serving prebuilt web frontend at http://127.0.0.1:5000"
	(cd "$ROOT_DIR/build/web" && python3 -m http.server 5000) &
	FRONTEND_PID=$!
else
	echo "[CyberSentinel] Starting frontend on Linux..."
	flutter run -d linux
fi
