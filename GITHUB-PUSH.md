# 🚀 推送千牛项目到 GitHub

项目已经准备好推送到你的仓库，现在需要认证。有两种方式可选：

## 📋 方案 A：使用 GitHub Token（推荐 ⭐）

### 步骤 1: 创建 Personal Access Token

1. 访问 GitHub：https://github.com/settings/tokens/new
2. 选择 "Tokens (classic)"
3. 设置权限：
   - ✅ repo (完整访问)
   - ✅ workflow (GitHub Actions)
   - ✅ packages (Docker 镜像)
4. 点击 "Generate token"
5. 复制生成的 token（只显示一次！）

### 步骤 2: 推送代码到 GitHub

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker

# 设置认证方式（选择下面其中一个）

# 方式 A: 使用 git credentials 存储 token（安全）
git config credential.helper store
git push -u origin main

# 然后会提示输入用户名和密码：
# 用户名：your_github_username
# 密码：粘贴你复制的 token

# 方式 B: 使用 URL 包含 token（一次性）
git push -u https://YOUR_USERNAME:YOUR_TOKEN@github.com/zongyangbigpolo/qianniu.git main
```

## 📋 方案 B：使用 SSH 密钥

### 步骤 1: 生成 SSH 密钥（如果还没有）

```bash
# 检查是否已有 SSH 密钥
ls -la ~/.ssh/id_rsa

# 如果没有，生成新的
ssh-keygen -t ed25519 -C "your_email@example.com"
# 或使用 RSA（兼容性更好）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 一直按 Enter 使用默认选项
```

### 步骤 2: 将公钥添加到 GitHub

```bash
# 复制公钥
cat ~/.ssh/id_rsa.pub

# 或 (ed25519)
cat ~/.ssh/id_ed25519.pub
```

1. 访问 GitHub 设置：https://github.com/settings/keys
2. 点击 "New SSH key"
3. 标题：输入任意名称（如 "My Mac"）
4. 密钥：粘贴上面复制的公钥内容
5. 点击 "Add SSH key"

### 步骤 3: 配置 Git 使用 SSH

```bash
cd /Users/polo2/srccode/ruoyi-vue-pro-docker

# 修改远程 URL 为 SSH 格式
git remote remove origin
git remote add origin git@github.com:zongyangbigpolo/qianniu.git

# 测试 SSH 连接
ssh -T git@github.com

# 推送代码
git push -u origin main
```

## ✅ 确认推送成功

推送成功后，你会看到：

```
Enumerating objects: 6965, done.
Counting objects: 100% (6965/100%), done.
Compressing objects: 100% (6500/100%), done.
Writing objects: 100% (6965/100%), done.
Total 6965 (delta XXX), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (XXX/XXX), done.
To https://github.com/zongyangbigpolo/qianniu.git
 * [new branch]      main -> main
Branch 'main' is tracking 'origin/main'.
```

## 🔍 验证 GitHub Actions 工作流

推送成功后：

1. 访问你的 GitHub 仓库：https://github.com/zongyangbigpolo/qianniu
2. 点击 "Actions" 标签
3. 你应该看到 "🐮 千牛 Docker 构建与推送" 工作流已自动开始运行
4. 等待构建完成（约 15-30 分钟）

### GitHub Actions 工作流说明

```
┌─────────────────────────────────────────┐
│  Push 代码到 GitHub (main 分支)         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  GitHub Actions 自动触发                 │
│  - 编译 Java 代码                       │
│  - 构建 Docker 镜像                     │
│  - 推送到 GHCR 容器注册表               │
│  - 运行 Trivy 安全扫描                  │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Docker 镜像已推送到：                   │
│  ghcr.io/zongyangbigpolo/qianniu:main  │
└─────────────────────────────────────────┘
```

## 🐳 配置 GHCR 访问权限

为了让阿里云 ECS 能够拉取 Docker 镜像，需要配置：

### 步骤 1: 生成 GitHub Token for GHCR

```bash
# 创建 packages-read 权限的 token
# https://github.com/settings/tokens/new
# 选择 "Tokens (classic)" → "packages" 权限
```

### 步骤 2: 在 ECS 上登录 GHCR

```bash
# 在阿里云 ECS 上执行
docker login ghcr.io -u your_github_username -p YOUR_TOKEN

# 如果是私有镜像，需要保存认证信息
# 编辑 docker-compose.yml，添加：
# image: ghcr.io/zongyangbigpolo/qianniu:main
# 或者在 ECS 上：
# docker pull ghcr.io/zongyangbigpolo/qianniu:main
```

## 📊 监控构建进度

### GitHub Actions 页面
- 访问：https://github.com/zongyangbigpolo/qianniu/actions
- 查看实时构建日志

### Docker 镜像
- 镜像地址：ghcr.io/zongyangbigpolo/qianniu
- 版本标签：
  - `main` - 主分支最新版本
  - `develop` - 开发分支版本
  - `vX.Y.Z` - 发布版本

## 🚨 常见问题

### Q1: 推送时提示 "fatal: unable to get password from user"

**原因**：Git 认证失败

**解决方案**：
```bash
# 方案 1: 使用 git credential helper
git config credential.helper store
git push -u origin main

# 方案 2: 直接在 URL 中提供 token
git push -u https://YOUR_USERNAME:YOUR_TOKEN@github.com/zongyangbigpolo/qianniu.git main

# 方案 3: 使用 SSH（推荐）
git remote set-url origin git@github.com:zongyangbigpolo/qianniu.git
git push -u origin main
```

### Q2: GitHub Actions 构建失败

**常见原因和解决方案**：

1. **Java 编译失败**
   - 检查代码是否有语法错误
   - 查看 GitHub Actions 日志

2. **Docker 镜像构建失败**
   - 检查 `yudao-server/Dockerfile` 是否存在
   - 验证 `yudao-server/target/yudao-server.jar` 是否正确生成

3. **推送到 GHCR 失败**
   - GitHub Token 权限不足
   - 更新 Token 并重新推送

### Q3: 如何重新运行 GitHub Actions

```bash
# 方式 1: 推送新的 commit
git commit --allow-empty -m "Trigger GitHub Actions"
git push origin main

# 方式 2: 在 GitHub 页面上手动运行
# 访问 Actions 页面 → 选择工作流 → "Run workflow"
```

## 📝 后续步骤

1. ✅ 推送代码到 GitHub
2. ✅ 监控 GitHub Actions 构建完成
3. ✅ 验证 Docker 镜像已推送到 GHCR
4. ✅ 在阿里云 ECS 上部署（参考 ALIYUN-DEPLOY.md）

## 🎯 Docker 镜像版本管理

### 自动生成的镜像标签

GitHub Actions 会自动为构建的镜像生成以下标签：

```yaml
# 从分支构建
ghcr.io/zongyangbigpolo/qianniu:main      # 主分支
ghcr.io/zongyangbigpolo/qianniu:develop   # 开发分支

# 从标签构建 (例如 git tag v1.0.0)
ghcr.io/zongyangbigpolo/qianniu:v1.0.0    # 发布版本
ghcr.io/zongyangbigpolo/qianniu:1.0       # 主版本号
ghcr.io/zongyangbigpolo/qianniu:latest    # 最新版本

# SHA 哈希（用于精确版本）
ghcr.io/zongyangbigpolo/qianniu:sha-abc123def
```

在 `docker-compose.yml` 中使用：

```yaml
server:
  image: ghcr.io/zongyangbigpolo/qianniu:main
  # 或使用特定版本
  image: ghcr.io/zongyangbigpolo/qianniu:v1.0.0
```

## 📞 获取帮助

- GitHub Issues：https://github.com/zongyangbigpolo/qianniu/issues
- GitHub Discussions：https://github.com/zongyangbigpolo/qianniu/discussions
- GitHub Actions 文档：https://docs.github.com/en/actions

---

**准备好了吗？让我们一起推动千牛项目！🐮** 
