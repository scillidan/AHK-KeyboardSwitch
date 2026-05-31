scriptDir := A_ScriptDir
iniPath := scriptDir . "\KeyboardSwitch.ini"
trayIcon := scriptDir . "\assets\icon.ico"

if (!FileExist(iniPath)) {
    MsgBox, 0x10, Error, Configuration file not found:`n%iniPath%`n`nPlease ensure KeyboardSwitch.ini exists in the same folder.
    ExitApp
}

IniRead, layout1, %iniPath%, Layouts, Layout1, 00000409
IniRead, layout2, %iniPath%, Layouts, Layout2, 00000804
IniRead, switchKey, %iniPath%, Hotkey, SwitchKey, CapsLock
IniRead, shortcut1, %iniPath%, Shortcuts, Shortcut1, 0
IniRead, shortcut2, %iniPath%, Shortcuts, Shortcut2, 1

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

Menu, Tray, Add, Suspend Hotkeys, SuspendHotkeys
Menu, Tray, Add, Pause Script, PauseScript
Menu, Tray, Add, Exit, ExitScript
Menu, Tray, Tip, Keyboard Switch`nHotkey: %switchKey%
Menu, Tray, Icon, %trayIcon%

Hotkey, %switchKey%, SwitchLayout
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
return

GetKeyboardLayout() {
	hwnd := WinExist("A")
	threadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt", 0)
	langId := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")
	return Format("{:08x}", langId & 0xFFFF)
}
