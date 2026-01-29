# Lightning-LM + Mid360 完整使用指南

> **最后更新**: 2026-01-29
> **系统**: Lightning-LM + Livox Mid360
> **作者**: Lightning-LM Team

---

## 📋 目录

1. [快速开始](#快速开始)
2. [系统安装](#系统安装)
3. [硬件准备](#硬件准备)
4. [建图使用](#建图使用)
5. [配置说明](#配置说明)
6. [故障排查](#故障排查)
7. [性能优化](#性能优化)
8. [常见问题](#常见问题)

---

## 🚀 快速开始

### 一键启动（推荐）

```bash
cd /home/ubuntu22/Desktop/lightning-lm
./start_mapping.sh
```

**提示：**
- 启动后等待 10-30 秒让可视化窗口打开
- 缓慢移动雷达进行建图
- 按 `Ctrl+C` 退出（自动保存地图）

### 快速命令

```bash
./start_mapping.sh          # 启动建图（有UI）
./start_mapping_no_ui.sh    # 启动建图（无UI，服务器模式）
./check_status.sh           # 检查系统状态
./build_safe.sh             # 安全编译
```

---

## 🔧 系统安装

### 1. 安装依赖

```bash
cd /home/ubuntu22/Desktop/lightning-lm
./scripts/install_deps.sh
./scripts/install_pangolin.sh
```

### 2. 编译项目

```bash
source /opt/ros/humble/setup.bash
colcon build --packages-select lightning
source install/setup.bash
```

### 3. 验证安装

```bash
ros2 run lightning --ros-args --help
```

---

## 🔌 硬件准备

### 网络配置

**Mid360 默认 IP**: `192.168.1.1xx`
**电脑 IP**: 需配置在同一网段 `192.168.1.xxx`

```bash
# 测试连接
ping 192.168.1.109
```

### 硬件连接

- Mid360 通过网线连接到电脑
- 确保网络配置正确
- 建议使用千兆网口

---

## 🗺️ 建图使用

### 启动建图

#### 方法1: 一键启动（推荐）

```bash
./start_mapping.sh
```

#### 方法2: 手动启动

**终端1 - 启动驱动**
```bash
source /opt/ros/humble/setup.bash
source install/setup.bash
ros2 launch livox_ros_driver2 msg_MID360_launch.py
```

**终端2 - 启动SLAM**
```bash
source /opt/ros/humble/setup.bash
source install/setup.bash
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ros2 run lightning run_slam_online --config=config/default_mid360.yaml
```

### 建图技巧

1. **运动速度**: 保持匀速缓慢移动（建议 < 0.5 m/s）
2. **回环检测**: 定期回到之前经过的地方触发回环
3. **丰富场景**: 多角度采集数据
4. **实时检查**: 通过3D界面查看建图质量

### 保存地图

**方法1: 正常退出（自动保存）**
```bash
# 在SLAM终端按 Ctrl+C
```

**方法2: 运行中保存**
```bash
source /opt/ros/humble/setup.bash
source install/setup.bash
ros2 service call /lightning/save_map lightning/srv/SaveMap "{map_id: new_map}"
```

### 地图文件

保存位置：`./data/new_map/`

包含内容：
- `global.pcd` - 完整3D点云地图
- `map.pgm` - 2D栅格地图（ROS2导航用）
- `map.yaml` - 地图配置文件
- `0.pcd` - 分块地图切片

---

## ⚙️ 配置说明

### 主配置文件

`config/default_mid360.yaml`

### 关键参数

#### Faster-LIO 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `lidar_type` | 1 | 1=Livox系列 |
| `point_filter_num` | 4 | 点云采样数(4-8)，越小越精确 |
| `filter_size_scan` | 0.3 | 扫描降采样(米) |
| `filter_size_map` | 0.3 | 地图降采样(米) |
| `ivox_grid_resolution` | 0.3 | 地图网格分辨率(米) |
| `extrinsic_est_en` | true | 启用在线外参估计 |
| `acc_cov` | 0.05 | 加速度计协方差 |
| `gyr_cov` | 0.05 | 陀螺仪协方差 |

#### 系统参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `with_loop_closing` | true | 启用回环检测 |
| `with_ui` | true | 显示3D可视化界面 |
| `with_g2p5` | true | 生成2D栅格地图 |

#### 回环检测参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `loop_kf_gap` | 10 | 每隔N个关键帧检测回环 |
| `min_id_interval` | 15 | 候选帧最小ID间隔 |
| `closest_id_th` | 30 | 历史帧ID间隔阈值 |
| `max_range` | 30.0 | 候选帧最大距离(米) |
| `ndt_score_th` | 0.8 | NDT配准分数阈值 |
| `with_height` | true | 启用高度约束 |

---

## 🔍 故障排查

### 1. 无法接收到点云数据

**检查步骤：**
```bash
# 检查话题
ros2 topic list | grep livox

# 检查数据率
ros2 topic hz /livox/lidar

# 检查发布者
ros2 topic info /livox/lidar
```

**可能原因：**
- ❌ Livox 驱动未启动
- ❌ 网络配置问题
- ❌ 防火墙阻止

**解决方法：**
```bash
# 重启驱动
pkill -f livox_ros_driver2
source install/setup.bash
ros2 launch livox_ros_driver2 msg_MID360_launch.py
```

### 2. 驱动启动失败

**检查日志：**
```bash
cat /tmp/livox_driver.log
```

**常见错误：**
```
bind failed
Failed to init livox lidar sdk.
```

**解决方法：**
- 检查 Mid360 IP 是否正确
- 确认网线连接
- 重启 Mid360 电源

### 3. 建图漂移严重

**调整参数：**
```yaml
fasterlio:
  point_filter_num: 4      # 减小采样，更精确
  ivox_grid_resolution: 0.3  # 更精细的地图
  acc_cov: 0.05            # 降低IMU噪声
  gyr_cov: 0.05

loop_closing:
  with_loop_closing: true  # 确保启用回环
```

### 4. 程序卡顿/性能问题

**降低配置：**
```yaml
system:
  with_ui: false           # 关闭3D界面
  with_2dui: false          # 关闭2D界面

fasterlio:
  point_filter_num: 6      # 增大采样数
  ivox_grid_resolution: 0.5  # 增大网格

maps:
  load_map_size: 1         # 减小地图块
```

### 5. 可视化窗口未打开

**原因：**
- `with_ui: false` 被设置
- OpenGL 上下文问题

**检查：**
```bash
grep "with_ui" config/default_mid360.yaml
```

### 6. 回环检测未生效

**检查日志：**
```
lc candi: 3        # 检测到候选
aligning 0 with 63 # NDT配准中
optimize finished  # 优化完成
```

**调整参数：**
```yaml
loop_closing:
  loop_kf_gap: 10         # 更频繁检测
  min_id_interval: 15      # 降低间隔
  closest_id_th: 30        # 降低阈值
  ndt_score_th: 0.8        # 降低阈值
```

### 7. 地图未保存

**原因：**
- 程序被强制终止（kill -9）
- 关键帧数量为0

**解决：**
- 使用 `Ctrl+C` 正常退出
- 确保有足够的建图数据

### 8. 时间戳问题

**检查配置：**
```yaml
fasterlio:
  time_scale: 1e-3  # Livox使用毫秒级时间戳
```

### 9. 多楼层场景（Z轴漂移）

**关闭高度约束：**
```yaml
loop_closing:
  with_height: false  # 多层建筑必须关闭
```

### 10. 内存不足

**优化参数：**
```yaml
fasterlio:
  ivox_grid_resolution: 0.8  # 增大网格

maps:
  load_map_size: 1
```

---

## 🎯 性能优化

### 高精度配置（电脑配置好）

```yaml
fasterlio:
  point_filter_num: 4
  ivox_grid_resolution: 0.3
  filter_size_scan: 0.3
  filter_size_map: 0.3

loop_closing:
  loop_kf_gap: 5
  ndt_score_th: 0.8
```

### 高性能配置（电脑配置一般）

```yaml
system:
  with_ui: false
  with_2dui: false

fasterlio:
  point_filter_num: 6
  ivox_grid_resolution: 0.5
  filter_size_scan: 0.5
  filter_size_map: 0.5
```

### 服务器模式（无显示器）

```yaml
system:
  with_ui: false
  with_2dui: false
  with_g2p5: true       # 保留2D栅格地图
```

---

## 📚 附录

### A. 检查系统状态

```bash
./check_status.sh
```

输出包括：
- 进程状态
- ROS2话题
- 数据目录大小
- 文件数量

### B. 查看日志

```bash
# SLAM日志
tail -f ~/.ros/log/latest/run_slam_online/*.log

# 驱动日志
cat /tmp/livox_driver.log

# 构建日志
ls log/latest_build/
```

### C. 清理临时文件

```bash
# 清理构建日志
rm -rf log/build_*

# 清理临时日志
rm -f /tmp/livox_*.log /tmp/*slam*

# 清理Python缓存
find install/ -name "__pycache__" -delete
```

### D. 彻底重新编译

```bash
rm -rf build/ install/ log/
source /opt/ros/humble/setup.bash
colcon build --packages-select lightning
source install/setup.bash
```

---

## 📞 技术支持

### 项目结构

```
/home/ubuntu22/Desktop/lightning-lm/
├── lightning-lm/           # 源代码
│   ├── src/               # 核心代码
│   ├── config/            # 配置文件
│   └── doc/               # 文档
├── config/                # 用户配置
│   └── default_mid360.yaml
├── data/                  # 建图数据
│   └── new_map/           # 最新地图
├── scripts/               # 辅助脚本
├── start_mapping.sh       # 主启动脚本
└── USER_GUIDE.md          # 本文档
```

### 相关文档

- Faster-LIO: 前端里程计
- Livox SDK: 雷达驱动
- Pangolin: 可视化界面

---

## ⚖️ 许可证

本项目遵循相应开源许可证。

---

**Happy Mapping! 🚀**
