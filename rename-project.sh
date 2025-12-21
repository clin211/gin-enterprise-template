#!/bin/bash

# 项目重命名脚本
# 将 cspedia 项目重命名为 gin-enterprise-template
# Module: github.com/clin211/gin-enterprise-template -> github.com/clin211/gin-enterprise-template

set -euo pipefail

# 定义新旧名称
OLD_MODULE="github.com/clin211/gin-enterprise-template"
NEW_MODULE="github.com/clin211/gin-enterprise-template"
OLD_NAME="cspedia"
NEW_NAME="gin-enterprise-template"
OLD_SERVICE_NAME="cspedia-apiserver"
NEW_SERVICE_NAME="gin-enterprise-template-apiserver"
OLD_REGISTRY="cspedia"
NEW_REGISTRY="clin211"

# 颜色定义
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

# 检查是否在正确的目录
if [ ! -f "go.mod" ]; then
    log_error "请在项目根目录运行此脚本"
    exit 1
fi

# 确认操作
echo "此脚本将执行以下重命名操作："
echo "  模块名: $OLD_MODULE -> $NEW_MODULE"
echo "  项目名: $OLD_NAME -> $NEW_NAME"
echo "  服务名: $OLD_SERVICE_NAME -> $NEW_SERVICE_NAME"
echo "  注册表: $OLD_REGISTRY -> $NEW_REGISTRY"
echo ""
read -p "确认继续吗？(y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    log_info "操作已取消"
    exit 0
fi

# 清理之前的构建产物
log_info "清理之前的构建产物..."
rm -rf _output/
rm -f cmd/cspedia-apiserver/cspedia-apiserver

# 1. 重命名文件夹
log_info "重命名文件夹..."
if [ -d "cmd/cspedia-apiserver" ]; then
    mv "cmd/cspedia-apiserver" "cmd/$NEW_SERVICE_NAME"
    log_info "  cmd/cspedia-apiserver -> cmd/$NEW_SERVICE_NAME"
fi

# 2. 重命名文件
log_info "重命名文件..."
files_to_rename=(
    "configs/cspedia-apiserver.yaml:configs/$NEW_SERVICE_NAME.yaml"
    "configs/cspedia.sql:configs/$NEW_NAME.sql"
)

for rename in "${files_to_rename[@]}"; do
    old_file="${rename%%:*}"
    new_file="${rename##*:}"
    if [ -f "$old_file" ]; then
        mv "$old_file" "$new_file"
        log_info "  $old_file -> $new_file"
    fi
done

# 3. 替换文件内容中的模块路径和名称
log_info "替换文件内容中的引用..."

# 查找需要替换的文件
find . -type f -name "*.go" -o -name "*.mod" -o -name "*.sum" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" -o -name "*.sql" -o -name "Dockerfile*" -o -name "Makefile" -o -name "*.md" -o -name "*.sh" -o -name "*.conf" | while read -r file; do
    # 跳过脚本自己
    if [ "$file" = "./rename-project.sh" ]; then
        continue
    fi

    # 跳过 .git 目录
    if [[ "$file" == *".git"* ]]; then
        continue
    fi

    # 检查文件是否包含需要替换的内容
    if grep -q "$OLD_MODULE\|$OLD_NAME\|$OLD_SERVICE_NAME\|$OLD_REGISTRY" "$file" 2>/dev/null; then
        log_info "  更新文件: $file"

        # 创建临时文件
        temp_file=$(mktemp)

        # 执行替换
        sed -e "s|$OLD_MODULE|$NEW_MODULE|g" \
            -e "s|$OLD_NAME|$NEW_NAME|g" \
            -e "s|$OLD_SERVICE_NAME|$NEW_SERVICE_NAME|g" \
            -e "s|$OLD_REGISTRY/$OLD_SERVICE_NAME|$NEW_REGISTRY/$NEW_SERVICE_NAME|g" \
            -e "s|$OLD_REGISTRY|$NEW_REGISTRY|g" \
            -e "s|cspedia_net|${NEW_NAME}_net|g" \
            -e "s|/home/project/$OLD_NAME|/home/project/$NEW_NAME|g" \
            "$file" > "$temp_file"

        # 替换原文件
        mv "$temp_file" "$file"
    fi
done

# 4. 更新 go.mod 并执行 go mod tidy
log_info "更新 Go modules..."
if [ -f "go.mod" ]; then
    log_info "  执行 go mod tidy..."
    go mod tidy
fi

# 5. 重新生成代码
log_info "重新生成代码..."
if command -v make >/dev/null 2>&1; then
    log_info "  执行 make generate..."
    make generate || log_warn "  make generate 失败，可能需要手动处理"
fi

# 6. 验证
log_info "验证重命名结果..."

# 检查 go.mod
if [ -f "go.mod" ]; then
    if grep -q "$NEW_MODULE" go.mod; then
        log_info "  ✓ go.mod 已更新"
    else
        log_error "  ✗ go.mod 更新失败"
    fi
fi

# 检查主要文件
key_files=(
    "cmd/$NEW_SERVICE_NAME/main.go"
    "configs/$NEW_SERVICE_NAME.yaml"
    "Makefile"
    "README.md"
)

for file in "${key_files[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "$NEW_MODULE\|$NEW_SERVICE_NAME" "$file" 2>/dev/null; then
            log_info "  ✓ $file 已更新"
        else
            log_warn "  ⚠ $file 可能未完全更新"
        fi
    else
        log_warn "  ⚠ 文件 $file 不存在"
    fi
done

# 7. 清理
log_info "清理临时文件..."
find . -name "*.tmp" -delete 2>/dev/null || true
find . -name ".DS_Store" -delete 2>/dev/null || true

# 8. 提示
echo ""
log_info "重命名完成！"
echo ""
echo "接下来的步骤："
echo "1. 运行以下命令验证项目："
echo "   make deps"
echo "   make build"
echo "   make test"
echo ""
echo "2. 检查并更新文档（如果需要）："
echo "   - README.md"
echo "   - API 文档"
echo ""
echo "3. 如果遇到构建问题，请检查："
echo "   - Wire 生成文件：make generate"
echo "   - Protobuf 文件：make protoc"
echo ""
echo "4. 提交更改："
echo "   git add ."
echo "   git commit -m \"feat: 重命名项目为 gin-enterprise-template\""
echo ""

log_info "项目重命名脚本执行完毕！"