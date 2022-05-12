# Microsoft Developer Studio Project File - Name="Editor" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=Editor - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Editor.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Editor.mak" CFG="Editor - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Editor - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "Editor - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Unreal/Editor", BBAAAAAA"
# PROP Scc_LocalPath ".."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Editor - Win32 Release"

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
# ADD CPP /nologo /Zp4 /MD /W4 /WX /vd0 /GX /O2 /Ob2 /I "." /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /I "..\..\Window\Inc" /I "..\Inc" /D EDITOR_API=__declspec(dllexport) /D "_WINDOWS" /D "NDEBUG" /D "UNICODE" /D "_UNICODE" /D "WIN32" /Yu"EditorPrivate.h" /FD /Zm256 /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 ..\..\Core\Lib\Core.lib ..\..\Engine\Lib\Engine.lib user32.lib oleaut32.lib advapi32.lib shell32.lib gdi32.lib /nologo /base:"0x10200000" /subsystem:windows /dll /incremental:yes /machine:I386 /out:"..\..\System\Editor.dll"
# SUBTRACT LINK32 /profile

!ELSEIF  "$(CFG)" == "Editor - Win32 Debug"

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
# ADD CPP /nologo /Zp4 /MDd /W4 /WX /vd0 /GX /ZI /Od /I "." /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /I "..\..\Window\Inc" /I "..\Inc" /D "_WINDOWS" /D EDITOR_API=__declspec(dllexport) /D "UNICODE" /D "_UNICODE" /D "_DEBUG" /D "WIN32" /Yu"EditorPrivate.h" /FD /D /Zm256 /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 ..\..\Core\Lib\Core.lib ..\..\Engine\Lib\Engine.lib user32.lib oleaut32.lib advapi32.lib shell32.lib gdi32.lib /nologo /base:"0x10200000" /subsystem:windows /dll /debug /machine:I386 /out:"..\..\System\Editor.dll" /pdbtype:sept

!ENDIF 

# Begin Target

# Name "Editor - Win32 Release"
# Name "Editor - Win32 Debug"
# Begin Group "Src"

# PROP Default_Filter "*.cpp"
# Begin Source File

SOURCE=.\CoolBsp.cpp
# End Source File
# Begin Source File

SOURCE=.\EdHook.cpp
# SUBTRACT CPP /YX /Yc /Yu
# End Source File
# Begin Source File

SOURCE=.\Editor.cpp
# ADD CPP /Yc"EditorPrivate.h"
# End Source File
# Begin Source File

SOURCE=.\EditorPrivate.h
# End Source File
# Begin Source File

SOURCE=.\TTFontImport.cpp
# End Source File
# Begin Source File

SOURCE=.\UBatchExportCommandlet.cpp
# End Source File
# Begin Source File

SOURCE=.\UBrushBuilder.cpp
# End Source File
# Begin Source File

SOURCE=.\UConformCommandlet.cpp
# End Source File
# Begin Source File

SOURCE=.\UMakeCommandlet.cpp
# End Source File
# Begin Source File

SOURCE=.\UMasterCommandlet.cpp
# End Source File
# Begin Source File

SOURCE=.\UMergeDXTCommandlet.cpp
# End Source File
# Begin Source File

SOURCE=.\UnBsp.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEdAct.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEdCam.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEdClick.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEdCnst.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEdCsg.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEdExp.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEdFact.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEditor.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEdRend.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEdSrv.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEdTran.cpp
# End Source File
# Begin Source File

SOURCE=.\UnEdTran.h
# End Source File
# Begin Source File

SOURCE=.\UnMeshEd.cpp
# End Source File
# Begin Source File

SOURCE=.\UnMeshLP.cpp
# End Source File
# Begin Source File

SOURCE=.\UnParams.cpp
# End Source File
# Begin Source File

SOURCE=.\UnScrCom.cpp
# End Source File
# Begin Source File

SOURCE=.\UnScrCom.h
# End Source File
# Begin Source File

SOURCE=.\UnShadow.cpp
# End Source File
# Begin Source File

SOURCE=.\UnSyntax.cpp
# End Source File
# Begin Source File

SOURCE=.\UnTopics.cpp
# End Source File
# Begin Source File

SOURCE=.\UnTopics.h
# End Source File
# Begin Source File

SOURCE=.\UnVisi.cpp
# End Source File
# End Group
# Begin Group "Classes"

# PROP Default_Filter "*.uc"
# Begin Source File

SOURCE=..\Classes\BrushBuilder.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ConeBuilder.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\CubeBuilder.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\CylinderBuilder.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Editor.upkg
# End Source File
# Begin Source File

SOURCE=..\Classes\EditorEngine.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SheetBuilder.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TetrahedronBuilder.uc
# End Source File
# End Group
# Begin Group "Inc"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\Inc\Editor.h
# End Source File
# Begin Source File

SOURCE=..\Inc\EditorClasses.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UBrushBuilder.h
# End Source File
# End Group
# Begin Group "Int"

# PROP Default_Filter "*.int"
# Begin Source File

SOURCE=..\..\System\Editor.int
# End Source File
# End Group
# End Target
# End Project
