# Microsoft Developer Studio Project File - Name="Window" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=Window - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Window.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Window.mak" CFG="Window - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Window - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "Window - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Unreal/Window", FAAAAAAA"
# PROP Scc_LocalPath ".."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Window - Win32 Release"

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
# ADD CPP /nologo /Zp4 /MD /W4 /WX /vd0 /GX /O2 /Ob2 /I "." /I "..\Inc" /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /D WINDOW_API=__declspec(dllexport) /D "_WINDOWS" /D "NDEBUG" /D "UNICODE" /D "_UNICODE" /D "WIN32" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 ..\..\Core\Lib\Core.lib user32.lib kernel32.lib gdi32.lib advapi32.lib comctl32.lib comdlg32.lib shell32.lib /nologo /base:"0x11000000" /subsystem:windows /dll /incremental:yes /machine:I386 /out:"..\..\System\Window.dll"

!ELSEIF  "$(CFG)" == "Window - Win32 Debug"

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
# ADD CPP /nologo /Zp4 /MDd /W4 /WX /Gm /vd0 /GX /ZI /Od /I "." /I "..\Inc" /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /D "_WINDOWS" /D WINDOW_API=__declspec(dllexport) /D "UNICODE" /D "_UNICODE" /D "_DEBUG" /D "WIN32" /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 ..\..\Core\Lib\Core.lib user32.lib kernel32.lib gdi32.lib advapi32.lib comctl32.lib comdlg32.lib shell32.lib /nologo /base:"0x11000000" /subsystem:windows /dll /debug /machine:I386 /out:"..\..\System\Window.dll" /pdbtype:sept

!ENDIF 

# Begin Target

# Name "Window - Win32 Release"
# Name "Window - Win32 Debug"
# Begin Group "Src"

# PROP Default_Filter "*.cpp;*.h"
# Begin Source File

SOURCE=.\Window.cpp
# End Source File
# Begin Source File

SOURCE=.\Res\WindowRes.h
# End Source File
# End Group
# Begin Group "Res"

# PROP Default_Filter "*.res"
# Begin Source File

SOURCE=.\Res\35FLOPPY.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\525FLOP1.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\add.cur
# End Source File
# Begin Source File

SOURCE=.\Res\AUDIO.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\CDDRIVE.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\CLIP01.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\CLIP08.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\CLSDFOLD.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\CRDFLE03.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\CRDFLE07.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\crosshai.cur
# End Source File
# Begin Source File

SOURCE=.\Res\CTRPANEL.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\DESKTOP.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\dragitem.cur
# End Source File
# Begin Source File

SOURCE=.\Res\draw.cur
# End Source File
# Begin Source File

SOURCE=.\Res\DRIVE.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\DRIVEDSC.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\DRIVENET.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\EXPLORER.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\FILES05A.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\FOLDER01.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\FOLDER02.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\FOLDER03.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\GRAPH01.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\GRAPH06.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\GRAPH07.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\hand.cur
# End Source File
# Begin Source File

SOURCE=.\Res\ico00001.ico
# End Source File
# Begin Source File

SOURCE=.\Res\ico00002.ico
# End Source File
# Begin Source File

SOURCE=.\Res\ico00003.ico
# End Source File
# Begin Source File

SOURCE=.\Res\idicon_c.ico
# End Source File
# Begin Source File

SOURCE=.\Res\idicon_f.ico
# End Source File
# Begin Source File

SOURCE=.\Res\idicon_h.ico
# End Source File
# Begin Source File

SOURCE=.\Res\idicon_p.ico
# End Source File
# Begin Source File

SOURCE=.\Res\idicon_s.ico
# End Source File
# Begin Source File

SOURCE=.\Res\idicon_t.ico
# End Source File
# Begin Source File

SOURCE=.\Res\littlear.cur
# End Source File
# Begin Source File

SOURCE=.\Res\littlepo.cur
# End Source File
# Begin Source File

SOURCE=.\Res\MYCOMP.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\NETHOOD.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\nodrop.cur
# End Source File
# Begin Source File

SOURCE=.\Res\OPENFOLD.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\PRINTFLD.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\RECYFULL.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\RULERS.ICO
# End Source File
# Begin Source File

SOURCE=.\Res\splitall.cur
# End Source File
# Begin Source File

SOURCE=.\Res\splitns.cur
# End Source File
# Begin Source File

SOURCE=.\Res\splitwe.cur
# End Source File
# Begin Source File

SOURCE=.\Res\unreal.bmp
# End Source File
# Begin Source File

SOURCE=.\Res\Unreal.ico
# End Source File
# Begin Source File

SOURCE=.\Res\WindowRes.rc
# End Source File
# Begin Source File

SOURCE=.\Res\zoomin.cur
# End Source File
# Begin Source File

SOURCE=.\Res\zoomout.cur
# End Source File
# End Group
# Begin Group "Inc"

# PROP Default_Filter "*.h"
# Begin Source File

SOURCE=..\Inc\Window.h
# End Source File
# End Group
# End Target
# End Project
