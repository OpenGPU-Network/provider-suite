###############################################################################
# 0. Common base (Docker‑in‑Docker image)
###############################################################################
ARG BASE_IMAGE=docker:27-dind
FROM ${BASE_IMAGE} AS base

ENV DOCKER_TLS_CERTDIR="" \
    STORAGE_DRIVER=vfs \
    COMPOSE_FILE_PATH=/stack/docker-compose.yml \
    ENV_FILE_PATH=/stack/.env

WORKDIR /stack
RUN touch /stack/docker-compose.yml /stack/.env

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Make our script the entrypoint (overrides the parent image’s ENTRYPOINT)
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

###############################################################################
# 1. CPU‑only image (default)
###############################################################################
FROM base AS cpu
# nothing else to install

###############################################################################
# 2. NVIDIA image
###############################################################################
FROM base AS nvidia
RUN apk add --no-cache nvidia-container-toolkit nvidia-container-cli
# Register NVIDIA runtime
RUN printf '%s\n' \
  '{' \
  '  "default-runtime": "nvidia",' \
  '  "runtimes": { "nvidia": { "path": "nvidia-container-runtime", "runtimeArgs": [] } }' \
  '}' > /etc/docker/daemon.json

###############################################################################
# 3. ROCm image
###############################################################################
FROM base AS rocm
RUN apk add --no-cache rocm-container-runtime
# Register ROCm runtime
RUN printf '%s\n' \
  '{' \
  '  "default-runtime": "rocrun",' \
  '  "runtimes": { "rocrun": { "path": "/opt/rocm/bin/rocrun", "runtimeArgs": [] } }' \
  '}' > /etc/docker/daemon.json

###############################################################################
# 4. Default export (CPU) if no --target specified
###############################################################################
FROM cpu AS final
