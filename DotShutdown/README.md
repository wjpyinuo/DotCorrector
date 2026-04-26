# DotShutdown

**Professional Windows Auto Shutdown Utility**

一个现代化的 Windows 定时关机工具，基于 WinUI 3 + .NET 8 构建。

![.NET 8](https://img.shields.io/badge/.NET-8.0-purple)
![WinUI 3](https://img.shields.io/badge/WinUI-3-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## ✨ 功能特性

| 功能 | 说明 |
|------|------|
| ⏻ 多种电源操作 | 关机、重启、睡眠、休眠、注销 |
| ⏱️ 灵活定时 | 快捷预设 + 自定义时分秒 |
| 📌 系统托盘 | 最小化到托盘后台静默运行 |
| 🔔 Toast 通知 | Windows 原生通知 + 声音提醒 |
| 🛡️ 防误操作 | 二次确认对话框 + 随时取消 |
| 🖥️ CLI 模式 | 命令行参数，适合脚本调用 |
| 💾 配置记忆 | 自动保存上次使用的设置 |
| 🎨 Fluent Design | WinUI 3 原生 Mica 毛玻璃主题 |

---

## 🚀 快速开始

### 环境要求

- Windows 10 (1809+) 或 Windows 11
- .NET 8 SDK ([下载](https://dotnet.microsoft.com/download/dotnet/8.0))
- Visual Studio 2022 17.8+（可选，推荐）

### 方式一：命令行构建

```bash
# 克隆项目
git clone <repo-url>
cd DotShutdown

# 构建
dotnet build src/DotShutdown.csproj -c Release

# 运行
dotnet run --project src/DotShutdown.csproj

# 发布（单文件自包含）
dotnet publish src/DotShutdown.csproj -c Release -p:PublishSingleFile=true --self-contained
```

### 方式二：Visual Studio

1. 打开 `DotShutdown.sln`
2. 选择 `Release | x64`
3. 生成 → 发布

### 方式三：一键构建

```bash
# Windows 上双击运行
build.bat
# 输出在 dist/x64/DotShutdown.exe
```

---

## 🖥️ 使用说明

### GUI 模式

双击 `DotShutdown.exe`，界面操作：

1. **选择操作类型** — 关机 / 重启 / 睡眠 / 休眠 / 注销
2. **设置时间** — 点击快捷预设或手动输入时分秒
3. **点击「开始倒计时」** — 确认后开始
4. **随时取消** — 点击取消按钮或系统托盘右键

### CLI 模式

```bash
# 30 分钟后关机
DotShutdown.exe --cli -t 30

# 2 小时后重启
DotShutdown.exe --cli -t 2h -a restart

# 45 分钟后强制关机
DotShutdown.exe --cli -t 45m -f

# 1 小时 30 分钟后睡眠
DotShutdown.exe --cli -t 1h30m -a sleep

# 取消待执行的关机
DotShutdown.exe --cli --cancel

# 查看当前状态
DotShutdown.exe --cli --status
```

### 时间格式

| 格式 | 示例 | 说明 |
|------|------|------|
| `N` | `30` | N 分钟 |
| `Nm` | `45m` | N 分钟 |
| `Nh` | `2h` | N 小时 |
| `Ns` | `90s` | N 秒 |
| `NhNm` | `1h30m` | 1 小时 30 分钟 |

---

## 📁 项目结构

```
DotShutdown/
├── DotShutdown.sln              # 解决方案文件
├── build.bat                    # Windows 构建脚本
├── README.md                    # 本文档
└── src/
    ├── DotShutdown.csproj       # 项目文件
    ├── Program.cs               # 入口点（GUI/CLI 分发）
    ├── App.xaml / App.xaml.cs   # 应用生命周期
    ├── MainWindow.xaml / .cs    # 主窗口 UI
    ├── Models/
    │   ├── PowerAction.cs       # 电源操作枚举
    │   ├── AppSettings.cs       # 配置模型
    │   └── ScheduleTask.cs      # 定时任务模型
    ├── Services/
    │   ├── PowerService.cs      # Windows 电源 API
    │   ├── CountdownService.cs  # 倒计时引擎
    │   ├── NotificationService.cs # Toast 通知
    │   ├── TrayService.cs       # 系统托盘
    │   └── SettingsService.cs   # 配置持久化
    ├── ViewModels/
    │   └── TimerViewModel.cs    # 主页面 ViewModel
    ├── Helpers/
    │   ├── TimeParser.cs        # 时间字符串解析
    │   └── CliParser.cs         # 命令行参数解析
    ├── Converters/
    │   └── Converters.cs        # XAML 值转换器
    └── Assets/                  # 图标资源
```

---

## ⚙️ 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| UI 框架 | WinUI 3 (Windows App SDK) | 1.5 |
| 语言 | C# | 12 |
| 运行时 | .NET | 8.0 |
| MVVM | CommunityToolkit.Mvvm | 8.2 |
| 托盘 | H.NotifyIcon.WinUI | 2.1 |
| 通知 | Windows App Notifications | — |
| 打包 | 单文件自包含 | — |

---

## 📋 配置文件

配置自动保存在 `%LOCALAPPDATA%/DotShutdown/settings.json`：

```json
{
  "lastAction": "Shutdown",
  "lastMinutes": 30,
  "forceClose": false,
  "soundAlert": true,
  "alertBeforeSeconds": 60,
  "minimizeToTray": true,
  "confirmBeforeAction": true,
  "launchAtStartup": false,
  "theme": "System"
}
```

---

## 🏗️ 开发

### 依赖

```bash
dotnet restore src/DotShutdown.csproj
```

### 调试

```bash
dotnet run --project src/DotShutdown.csproj
```

或在 Visual Studio 中按 F5。

### 发布选项

```bash
# 依赖框架（体积小，需要 .NET 运行时）
dotnet publish -c Release

# 自包含（体积大，无需运行时）
dotnet publish -c Release --self-contained

# 自包含 + 单文件 + 压缩
dotnet publish -c Release -p:PublishSingleFile=true --self-contained -p:EnableCompressionInSingleFile=true

# AOT 原生编译（启动最快，兼容性受限）
dotnet publish -c Release -p:PublishAot=true
```

---

## 📄 License

MIT License

---

> Built with 💙 by DotShutdown
