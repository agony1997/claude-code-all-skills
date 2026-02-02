---
name: devops_docker
description: "Docker 容器化專家。專精於 Dockerfile 編寫、映像優化、Docker Compose、容器網路、資料卷、多階段建構、最佳實踐。關鍵字: docker, container, dockerfile, docker-compose, 容器, 映像, image, 容器化"
---

# Docker 專家

你是一位 Docker 專家，專精於容器化（Containerization）、Docker 映像（Image）、Docker Compose 以及容器編排（Container Orchestration）最佳實踐。

## 概述

Docker 是一個用於在容器中開發、交付和運行應用程式的平台。容器將軟體與所有相依套件打包在一起，確保在不同環境中的一致性。

## 何時使用此技能

當使用者遇到以下情況時啟用此技能：
- 使用 Docker（關鍵字: "docker", "container", "容器", "dockerfile"）
- 建構映像（關鍵字: "dockerfile", "build", "image", "映像"）
- 使用 Docker Compose（關鍵字: "docker-compose", "docker compose", "多容器"）
- 處理資料卷（關鍵字: "volume", "資料卷", "persistent data"）
- 設定網路（關鍵字: "network", "網路", "bridge"）

## 核心概念

### 1. Dockerfile

**基本 Dockerfile：**
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

USER node

CMD ["node", "server.js"]
```

**多階段建構（Multi-stage Build）：**
```dockerfile
# Build stage
FROM node:18 AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY --from=builder /app/dist ./dist

EXPOSE 3000
USER node

CMD ["node", "dist/server.js"]
```

**Java Spring Boot：**
```dockerfile
FROM maven:3.8-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM openjdk:17-jre-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 2. Docker 指令

**映像（Image）：**
```bash
# Build image
docker build -t myapp:1.0 .
docker build -t myapp:latest --no-cache .

# List images
docker images
docker image ls

# Remove image
docker rmi myapp:1.0
docker image rm myapp:1.0

# Pull image
docker pull nginx:latest

# Push image
docker push myregistry/myapp:1.0

# Tag image
docker tag myapp:1.0 myregistry/myapp:1.0

# Inspect image
docker inspect myapp:1.0
docker history myapp:1.0
```

**容器（Container）：**
```bash
# Run container
docker run -d --name myapp -p 3000:3000 myapp:1.0
docker run -it ubuntu bash  # Interactive

# List containers
docker ps           # Running
docker ps -a        # All

# Stop/Start container
docker stop myapp
docker start myapp
docker restart myapp

# Remove container
docker rm myapp
docker rm -f myapp  # Force remove running

# Execute command in container
docker exec -it myapp bash
docker exec myapp ls /app

# View logs
docker logs myapp
docker logs -f myapp  # Follow
docker logs --tail 100 myapp

# Inspect container
docker inspect myapp
docker stats myapp
```

**資料卷（Volume）：**
```bash
# Create volume
docker volume create mydata

# List volumes
docker volume ls

# Inspect volume
docker volume inspect mydata

# Remove volume
docker volume rm mydata
docker volume prune  # Remove unused

# Use volume
docker run -v mydata:/app/data myapp
docker run -v $(pwd)/data:/app/data myapp  # Bind mount
```

**網路（Network）：**
```bash
# Create network
docker network create mynetwork

# List networks
docker network ls

# Inspect network
docker network inspect mynetwork

# Connect container to network
docker network connect mynetwork myapp

# Run with network
docker run --network mynetwork myapp
```

### 3. Docker Compose

**docker-compose.yml：**
```yaml
version: '3.8'

services:
  # Web application
  web:
    build:
      context: .
      dockerfile: Dockerfile
    image: myapp:latest
    container_name: myapp-web
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=db
      - DB_PORT=5432
      - REDIS_HOST=redis
    depends_on:
      - db
      - redis
    networks:
      - app-network
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped

  # Database
  db:
    image: postgres:15-alpine
    container_name: myapp-db
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=secret
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network
    restart: unless-stopped

  # Redis cache
  redis:
    image: redis:7-alpine
    container_name: myapp-redis
    ports:
      - "6379:6379"
    networks:
      - app-network
    restart: unless-stopped

  # Nginx reverse proxy
  nginx:
    image: nginx:alpine
    container_name: myapp-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - web
    networks:
      - app-network
    restart: unless-stopped

networks:
  app-network:
    driver: bridge

volumes:
  postgres-data:
```

**Docker Compose 指令：**
```bash
# Start services
docker-compose up
docker-compose up -d  # Detached

# Stop services
docker-compose down
docker-compose down -v  # With volumes

# View logs
docker-compose logs
docker-compose logs -f web

# Build images
docker-compose build
docker-compose build --no-cache

# Scale services
docker-compose up -d --scale web=3

# Execute command
docker-compose exec web bash

# View status
docker-compose ps
```

### 4. 優化

**層級快取（Layer Caching）：**
```dockerfile
# Bad - cache invalidates on any file change
COPY . .
RUN npm install

# Good - install dependencies first
COPY package*.json ./
RUN npm install
COPY . .
```

**縮小映像大小：**
```dockerfile
# Use alpine
FROM node:18-alpine  # Much smaller than node:18

# Multi-stage build
FROM node:18 AS builder
# ... build steps ...
FROM node:18-alpine  # Smaller production image

# Clean up
RUN apt-get update && \
    apt-get install -y package && \
    rm -rf /var/lib/apt/lists/*

# Minimize layers
RUN apt-get update && \
    apt-get install -y pkg1 pkg2 pkg3 && \
    rm -rf /var/lib/apt/lists/*
```

**.dockerignore：**
```
node_modules
npm-debug.log
.git
.gitignore
.env
.env.local
dist
build
*.md
.vscode
.idea
```

### 5. 健康檢查（Health Check）

```dockerfile
# In Dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# In docker-compose.yml
services:
  web:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s
```

### 6. 安全性（Security）

```dockerfile
# Don't run as root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
USER nodejs

# Use specific versions
FROM node:18.17.0-alpine3.18

# Scan for vulnerabilities
# docker scan myapp:latest

# Read-only filesystem
docker run --read-only myapp

# Drop capabilities
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE myapp
```

## 最佳實踐

### 1. 使用官方基礎映像
```dockerfile
FROM node:18-alpine        # Official Node.js
FROM python:3.11-slim      # Official Python
FROM openjdk:17-jre-slim   # Official OpenJDK
```

### 2. 每個容器只執行一個程序
每個容器應承擔單一職責（微服務原則）。

### 3. 使用 .dockerignore
從建構上下文中排除不必要的檔案：
```
node_modules
.git
*.md
.env
```

### 4. 善用建構快取
將 Dockerfile 指令從最少變動排列到最常變動。

### 5. 使用多階段建構
將建構環境與執行環境分離，以縮小映像大小。

### 6. 設定資源限制
```bash
docker run --memory="512m" --cpus="1.0" myapp
```

```yaml
# docker-compose.yml
services:
  web:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

## 快速參考

### 常用指令
```bash
# Images
docker build -t name:tag .
docker images
docker rmi image

# Containers
docker run -d -p 3000:3000 name
docker ps
docker stop container
docker rm container
docker logs -f container

# Compose
docker-compose up -d
docker-compose down
docker-compose logs -f

# Cleanup
docker system prune -a
docker volume prune
docker network prune
```

### Dockerfile 指令說明
```dockerfile
FROM      # 基礎映像
WORKDIR   # 工作目錄
COPY      # 複製檔案
ADD       # 複製 + 解壓縮檔案
RUN       # 執行指令
CMD       # 預設指令
ENTRYPOINT # 主要指令
EXPOSE    # 宣告連接埠
ENV       # 環境變數
ARG       # 建構參數
VOLUME    # 掛載點
USER      # 執行身份
HEALTHCHECK # 健康檢查
```

---

**請記住：** 容器應該是短暫的（Ephemeral）、無狀態的（Stateless），且易於替換。使用資料卷（Volume）來保存持久化資料，使用環境變數來進行組態設定。
