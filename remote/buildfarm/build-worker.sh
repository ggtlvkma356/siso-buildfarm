#!/bin/bash
set -euo pipefail

BUILDFARM_VERSION="2.16.0"
INTERMEDIATE_IMAGE="siso-chromium-with-java"
FINAL_IMAGE="buildfarm-chromium-worker"

echo "Step 1: Pull base images"
podman pull gcr.io/chops-public-images-prod/rbe/siso-chromium/linux:latest
podman pull bazelbuild/buildfarm-worker:${BUILDFARM_VERSION}

echo "Step 2: Install Java and dependencies into siso-chromium"
podman rm -f buildfarm-build 2>/dev/null || true
podman run --name buildfarm-build \
  gcr.io/chops-public-images-prod/rbe/siso-chromium/linux:latest \
  bash -c "apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openjdk-21-jdk-headless \
    libfuse2 \
    cgroup-tools && \
    rm -rf /var/lib/apt/lists/*"

echo "Step 3: Commit intermediate image"
podman commit buildfarm-build "$INTERMEDIATE_IMAGE"
podman rm buildfarm-build

echo "Step 4: Build final combined image"
podman build \
  --no-cache \
  --build-arg BUILDFARM_VERSION=${BUILDFARM_VERSION} \
  -t "$FINAL_IMAGE" -f Dockerfile.worker .

echo "Done! "
echo "Image built: $FINAL_IMAGE (BuildFarm ${BUILDFARM_VERSION})"
echo "Verify with: podman run --rm --entrypoint java $FINAL_IMAGE -version"
