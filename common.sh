#!/bin/bash
set -e

COMMON_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# 日志文件的基础名称（不包含日期）
LOG_BASE_NAME="log"
# 日志文件最大大小（以字节为单位），例如5MB
MAX_SIZE=5242880
# 日志文件当前目录（可以是相对路径或绝对路径）
LOG_DIR="$COMMON_DIR/logs"
# 确保日志目录存在
mkdir -p "$LOG_DIR"

# 获取当前日期，用于日志文件命名
CURRENT_DATE=$(date +%Y%m%d)

# 完整的日志文件路径（包括日期前缀）
LOG_FILE_PATH="$LOG_DIR/${LOG_BASE_NAME}_${CURRENT_DATE}.log"

# 检查是否有旧的日志文件存在，并且找到最新的一个
LATEST_LOG_FILE=
for file in "$LOG_DIR/${LOG_BASE_NAME}_"*.log; do
    if [[ -z "$LATEST_LOG_FILE" ]] || [[ "$file" -nt "$LATEST_LOG_FILE" ]]; then
        LATEST_LOG_FILE="$file"
    fi
done

# 如果旧的日志文件存在且超过最大大小，则更新LOG_FILE_PATH为新文件
if [[ -f "$LATEST_LOG_FILE" ]] && [[ $(stat -c%s "$LATEST_LOG_FILE") -ge "$MAX_SIZE" ]]; then
    CURRENT_DATE=$(date +%Y%m%d_%H%M%S) # 重新获取当前日期以确保唯一性
    LOG_FILE_PATH="$LOG_DIR/${LOG_BASE_NAME}_${CURRENT_DATE}.log"
fi

set +e
set -o noglob

### 全局通用变量
# app_dir_name="DAKEWE_APP_DIR"
# app_is_install_name="DAKEWE_APP_IS_INSTALL"
# APP_DIR_NAME="dakewe-pms"

# 定义颜色变量
RED='\033[0;31m'     # 红色，用于错误信息
GREEN='\033[0;32m'   # 绿色，用于成功信息
YELLOW='\033[0;33m'  # 黄色，用于警告信息
BLUE='\033[0;34m'    # 蓝色，用于一般信息或者提示信息
MAGENTA='\033[0;35m' # 紫色，用于调试信息
CYAN='\033[0;36m'    # 青色，用于次要提示信息
WHITE='\033[0;37m'   # 白色，用于普通信息
NC='\033[0m'         # 无颜色（重置颜色）

# 日志记录函数
function log_message() {
    local level=$1
    local message=$2
    local color
    local prefix

    case $level in
        ERROR)
            color="${RED}"
            prefix="ERROR:"
            ;;
        SUCCESS)
            color="${GREEN}"
            prefix="SUCCESS:"
            ;;
        WARNING)
            color="${YELLOW}"
            prefix="WARNING:"
            ;;
        DEBUG)
            color="${MAGENTA}"
            prefix="DEBUG:"
            ;;
        TIPS)
            color="${CYAN}"
            prefix="TIPS:"
            ;;
        NOTES)
            color="${BLUE}"
            prefix=""
            ;;
        INFO)
            color="${WHITE}"
            prefix=""
            ;;
        
        *)
    esac

    # 将日志（不带颜色）写入文件
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level]: $message" >> "$LOG_FILE_PATH"

    # 在终端输出带颜色的日志
    echo -e "${color}${prefix} $message${NC}"
}

function LOG_ERROR() {
    log_message ERROR "[✘] $1 "
}

function LOG_SUCCESS() {
    log_message SUCCESS "[✔] $1 "
}

function LOG_WARNING() {
    log_message WARNING "$1"
}

function LOG_DEBUG() {
    log_message DEBUG "$1"
}

function LOG_TIPS() {
    log_message TIPS "$1"
}
function LOG_NOTES() {
    log_message NOTES "$1"
}

function LOG_INFO() {
    log_message INFO "$1"
}
#### 示例日志消息
# LOG_ERROR "这是一个错误消息"
# LOG_SUCCESS "这是一个成功消息"
# LOG_WARNING "这是一个警告消息"
# LOG_DEBUG "这是一个调试消息"
# LOG_TIPS "这是一个提示信息"
# LOG_NOTES "这是一个次要提示信息"
# LOG_INFO "这是一个普通信息"

