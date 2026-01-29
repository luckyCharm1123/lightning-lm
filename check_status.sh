#!/bin/bash
# Lightning-LM 系统状态检查脚本

echo "========================================="
echo "  Lightning-LM 系统状态"
echo "========================================="
echo ""

# 检查ROS2环境
source /opt/ros/humble/setup.bash 2>/dev/null

echo "🔍 进程状态:"
echo "----------------------------------------"

# 检查Livox驱动
if ps aux | grep -v grep | grep -q "livox_ros_driver2_node"; then
    echo "✅ Livox驱动: 运行中"
    LIVOX_PID=$(ps aux | grep "livox_ros_driver2_node" | grep -v grep | awk '{print $2}')
    echo "   PID: $LIVOX_PID"
else
    echo "❌ Livox驱动: 未运行"
fi

# 检查SLAM进程
if ps aux | grep -v grep | grep -q "run_slam_online"; then
    echo "✅ SLAM进程: 运行中"
    SLAM_PID=$(ps aux | grep "run_slam_online" | grep -v grep | awk '{print $2}')
    echo "   PID: $SLAM_PID"
    CPU=$(ps aux | grep "run_slam_online" | grep -v grep | awk '{print $3"%"}')
    MEM=$(ps aux | grep "run_slam_online" | grep -v grep | awk '{print $4"%"}')
    echo "   CPU: $CPU, 内存: $MEM"
else
    echo "❌ SLAM进程: 未运行"
fi

echo ""
echo "📡 ROS2 话题:"
echo "----------------------------------------"

TOPICS=$(ros2 topic list 2>/dev/null)
if [ $? -eq 0 ]; then
    if echo "$TOPICS" | grep -q "/livox/lidar"; then
        echo "✅ /livox/lidar - 点云数据"
    fi
    if echo "$TOPICS" | grep -q "/livox/imu"; then
        echo "✅ /livox/imu - IMU数据"
    fi
    if echo "$TOPICS" | grep -q "Odometry"; then
        echo "✅ /Odometry - 位姿数据"
    fi
else
    echo "❌ 无法获取话题列表"
fi

echo ""
echo "📁 数据目录:"
echo "----------------------------------------"
if [ -d "data/mid360_map" ]; then
    KB_SIZE=$(du -sk data/mid360_map 2>/dev/null | cut -f1)
    MB_SIZE=$(echo "scale=2; $KB_SIZE/1024" | bc)
    echo "📦 地图大小: ${MB_SIZE} MB"
    FILE_COUNT=$(find data/mid360_map -type f 2>/dev/null | wc -l)
    echo "📄 文件数量: $FILE_COUNT"
else
    echo "⚠️  数据目录不存在"
fi

echo ""
echo "========================================="
