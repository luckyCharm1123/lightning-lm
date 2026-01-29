#!/bin/bash
# Lightning-LM Mid360 离线建图脚本 (从 rosbag)

cd "$(dirname "$0")/.."

echo "========================================="
echo "  Lightning-LM Mid360 离线建图"
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

# 检查参数
BAG_FILE="$1"
CONFIG_FILE="$2"

if [ -z "$CONFIG_FILE" ]; then
    CONFIG_FILE="./config/default_mid360.yaml"
fi

if [ -z "$BAG_FILE" ]; then
    echo "用法: $0 <bag_file> [config_file]"
    echo ""
    echo "示例:"
    echo "  $0 my_data.bag"
    echo "  $0 my_data.bag ./config/default_mid360.yaml"
    exit 1
fi

if [ ! -f "$BAG_FILE" ]; then
    echo "错误: 数据包不存在: $BAG_FILE"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

echo "数据包: $BAG_FILE"
echo "配置文件: $CONFIG_FILE"
echo "========================================="

# 启动离线建图
ros2 run lightning run_slam_offline --config "$CONFIG_FILE" --input_bag "$BAG_FILE"
