# 快速开始指南

## 🎯 你现在拥有

项目已经完全准备好了！位置在：`/Users/polo2/srccode/ruoyi-vue-pro-docker`

### 包含内容

```
ruoyi-vue-pro-docker/
├── DOCKER-DEPLOY.md          ✨ 详细部署指南（90+ 行）
├── deploy.sh                 ✨ 自动化部署脚本
├── script/docker/
│   ├── .env.example          ✨ 环境变量模板
│   └── docker-compose.yml    原项目 Docker 配置
├── yudao-server/             后端项目（Java 25）
├── yudao-ui-admin/           前端项目（Vue 3）
├── pom.xml                   Maven 主配置
└── sql/                      数据库初始化脚本
```

## 🚀 快速开始（3 个步骤）

### 步骤 1: 构建后端（首次需要，约 15-30 分钟）

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker
./deploy.sh build
```

### 步骤 2: 启动 Docker 服务

```bash
cd script/docker
docker-compose up -d
```

或使用自动化脚本：

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker
./deploy.sh up
```

### 步骤 3: 访问应用

- **管理后台**：http://localhost:8080
- **登录账号**：admin / admin123
- **后端 API**：http://localhost:48080

## 📊 部署脚本命令

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker

# 查看帮助
./deploy.sh help

# 构建 JAR 包
./deploy.sh build

# 启动所有服务
./deploy.sh up

# 查看服务状态
./deploy.sh status

# 查看日志（后端）
./deploy.sh logs -s server -f

# 重启服务
./deploy.sh restart

# 停止服务
./deploy.sh down

# 清空所有数据（危险！）
./deploy.sh clean
```

## 🌐 部署到阿里云（简单版）

### 1. 在阿里云创建 ECS 实例

- 系统：CentOS 8 / Ubuntu 20.04+
- 配置：2核 4GB 内存 50GB 磁盘

### 2. SSH 连接并安装 Docker

```bash
ssh root@your_aliyun_ip

# Ubuntu
curl -fsSL https://get.docker.com | bash
apt install docker-compose

# 或 CentOS
yum install docker
```

### 3. 上传项目到服务器

```bash
# 本地执行
scp -r /Users/polo2/srccode/ruoyi-vue-pro-docker root@your_aliyun_ip:/opt/

# 进入服务器
ssh root@your_aliyun_ip
cd /opt/ruoyi-vue-pro-docker
```

### 4. 构建并启动

```bash
# 如果本地已构建，可以跳过此步
./deploy.sh build

# 启动服务
cd script/docker
docker-compose up -d

# 查看日志
docker-compose logs -f
```

### 5. 配置阿里云安全组

开放以下端口：
- `8080`：前端管理后台
- `48080`：后端 API
- `22`：SSH（已默认开放）

### 6. 访问应用

```
http://your_aliyun_ip:8080
```

## 📝 推送代码到你自己的 GitHub

### 1. 在 GitHub 创建新仓库

访问 https://github.com/new，创建仓库名：`ruoyi-vue-pro-docker`

### 2. 推送代码

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker

# 配置 Git 用户信息
git config user.email "your_email@gmail.com"
git config user.name "Your Name"

# 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/ruoyi-vue-pro-docker.git

# 推送代码
git branch -M main
git push -u origin main
```

## 🔧 环境变量配置

编辑 `script/docker/.env` 文件（从 `.env.example` 复制）：

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker/script/docker
cp .env.example .env
vim .env

# 生产环境必须修改：
# - MYSQL_ROOT_PASSWORD
# - MASTER_DATASOURCE_PASSWORD
# - JAVA_OPTS 内存配置
```

## 🎓 项目学习资源

### 官方文档
- [芋道项目官方文档](https://doc.iocoder.cn/)
- [GitHub 仓库](https://github.com/YunaiV/ruoyi-vue-pro)

### 技术栈
- **后端**：Spring Boot 4.1.0 + Java 25
- **前端**：Vue 3 + Element Plus
- **数据库**：MySQL 8
- **缓存**：Redis 6
- **容器化**：Docker + Docker Compose

### 项目结构
- `yudao-server/`：后端主项目
- `yudao-ui-admin/`：前端管理后台
- `yudao-module-*`：各个功能模块（可选）
- `yudao-framework/`：框架层
- `sql/`：数据库脚本

## 💡 常见问题

**Q: 构建时间太长怎么办？**
A: 这是正常的，首次构建需要下载大量 Maven 依赖（约 1-2GB）。使用国内镜像可以加快速度。

**Q: 如何修改数据库密码？**
A: 编辑 `script/docker/.env`，修改 `MYSQL_ROOT_PASSWORD` 和 `MASTER_DATASOURCE_PASSWORD`，然后重启容器。

**Q: 前端无法访问后端 API？**
A: 检查 `docker-compose.yml` 中的 `VUE_APP_BASE_API` 配置，确保指向正确的 API 地址。

**Q: 如何备份数据库？**
A: 使用命令：`docker exec yudao-mysql mysqldump -u root -p123456 ruoyi-vue-pro > backup.sql`

**Q: 如何查看实时日志？**
A: 使用命令：`docker-compose logs -f server` (查看后端日志)

## 📞 获取帮助

- 查看详细文档：`cat DOCKER-DEPLOY.md`
- 查看脚本帮助：`./deploy.sh help`
- 查看 Docker 日志：`docker-compose logs`
- 官方文档：https://doc.iocoder.cn/

## ✅ 下一步

1. ✅ 构建项目：`./deploy.sh build`
2. ✅ 启动服务：`./deploy.sh up`
3. ✅ 访问应用：http://localhost:8080
4. ✅ 探索代码：查看 `yudao-server` 和 `yudao-ui-admin`
5. ✅ 推送 GitHub：将代码推送到你自己的仓库
6. ✅ 部署到阿里云：按照上面的步骤部署

祝你使用愉快！🎉
