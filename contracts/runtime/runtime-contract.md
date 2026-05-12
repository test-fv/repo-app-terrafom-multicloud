# Runtime Contract

## Objective

Every provider must satisfy these operational requirements:

- Docker installed
- Docker enabled at boot
- Registry authentication supported
- Container deployment supported
- Restart policy enabled
- Port 80 exposed
- SSH access enabled

## Required Runtime Variables

- REGISTRY_URL
- IMAGE_NAME
- IMAGE_TAG
- CLOUD_PROVIDER

## Deployment Semantics

Deployment must:
1. Pull latest image
2. Stop previous container
3. Remove previous container
4. Start new container
5. Enable restart policy