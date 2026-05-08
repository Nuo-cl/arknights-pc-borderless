; 明日方舟 无边框窗口工具
; 功能: 去除/恢复标题栏，保留任务栏
; 需要: AutoHotkey v2.0+

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

if !A_IsAdmin {
    try Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

; ============================== 配置 ==============================
; 可根据需要修改以下配置

global CFG_TITLE := "明日方舟"       ; 游戏窗口标题
global CFG_KEY_HIDE := "^F4"         ; 去标题栏快捷键 (Ctrl+F4)
global CFG_KEY_RESTORE := "^F7"      ; 恢复标题栏快捷键 (Ctrl+F7)

; ============================== 状态 ==============================
global g_OrigStyle := 0
global g_OrigX := 0
global g_OrigY := 0
global g_OrigW := 0
global g_OrigH := 0
global g_Hidden := false

; ============================== 初始化 ==============================
A_IconTip := "明日方舟 无边框窗口"

Hotkey(CFG_KEY_HIDE, (*) => HideTitleBar())
Hotkey(CFG_KEY_RESTORE, (*) => RestoreTitleBar())

BuildTray()
return

; ============================== 去标题栏 ==============================

HideTitleBar() {
    global
    hwnd := WinExist(CFG_TITLE)
    if !hwnd {
        MsgBox("未找到窗口: " CFG_TITLE "`n请先启动游戏。")
        return
    }

    if g_Hidden {
        Flash("标题栏已处于隐藏状态")
        return
    }

    ; 保存原始状态用于恢复
    g_OrigStyle := WinGetStyle(hwnd)
    WinGetPos(&g_OrigX, &g_OrigY, &g_OrigW, &g_OrigH, hwnd)

    ; 查找窗口所在显示器
    targetMon := MonitorGetPrimary()
    monCount := MonitorGetCount()
    loop monCount {
        MonitorGet(A_Index, &ml, &mt, &mr, &mb)
        if g_OrigX >= ml && g_OrigX < mr && g_OrigY >= mt && g_OrigY < mb {
            targetMon := A_Index
            break
        }
    }

    try {
        WinSetStyle(g_OrigStyle & ~0xC00000 & ~0x40000, hwnd)
        MonitorGetWorkArea(targetMon, &l, &t, &r, &b)
        WinMove(l, t, r - l, b - t, hwnd)
        g_Hidden := true
        Flash("已隐藏标题栏")
        BuildTray()
    } catch as e {
        MsgBox("操作失败: " e.Message "`n`n请确认脚本以管理员身份运行。", "错误", "Icon!")
    }
}

; ============================== 恢复标题栏 ==============================

RestoreTitleBar() {
    global
    hwnd := WinExist(CFG_TITLE)
    if !hwnd {
        MsgBox("未找到窗口: " CFG_TITLE)
        return
    }

    if !g_Hidden {
        Flash("标题栏已处于显示状态")
        return
    }

    try {
        WinSetStyle(g_OrigStyle, hwnd)
        WinMove(g_OrigX, g_OrigY, g_OrigW, g_OrigH, hwnd)
        g_Hidden := false
        Flash("已恢复标题栏")
        BuildTray()
    } catch as e {
        MsgBox("恢复失败: " e.Message, "错误", "Icon!")
    }
}

; ============================== 托盘菜单 ==============================

BuildTray() {
    global
    tm := A_TrayMenu
    tm.Delete()
    tm.Add("状态: " (g_Hidden ? "已隐藏" : "正常"), (*) => 0)
    tm.Disable("状态: " (g_Hidden ? "已隐藏" : "正常"))
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
