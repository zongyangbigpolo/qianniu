#!/bin/bash

# ============================================================
# RuoYi-Vue-Pro Docker 快速部署脚本
# 支持本地和远程服务器部署
# ============================================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示使用说明
show_usage() {
    cat << EOF
使用方法:
    $0 [命令] [选项]

命令:
    build       构建 JAR 包
    up          启动所有服务
    down        停止所有服务
    restart     重启服务
    logs        查看日志
    status      查看服务状态
    clean       清理所有数据和容器
    help        显示此帮助信息

选项:
    -s          服务名称 (server, admin, mysql, redis)
    -f          跟随日志 (logs 命令)

示例:
    $0 build                   # 构建 JAR 包
    $0 up                      # 启动所有服务
    $0 logs -s server -f       # 跟随查看后端日志
    $0 down                    # 停止服务

EOF
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_warn "Docker Compose 未找到，尝试使用 docker compose"
        DOCKER_COMPOSE="docker compose"
    else
        DOCKER_COMPOSE="docker-compose"
    fi
    
    log_info "Docker 版本: $(docker --version)"
    log_info "Docker Compose 版本: $($DOCKER_COMPOSE --version)"
}

# 构建 JAR 包
build_jar() {
    log_info "开始构建 JAR 包..."
    
    if [ -f "mvnw" ]; then
        ./mvnw clean install -DskipTests
    elif command -v mvn &> /dev/null; then
        mvn clean install -DskipTests
    else
        log_error "Maven 未安装，请先安装 Maven 或使用 Maven wrapper"
        exit 1
    fi
    
    log_info "JAR 包构建完成"
}

# 启动服务
start_services() {
    log_info "启动所有服务..."
    
    cd "$(dirname "$0")"
    
    if [ -f ".env" ]; then
        log_info "使用环境变量文件: .env"
        $DOCKER_COMPOSE up -d
    elif [ -f ".env.example" ]; then
        log_warn "未找到 .env 文件，使用 .env.example"
        $DOCKER_COMPOSE up -d
    else
        log_warn "未找到环境变量文件"
        $DOCKER_COMPOSE up -d
    fi
    
    log_info "服务启动完成"
    
    # 等待服务启动
    sleep 5
    show_status
}

# 停止服务
stop_services() {
    log_info "停止所有服务..."
    
    cd "$(dirname "$0")"
    $DOCKER_COMPOSE down
    
    log_info "服务已停止"
}

# 重启服务
restart_services() {
    log_info "重启服务..."
    
    cd "$(dirname "$0")"
    
    if [ -n "$SERVICE_NAME" ]; then
        log_info "重启服务: $SERVICE_NAME"
        $DOCKER_COMPOSE restart "$SERVICE_NAME"
    else
        $DOCKER_COMPOSE restart
    fi
    
    log_info "服务已重启"
}

# 查看日志
show_logs() {
    cd "$(dirname "$0")"
    
    if [ -n "$SERVICE_NAME" ]; then
        if [ "$FOLLOW_LOG" = "true" ]; then
            log_info "实时显示 $SERVICE_NAME 日志 (按 Ctrl+C 停止)..."
            $DOCKER_COMPOSE logs -f --tail=100 "$SERVICE_NAME"
        else
            $DOCKER_COMPOSE logs --tail=100 "$SERVICE_NAME"
        fi
    else
        if [ "$FOLLOW_LOG" = "true" ]; then
            log_info "实时显示所有日志 (按 Ctrl+C 停止)..."
            $DOCKER_COMPOSE logs -f --tail=50
        else
            $DOCKER_COMPOSE logs --tail=50
        fi
    fi
}

# 查看服务状态
show_status() {
    cd "$(dirname "$0")"
    
    log_info "服务状态:"
    $DOCKER_COMPOSE ps
    
    echo ""
    log_info "访问地址:"
    echo "  - 管理后台: http://localhost:8080"
    echo "  - 后端 API: http://localhost:48080"
    echo "  - MySQL: localhost:3306 (root/123456)"
    echo "  - Redis: localhost:6379"
}

# 清理数据
cleanup() {
    log_warn "这将删除所有容器和数据！"
    read -p "确认删除？(y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$(dirname "$0")"
        log_info "删除所有容器和 volumes..."
        $DOCKER_COMPOSE down -v
        log_info "清理完成"
    else
        log_info "取消操作"
    fi
}

# 主程序
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 0
    fi
    
    check_dependencies
    
    COMMAND="$1"
    shift
    
    # 解析选项
    while getopts "s:f" opt; do
        case $opt in
            s) SERVICE_NAME="$OPTARG" ;;
            f) FOLLOW_LOG="true" ;;
            \?) log_error "未知选项: -$OPTARG"; show_usage; exit 1 ;;
        esac
    done
    
    case "$COMMAND" in
        build)
            build_jar
            ;;
        up)
            start_services
            ;;
        down)
            stop_services
            ;;
        restart)
            restart_services
            ;;
        logs)
            show_logs
            ;;
        status)
            show_status
            ;;
        clean)
            cleanup
            ;;
        help)
            show_usage
            ;;
        *)
            log_error "未知命令: $COMMAND"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
