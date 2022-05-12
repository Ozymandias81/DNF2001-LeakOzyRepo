# Microsoft Developer Studio Project File - Name="Fire" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=Fire - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Fire.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Fire.mak" CFG="Fire - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Fire - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "Fire - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Unreal/Fire", IAAAAAAA"
# PROP Scc_LocalPath ".."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Fire - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "..\Lib"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /Zp4 /MD /W4 /WX /vd0 /GX /O2 /Ob2 /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /I "..\Inc" /D "_WINDOWS" /D "NDEBUG" /D "UNICODE" /D "_UNICODE" /D "WIN32" /YX /FD /Zm256 /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 ..\..\Core\Lib\Core.lib ..\..\Engine\Lib\Engine.lib /nologo /base:"0x10500000" /subsystem:windows /dll /machine:I386 /out:"..\..\System\Fire.dll"
# SUBTRACT LINK32 /incremental:yes

!ELSEIF  "$(CFG)" == "Fire - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "..\Lib"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /Zp4 /MDd /W4 /WX /vd0 /GX /ZI /Od /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /I "..\Inc" /D "_WINDOWS" /D "UNICODE" /D "_UNICODE" /D "_DEBUG" /D "WIN32" /YX /FD /D /Zm256 /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 ..\..\Core\Lib\Core.lib ..\..\Engine\Lib\Engine.lib /nologo /base:"0x10500000" /subsystem:windows /dll /debug /machine:I386 /out:"..\..\System\Fire.dll" /pdbtype:sept

!ENDIF 

# Begin Target

# Name "Fire - Win32 Release"
# Name "Fire - Win32 Debug"
# Begin Group "Src"

# PROP Default_Filter "*.cpp;*.asm"
# Begin Source File

SOURCE=.\FractalPrivate.h
# End Source File
# Begin Source File

SOURCE=.\UnFire.asm

!IF  "$(CFG)" == "Fire - Win32 Release"

# Begin Custom Build
IntDir=.\Release
InputPath=.\UnFire.asm

"$(IntDir)\UnFire.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\UnFire.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "Fire - Win32 Debug"

# Begin Custom Build
IntDir=.\Debug
InputPath=.\UnFire.asm

"$(IntDir)\UnFire.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\UnFire.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\UnFireP2.asm

!IF  "$(CFG)" == "Fire - Win32 Release"

# Begin Custom Build
IntDir=.\Release
InputPath=.\UnFireP2.asm

"$(IntDir)\UnFireP2.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\UnFireP2.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "Fire - Win32 Debug"

# Begin Custom Build
IntDir=.\Debug
InputPath=.\UnFireP2.asm

"$(IntDir)\UnFireP2.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\UnFireP2.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\UnFractal.cpp

!IF  "$(CFG)" == "Fire - Win32 Release"

# ADD CPP /FAcs

!ELSEIF  "$(CFG)" == "Fire - Win32 Debug"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\UnWater.asm

!IF  "$(CFG)" == "Fire - Win32 Release"

# Begin Custom Build
IntDir=.\Release
InputPath=.\UnWater.asm

"$(IntDir)\UnWater.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\UnWater.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "Fire - Win32 Debug"

# Begin Custom Build
IntDir=.\Debug
InputPath=.\UnWater.asm

"$(IntDir)\UnWater.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\UnWater.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# End Group
# Begin Group "Classes"

# PROP Default_Filter "*.uc"
# Begin Source File

SOURCE=..\Classes\Fire.upkg
# End Source File
# Begin Source File

SOURCE=..\Classes\FireTexture.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FractalTexture.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\IceTexture.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\WaterTexture.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\WaveTexture.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\WetTexture.uc
# End Source File
# End Group
# End Target
# End Project
