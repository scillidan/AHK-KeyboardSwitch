#Persistent
SetTimer, ShowLayout, 500
return

ShowLayout:
    hwnd := WinExist("A")
    threadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt", 0)
    langId := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")
    fullId := Format("0x{:08x}", langId)
    shortId := Format("0x{:04x}", langId & 0xFFFF)
    ToolTip, Full: %fullId%`nShort: %shortId%
return
