#!/bin/bash
# 实时监控建图进度

echo "========================================="
echo "  Lightning-LM 建图监控"
echo "========================================="
echo ""
echo "按 Ctrl+C 退出监控"
echo ""

source /opt/ros/humble/setup.bash 2>/dev/null

while true; do
    clear
    echo "========================================="
    echo "  Lightning-LM 建图监控"
    echo "========================================="
    echo ""

    # 显示时间
    echo "⏰ $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    # 检查进程
    echo "🔍 进程状态:"
    echo "----------------------------------------"

    if ps aux | grep -v grep | grep -q "livox_ros_driver2_node"; then
        LIVOX_PID=$(ps aux | grep "livox_ros_driver2_node" | grep -v grep | awk '{print $2}')
        echo "✅ Livox驱动: 运行中 (PID: $LIVOX_PID)"
    else
        echo "❌ Livox驱动: 未运行"
    fi

    if ps aux | grep -v grep | grep -q "run_slam_online"; then
        SLAM_PID=$(ps aux | grep "run_slam_online" | grep -v grep | awk '{print $2}' | head -1)
        CPU=$(ps aux | grep "run_slam_online" | grep -v grep | awk '{print $3}' | head -1)
        MEM=$(ps aux | grep "run_slam_online" | grep -v grep | awk '{print $4}' | head -1)
        echo "✅ SLAM进程: 运行中"
        echo "   PID: $SLAM_PID | CPU: ${CPU}% | 内存: ${MEM}%"
    else
        echo "❌ SLAM进程: 未运行"
    fi

    echo ""

    # 显示数据频率
    echo "📡 数据流:"
    echo "----------------------------------------"

    # 检查话题
    if ros2 topic list 2>/dev/null | grep -q "/livox/lidar"; then
        echo "✅ /livox/lidar - 点云数据正常"

        # 尝试获取频率
        HZ=$(timeout 2 ros2 topic hz /livox/lidar 2>/dev/null | grep "average rate" | awk '{print $3}')
        if [ -n "$HZ" ]; then
            echo "   频率: $HZ Hz"
        fi
    else
        echo "❌ /livox/lidar - 无数据"
    fi

    if ros2 topic list 2>/dev/null | grep -q "/livox/imu"; then
        echo "✅ /livox/imu - IMU数据正常"
    else
        echo "❌ /livox/imu - 无数据"
    fi

    echo ""

    # 显示数据目录
    echo "📁 数据目录:"
    echo "----------------------------------------"

    if [ -d "data/mid360_map" ]; then
        KB_SIZE=$(du -sk data/mid360_map 2>/dev/null | cut -f1)
        if [ -n "$KB_SIZE" ] && [ "$KB_SIZE" != "0" ]; then
            MB_SIZE=$(echo "scale=2; $KB_SIZE/1024" | bc 2>/dev/null)
            echo "📦 地图大小: ${MB_SIZE} MB"
        else
            echo "📦 地图大小: 0 MB (未开始或未保存)"
        fi

        FILE_COUNT=$(find data/mid360_map -type f 2>/dev/null | wc -l)
        echo "📄 文件数量: $FILE_COUNT"

        if [ "$FILE_COUNT" -gt 0 ]; then
            echo ""
            echo "最近保存的文件:"
            ls -lt data/mid360_map/ 2>/dev/null | head -6 | tail -5
        fi
    else
        echo "⚠️  数据目录不存在"
    fi

    echo ""
    echo "========================================="
    echo "刷新间隔: 2秒 | 按 Ctrl+C 退出"
    echo ""

    sleep 2
done
