scriptDir := A_ScriptDir
iniPath := scriptDir . "\KeyboardSwitch.ini"
trayIcon := scriptDir . "\assets\icon.ico"

if (!FileExist(iniPath)) {
    MsgBox, 0x10, Error, Configuration file not found:`n%iniPath%`n`nPlease ensure KeyboardSwitch.ini exists in the same folder.
    ExitApp
}

global switchMode, layouts, shortcuts, layoutCount
global swapEscCaps, notifyOnSwitch

IniRead, switchMode, %iniPath%, Settings, SwitchMode, InDefine
IniRead, swapEscCaps, %iniPath%, Hotkey, SwapEscCapsLock, 0
IniRead, notifyOnSwitch, %iniPath%, Hotkey, NotifyOnSwitch, 1

layouts := []
shortcuts := []
layoutCount := 0

if (switchMode = "InDefine") {
    Loop {
        IniRead, layout, %iniPath%, Layouts, Layout%A_Index%
        if (layout = "ERROR") {
            break
        }
        layouts.Push(layout)
        IniRead, shortcut, %iniPath%, Shortcuts, Shortcut%A_Index%, %A_Index%
        shortcuts.Push(shortcut)
        layoutCount++
    }
    if (layoutCount = 0) {
        layouts := ["00000409", "00000804"]
        shortcuts := ["1", "2"]
        layoutCount := 2
    }
}

startupDir := A_StartMenu . "\Programs\Startup"
shortcutPath := startupDir . "\Keyboard Switch.lnk"
isStartup := FileExist(shortcutPath)

Menu, Tray, NoStandard
Menu, Tray, DeleteAll

Menu, Tray, Add, Swap ESC/CapsLock, ToggleSwapEscCaps
if (swapEscCaps) {
    Menu, Tray, Check, Swap ESC/CapsLock
}

Menu, Tray, Add, Notify on Switch, ToggleNotify
if (notifyOnSwitch) {
    Menu, Tray, Check, Notify on Switch
}

if (isStartup) {
    Menu, Tray, Add, Start with Windows, ToggleStartup
    Menu, Tray, Check, Start with Windows
} else {
    Menu, Tray, Add, Start with Windows, ToggleStartup
}

Menu, Tray, Add
Menu, Tray, Add, Mode: %switchMode%, ShowSwitchMode
Menu, Tray, Disable, Mode: %switchMode%
Menu, Tray, Add, Suspend Hotkeys, SuspendHotkeys
Menu, Tray, Add, Pause Script, PauseScript
Menu, Tray, Add, Exit, ExitScript

Gosub, UpdateTrayTip
Menu, Tray, Icon, %trayIcon%

 $*CapsLock::
    global swapEscCaps
    if (swapEscCaps) {
        Send {Blind}{Esc}
    } else {
        Gosub, SwitchLayout
    }
return

 $*Esc::
    global swapEscCaps
    if (swapEscCaps) {
        Gosub, SwitchLayout
    } else {
        Send {Blind}{Esc}
    }
return
return


ToggleSwapEscCaps:
    global swapEscCaps
    swapEscCaps := !swapEscCaps
    if (swapEscCaps) {
        Menu, Tray, Check, Swap ESC/CapsLock
    } else {
        Menu, Tray, Uncheck, Swap ESC/CapsLock
    }
    IniWrite, %swapEscCaps%, %iniPath%, Hotkey, SwapEscCapsLock
    Gosub, UpdateTrayTip
return

ToggleNotify:
    global notifyOnSwitch
    notifyOnSwitch := !notifyOnSwitch
    if (notifyOnSwitch) {
        Menu, Tray, Check, Notify on Switch
    } else {
        Menu, Tray, Uncheck, Notify on Switch
        ToolTip
    }
    IniWrite, %notifyOnSwitch%, %iniPath%, Hotkey, NotifyOnSwitch
return

ToggleStartup:
    global shortcutPath
    if (FileExist(shortcutPath)) {
        FileDelete, %shortcutPath%
        if !ErrorLevel {
            Menu, Tray, Uncheck, Start with Windows
        }
    } else {
        FileCreateShortcut, %A_ScriptFullPath%, %shortcutPath%, %A_ScriptDir%
        if !ErrorLevel {
            Menu, Tray, Check, Start with Windows
        }
    }
return

ShowSwitchMode:
return

SuspendHotkeys:
    Suspend, Toggle
    if (A_IsSuspended) {
        Menu, Tray, Check, Suspend Hotkeys
    } else {
        Menu, Tray, Uncheck, Suspend Hotkeys
    }
return

PauseScript:
    Pause, Toggle
    if (A_IsPaused) {
        Menu, Tray, Check, Pause Script
    } else {
        Menu, Tray, Uncheck, Pause Script
    }
return

ExitScript:
    ExitApp
return


UpdateTrayTip:
    global swapEscCaps, switchMode, layouts, layoutCount

    currentLayout := GetKeyboardLayout()
    tip := "Keyboard Switch"

    if (swapEscCaps) {
        tip .= "`nHotkey: ESC (CapsLock->ESC)"
    } else {
        tip .= "`nHotkey: CapsLock"
    }

    tip .= "`nMode: " . switchMode

    if (switchMode = "InDefine") {
        tip .= "`nDefined layouts:"
        for idx, layout in layouts {
            n := GetLayoutName(layout)
            if (layout = currentLayout) {
                tip .= "`n> " . n
            } else {
                tip .= "`n  " . n
            }
        }
    } else if (switchMode = "InAll") {
        installedLayouts := GetInstalledLayouts()
        tip .= "`nInstalled layouts:"
        for idx, layout in installedLayouts {
            n := GetLayoutName(layout)
            if (layout = currentLayout) {
                tip .= "`n> " . n
            } else {
                tip .= "`n  " . n
            }
        }
    }

    Menu, Tray, Tip, %tip%
return


ShowSwitchTip:
    global notifyOnSwitch
    if (!notifyOnSwitch) {
        return
    }
    Sleep, 100
    currentLayout := GetKeyboardLayout()
    name := GetLayoutName(currentLayout)

    hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    VarSetCapacity(size, 8, 0)
    DllCall("GetTextExtentPoint32", "Ptr", hDC, "Str", name, "Int", StrLen(name), "Ptr", &size)
    textW := NumGet(size, 0, "Int")
    textH := NumGet(size, 4, "Int")
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)

    WinGetPos, , , ww, wh, A
    CoordMode, ToolTip, Relative
    ToolTip, %name%, (ww - textW) // 2, (wh - textH) // 2
    SetTimer, RemoveSwitchTip, -1500
return

RemoveSwitchTip:
    ToolTip
return

UpdateTrayTipDelayed:
    Gosub, UpdateTrayTip
return


SetKeyboardLayoutShortcut(shortcut) {
    SendInput, {Alt down}{Shift down}%shortcut%{Shift up}{Alt up}
}

SwitchLayout:
    global switchMode, layouts, shortcuts, layoutCount

    currentLayout := GetKeyboardLayout()

    if (switchMode = "InDefine") {
        idx := 0
        for i, layout in layouts {
            if (layout = currentLayout) {
                idx := i
                break
            }
        }
        nextIdx := Mod(idx, layoutCount) + 1
        SetKeyboardLayoutShortcut(shortcuts[nextIdx])
    } else if (switchMode = "InAll") {
        installedLayouts := GetInstalledLayouts()
        foundIdx := 0
        for i, layout in installedLayouts {
            if (layout = currentLayout) {
                foundIdx := i
                break
            }
        }
        nextIdx := Mod(foundIdx, installedLayouts.MaxIndex()) + 1
        nextLayout := installedLayouts[nextIdx]
        SwitchToLayout(nextLayout)
    } else {
        SetKeyboardLayoutShortcut("1")
    }

    SetTimer, ShowSwitchTip, -80
    SetTimer, UpdateTrayTipDelayed, -300
return

GetKeyboardLayout() {
    hwnd := WinExist("A")
    threadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt", 0)
    langId := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")
    return Format("{:08x}", langId & 0xFFFF)
}

GetLayoutName(klid) {
    regPath := "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\" . klid
    RegRead, name, %regPath%, Layout Text
    if (ErrorLevel) {
        return klid
    }
    return name
}

GetInstalledLayouts() {
    static installedLayouts := ""
    if (installedLayouts != "") {
        return installedLayouts
    }

    VarSetCapacity(hklList, 1024, 0)
    count := DllCall("GetKeyboardLayoutList", "Int", 0, "Ptr", 0)
    VarSetCapacity(hklList, count * A_PtrSize, 0)
    DllCall("GetKeyboardLayoutList", "Int", count, "Ptr", &hklList)

    installedLayouts := []
    Loop, %count% {
        hkl := NumGet(hklList, (A_Index - 1) * A_PtrSize, "Ptr")
        klid := Format("{:08x}", hkl & 0xFFFF)
        installedLayouts.Push(klid)
    }
    return installedLayouts
}

SwitchToLayout(targetKlid) {
    static WM_INPUTLANGCHANGEREQUEST := 0x0050
    hwnd := WinExist("A")
    targetKlidNum := "0x" . targetKlid
    PostMessage, WM_INPUTLANGCHANGEREQUEST, 0, %targetKlidNum%, , ahk_id %hwnd%
}
