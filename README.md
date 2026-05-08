# 明日方舟PC端 无边框窗口工具 / Arknights PC Borderless Window Tool

为**明日方舟PC端（官方桌面版）**设计的无边框窗口工具。去除窗口全屏模式下的白色标题栏，同时保留系统任务栏可见。

> A lightweight AutoHotkey v2 tool for the official Arknights PC client. Removes the title bar in windowed-fullscreen mode while keeping the Windows taskbar visible.

## 解决的问题

明日方舟PC端的显示模式：
- **全屏** — 遮挡任务栏，无法快速切换其他程序
- **窗口全屏** — 顶部有白色"明日方舟"标题栏，不美观

本工具将窗口全屏优化为**无边框窗口模式**：没有标题栏，也不遮挡任务栏。

## 环境要求

- Windows 10 / 11
- [AutoHotkey v2.0+](https://www.autohotkey.com/)
- 明日方舟PC端（官方桌面版）

## 使用方法

1. 将游戏内显示模式设为**窗口全屏**
2. 双击 `borderless.ahk` 运行（自动请求管理员权限）
3. 按 `Ctrl+F4` 隐藏标题栏，按 `Ctrl+F7` 恢复

## 快捷键

| 快捷键 | 功能 |
|---|---|
| Ctrl+F4 | 隐藏标题栏 |
| Ctrl+F7 | 恢复标题栏 |

## 自定义配置

编辑脚本顶部的配置区域：

```ahk
global CFG_TITLE := "明日方舟"       ; 窗口标题（如有不同请修改）
global CFG_KEY_HIDE := "^F4"         ; 隐藏快捷键
global CFG_KEY_RESTORE := "^F7"      ; 恢复快捷键
```

快捷键语法参考 [AutoHotkey v2 Hotkey 文档](https://www.autohotkey.com/docs/v2/Hotkeys.htm)：`^` = Ctrl, `!` = Alt, `+` = Shift, `#` = Win。

## 开机自启

右键系统托盘绿色 `H` 图标 → 点击「开机自启」切换开关。

原理是在系统启动文件夹（`shell:startup`）中创建/删除快捷方式，可随时关闭。

## 原理说明

通过 Windows API 修改窗口样式（移除 `WS_CAPTION` 和 `WS_THICKFRAME`），并将窗口调整为显示器工作区大小（排除任务栏区域）。恢复时还原原始样式和窗口位置。

脚本需要管理员权限运行，因为明日方舟PC端以管理员权限启动，普通权限无法修改其窗口样式。
