# 🐮 千牛 - 完整部署方案指南

## 📋 项目概述

"千牛"是一个基于 Spring Boot 4.1.0 + Vue 3 + Docker 的全栈管理系统，已配置 GitHub Actions 自动构建和推送 Docker 镜像到 GHCR（GitHub 容器注册表）。

### 技术栈
- **后端**：Java 25 + Spring Boot 4.1.0 + MyBatis Plus
- **前端**：Vue 3 + Element Plus + Vite
- **数据库**：MySQL 8
- **缓存**：Redis 6
- **容器化**：Docker + Docker Compose
- **CI/CD**：GitHub Actions
- **镜像仓库**：GHCR (ghcr.io)

## 🎯 完整部署流程图

```
┌─────────────────────────────────────────────────────────────┐
│                      本地开发环境                            │
│ /Users/polo2/srccode/ruoyi-vue-pro-docker                  │
└────────────────┬────────────────────────────────────────────┘
                 │ git push origin main
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                   GitHub 仓库                               │
│  https://github.com/zongyangbigpolo/qianniu               │
└────────────────┬────────────────────────────────────────────┘
                 │ 触发 GitHub Actions 工作流
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                GitHub Actions CI/CD                         │
│ 1. 编译 Java 代码 (mvn clean package)                      │
│ 2. 构建 Docker 镜像                                        │
│ 3. 推送到 GHCR: ghcr.io/zongyangbigpolo/qianniu:main     │
│ 4. Trivy 安全扫描                                          │
└────────────────┬────────────────────────────────────────────┘
                 │ Docker 镜像已准备好
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                   阿里云 ECS                                │
│ 1. SSH 连接到 ECS                                          │
│ 2. 安装 Docker & Docker Compose                            │
│ 3. docker-compose pull (拉取最新镜像)                     │
│ 4. docker-compose up -d (启动服务)                        │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│            应用已运行 🚀                                    │
│ • 前端: http://your_aliyun_ip:8080                         │
│ • 后端: http://your_aliyun_ip:48080                        │
│ • 数据库: MySQL 3306                                       │
│ • 缓存: Redis 6379                                         │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 部署步骤总览

### 第 1 步：推送代码到 GitHub ⭐

**时间**：5 分钟 | **难度**：⭐

这是最关键的步骤！代码推送后，GitHub Actions 会自动构建 Docker 镜像。

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker

# 配置 GitHub 认证（选择一种方式）
# 方式 A: 使用 GitHub Token（推荐）
git config credential.helper store
git push -u origin main
# 输入用户名和 GitHub Token

# 方式 B: 使用 SSH（最安全）
git remote set-url origin git@github.com:zongyangbigpolo/qianniu.git
git push -u origin main
```

**详细步骤**：请参考 [GITHUB-PUSH.md](./GITHUB-PUSH.md)

### 第 2 步：监控 GitHub Actions 构建 ⭐⭐

**时间**：20-30 分钟 | **难度**：⭐

1. 访问你的 GitHub 仓库：https://github.com/zongyangbigpolo/qianniu
2. 点击 "Actions" 标签
3. 查看工作流 "🐮 千牛 Docker 构建与推送" 的运行进度
4. 等待构建完成（绿色 ✅ 表示成功）
5. Docker 镜像自动推送到 GHCR：`ghcr.io/zongyangbigpolo/qianniu:main`

### 第 3 步：准备阿里云 ECS ⭐⭐⭐

**时间**：15 分钟 | **难度**：⭐⭐

#### 3.1 创建 ECS 实例

在阿里云控制台：
- **实例规格**：ecs.t6-c1m2.large 或更高
- **操作系统**：Ubuntu 20.04 LTS
- **存储**：50GB SSD
- **带宽**：2-5Mbps

#### 3.2 配置安全组

开放端口：
- `22` - SSH（管理）
- `80` - HTTP 前端
- `8080` - 前端服务
- `48080` - 后端 API

#### 3.3 连接到 ECS

```bash
# 使用密钥对连接
ssh -i your-key.pem ubuntu@your_aliyun_ip

# 或使用密码
ssh ubuntu@your_aliyun_ip
```

### 第 4 步：ECS 初始化配置 ⭐⭐

**时间**：10 分钟 | **难度**：⭐

SSH 连接到 ECS 后执行：

```bash
# 1. 更新系统
sudo apt update && sudo apt upgrade -y

# 2. 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo bash get-docker.sh

# 3. 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 4. 验证安装
docker --version
docker-compose --version

# 5. 创建项目目录
mkdir -p /opt/qianniu
cd /opt/qianniu
```

**完整步骤**：请参考 [ALIYUN-DEPLOY.md](./ALIYUN-DEPLOY.md)

### 第 5 步：在 ECS 上部署千牛 ⭐⭐⭐

**时间**：5 分钟（已有镜像）| **难度**：⭐⭐

#### 方案 A：最简单 - 直接使用 GitHub Actions 构建的镜像

```bash
cd /opt/qianniu

# 1. 创建 docker-compose.yml
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
      MYSQL_ROOT_PASSWORD: your_strong_password
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
        --spring.datasource.dynamic.datasource.master.password=your_strong_password
        --spring.data.redis.host=qianniu-redis
    depends_on:
      - mysql
      - redis
    networks:
      - qianniu-net

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
  redis_data:

networks:
  qianniu-net:
    driver: bridge
EOF

# 2. 修改密码（重要！）
vim docker-compose.yml
# 找到 "your_strong_password" 改成强密码（至少一处）

# 3. 启动所有服务
docker-compose up -d

# 4. 查看服务状态
docker-compose ps

# 5. 查看日志
docker-compose logs -f server
```

#### 方案 B：从源码克隆部署

```bash
cd /opt/qianniu

# 克隆项目
git clone https://github.com/zongyangbigpolo/qianniu.git .

# 进入 Docker 目录
cd script/docker

# 启动服务
docker-compose up -d
```

### 第 6 步：访问应用 ✅

**时间**：2 分钟 | **难度**：⭐

```bash
# 等待服务启动（约 30-60 秒）
# 查看日志确认启动完成
docker-compose logs server | tail -20

# 应该看到类似的输出：
# Started YudaoServerApplication in X seconds
```

然后访问：

- **管理后台**：http://your_aliyun_ip:8080
- **后端 API**：http://your_aliyun_ip:48080
- **用户名**：admin
- **密码**：admin123

## 📊 各步骤耗时总结

| 步骤 | 耗时 | 说明 |
|------|------|------|
| 1. 推送到 GitHub | 5 分钟 | 取决于网络速度 |
| 2. GitHub Actions 构建 | 20-30 分钟 | 包括编译、构建镜像、推送 |
| 3. 准备 ECS | 15 分钟 | 创建实例、配置网络 |
| 4. ECS 初始化 | 10 分钟 | 安装 Docker 和依赖 |
| 5. 部署应用 | 2-5 分钟 | 拉取镜像并启动容器 |
| **总计** | **50-65 分钟** | 从本地到阿里云上线 |

## 🔧 常用运维命令速查

```bash
cd /opt/qianniu

# 查看服务状态
docker-compose ps

# 查看日志（实时）
docker-compose logs -f server

# 重启服务
docker-compose restart server

# 停止服务
docker-compose stop

# 启动服务
docker-compose start

# 更新镜像（拉取最新版本）
docker-compose pull server
docker-compose up -d

# 进入容器
docker exec -it qianniu-server bash

# 查看资源占用
docker stats

# 完全清除数据（危险！）
docker-compose down -v
```

## 📈 自动化更新部署

为了让阿里云自动拉取最新的 GitHub Actions 构建镜像，可以部署 Watchtower：

```bash
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ghcr.io/containrrr/watchtower \
  --cleanup \
  --interval 3600 \
  qianniu-server qianniu-admin

# 或者使用 cron 定时更新（每天凌晨 2 点）
crontab -e
# 添加行：0 2 * * * cd /opt/qianniu && docker-compose pull && docker-compose up -d
```

## 🔐 生产环境检查清单

在正式上线前，请确保：

- [ ] ✅ 修改 MySQL root 密码（改成强密码）
- [ ] ✅ 修改 Redis 密码（如需要）
- [ ] ✅ 修改应用内 admin 账户密码
- [ ] ✅ 配置了 HTTPS SSL 证书
- [ ] ✅ 配置了域名解析（DNS A 记录）
- [ ] ✅ 配置了日志收集和监控告警
- [ ] ✅ 设置了数据库自动备份脚本
- [ ] ✅ 配置了防火墙规则（关闭不必要的端口）
- [ ] ✅ 测试了数据库备份和恢复流程
- [ ] ✅ 配置了容器自动重启

## 🐛 故障排除

### 问题 1: 无法拉取 Docker 镜像

```bash
# 原因：可能是 GHCR 镜像是私有的，或网络问题

# 解决方案 1：使用 GitHub Token 登录
docker login ghcr.io -u your_username -p YOUR_TOKEN

# 解决方案 2：配置 Docker 镜像加速
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": ["https://registry.aliyuncs.com"]
}
EOF
sudo systemctl restart docker
```

### 问题 2: 服务无法启动

```bash
# 查看详细日志
docker-compose logs server

# 常见原因：
# 1. 端口被占用：lsof -i :48080
# 2. 内存不足：free -h
# 3. 数据库连接失败：检查数据库密码
```

### 问题 3: 内存不足

```bash
# 增加 Swap 空间
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 或调整 JVM 内存
# 编辑 docker-compose.yml，修改 JAVA_OPTS
```

## 📚 相关文档

- [QUICKSTART.md](./QUICKSTART.md) - 快速开始指南
- [DOCKER-DEPLOY.md](./DOCKER-DEPLOY.md) - Docker 部署详解
- [ALIYUN-DEPLOY.md](./ALIYUN-DEPLOY.md) - 阿里云 ECS 部署详解
- [GITHUB-PUSH.md](./GITHUB-PUSH.md) - GitHub 推送和认证指南

## 🎯 下一步

1. ✅ 推送代码到 GitHub：`git push -u origin main`
2. ✅ 监控 GitHub Actions 构建完成
3. ✅ 创建阿里云 ECS 实例
4. ✅ 初始化 ECS 环境
5. ✅ 部署千牛应用
6. ✅ 访问应用并配置
7. ✅ 配置域名和 HTTPS
8. ✅ 设置自动化备份和监控

## 💡 技巧和最佳实践

### 开发效率
- 使用 GitHub Actions 的 `workflow_dispatch` 手动触发构建
- 在 `docker-compose.yml` 中使用 `:latest` 标签快速测试新版本

### 性能优化
- 调整 JAVA_OPTS 中的堆内存（根据 ECS 配置）
- 为数据库和 Redis 配置持久化
- 使用 Nginx 作为反向代理和负载均衡

### 安全最佳实践
- 定期更新依赖包和基础镜像
- 使用 GitHub Actions 中的 Trivy 扫描安全漏洞
- 配置 HTTPS 和 SSL 证书
- 定期备份数据库

## 📞 获取帮助

- GitHub Issues：https://github.com/zongyangbigpolo/qianniu/issues
- 官方文档：https://doc.iocoder.cn/
- Docker 文档：https://docs.docker.com/

---

**祝部署顺利！如有问题，欢迎提交 Issue 或 Discussion。🚀🐮**
