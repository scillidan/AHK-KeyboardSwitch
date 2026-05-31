set shell := ["pwsh", "-NoLogo", "-Command"]

dist:
	Ahk2Exe /in "KeyboardSwitch.ahk" /icon "assets/icon.ico" /out "KeyboardSwitch.exe"

clean:
	rm KeyboardSwitch.exe