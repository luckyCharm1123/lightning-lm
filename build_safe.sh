#!/bin/bash
# 安全编译脚本 - 防止内存耗尽导致死机

echo "========================================="
echo "  Lightning-LM 安全编译"
echo "========================================="

# 检查内存
TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
echo "系统内存: ${TOTAL_MEM}GB"

# 根据内存大小自动设置并行数
if [ "$TOTAL_MEM" -lt 8 ]; then
    PARALLEL_JOBS=1
    echo "内存较少，使用单线程编译"
elif [ "$TOTAL_MEM" -lt 16 ]; then
    PARALLEL_JOBS=2
    echo "使用 2 个并行任务"
else
    PARALLEL_JOBS=4
    echo "使用 4 个并行任务"
fi

# 设置编译器并行数限制
export MAKEFLAGS="-j${PARALLEL_JOBS}"

# 清理之前的构建
echo "清理旧构建文件..."
rm -rf build install log

# 使用限制的并行数编译
echo "开始编译（并行数: ${PARALLEL_JOBS}）..."
colcon build \
    --packages-select lightning \
    --cmake-args \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS_RELEASE="-O1 -fopenmp -fPIC" \
      --parallel-workers ${PARALLEL_JOBS}

if [ $? -eq 0 ]; then
    echo "========================================="
    echo "  编译成功！"
    echo "========================================="
else
    echo "========================================="
    echo "  编译失败！"
    echo "========================================="
    exit 1
fi
