## 千牛前端 - 多阶段构建
## Stage 1: 使用 pnpm 构建静态资源
FROM node:20-alpine AS build

## lockfile 是 v9 格式，需要 pnpm 9+
RUN corepack enable && corepack prepare pnpm@9 --activate

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --ignore-scripts

COPY . .

## 使用 docker 专用环境变量构建（相对路径 API，配合 Nginx 反代）
RUN node --max_old_space_size=4096 ./node_modules/vite/bin/vite.js build --mode docker

## Stage 2: 使用 Nginx 提供静态文件服务
FROM nginx:1.25-alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
