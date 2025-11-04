# Development-to-Deployment Workflow Guide

## Overview

This guide outlines the workflow for developing containers on your PC and deploying them to your homelab server using Docker Hub.

## Workflow Architecture

```
PC (Development)                    Docker Hub                    Server (Production)
    |                                      |                              |
    |-- Build Image                       |                              |
    |-- Tag Image                         |                              |
    |-- Push Image ---------------------->|                              |
    |                                      |                              |
    |                                      |-- Pull Image --------------->|
    |                                      |                              |
    |                                      |                    Deploy Container
```

## Prerequisites

### On Your PC (Development Machine)
1. Docker Desktop or Docker Engine installed
2. Docker Hub account created
3. Git configured for your projects

### On Your Server (Production)
1. Docker Engine installed and running
2. Docker Hub credentials configured (optional, for private repos)
3. Access to `homelab-web` network

## Step-by-Step Workflow

### 1. Development on PC

#### Build Your Application Image
```bash
# Navigate to your project directory on PC
cd ~/projects/your-app

# Build the image
docker build -t your-username/your-app:latest .

# Test locally
docker run -p 8080:8080 your-username/your-app:latest
```

#### Version Tagging Strategy
```bash
# Tag with version number
docker tag your-username/your-app:latest your-username/your-app:v1.0.0

# Tag with development tag
docker tag your-username/your-app:latest your-username/your-app:dev

# Tag with date tag
docker tag your-username/your-app:latest your-username/your-app:2025-11-03
```

### 2. Push to Docker Hub

#### Login to Docker Hub
```bash
# Login from your PC
docker login

# Or use token
docker login -u your-username -p your-token
```

#### Push Images
```bash
# Push latest
docker push your-username/your-app:latest

# Push versioned tag
docker push your-username/your-app:v1.0.0

# Push all tags
docker push your-username/your-app --all-tags
```

### 3. Deployment on Server

#### Pull and Deploy
```bash
# SSH to server
ssh chris@hephaestus

# Navigate to app directory
cd ~/apps/your-app

# Pull latest image
docker pull your-username/your-app:latest

# Or use docker compose (recommended)
docker compose -f docker-compose-homelab.yml pull
docker compose -f docker-compose-homelab.yml up -d
```

#### Update Existing Container
```bash
# Stop container
docker compose -f docker-compose-homelab.yml down

# Pull new image
docker compose -f docker-compose-homelab.yml pull

# Start with new image
docker compose -f docker-compose-homelab.yml up -d
```

## Docker Compose Configuration

### Development docker-compose.yml (PC)
```yaml
version: '3.8'

services:
  your-app:
    build:
      context: .
      dockerfile: Dockerfile
    image: your-username/your-app:dev
    ports:
      - "8080:8080"
    environment:
      - NODE_ENV=development
    volumes:
      - ./src:/app/src
      - ./logs:/app/logs
```

### Production docker-compose-homelab.yml (Server)
```yaml
version: '3.8'

networks:
  web:
    external: true
    name: homelab-web

services:
  your-app:
    image: your-username/your-app:latest  # Pulls from Docker Hub
    container_name: your-app
    restart: unless-stopped
    networks:
      - web
    ports:
      - "81XX:8080"
    environment:
      - NODE_ENV=production
    volumes:
      - your_app_data:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  your_app_data:
```

## Automated Workflow Scripts

### Build and Push Script (PC)
```bash
#!/bin/bash
# build-push.sh

APP_NAME="your-app"
USERNAME="your-username"
VERSION=${1:-latest}

echo "Building $APP_NAME:$VERSION..."
docker build -t $USERNAME/$APP_NAME:$VERSION .

echo "Tagging as latest..."
docker tag $USERNAME/$APP_NAME:$VERSION $USERNAME/$APP_NAME:latest

echo "Pushing to Docker Hub..."
docker push $USERNAME/$APP_NAME:$VERSION
docker push $USERNAME/$APP_NAME:latest

echo "Done! Image available at: docker.io/$USERNAME/$APP_NAME:$VERSION"
```

### Deployment Script (Server)
```bash
#!/bin/bash
# deploy.sh

APP_NAME="your-app"
APP_DIR=~/apps/$APP_NAME

cd $APP_DIR

echo "Pulling latest image..."
docker compose -f docker-compose-homelab.yml pull

echo "Stopping existing container..."
docker compose -f docker-compose-homelab.yml down

echo "Starting new container..."
docker compose -f docker-compose-homelab.yml up -d

echo "Waiting for health check..."
sleep 10

echo "Checking status..."
docker compose -f docker-compose-homelab.yml ps
```

## Best Practices

### Image Tagging
- **latest**: Always points to most recent stable release
- **v1.0.0**: Semantic versioning for releases
- **dev**: Development builds
- **YYYY-MM-DD**: Date-based tags for snapshots

### Security
- Use Docker Hub private repositories for sensitive applications
- Use Docker secrets for credentials
- Scan images for vulnerabilities: `docker scan your-image`

### CI/CD Integration
- Use GitHub Actions for automated builds
- Push to Docker Hub on successful builds
- Tag releases automatically

### Rollback Strategy
```bash
# Keep previous version tagged
docker tag your-username/your-app:latest your-username/your-app:previous

# If new version fails, rollback
docker compose -f docker-compose-homelab.yml pull your-username/your-app:previous
docker compose -f docker-compose-homelab.yml up -d
```

## Troubleshooting

### Image Not Found
```bash
# Check if image exists on Docker Hub
docker search your-username/your-app

# Pull explicitly
docker pull your-username/your-app:latest
```

### Authentication Issues
```bash
# Login again
docker login

# Check credentials
cat ~/.docker/config.json
```

### Network Issues
```bash
# Ensure homelab-web network exists
docker network ls | grep homelab-web

# Create if missing
docker network create homelab-web
```

## Example Workflow

### Complete Example: Portfolio App

**On PC:**
```bash
cd ~/projects/portfolio
docker build -t chrislawrence/portfolio:latest .
docker push chrislawrence/portfolio:latest
```

**On Server:**
```bash
cd ~/apps/portfolio
docker compose -f docker-compose-homelab.yml pull
docker compose -f docker-compose-homelab.yml up -d
```

## MCP Server/Toolkit Integration

### Docker Engine with MCP
- MCP Server can connect to Docker Engine via socket: `/var/run/docker.sock`
- Works with Portainer for GUI management
- CLI tools work seamlessly

### Docker Desktop with MCP
- Has built-in plugin support
- GUI integration available
- May have remote desktop conflicts

**Recommendation**: Use Docker Engine + Portainer for server (best of both worlds)

## Related Documentation

- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Network Architecture](../context/homelab/infra/networks.md)
- [Deployment Guide](../context/homelab/infra/deployment.md)

---

**Last Updated**: 2025-11-03
**Version**: 1.0

