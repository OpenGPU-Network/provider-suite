#!/bin/sh
set -euo pipefail

# ---------------- settings ----------------
DOCKER_SOCK="${DOCKER_SOCK:-unix:///var/run/docker.sock}"
COMPOSE_FILE_PATH="${COMPOSE_FILE_PATH:-/app/docker-compose.yml}"
STORAGE_DRIVER="${STORAGE_DRIVER:-vfs}"
WAIT_LIMIT="${WAIT_LIMIT:-60}"
EXTRA_COMPOSE_ARGS="${EXTRA_COMPOSE_ARGS:-}"   # e.g. "--pull --quiet-pull"


# Docker client will talk to the inner daemon
unset DOCKER_HOST
export DOCKER_HOST="$DOCKER_SOCK"

# Prevent stale PID errors
rm -f /var/run/docker.pid

# ---------------- start inner dockerd ----------------
dockerd --host="$DOCKER_SOCK" --storage-driver="$STORAGE_DRIVER" \
  >/var/log/dockerd.log 2>&1 &
DOCKERD_PID=$!

# Compose wrapper: prefer v2, fallback to v1
compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    echo "[entrypoint] ERROR: Docker Compose is not installed." >&2
    exit 1
  fi
}

# Graceful shutdown
cleanup() {
  echo "[entrypoint] Stopping provider-app ..."
  # Use absolute -f path; no reliance on current directory
  compose -f "$COMPOSE_FILE_PATH" stop || true
  kill -SIGTERM "$DOCKERD_PID" || true
  wait "$DOCKERD_PID" || true
  rm -f /var/run/docker.pid
  exit 0
}
trap cleanup SIGTERM SIGINT

# Wait for dockerd to be usable
echo "[entrypoint] Waiting for inner dockerd ..."
for i in $(seq 1 "$WAIT_LIMIT"); do
  if docker ps >/dev/null 2>&1; then
    echo "[entrypoint] dockerd is ready."
    break
  fi
  sleep 1
done

# Change to compose directory
COMPOSE_DIR="$(dirname "$COMPOSE_FILE_PATH")"
COMPOSE_FILE_BASENAME="$(basename "$COMPOSE_FILE_PATH")"
cd "$COMPOSE_DIR"
echo "[entrypoint] Launching provider-app ..."
compose -f "$COMPOSE_FILE_BASENAME" $EXTRA_COMPOSE_ARGS up -d

# Keep PID1 alive
echo "[entrypoint] provider-app is running. PID1 is dockerd ($DOCKERD_PID)."
wait "$DOCKERD_PID"
