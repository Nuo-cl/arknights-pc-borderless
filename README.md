# 明日方舟PC端 无边框窗口工具 / Arknights PC Borderless Window Tool

为**明日方舟PC端（官方桌面版）**及**明日方舟：终末地**设计的无边框窗口工具。去除窗口全屏模式下的白色标题栏，同时保留系统任务栏可见。

> A lightweight AutoHotkey v2 tool for the official Arknights PC client and Arknights: Endfield. Removes the title bar in windowed-fullscreen mode while keeping the Windows taskbar visible.

## 解决的问题

明日方舟PC端 / 终末地的显示模式：
- **全屏** — 遮挡任务栏，无法快速切换其他程序
- **窗口全屏** — 顶部有白色标题栏，不美观

本工具将窗口全屏优化为**无边框窗口模式**：没有标题栏，也不遮挡任务栏。

## 下载

从 [Releases](https://github.com/Nuo-cl/arknights-pc-borderless/releases) 页面下载最新版本：

- **borderless.exe** — 直接运行，不需要安装任何东西
- **borderless.ahk** — 需要 [AutoHotkey v2.0+](https://www.autohotkey.com/)，可直接编辑脚本

## 环境要求

- Windows 10 / 11
- 明日方舟PC端 / 明日方舟：终末地

## 使用方法

1. 将游戏内显示模式设为**窗口全屏**
2. 运行 `borderless.exe` 或 `borderless.ahk`（自动请求管理员权限）
3. 按 `Ctrl+F4` 隐藏标题栏，按 `Ctrl+F7` 恢复
4. 脚本退出时自动恢复所有窗口

## 快捷键

| 快捷键 | 功能 |
|---|---|
| Ctrl+F4 | 隐藏标题栏 |
| Ctrl+F7 | 恢复标题栏 |

## 自定义配置

在脚本同目录下创建 `config.ini` 文件即可自定义配置（不创建则使用默认值）：

```ini
[General]
Title=明日方舟
HideKey=^F4
RestoreKey=^F7
```

快捷键语法参考 [AutoHotkey v2 Hotkey 文档](https://www.autohotkey.com/docs/v2/Hotkeys.htm)：`^` = Ctrl, `!` = Alt, `+` = Shift, `#` = Win。

使用 `.ahk` 版本时也可以直接编辑脚本顶部的配置区域。

## 开机自启

右键系统托盘绿色 `H` 图标 → 点击「开机自启」切换开关。

原理是在系统启动文件夹（`shell:startup`）中创建/删除快捷方式，可随时关闭。

## 原理说明

通过 Windows API 修改窗口样式（移除 `WS_CAPTION` 和 `WS_THICKFRAME`），并将窗口调整为显示器工作区大小（排除任务栏区域）。恢复时还原原始样式和窗口位置。

脚本需要管理员权限运行，因为明日方舟PC端以管理员权限启动，普通权限无法修改其窗口样式。

## 多窗口支持

脚本通过标题关键词"明日方舟"进行包含匹配，同时适用于明日方舟PC端和终末地。

如果两个游戏同时运行：
- 每次按快捷键只操作**当前活跃（或最近活跃）的那个窗口**
- 每个窗口的状态独立保存，可分别隐藏和恢复
- 切换到另一个游戏窗口后再按快捷键即可操作该窗口
