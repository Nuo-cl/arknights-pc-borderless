; 明日方舟 无边框窗口工具
; 适用: 明日方舟PC端（官方桌面版）
; 功能: 去除/恢复标题栏，保留任务栏
; 需要: AutoHotkey v2.0+

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

DllCall("SetProcessDpiAwarenessContext", "ptr", -4)

if !A_IsAdmin {
    try Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

; ============================== 配置 ==============================
; 优先读取 config.ini（适用于 exe 发布），不存在则用以下默认值

global CFG_INI := A_ScriptDir "\config.ini"
global CFG_TITLE := IniRead(CFG_INI, "General", "Title", "明日方舟")
global CFG_KEY_HIDE := IniRead(CFG_INI, "General", "HideKey", "^F4")
global CFG_KEY_RESTORE := IniRead(CFG_INI, "General", "RestoreKey", "^F7")

; ============================== 状态 ==============================
; 按窗口句柄存储每个窗口的原始状态，支持多窗口独立操作
global g_States := Map()             ; hwnd -> {style, x, y, w, h}

; ============================== 初始化 ==============================
A_IconTip := "明日方舟 无边框窗口"

Hotkey(CFG_KEY_HIDE, (*) => HideTitleBar())
Hotkey(CFG_KEY_RESTORE, (*) => RestoreTitleBar())

OnExit((*) => RestoreAll())
BuildTray()
return

; ============================== 查找窗口 ==============================

FindTargetWindow() {
    global
    ; 优先选择当前活跃的匹配窗口
    hwnd := WinActive(CFG_TITLE)
    if hwnd
        return hwnd
    ; 其次选择最近活跃的匹配窗口
    hwnd := WinExist(CFG_TITLE)
    if hwnd
        return hwnd
    return 0
}

GetWindowLabel(hwnd) {
    try return WinGetTitle(hwnd)
    return "未知窗口"
}

IsHidden(hwnd) {
    global
    return g_States.Has(hwnd)
}

; ============================== 去标题栏 ==============================

HideTitleBar() {
    global
    hwnd := FindTargetWindow()
    if !hwnd {
        MsgBox("未找到标题含 '" CFG_TITLE "' 的窗口。`n请先启动游戏。")
        return
    }

    label := GetWindowLabel(hwnd)

    if IsHidden(hwnd) {
        Flash(label " — 标题栏已隐藏")
        return
    }

    ; 保存原始状态
    origStyle := WinGetStyle(hwnd)
    WinGetPos(&ox, &oy, &ow, &oh, hwnd)

    try {
        WinSetStyle(origStyle & ~0xC00000 & ~0x40000, hwnd)
        ; 通过 Windows API 直接获取窗口所在显示器的工作区
        hMon := DllCall("MonitorFromWindow", "ptr", hwnd, "uint", 2)
        mi := Buffer(40)
        NumPut("uint", 40, mi, 0)
        DllCall("GetMonitorInfo", "ptr", hMon, "ptr", mi)
        l := NumGet(mi, 20, "int")
        t := NumGet(mi, 24, "int")
        r := NumGet(mi, 28, "int")
        b := NumGet(mi, 32, "int")
        WinMove(l, t, r - l, b - t, hwnd)
        g_States[hwnd] := {style: origStyle, x: ox, y: oy, w: ow, h: oh}
        Flash(label " — 已隐藏标题栏")
        BuildTray()
    } catch as e {
        MsgBox("操作失败: " e.Message "`n`n请确认脚本以管理员身份运行。", "错误", "Icon!")
    }
}

; ============================== 恢复标题栏 ==============================

RestoreTitleBar() {
    global
    hwnd := FindTargetWindow()
    if !hwnd {
        MsgBox("未找到标题含 '" CFG_TITLE "' 的窗口。")
        return
    }

    label := GetWindowLabel(hwnd)

    if !IsHidden(hwnd) {
        Flash(label " — 标题栏未被修改")
        return
    }

    s := g_States[hwnd]
    try {
        WinSetStyle(s.style, hwnd)
        WinMove(s.x, s.y, s.w, s.h, hwnd)
        g_States.Delete(hwnd)
        Flash(label " — 已恢复标题栏")
        BuildTray()
    } catch as e {
        MsgBox("恢复失败: " e.Message, "错误", "Icon!")
    }
}

RestoreAll() {
    global
    for hwnd, s in g_States.Clone() {
        try {
            WinSetStyle(s.style, hwnd)
            WinMove(s.x, s.y, s.w, s.h, hwnd)
        }
    }
    g_States.Clear()
}

; ============================== 托盘菜单 ==============================

BuildTray() {
    global
    tm := A_TrayMenu
    tm.Delete()

    count := g_States.Count
    tm.Add("已修改窗口: " count " 个", (*) => 0)
    tm.Disable("已修改窗口: " count " 个")
    tm.Add()
    tm.Add("隐藏标题栏 (" CFG_KEY_HIDE ")", (*) => HideTitleBar())
    tm.Add("恢复标题栏 (" CFG_KEY_RESTORE ")", (*) => RestoreTitleBar())
    tm.Add()
    tm.Add("开机自启: " (HasAutoStart() ? "已开启" : "未开启"), (*) => ToggleAutoStart())
    tm.Add()
    tm.Add("退出", (*) => ExitApp())
}

; ============================== 开机自启 ==============================

GetStartupLink() {
    return A_Startup "\" StrReplace(A_ScriptName, ".ahk", "") ".lnk"
}

HasAutoStart() {
    return FileExist(GetStartupLink())
}

ToggleAutoStart() {
    global
    link := GetStartupLink()
    if FileExist(link) {
        FileDelete(link)
        Flash("已关闭开机自启")
    } else {
        FileCreateShortcut(A_ScriptFullPath, link, A_ScriptDir)
        Flash("已开启开机自启")
    }
    BuildTray()
}

; ============================== 工具 ==============================

Flash(text) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -2000)
}
