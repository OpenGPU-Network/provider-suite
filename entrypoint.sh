#!/bin/sh
set -euo pipefail

# ────────── vars ──────────
DOCKER_SOCK=unix:///var/run/docker.sock
COMPOSE_FILE_PATH="${COMPOSE_FILE_PATH:-/stack/docker-compose.yml}"
ENV_FILE_PATH="${ENV_FILE_PATH:-/stack/.env}"
STORAGE_DRIVER="${STORAGE_DRIVER:-vfs}"
WAIT_LIMIT="${WAIT_LIMIT:-60}"

unset DOCKER_HOST
export DOCKER_HOST="$DOCKER_SOCK"

# ────────── start dockerd ──────────
rm -f /var/run/docker.pid

dockerd \
  --host="$DOCKER_SOCK" \
  --storage-driver="$STORAGE_DRIVER" \
  >/var/log/dockerd.log 2>&1 &
DOCKERD_PID=$!

# graceful shutdown
cleanup() {
  echo "[entrypoint] Stopping inner stack …"
  docker compose --env-file "$ENV_FILE_PATH" -f "$COMPOSE_FILE_PATH" stop || true
  kill -SIGTERM "$DOCKERD_PID"
  wait "$DOCKERD_PID"
  rm -f /var/run/docker.pid
  exit 0
}
trap cleanup SIGTERM SIGINT

# ────────── wait for dockerd ──────────
echo "[entrypoint] Waiting for inner dockerd ..."
for i in $(seq 1 "$WAIT_LIMIT"); do
  if docker ps >/dev/null 2>&1; then
    echo "[entrypoint] dockerd is ready."
    break
  fi
  sleep 1
done

# ────────── bring up compose ──────────
echo "[entrypoint] Launching inner compose stack ..."
docker compose --env-file "$ENV_FILE_PATH" -f "$COMPOSE_FILE_PATH" up -d

# ────────── keep container alive, no tail ──────────
wait "$DOCKERD_PID"
# ────────── end ──────────