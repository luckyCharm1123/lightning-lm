#!/bin/bash
# Lightning-LM 无UI模式启动脚本（适合服务器/远程环境）

echo "========================================="
echo "  Lightning-LM 建图 (无UI模式)"
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
echo "   模式: 无UI（适合远程/服务器）"
echo "   雷达IP: 192.168.1.109"
echo "   地图保存: data/mid360_map/"
echo ""

# 检查驱动是否已运行
if ros2 node list 2>/dev/null | grep -q "livox"; then
    echo "✅ Livox驱动已在运行"
else
    echo "步骤 1/2: 启动 Mid360 驱动..."
    echo "----------------------------------------"

    # 后台启动Mid360驱动
    ros2 launch livox_ros_driver2 msg_MID360_launch.py > /tmp/livox_driver.log 2>&1 &
    LIVOX_PID=$!

    echo "等待驱动初始化 (8秒)..."
    sleep 8

    # 检查话题
    if ! ros2 topic list | grep -q "/livox/lidar"; then
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

    echo "✅ 驱动启动成功！"
    echo ""
fi

echo "步骤 2/2: 启动 Lightning-LM SLAM (无UI模式)..."
echo "========================================="
echo ""
echo "🚀 开始建图！"
echo ""
echo "提示:"
echo "  - 移动雷达进行建图"
echo "  - 按 Ctrl+C 停止建图"
echo "  - 地图会自动保存到 data/mid360_map/"
echo "  - 可以用 ./check_status.sh 查看状态"
echo ""
echo "保存地图（在另一个终端）:"
echo "  ./save_map.sh"
echo ""

# 启动SLAM（无UI模式）
ros2 run lightning run_slam_online --config=config/default_mid360.yaml

# 清理
if [ -n "$LIVOX_PID" ]; then
    kill $LIVOX_PID 2>/dev/null
fi

echo ""
echo "========================================="
echo "  建图已停止"
echo "========================================="
echo ""
echo "检查保存的数据:"
ls -lh data/mid360_map/ 2>/dev/null || echo "  ⚠️  目录为空"
echo ""
