# 🐮 千牛 - 阿里云 ECS 部署指南

## 📋 概述

本指南说明如何在阿里云 ECS 上部署"千牛"管理系统，并自动从 GitHub Actions 拉取已构建的 Docker 镜像。

## 🚀 部署流程

### 总体架构

```
GitHub Actions 自动构建 Docker 镜像
           ↓
   推送到 GHCR (GitHub 容器注册表)
           ↓
  阿里云 ECS 定期拉取最新镜像
           ↓
   Docker Compose 启动服务
           ↓
  通过浏览器访问应用
```

## 📦 前置准备

### 1. 阿里云 ECS 实例配置

**推荐配置：**
- 实例类型：ecs.t6-c1m2.large 或更高
- CPU：2核
- 内存：4GB
- 系统盘：50GB SSD
- 操作系统：Ubuntu 20.04 LTS 或 CentOS 8

### 2. 安全组规则

在阿里云控制台配置以下入站规则：

| 协议 | 端口 | 来源 | 说明 |
|------|------|------|------|
| TCP | 22 | 0.0.0.0/0 | SSH 远程连接 |
| TCP | 80 | 0.0.0.0/0 | HTTP 前端 |
| TCP | 8080 | 0.0.0.0/0 | 前端服务（可选） |
| TCP | 48080 | 0.0.0.0/0 | 后端 API（可选） |
| TCP | 443 | 0.0.0.0/0 | HTTPS（如需 SSL） |

### 3. 创建密钥对

推荐使用密钥对而非密码连接 ECS：

1. 在阿里云控制台 → 密钥对 → 创建密钥对
2. 下载 `.pem` 文件并保存到安全位置
3. 设置权限：`chmod 400 your-key.pem`

## 🔧 阿里云 ECS 初始化配置

### 步骤 1: 连接到 ECS

```bash
# 使用密钥对连接 (Ubuntu)
ssh -i your-key.pem ubuntu@your_aliyun_ip

# 或使用密钥对连接 (CentOS)
ssh -i your-key.pem root@your_aliyun_ip

# 或使用密码连接 (首次使用密码，之后改成密钥)
ssh root@your_aliyun_ip
```

### 步骤 2: 系统更新

```bash
# Ubuntu 20.04
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl wget git

# 或 CentOS 8
sudo yum update -y
sudo yum install -y curl wget git
```

### 步骤 3: 安装 Docker 和 Docker Compose

```bash
# 安装 Docker（使用官方脚本）
curl -fsSL https://get.docker.com -o get-docker.sh
sudo bash get-docker.sh

# 添加当前用户到 docker 组（避免每次都用 sudo）
sudo usermod -aG docker $USER
newgrp docker

# 验证 Docker 安装
docker --version

# 安装 Docker Compose（V2 版本）
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### 步骤 4: 创建项目目录

```bash
# 创建应用目录
sudo mkdir -p /opt/qianniu
cd /opt/qianniu

# 如果是 root 用户，可以跳过 sudo
sudo chown -R $USER:$USER /opt/qianniu
```

## 📥 部署千牛应用

### 方案 A：从源码克隆并使用本地构建的镜像

```bash
cd /opt/qianniu

# 克隆项目
git clone https://github.com/zongyangbigpolo/qianniu.git .

# 进入 Docker 配置目录
cd script/docker

# 创建环境变量文件
cp .env.example .env

# 编辑环境变量（修改密码等）
vim .env

# 构建镜像（注意：这会在本地构建，需要 Java 环境）
docker-compose build

# 或者，如果已在 GitHub Actions 中构建，直接启动
docker-compose up -d
```

### 方案 B：只拉取预构建的 Docker 镜像（推荐 ⭐）

这个方案最简单，因为 GitHub Actions 已经为你构建好了镜像！

```bash
cd /opt/qianniu

# 1. 创建 docker-compose 文件（只需要这一个文件）
cat > docker-compose.yml << 'EOF'
version: "3.8"

name: qianniu-system

services:
  mysql:
    container_name: qianniu-mysql
    image: mysql:8
    restart: unless-stopped
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: qianniu
      MYSQL_ROOT_PASSWORD: your_mysql_password
    volumes:
      - mysql_data:/var/lib/mysql/
    networks:
      - qianniu-net

  redis:
    container_name: qianniu-redis
    image: redis:6-alpine
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - qianniu-net

  server:
    container_name: qianniu-server
    image: ghcr.io/zongyangbigpolo/qianniu:main
    restart: unless-stopped
    ports:
      - "48080:48080"
    environment:
      SPRING_PROFILES_ACTIVE: local
      JAVA_OPTS: -Xms512m -Xmx1024m
      ARGS: >
        --spring.datasource.dynamic.datasource.master.url=jdbc:mysql://qianniu-mysql:3306/qianniu?useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
        --spring.datasource.dynamic.datasource.master.username=root
        --spring.datasource.dynamic.datasource.master.password=your_mysql_password
        --spring.data.redis.host=qianniu-redis
    depends_on:
      - mysql
      - redis
    networks:
      - qianniu-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:48080/swagger-ui"]
      interval: 30s
      timeout: 10s
      retries: 3

  admin:
    container_name: qianniu-admin
    image: nginx:latest
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - server
    networks:
      - qianniu-net

volumes:
  mysql_data:
    driver: local
  redis_data:
    driver: local

networks:
  qianniu-net:
    driver: bridge
EOF

# 2. 创建 Nginx 配置文件
cat > nginx.conf << 'EOF'
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    gzip on;

    upstream backend {
        server qianniu-server:48080;
    }

    server {
        listen 80;
        server_name _;
        client_max_body_size 100M;

        # 前端
        location / {
            index index.html index.htm;
            error_page 404 =200 /index.html;
        }

        # 后端 API
        location /prod-api {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

# 3. 修改环境变量
vim docker-compose.yml
# 需要修改的字段：
# - MYSQL_ROOT_PASSWORD: 改成你的强密码
# - password=xxx: 两处都要改

# 4. 启动所有服务
docker-compose up -d

# 5. 查看服务状态
docker-compose ps

# 6. 查看日志
docker-compose logs -f server
```

## 🔄 自动更新部署

为了让部署自动拉取 GitHub Actions 构建的最新镜像，可以使用 Watchtower 工具：

```bash
# 1. 创建 Watchtower 容器（自动更新其他容器镜像）
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ghcr.io/containrrr/watchtower \
  --cleanup \
  --interval 3600 \
  --trace

# 2. 或者手动定期更新（使用 cron）
# 编辑 crontab
crontab -e

# 添加以下行（每天凌晨2点更新）
0 2 * * * cd /opt/qianniu && docker-compose pull && docker-compose up -d
```

## 🌐 配置域名和 HTTPS（可选）

### 使用阿里云 DNS 配置域名

1. 在阿里云控制台 → 域名列表 → 解析设置
2. 添加 A 记录指向你的 ECS IP 地址
3. 配置 SSL 证书（免费 1 年）

### 使用 Nginx 配置 HTTPS

```bash
# 1. 安装 Certbot（Let's Encrypt 证书管理）
sudo apt install certbot python3-certbot-nginx -y

# 2. 申请证书
sudo certbot certonly --standalone -d your-domain.com -d www.your-domain.com

# 3. 配置自动续期
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# 4. 修改 Nginx 配置使用 HTTPS
# 编辑 nginx.conf，在 server 块中：
# listen 443 ssl;
# ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
```

## 📊 常用运维命令

```bash
cd /opt/qianniu

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f server      # 后端日志
docker-compose logs -f admin       # 前端日志
docker-compose logs -f mysql       # 数据库日志

# 重启服务
docker-compose restart server

# 停止服务
docker-compose stop

# 启动服务
docker-compose start

# 完全停止并删除（危险！）
docker-compose down

# 进入容器
docker exec -it qianniu-server bash

# 查看 Docker 资源占用
docker stats

# 清理无用镜像和容器
docker image prune -a
docker container prune

# 查看数据库日志
docker logs qianniu-mysql

# 备份数据库
docker exec qianniu-mysql mysqldump -u root -pyour_password qianniu > backup.sql

# 恢复数据库
cat backup.sql | docker exec -i qianniu-mysql mysql -u root -pyour_password qianniu
```

## 🔐 安全建议

1. **修改默认密码**
   - MySQL root 密码
   - Redis 密码（如需要）
   - 应用内置 admin 账户密码

2. **配置防火墙**
   ```bash
   # Ubuntu 使用 ufw
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

3. **定期备份**
   ```bash
   # 创建备份脚本
   cat > /opt/qianniu/backup.sh << 'BACKUP_EOF'
   #!/bin/bash
   BACKUP_DIR="/opt/qianniu/backups"
   mkdir -p $BACKUP_DIR
   docker exec qianniu-mysql mysqldump -u root -p${MYSQL_PASSWORD} qianniu | gzip > $BACKUP_DIR/qianniu_$(date +%Y%m%d_%H%M%S).sql.gz
   # 删除 7 天前的备份
   find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
   BACKUP_EOF
   
   chmod +x /opt/qianniu/backup.sh
   
   # 添加到 crontab（每天凌晨 3 点）
   crontab -e
   # 添加：0 3 * * * /opt/qianniu/backup.sh
   ```

4. **监控日志**
   ```bash
   # 实时监控错误日志
   docker-compose logs -f --tail=50 | grep -i error
   ```

## 🐛 故障排除

### 问题 1: 镜像拉取失败

```bash
# 检查 Docker 能否连接到 GHCR
docker login ghcr.io -u your_username

# 如果网络慢，可以配置镜像加速（阿里云）
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "https://registry.aliyuncs.com"
  ]
}
EOF

# 重启 Docker
sudo systemctl restart docker
```

### 问题 2: 内存不足

```bash
# 检查内存使用
free -h
docker stats

# 增加 swap（如需要）
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 问题 3: 磁盘空间不足

```bash
# 检查磁盘
df -h

# 清理 Docker 镜像和容器
docker image prune -a -f
docker container prune -f

# 清理日志
docker exec qianniu-mysql truncate -s 0 /var/log/mysql/error.log
```

### 问题 4: 无法连接数据库

```bash
# 检查 MySQL 容器状态
docker-compose ps mysql

# 查看 MySQL 日志
docker-compose logs mysql

# 进入 MySQL 容器测试
docker exec -it qianniu-mysql mysql -u root -p
# 然后输入密码

# 检查网络连接
docker exec qianniu-server ping qianniu-mysql
```

## 📈 性能优化

### 1. 调整 Java 内存

编辑 `docker-compose.yml`：

```yaml
environment:
  JAVA_OPTS: -Xms1024m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200
```

### 2. 调整 MySQL 缓冲池

```bash
docker exec qianniu-mysql mysql -u root -p -e "SET GLOBAL innodb_buffer_pool_size = 1073741824;"
```

### 3. 启用 Redis 持久化

编辑 `docker-compose.yml` Redis 配置。

### 4. 配置 CDN 加速

- 使用阿里云 CDN 加速前端静态资源
- 配置 API 网关加速后端接口

## 🎯 下一步

1. ✅ 启动应用：`docker-compose up -d`
2. ✅ 访问应用：`http://your_aliyun_ip:8080`
3. ✅ 查看日志：`docker-compose logs -f`
4. ✅ 配置域名：指向你的 ECS IP
5. ✅ 配置 HTTPS：申请 SSL 证书
6. ✅ 定期备份：配置数据库备份脚本
7. ✅ 监控告警：配置阿里云监控和告警

## 📞 获取帮助

- 官方文档：https://doc.iocoder.cn/
- GitHub Issues：https://github.com/zongyangbigpolo/qianniu/issues
- Docker 官方文档：https://docs.docker.com/

祝部署顺利！🚀
