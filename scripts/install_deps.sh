#!/bin/bash
# Lightning-LM 依赖安装脚本

echo "========================================="
echo "  安装 Lightning-LM 依赖"
echo "========================================="

sudo apt update
sudo apt install -y \
    libopencv-dev \
    libpcl-dev \
    pcl-tools \
    libyaml-cpp-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    ros-humble-pcl-conversions \
    ros-humble-pcl-ros \
    ros-humble-tf2-ros \
    ros-humble-tf2-geometry-msgs \
    ros-humble-sensor-msgs \
    ros-humble-geometry-msgs \
    ros-humble-nav-msgs \
    ros-humble-std-msgs

echo "========================================="
echo "  依赖安装完成！"
echo "========================================="
