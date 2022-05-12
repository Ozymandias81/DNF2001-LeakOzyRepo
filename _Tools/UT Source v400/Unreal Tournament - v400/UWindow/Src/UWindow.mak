all:    chdir UWindow.u

chdir:
	cd ..\..\System

UWindow.u:     Unreal.exe ..\UWindow\Classes\*.uc ..\UWindow\Textures\*.*
	del UWindow.u
	-unreal -make
	type editor.log

Unreal.exe:
	@echo Skipping make as Unreal.exe doesn't exist yet.
	exit