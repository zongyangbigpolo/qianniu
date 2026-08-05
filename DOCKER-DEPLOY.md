# 芋道项目 (RuoYi-Vue-Pro) Docker 部署指南

## 📋 项目介绍

这是 **ruoyi-vue-pro** 项目的 master-jdk25 分支，是一个基于 Spring Boot + Vue 3 的全栈管理系统。

- **后端**：Spring Boot 4.1.0，Java 25
- **前端**：Vue 3 + Element Plus
- **数据库**：MySQL 8
- **缓存**：Redis 6
- **UI 框架**：Element Plus

## 🚀 快速开始（本地 Docker 部署）

### 前置要求

- Docker & Docker Compose (推荐版本：Docker 20.10+)
- 至少 4GB 内存
- 10GB 磁盘空间

### 步骤 1: 克隆项目（如果还未克隆）

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker
```

### 步骤 2: 构建后端 JAR 包

```bash
# 使用 Maven 构建（确保已安装 Maven 3.8.1+）
mvn clean install -DskipTests

# 或使用 Maven wrapper（推荐，不需要本地安装 Maven）
./mvnw clean install -DskipTests
```

**构建过程可能需要 15-30 分钟**，首次构建会下载大量依赖。

### 步骤 3: 构建 Docker 镜像并启动服务

```bash
cd script/docker

# 使用 Docker Compose 启动所有服务
# 这会启动：MySQL、Redis、后端服务(48080)、前端服务(8080)
docker-compose up -d

# 查看日志
docker-compose logs -f server    # 查看后端日志
docker-compose logs -f admin     # 查看前端日志
```

### 步骤 4: 访问应用

- **管理后台**：http://localhost:8080
- **后端 API**：http://localhost:48080
- **MySQL**：localhost:3306 (root/123456)
- **Redis**：localhost:6379

### 默认登录凭证

- 用户名：admin
- 密码：admin123

## 🔧 环境变量配置

编辑 `script/docker/docker-compose.yml` 中的环境变量：

```yaml
environment:
  # MySQL 配置
  MYSQL_DATABASE: ruoyi-vue-pro
  MYSQL_ROOT_PASSWORD: 123456
  
  # 数据源 URL（如需修改）
  MASTER_DATASOURCE_URL: jdbc:mysql://yudao-mysql:3306/ruoyi-vue-pro?useSSL=false
  MASTER_DATASOURCE_USERNAME: root
  MASTER_DATASOURCE_PASSWORD: 123456
  
  # Redis 配置
  REDIS_HOST: yudao-redis
  
  # 前端配置
  VUE_APP_BASE_API: /prod-api
  VUE_APP_TITLE: 芋道管理系统
```

## 📦 本地开发（不使用 Docker）

### 后端

```bash
# 进入后端项目目录
cd yudao-server

# 运行开发服务器
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=local"
```

### 前端

```bash
# 进入前端项目目录
cd yudao-ui-admin

# 安装依赖
npm install

# 开发模式启动
npm run dev

# 生产构建
npm run build
```

## ☁️ 部署到阿里云服务器

### 前置准备

1. **阿里云 ECS 实例**
   - 系统：CentOS 8 或 Ubuntu 20.04+
   - CPU：2核 或以上
   - 内存：4GB 或以上
   - 磁盘：50GB 或以上

2. **安装 Docker 和 Docker Compose**

   ```bash
   # Ubuntu/Debian
   curl -fsSL https://get.docker.com | bash
   sudo apt install docker-compose

   # CentOS
   sudo yum install docker
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. **克隆项目到服务器**

   ```bash
   cd /opt
   git clone -b master-jdk25 https://github.com/YunaiV/ruoyi-vue-pro.git
   # 或使用你自己的 repo（如果已推送）
   git clone https://github.com/YOUR_USERNAME/ruoyi-vue-pro-docker.git
   ```

### 部署步骤

#### 方案 A：快速部署（预构建镜像）

```bash
# 进入项目目录
cd ruoyi-vue-pro-docker/script/docker

# 编辑 docker-compose.yml，修改数据库密码等配置
vim docker-compose.yml

# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看后端日志
docker-compose logs -f server

# 停止服务
docker-compose down
```

#### 方案 B：从源码构建部署

```bash
# 上传代码到服务器
scp -r /Users/polo2/srccode/ruoyi-vue-pro-docker root@YOUR_SERVER_IP:/opt/

# SSH 连接到服务器
ssh root@YOUR_SERVER_IP

# 进入项目目录
cd /opt/ruoyi-vue-pro-docker

# 构建 JAR 包
mvn clean install -DskipTests

# 进入 Docker 目录
cd script/docker

# 修改配置（重要！）
vim docker-compose.yml

# 启动服务
docker-compose up -d

# 查看状态和日志
docker-compose ps
docker-compose logs -f
```

### 阿里云安全组配置

在阿里云控制台中，为你的 ECS 实例配置以下安全组规则：

| 协议 | 端口 | 来源 | 说明 |
|------|------|------|------|
| TCP | 8080 | 0.0.0.0/0 | 前端管理后台 |
| TCP | 48080 | 0.0.0.0/0 | 后端 API |
| TCP | 3306 | 内网 | MySQL（内部通信） |
| TCP | 6379 | 内网 | Redis（内部通信） |

### 使用反向代理（推荐）

配置 Nginx 反向代理，将流量转发到 Docker 容器：

```nginx
upstream backend {
    server localhost:48080;
}

upstream admin {
    server localhost:8080;
}

server {
    listen 80;
    server_name yourdomain.com;

    # 前端
    location / {
        proxy_pass http://admin;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # API
    location /prod-api {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## 🔐 生产环境建议

### 1. 修改默认密码

```bash
# 进入 MySQL 容器
docker exec -it yudao-mysql mysql -u root -p

# 修改 root 密码
ALTER USER 'root'@'%' IDENTIFIED BY 'your_strong_password';
```

### 2. 配置环境变量（.env 文件）

创建 `script/docker/.env` 文件：

```env
MYSQL_DATABASE=ruoyi-vue-pro
MYSQL_ROOT_PASSWORD=your_strong_password_here
MYSQL_USER=yudao
MYSQL_PASSWORD=your_user_password_here

MASTER_DATASOURCE_USERNAME=root
MASTER_DATASOURCE_PASSWORD=your_strong_password_here

REDIS_PASSWORD=your_redis_password

JAVA_OPTS=-Xms1024m -Xmx2048m
```

然后在 `docker-compose.yml` 中引用：

```yaml
environment:
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
```

### 3. 持久化数据

确保 Docker volumes 配置正确（已在 docker-compose.yml 中配置）：

```bash
# 查看 volume 信息
docker volume ls

# 查看 volume 详情
docker volume inspect yudao_mysql

# 备份数据库
docker exec yudao-mysql mysqldump -u root -p'password' ruoyi-vue-pro > backup.sql

# 恢复数据库
cat backup.sql | docker exec -i yudao-mysql mysql -u root -p'password' ruoyi-vue-pro
```

### 4. 自动重启配置

Docker Compose 已配置 `restart: unless-stopped`，容器会自动重启。

### 5. 日志管理

```bash
# 查看所有日志
docker-compose logs

# 查看特定服务日志（最后 100 行，持续跟踪）
docker-compose logs -f --tail=100 server

# 查看日志统计
docker-compose logs server | wc -l
```

### 6. 性能优化

编辑 `docker-compose.yml`，调整 Java 内存配置：

```yaml
environment:
  JAVA_OPTS: -Xms1024m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200
```

## 📊 常用命令

```bash
# 启动所有服务
docker-compose up -d

# 停止所有服务
docker-compose down

# 查看服务状态
docker-compose ps

# 重启特定服务
docker-compose restart server

# 查看日志
docker-compose logs -f server

# 进入容器
docker exec -it yudao-server bash

# 停止并删除所有容器和 volumes（清空数据！）
docker-compose down -v

# 查看资源占用
docker stats

# 清理未使用的镜像
docker image prune -a

# 清理未使用的 volumes
docker volume prune
```

## 🐛 故障排除

### 问题 1: 构建 JAR 时缺少依赖

```bash
# 清理本地 Maven 缓存
mvn clean
rm -rf ~/.m2/repository

# 重新构建
mvn clean install -DskipTests
```

### 问题 2: 容器无法启动

```bash
# 查看错误日志
docker-compose logs server

# 检查环境变量是否正确
docker-compose config

# 重启 Docker 守护进程
sudo systemctl restart docker
```

### 问题 3: 无法连接数据库

```bash
# 检查 MySQL 容器是否运行
docker-compose ps mysql

# 进入 MySQL 容器测试连接
docker exec -it yudao-mysql mysql -u root -p

# 检查网络
docker-compose exec server ping yudao-mysql
```

### 问题 4: 前端无法访问后端 API

确保 `docker-compose.yml` 中的环境变量配置正确：

```yaml
VUE_APP_BASE_API: /prod-api  # 或你的 API 地址
```

## 📚 相关文档

- [官方项目文档](https://doc.iocoder.cn/)
- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [Spring Boot 文档](https://spring.io/projects/spring-boot)
- [Vue 3 文档](https://vuejs.org/)

## 🤝 推送代码到自己的 GitHub

```bash
# 创建你自己的 GitHub 仓库（在 GitHub 上创建）
# https://github.com/new

# 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/ruoyi-vue-pro-docker.git

# 提交代码
git config user.email "your_email@example.com"
git config user.name "Your Name"
git add .
git commit -m "Initial commit: RuoYi-Vue-Pro with Docker deployment"

# 推送到 GitHub
git branch -M main
git push -u origin main
```

## 💡 更多配置选项

查看 `yudao-server/src/main/resources/application.yml` 了解更多配置选项。

祝你使用愉快！如有问题，欢迎提交 Issue 或联系支持团队。
