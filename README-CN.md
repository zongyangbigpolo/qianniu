# 🐮 千牛管理系统

[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/zongyangbigpolo/qianniu/docker-build.yml?branch=main)](https://github.com/zongyangbigpolo/qianniu/actions)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/zongyangbigpolo/qianniu.svg)](https://github.com/zongyangbigpolo/qianniu)

一个基于 **Spring Boot 4.1.0 + Vue 3 + Docker** 的全栈企业管理系统，支持 GitHub Actions 自动构建和阿里云 ECS 一键部署。

## ✨ 核心特性

- 🚀 **开箱即用**：预配置 Docker Compose，零依赖快速启动
- 🔄 **自动构建**：GitHub Actions 自动编译、构建镜像、推送到 GHCR
- ☁️ **云原生**：完全容器化，支持阿里云、腾讯云、AWS 等公有云
- 🔐 **企业级**：内置权限管理、工作流、数据加密等
- 📊 **完整功能**：包括 CRM、ERP、电商、支付等模块
- 🎨 **现代 UI**：Vue 3 + Element Plus，响应式设计

## 🎯 快速开始

### 本地 Docker 部署（5 分钟）

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker
cd script/docker
docker-compose up -d
```

访问：http://localhost:8080 (admin/admin123)

### 推送到 GitHub 自动构建（5 分钟）

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker
git push -u origin main
```

GitHub Actions 会自动：
1. ✅ 编译 Java 代码
2. ✅ 构建 Docker 镜像
3. ✅ 推送到 GHCR
4. ✅ 运行安全扫描

### 部署到阿里云（15 分钟）

```bash
# 1. SSH 连接到 ECS
ssh -i your-key.pem ubuntu@your_aliyun_ip

# 2. 安装 Docker
curl -fsSL https://get.docker.com | bash

# 3. 拉取并运行
mkdir -p /opt/qianniu && cd /opt/qianniu
docker run -d --name qianniu-mysql -e MYSQL_ROOT_PASSWORD=123456 mysql:8
docker run -d --name qianniu-redis redis:6-alpine
docker run -d -p 48080:48080 --link qianniu-mysql:mysql --link qianniu-redis:redis \
  ghcr.io/zongyangbigpolo/qianniu:main
docker run -d -p 8080:80 -e API_URL=http://your_aliyun_ip:48080 \
  ghcr.io/zongyangbigpolo/qianniu:admin
```

访问：http://your_aliyun_ip:8080

## 📚 文档

| 文档 | 说明 | 耗时 |
|------|------|------|
| [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md) | ⭐ 从本地到阿里云的完整指南 | 50-65 分钟 |
| [GITHUB-PUSH.md](./GITHUB-PUSH.md) | 推送代码和配置认证 | 5 分钟 |
| [ALIYUN-DEPLOY.md](./ALIYUN-DEPLOY.md) | 阿里云 ECS 详细部署 | 30 分钟 |
| [QUICKSTART.md](./QUICKSTART.md) | 快速开始指南 | 5 分钟 |
| [DOCKER-DEPLOY.md](./DOCKER-DEPLOY.md) | Docker 部署详解 | 参考 |

## 🔧 技术栈

```
前端 (yudao-ui-admin)
├── Vue 3
├── Element Plus
├── Vite
└── Axios

后端 (yudao-server)
├── Spring Boot 4.1.0
├── Java 25
├── MyBatis Plus
└── Flowable BPM

基础设施
├── MySQL 8
├── Redis 6
├── Docker
└── Docker Compose
```

## 📦 项目结构

```
.
├── yudao-server/               # 后端项目
│   ├── src/
│   ├── target/                 # 编译输出
│   └── Dockerfile              # Docker 构建配置
├── yudao-ui-admin/             # 前端项目
│   ├── src/
│   ├── package.json
│   └── Dockerfile              # Docker 构建配置
├── script/
│   └── docker/
│       ├── docker-compose.yml  # Docker 编排
│       └── .env.example        # 环境变量模板
├── sql/                        # 数据库脚本
├── .github/
│   └── workflows/
│       └── docker-build.yml    # GitHub Actions CI/CD
└── qianniu-logo.svg            # 项目 Logo
```

## 🐳 Docker 镜像

镜像自动推送到 GHCR：

```bash
# 主分支最新版本
docker pull ghcr.io/zongyangbigpolo/qianniu:main

# 开发分支
docker pull ghcr.io/zongyangbigpolo/qianniu:develop

# 特定版本（标签）
docker pull ghcr.io/zongyangbigpolo/qianniu:v1.0.0
```

## 🚀 部署方案对比

| 方案 | 难度 | 耗时 | 成本 | 说明 |
|------|------|------|------|------|
| **本地 Docker** | ⭐ | 5 分钟 | ¥0 | 快速体验，推荐新手 |
| **GitHub Actions** | ⭐⭐ | 25 分钟 | ¥0 | 自动构建，强烈推荐 |
| **阿里云 ECS** | ⭐⭐⭐ | 45 分钟 | ¥20-50/月 | 正式上线方案 |
| **Kubernetes** | ⭐⭐⭐⭐ | 1-2 小时 | ¥100+/月 | 企业级部署 |

## 🔄 完整工作流

```bash
# 1️⃣ 本地开发
cd yudao-server
mvn spring-boot:run

# 2️⃣ 提交代码
git add .
git commit -m "feat: 新增功能"
git push origin main

# 3️⃣ GitHub Actions 自动构建
# 访问 Actions 选项卡查看进度

# 4️⃣ 阿里云自动部署
# 配置 Watchtower 自动拉取最新镜像

# 5️⃣ 访问应用
# http://your_domain.com
```

## 🔐 安全性

- ✅ GitHub Actions 自动安全扫描（Trivy）
- ✅ 数据库密码加密存储
- ✅ Redis 支持密码认证
- ✅ API 基于权限的访问控制
- ✅ 支持 OAuth2 登录

## 📊 性能指标

- **后端启动时间**：15-20 秒
- **前端加载时间**：< 3 秒
- **数据库连接池**：10-20 个
- **Redis 缓存层**：支持高并发

## 🎓 学习资源

- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)
- [Vue 3 官方文档](https://vuejs.org/)
- [Docker 官方文档](https://docs.docker.com/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [芋道项目文档](https://doc.iocoder.cn/)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📝 许可

MIT License - 详见 [LICENSE](./LICENSE) 文件

## 💡 常见问题

### Q: GitHub Actions 构建失败怎么办？

A: 查看 Actions 页面的详细日志，常见原因有：
- Java 编译错误
- Docker 镜像构建失败
- GHCR 推送权限问题

### Q: 如何更新到最新版本？

A: 
```bash
cd /opt/qianniu
docker-compose pull
docker-compose up -d
```

### Q: 如何备份数据库？

A:
```bash
docker exec qianniu-mysql mysqldump -u root -p123456 qianniu > backup.sql
```

### Q: 可以在生产环境直接使用吗？

A: 可以，但需要：
- ✅ 修改默认密码
- ✅ 配置 HTTPS SSL 证书
- ✅ 设置数据库自动备份
- ✅ 配置监控和告警
- ✅ 定期安全更新

## 📞 联系方式

- GitHub Issues：https://github.com/zongyangbigpolo/qianniu/issues
- GitHub Discussions：https://github.com/zongyangbigpolo/qianniu/discussions

## 🎉 致谢

感谢 [YunaiV](https://github.com/YunaiV) 开源的 ruoyi-vue-pro 项目！

---

**准备好体验千牛了吗？👉 [查看完整部署指南](./DEPLOYMENT-GUIDE.md) 🚀**
