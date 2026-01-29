# Lightning-LM SLAM System

基于 Faster-LIO 的 SLAM 系统，**已完成对 Livox Mid360 LiDAR 的完整适配与优化**，支持在线建图与定位。

## ⚠️ 克隆注意事项

本项目包含三个 git 子模块（lightning-lm、livox_ros_driver2、thirdparty/Pangolin），克隆时请使用以下命令：

```bash
git clone --recursive git@github.com:luckyCharm1123/lightning-lm.git
```

如果已经克隆了仓库但子模块未初始化，请运行：

```bash
cd lightning-lm
git submodule update --init --recursive
```

## 🚀 快速开始

详细的使用指南请查看 [USER_GUIDE.md](USER_GUIDE.md)

### 一键启动建图

```bash
cd /home/ubuntu22/Desktop/lightning-lm
./start_mapping.sh
```

## 📋 主要功能

- ✅ **已完成 Livox Mid360 LiDAR 完整适配**
- ✅ 在线 SLAM 建图
- ✅ 离线点云地图构建
- ✅ 在线定位
- ✅ 2D 栅格地图生成（支持 ROS2 导航）
- ✅ 回环检测
- ✅ 3D 可视化界面

## 📦 项目结构

```
lightning-lm/
├── lightning-lm/           # 核心源代码
├── livox_ros_driver2/      # Livox 雷达驱动
├── thirdparty/Pangolin/    # 第三方可视化库
├── config/                 # 配置文件
├── scripts/                # 辅助脚本
├── data/                   # 地图数据
└── USER_GUIDE.md           # 详细使用指南
```

## 🔧 系统要求

- Ubuntu 22.04
- ROS 2 Humble
- Livox Mid360 LiDAR
- 千兆网卡

## 📖 文档

完整的使用说明、配置参数、故障排查请参阅：[USER_GUIDE.md](USER_GUIDE.md)

## ⚖️ 许可证

本项目遵循相应开源许可证。

---

**Happy Mapping! 🚀**
