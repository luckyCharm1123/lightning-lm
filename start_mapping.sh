#!/bin/bash
# Lightning-LM + Mid360 一键启动脚本

echo "========================================="
echo "  Lightning-LM 自动建图系统"
echo "========================================="

# 检查ROS2环境
if [ -z "$ROS_DISTRO" ]; then
    echo "❌ 错误: ROS2环境未加载"
    echo "   请先运行: source /opt/ros/humble/setup.bash"
    exit 1
fi

# 设置工作空间
cd /home/ubuntu22/Desktop/lightning-lm

# 添加Pangolin库路径
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# 加载工作空间
source /opt/ros/humble/setup.bash
source install/setup.bash

# 创建数据目录
mkdir -p data/mid360_map

echo ""
echo "📋 系统信息:"
echo "   雷达IP: 192.168.1.109"
echo "   电脑IP: 192.168.1.123"
echo "   配置文件: config/default_mid360.yaml"
echo "   地图保存: data/mid360_map/"
echo ""

# 检查驱动是否已运行且正常工作
DRIVER_WORKING=false

# 检查1: 节点是否存在
if ros2 node list 2>/dev/null | grep -q "livox"; then
    echo "检测到 Livox 驱动节点，检查是否正常工作..."

    # 检查2: 话题是否有发布者
    PUBLISHER_COUNT=$(ros2 topic info /livox/lidar 2>/dev/null | grep "Publisher count" | awk '{print $3}' || echo "0")

    if [ "$PUBLISHER_COUNT" -gt 0 ]; then
        echo "✅ Livox驱动已在运行且正常工作"
        DRIVER_WORKING=true
    else
        echo "⚠️  Livox驱动节点存在但未发布数据，将重启驱动"
        # 杀死旧进程
        pkill -f "livox_ros_driver2" 2>/dev/null
        sleep 2
    fi
fi

# 如果驱动没有正常工作，启动它
if [ "$DRIVER_WORKING" = false ]; then
    echo "步骤 1/2: 启动 Mid360 驱动..."
    echo "----------------------------------------"

    # 后台启动Mid360驱动
    ros2 launch livox_ros_driver2 msg_MID360_launch.py > /tmp/livox_driver.log 2>&1 &
    LIVOX_PID=$!

    echo "等待驱动初始化 (8秒)..."
    sleep 8

    # 检查话题
    if ! ros2 topic list 2>/dev/null | grep -q "/livox/lidar"; then
        echo "❌ 错误: 未检测到 /livox/lidar 话题"
        echo ""
        echo "请检查:"
        echo "  1. Mid360是否连接 (IP: 192.168.1.109)"
        echo "  2. 网络线是否插好"
        echo "  3. 驱动日志: cat /tmp/livox_driver.log"
        echo ""
        read -p "按Enter键退出..."
        exit 1
    fi

    # 检查发布者数量
    PUBLISHER_COUNT=$(ros2 topic info /livox/lidar 2>/dev/null | grep "Publisher count" | awk '{print $3}' || echo "0")
    if [ "$PUBLISHER_COUNT" -eq 0 ]; then
        echo "❌ 错误: 驱动未发布数据，请检查驱动日志: cat /tmp/livox_driver.log"
        read -p "按Enter键退出..."
        exit 1
    fi

    echo "✅ 驱动启动成功！"
    echo ""
fi

echo "步骤 2/2: 启动 Lightning-LM SLAM..."
echo "========================================="
echo ""
echo "🚀 开始建图！"
echo ""
echo "提示:"
echo "  - 移动雷达进行建图"
echo "  - 按 Ctrl+C 停止建图"
echo "  - 地图会自动保存到 data/mid360_map/"
echo ""

# 启动SLAM
ros2 run lightning run_slam_online --config=config/default_mid360.yaml

# 清理
if [ -n "$LIVOX_PID" ]; then
    kill $LIVOX_PID 2>/dev/null
fi

echo ""
echo "========================================="
echo "  建图已停止，地图已保存"
echo "========================================="
