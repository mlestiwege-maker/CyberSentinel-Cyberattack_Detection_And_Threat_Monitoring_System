#!/usr/bin/env bash
set -euo pipefail

# Ensure we use the system Python, not any virtualenv
unset VIRTUAL_ENV
export PATH="/usr/bin:/usr/local/bin:$PATH"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
BACKEND_OWNED=false
PYTHON="/usr/bin/python3"
FRONTEND_MODE="${CYBER_SENTINEL_FRONTEND_MODE:-desktop}"
LOCAL_API_BASE_URL="http://127.0.0.1:8000"
REMOTE_API_BASE_URL="https://cybersentinel-cyberattack-detection-and.onrender.com"

port_is_free() {
	local port="$1"
	"$PYTHON" - "$port" <<'PY'
import socket, sys
port = int(sys.argv[1])
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.settimeout(0.2)
try:
	sock.bind(("127.0.0.1", port))
except OSError:
	sys.exit(1)
finally:
	sock.close()
sys.exit(0)
PY
}

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

if [[ "$FRONTEND_MODE" == "web" ]]; then
	# Optional web mode for Vercel/static preview.
	if [[ ! -f "$ROOT_DIR/build/web/index.html" ]]; then
		echo "[CyberSentinel] build/web is missing, building Flutter web..."
		flutter build web --release --no-wasm-dry-run --dart-define=API_BASE_URL="$REMOTE_API_BASE_URL"
	fi

	FRONTEND_PORT="${CYBER_SENTINEL_FRONTEND_PORT:-5000}"
	if ! port_is_free "$FRONTEND_PORT"; then
		for candidate in 5001 5002 5003 5004 5005 5006 5007 5008 5009 5010; do
			if port_is_free "$candidate"; then
				FRONTEND_PORT="$candidate"
				break
			fi
		done
	fi

	if ! port_is_free "$FRONTEND_PORT"; then
		echo "[CyberSentinel] No free frontend port found in 5000-5010. Stop the existing static server and try again."
		exit 1
	fi

	echo "[CyberSentinel] Serving web frontend at http://127.0.0.1:${FRONTEND_PORT}"
	(cd "$ROOT_DIR/build/web" && python3 -m http.server "$FRONTEND_PORT" --bind 127.0.0.1) &
	FRONTEND_PID=$!
	wait "$FRONTEND_PID"
else
	echo "[CyberSentinel] Starting desktop frontend on Linux..."
	flutter run -d linux --dart-define=API_BASE_URL="$LOCAL_API_BASE_URL"
fi
