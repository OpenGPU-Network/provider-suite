# OpenGPU Network Provider-Suite


docker run -d --name opengpu_network__provider_suite__cpu \
  --privileged \
  -e PROVIDER_PRIVATE_KEY='your_provider_private_key' \
  -e MASTER_ADDRESS='your_master_address' \
  opengpunetwork/provider-suite:cpu


docker run -d --name opengpu_network__provider_suite__cuda \
  --privileged --gpus all \
  -e PROVIDER_PRIVATE_KEY='your_provider_private_key' \
  -e MASTER_ADDRESS='your_master_address' \
  opengpunetwork/provider-suite:cuda


docker run -d --name opengpu_network__provider_suite__rocm \
  --privileged --device /dev/kfd --device /dev/dri \
  -e PROVIDER_PRIVATE_KEY='your_provider_private_key' \
  -e MASTER_ADDRESS='your_master_address' \
  opengpunetwork/provider-suite:rocm
