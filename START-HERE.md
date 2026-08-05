# 🐮 千牛项目 - 从这里开始！

## 📍 项目已准备就绪！

你现在拥有一个完整的、生产级别的千牛管理系统项目，包括：

- ✅ 完整的后端代码（Java 25 + Spring Boot 4.1.0）
- ✅ 完整的前端代码（Vue 3 + Element Plus）
- ✅ 卡通牛 Logo 🐮
- ✅ Docker 部署配置
- ✅ GitHub Actions 自动构建流程
- ✅ 详细的部署文档

## 🚀 现在你需要做什么？

### 第 1 步：推送代码到 GitHub ⭐ **必须先做这个！**

项目已经在本地准备好了，现在需要推送到你的 GitHub 仓库。

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker

# 查看提交日志
git log --oneline

# 推送到 GitHub
git push -u origin main
```

**推送时需要认证**，有两种方式：

#### 方式 A：使用 GitHub Token（简单，推荐）

1. 访问：https://github.com/settings/tokens/new
2. 创建 "Personal Access Token (classic)"
3. 选择权限：`repo`, `workflow`, `packages`
4. 复制 token

然后执行：
```bash
git config credential.helper store
git push -u origin main

# 输入用户名：your_github_username
# 输入密码：粘贴你复制的 token
```

#### 方式 B：使用 SSH（更安全）

```bash
# 1. 生成 SSH 密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 2. 添加公钥到 GitHub
# https://github.com/settings/keys

# 3. 推送代码
git remote set-url origin git@github.com:zongyangbigpolo/qianniu.git
git push -u origin main
```

### 第 2 步：监控 GitHub Actions 自动构建 ⭐⭐

推送成功后，GitHub 会自动触发构建：

1. 访问你的仓库：https://github.com/zongyangbigpolo/qianniu
2. 点击 **Actions** 标签
3. 查看工作流 "🐮 千牛 Docker 构建与推送"
4. 等待构建完成（绿色 ✅ = 成功）

**构建过程**（约 20-30 分钟）：
```
✅ 编译 Java 代码
✅ 构建 Docker 镜像
✅ 推送到 GHCR (ghcr.io/zongyangbigpolo/qianniu:main)
✅ Trivy 安全扫描
```

### 第 3 步：在阿里云部署 ⭐⭐⭐

GitHub Actions 完成后，Docker 镜像已经准备好了，现在可以在阿里云部署。

#### 3.1 创建阿里云 ECS 实例

在阿里云控制台：
- CPU：2核 或更高
- 内存：4GB
- 磁盘：50GB SSD
- 系统：Ubuntu 20.04 LTS
- 安全组：开放 22, 80, 8080, 48080 端口

#### 3.2 连接到 ECS

```bash
ssh -i your-key.pem ubuntu@your_aliyun_ip
```

#### 3.3 安装 Docker

```bash
# 安装 Docker
curl -fsSL https://get.docker.com | bash

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 验证
docker --version
docker-compose --version
```

#### 3.4 部署千牛（只需 5 分钟！）

```bash
mkdir -p /opt/qianniu && cd /opt/qianniu

# 创建 docker-compose.yml
cat > docker-compose.yml << 'COMPOSE'
version: "3.8"
name: qianniu-system

services:
  mysql:
    image: mysql:8
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: qianniu
      MYSQL_ROOT_PASSWORD: your_password_here
    volumes:
      - mysql_data:/var/lib/mysql/
    networks:
      - qianniu-net

  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - qianniu-net

  server:
    image: ghcr.io/zongyangbigpolo/qianniu:main
    ports:
      - "48080:48080"
    environment:
      SPRING_PROFILES_ACTIVE: local
      JAVA_OPTS: -Xms512m -Xmx1024m
      ARGS: >
        --spring.datasource.dynamic.datasource.master.url=jdbc:mysql://mysql:3306/qianniu?useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
        --spring.datasource.dynamic.datasource.master.username=root
        --spring.datasource.dynamic.datasource.master.password=your_password_here
        --spring.data.redis.host=redis
    depends_on:
      - mysql
      - redis
    networks:
      - qianniu-net

  admin:
    image: nginx:latest
    ports:
      - "8080:80"
    depends_on:
      - server
    networks:
      - qianniu-net

volumes:
  mysql_data:
  redis_data:

networks:
  qianniu-net:
COMPOSE

# 启动服务！
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f server
```

#### 3.5 访问应用

```
前端：http://your_aliyun_ip:8080
用户名：admin
密码：admin123

后端 API：http://your_aliyun_ip:48080
```

## 📚 详细文档

项目包含了完整的文档：

| 文档 | 说明 |
|------|------|
| **[README-CN.md](./README-CN.md)** | 项目总览和快速参考 |
| **[DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)** | ⭐ **从本地到阿里云的完整指南** |
| **[GITHUB-PUSH.md](./GITHUB-PUSH.md)** | GitHub 推送和认证详解 |
| **[ALIYUN-DEPLOY.md](./ALIYUN-DEPLOY.md)** | 阿里云 ECS 详细部署步骤 |
| **[QUICKSTART.md](./QUICKSTART.md)** | 快速开始指南 |
| **[DOCKER-DEPLOY.md](./DOCKER-DEPLOY.md)** | Docker 部署详解 |

## 🎯 3 个简单步骤总结

```
1️⃣  git push -u origin main
    ↓
2️⃣  等待 GitHub Actions 构建完成（20-30 分钟）
    ↓
3️⃣  在阿里云运行 docker-compose up -d
    ↓
✅ 应用上线！
```

## ⏱️ 时间预估

- 推送代码：5 分钟
- GitHub Actions 构建：20-30 分钟
- ECS 初始化：10 分钟
- 部署应用：2-5 分钟
- **总计：40-50 分钟**

## 🔑 关键要点

### ✅ 必须做的

1. 推送代码到 GitHub
2. 修改 ECS docker-compose.yml 中的密码
3. 修改安全组开放必要端口
4. 等待 GitHub Actions 构建完成

### ⚠️ 常见问题

**Q: 推送时提示认证错误？**
A: 使用 GitHub Token 或 SSH 密钥。详见 GITHUB-PUSH.md

**Q: GitHub Actions 构建失败？**
A: 查看 Actions 日志，常见原因是 Java 编译错误

**Q: 无法拉取 Docker 镜像？**
A: 确保 GHCR 镜像是公开的，或配置 Docker 认证

**Q: 应用无法启动？**
A: 检查 MySQL 密码、端口是否开放、内存是否足够

## 📞 获取帮助

- GitHub Issues：https://github.com/zongyangbigpolo/qianniu/issues
- 官方文档：https://doc.iocoder.cn/
- Docker 文档：https://docs.docker.com/
- GitHub Actions：https://docs.github.com/en/actions

## 🎉 下一步

现在就开始吧！

1. 打开终端
2. 运行 `git push -u origin main`
3. 监控 GitHub Actions
4. 在阿里云部署

**祝你使用愉快！🚀🐮**

---

**需要更多帮助？查看 [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md) 获取详细步骤。**
