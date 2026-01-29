#!/bin/bash
# Pangolin 安装脚本

echo "========================================="
echo "  安装 Pangolin 依赖"
echo "========================================="

# 安装 Pangolin 依赖
sudo apt update
sudo apt install -y \
    libgl1-mesa-dev \
    libglvnd0 \
    libglx0 \
    libxext-dev \
    libx11-dev \
    libglew-dev \
    libeigen3-dev \
    libboost-dev \
    cmake \
    git

echo "========================================="
echo "  克隆并编译 Pangolin"
echo "========================================="

# 克隆 Pangolin (如果已存在则跳过)
if [ -d "~/thirdparty/Pangolin" ]; then
    echo "Pangolin 目录已存在，跳过克隆"
else
    git clone --recursive https://github.com/stevenlovegrove/Pangolin.git ~/thirdparty/Pangolin
fi

cd ~/thirdparty/Pangolin

# 创建构建目录
mkdir -p build && cd build

# 配置和编译
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TOOLS=OFF

make -j$(nproc)

# 安装
sudo make install

echo "========================================="
echo "  Pangolin 安装完成！"
echo "========================================="
