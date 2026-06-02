set shell := ["pwsh", "-NoLogo", "-Command"]

dist:
	Ahk2Exe /in "KeyboardSwitch.ahk" /icon "assets/icon.ico" /out "KeyboardSwitch.exe"

check:
	autohotkeyu64 tests/CheckLayout.ahk

clean:
	rm KeyboardSwitch.exe