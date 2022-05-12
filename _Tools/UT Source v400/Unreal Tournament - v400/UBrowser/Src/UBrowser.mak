all:    chdir UBrowser.u

chdir:
	cd ..\..\System

UBrowser.u:     Unreal.exe ..\UBrowser\Classes\*.uc ..\UBrowser\Textures\*.*
	del UBrowser.u
	-unreal -make
	type editor.log

Unreal.exe:
	@echo Skipping make as Unreal.exe doesn't exist yet.
	exit