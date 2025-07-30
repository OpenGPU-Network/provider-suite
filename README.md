# **OpenGPU Network Provider-Suite**

> **Requirements**
>
> * Docker **version 20.10.0** or higher (including Docker Compose v2 support)
> * Linux, macOS, or Windows host with Docker support

---

This guide explains two alternative ways to install and run the **Provider Suite**:

1. As a Docker Compose stack
2. As a single privileged container (Docker-in-Docker)

---

## 1. Docker Compose Stack Installation

**Recommended for:**

* Individual providers who want an easier, modular way to manage and monitor each service (recommended for home setups or single-machine deployments).
* Users who want modularity and want to manage each service independently.
* Environments where running multiple containers is possible.

### Steps

#### 1.1. Download the Compose File

First, download the latest `docker-compose.yml` directly from the official repository:

```bash
curl -o docker-compose.yml https://raw.githubusercontent.com/OpenGPU-Network/provider-suite/refs/heads/main/docker-compose.yml
```

#### 1.2. Prepare Environment Variables

You must provide at least the following variables:

* `PROVIDER_PRIVATE_KEY`
* `MASTER_ADDRESS`

There are two ways to set these variables:

* **A. Use a `.env` file:**
  Place a file named `.env` in the same directory as your `docker-compose.yml`. Example:

  ```env
  PROVIDER_PRIVATE_KEY=your_provider_private_key
  MASTER_ADDRESS=your_master_address
  ```

* **B. Export environment variables manually:**

  ```bash
  export PROVIDER_PRIVATE_KEY=your_provider_private_key
  export MASTER_ADDRESS=your_master_address
  ```

#### 1.3. Launch the Stack

```bash
docker compose up -d
```

> All services will start.
> View logs with:
>
> ```bash
> docker compose logs -f
> ```

#### 1.4. Stopping, Restarting, and Removing the Stack

To gracefully stop all running containers in the stack (without removing them):

```bash
docker compose stop
```

To restart stopped services:

```bash
docker compose start
```

To fully restart (stop, remove, and recreate) all services:

```bash
docker compose down
# then
docker compose up -d
```

To remove all containers, networks, and volumes:

```bash
docker compose down
```

---

## 2. Single Container (Docker-in-Docker) Installation

**Recommended for:**

* Cloud environments or platforms that require running everything inside a single container.
* Scenarios where Docker Compose is not supported.

In this setup, the stack runs inside a privileged container using the [docker-dind](https://hub.docker.com/r/chainguard/docker-dind/) base image.

### How to Run

Select the image suitable for your hardware:

#### A. CPU-only

```bash
docker run -d --name opengpu_network__provider_suite__cpu \
  --privileged \
  -e PROVIDER_PRIVATE_KEY='your_provider_private_key' \
  -e MASTER_ADDRESS='your_master_address' \
  opengpunetwork/provider-suite:cpu
```

#### B. NVIDIA CUDA GPU

```bash
docker run -d --name opengpu_network__provider_suite__cuda \
  --privileged --gpus all \
  -e PROVIDER_PRIVATE_KEY='your_provider_private_key' \
  -e MASTER_ADDRESS='your_master_address' \
  opengpunetwork/provider-suite:cuda
```

#### C. AMD ROCm GPU

```bash
docker run -d --name opengpu_network__provider_suite__rocm \
  --privileged --device /dev/kfd --device /dev/dri \
  -e PROVIDER_PRIVATE_KEY='your_provider_private_key' \
  -e MASTER_ADDRESS='your_master_address' \
  opengpunetwork/provider-suite:rocm
```

> **Note:** The `--privileged` flag is required for inner Docker engine access.
> For GPU support, ensure your host drivers and Docker runtime are properly configured.

---

## Graceful Shutdown

Both deployment methods support graceful shutdown:

* **For Compose:**

  * Stop all services (keep containers and volumes):

    ```bash
    docker compose stop
    ```
  * Remove all (containers, networks, volumes):

    ```bash
    docker compose down
    ```
* **For Single Container:**

  ```bash
  docker stop <container_name>
  docker rm <container_name>
  ```

---

## Troubleshooting & Support

* Ensure your Docker version supports required features (Compose v2, `--gpus all`, etc.).
* If you encounter permission issues, check your Docker daemon and user permissions.

---

## Security Warning

Never share your `PROVIDER_PRIVATE_KEY` or other secrets publicly.
Use secure secret management solutions in production.

---
