scriptDir := A_ScriptDir
iniPath := scriptDir . "\KeyboardSwitch.ini"
trayIcon := scriptDir . "\assets\icon.ico"

if (!FileExist(iniPath)) {
    MsgBox, 0x10, Error, Configuration file not found:`n%iniPath%`n`nPlease ensure KeyboardSwitch.ini exists in the same folder.
    ExitApp
}

IniRead, layout1, %iniPath%, Layouts, Layout1, 00000409
IniRead, layout2, %iniPath%, Layouts, Layout2, 00000804
IniRead, swapEscCaps, %iniPath%, Hotkey, SwapEscCapsLock, 0
IniRead, notifyOnSwitch, %iniPath%, Hotkey, NotifyOnSwitch, 1
IniRead, shortcut1, %iniPath%, Shortcuts, Shortcut1, 1
IniRead, shortcut2, %iniPath%, Shortcuts, Shortcut2, 2

startupDir := A_StartMenu . "\Programs\Startup"
shortcutPath := startupDir . "\Keyboard Switch.lnk"
isStartup := FileExist(shortcutPath)

Menu, Tray, NoStandard
Menu, Tray, DeleteAll

if (isStartup) {
    Menu, Tray, Add, Start with Windows, ToggleStartup
    Menu, Tray, Check, Start with Windows
} else {
    Menu, Tray, Add, Start with Windows, ToggleStartup
}

Menu, Tray, Add, Swap ESC/CapsLock, ToggleSwapEscCaps
if (swapEscCaps) {
    Menu, Tray, Check, Swap ESC/CapsLock
}

Menu, Tray, Add, Notify on Switch, ToggleNotify
if (notifyOnSwitch) {
    Menu, Tray, Check, Notify on Switch
}

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
    global swapEscCaps, layout1, layout2
    name1 := GetLayoutName(layout1)
    name2 := GetLayoutName(layout2)
    currentLayout := GetKeyboardLayout()

    if (swapEscCaps) {
        tip := "Keyboard Switch`nHotkey: ESC (CapsLock->ESC)"
    } else {
        tip := "Keyboard Switch`nHotkey: CapsLock"
    }

    if (currentLayout = layout1) {
        tip .= "`n> " . name1 . "`n  " . name2
    } else if (currentLayout = layout2) {
        tip .= "`n  " . name1 . "`n> " . name2
    } else {
        tip .= "`n  " . name1 . "`n  " . name2
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
    global shortcut1, shortcut2
    SendInput, {Alt down}{Shift down}%shortcut%{Shift up}{Alt up}
}

SwitchLayout:
    global layout1, layout2, shortcut1, shortcut2
    currentLayout := GetKeyboardLayout()

    if (currentLayout = layout1) {
        SetKeyboardLayoutShortcut(shortcut2)
    } else if (currentLayout = layout2) {
        SetKeyboardLayoutShortcut(shortcut1)
    } else {
        SetKeyboardLayoutShortcut(shortcut1)
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