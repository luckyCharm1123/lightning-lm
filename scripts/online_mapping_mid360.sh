#!/bin/bash
# Lightning-LM Mid360 在线建图启动脚本

cd "$(dirname "$0")/.."

echo "========================================="
echo "  Lightning-LM Mid360 在线建图"
echo "========================================="

# 检查是否 source 了 ROS2 环境
if [ -z "$ROS_DISTRO" ]; then
    echo "错误: 未检测到 ROS2 环境，请先运行:"
    echo "  source /opt/ros/humble/setup.bash"
    exit 1
fi

# source Lightning-LM
if [ -f install/setup.bash ]; then
    source install/setup.bash
else
    echo "错误: 未找到编译后的 Lightning-LM，请先运行 colcon build"
    exit 1
fi

# 检查配置文件
CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ]; then
    CONFIG_FILE="./config/default_mid360.yaml"
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

echo "配置文件: $CONFIG_FILE"
echo "----------------------------------------"
echo "保存地图命令:"
echo "  ros2 service call /lightning/save_map lightning/srv/SaveMap \"{map_id: my_map}\""
echo "========================================="

# 启动建图
ros2 run lightning run_slam_online --config "$CONFIG_FILE"
