# SK120X Controller App

一款用于控制SK120X可调电源的跨平台移动应用，支持通过蓝牙连接和控制设备。

## 功能特性

- 🔌 通过低功耗蓝牙(BLE)连接SK120X电源设备
- 🎛️ 直观的旋钮控制电压和电流设置
- 📊 实时监控输入/输出电压、电流、功率和能耗
- 📱 支持横竖屏显示模式
  
## 下载与安装
- 前往[Releases](https://github.com/worldyun/sk120x-controller-app/releases) 页面下载最新版本，并安装。

## 界面

### 竖屏模式
- 信息卡片显示：电压、电流、功率、电量等参数
- 电源开关控制
- 设置选项列表

### 横屏模式
- 大尺寸旋钮控制电压和电流
- 实时数据显示面板
- 快速切换显示单位（电压/电流/电量）

## 技术栈
- Flutter: 跨平台移动应用开发框架
- Dart: 编程语言
- Bluetooth LE: 设备通信

## 开发与编译
### 克隆项目
```bash
git clone https://github.com/your-username/sk120x-controller-app.git
cd sk120x-controller-app
```

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
flutter run
```

## 应用结构

```
lib/
├── home_page.dart # 主页面和业务逻辑
├── ble.dart # 蓝牙通信模块
├── models/
│ └── sk_device.dart # 设备数据模型
└── utils/
└── event_bus.dart # 事件总线
```

## 核心功能说明

### 1. 蓝牙连接

应用启动后自动搜索并连接SK120X设备，通过 Ble 类处理所有蓝牙通信。

### 2. 参数控制
- 电压控制: 范围 0-36V，精度0.01V
- 电流控制: 范围 0-6A，精度0.001A

### 3. 数据监控
- 实时显示输入电压、输出电压、输出电流、功率
- 累计能量统计（Wh和mAh）
- 设备状态监控

### 4. 用户交互
- 旋钮控制：通过 KnobWidget 提供直观的参数调节
- 触摸控制：点击卡片可切换显示单位
- 文本输入：支持直接输入数值设置

### 5. 显示模式
- 竖屏模式: 紧凑布局，适合查看数据
- 横屏模式: 大旋钮控制，适合参数调节

## 开发特性
- 使用 StreamSubscription 监听蓝牙事件
- 通过 SharedPreferences 保存用户偏好设置
- 实现防抖动机制，优化旋钮操作体验
- 震动反馈增强用户交互体验
- 屏幕常亮功能防止应用运行时屏幕休眠

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 致谢
- knob_widget - 提供旋钮控件
- animated_toggle_switch - 提供电源开关控件

---

> 注意: 此应用需要配合SK120X可调电源设备使用，仅支持具有蓝牙功能的移动设备。
