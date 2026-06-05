<div align="center">
  <img src="assets/icon.png" alt="icon" width="32" />
</div>

# Keyboard Switch

Switch between keyboard layouts. Inspired by https://github.com/xmdn/2_of_3_lang_switch_hotkey.

Authors: GLM-5🧙‍♂️, scillidan🤡

The icon is from [SimpleKeys](https://beamedeighth.itch.io/simplekeys-animated-pixel-keyboard-keys) by [beamedeighth](https://beamedeighth.itch.io/).

## Switch Modes

- **InDefine** (default): Switch between layouts defined in `KeyboardSwitch.ini`. Supports 2+ layouts.
- **InAll**: Cycle through all installed keyboard layouts automatically using Windows API.

## Usage

1. Edit `KeyboardSwitch.ini`:
   - Set `SwitchMode` to `InAll` or `InDefine`
   - For `InDefine`, add your layouts (Layout1, Layout2, Layout3, etc.)
   - Set `SwitchHotkey` if you want a different key (default: CapsLock)
2. For `InDefine` mode:
   1. Windows 10 → Advanced keyboard settings → Input language hot keys → Advanced key settings
   2. Set `Alt+Shift+1` for Layout1, `Alt+Shift+2` for Layout2, etc.
3. `autohotkeyu64.exe KeyboardSwitch.ahk`
4. Press the hotkey to switch keyboard

## Note

The hotkey may not work in some cases: taskbar, desktop, lock screen, UAC prompt, admin apps (run script as admin to fix), or some full-screen apps.
