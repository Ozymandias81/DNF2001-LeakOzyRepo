# Microsoft Developer Studio Project File - Name="CannibalEditor" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=CannibalEditor - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "CannibalEditor.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "CannibalEditor.mak" CFG="CannibalEditor - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "CannibalEditor - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "CannibalEditor - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Duke4_UT400/CannibalEditor", KJPAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "CannibalEditor - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "../core/inc" /I "../xcore" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "CANNIBAL_TOOL" /D "XCORE_PURE" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 msvcrt.lib ../xcore/xcore.lib dinput8.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib dxguid.lib comctl32.lib winmm.lib /nologo /subsystem:windows /pdb:"..\System\CannibalEd.pdb" /map /machine:I386 /nodefaultlib /out:"..\System\CannibalEd.exe"
# SUBTRACT LINK32 /pdb:none /debug
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=copy ..\system\xcore.dll .	copy ..\system\cannibaled.exe .
# End Special Build Tool

!ELSEIF  "$(CFG)" == "CannibalEditor - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /ZI /Od /I "../core/inc" /I "../xcore" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "CANNIBAL_TOOL" /D "XCORE_PURE" /FR /FD /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 msvcrt.lib ../xcore/xcore.lib dinput8.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib dxguid.lib comctl32.lib winmm.lib /nologo /subsystem:windows /pdb:"..\System\CannibalEd.pdb" /map /debug /machine:I386 /nodefaultlib /out:"..\System\CannibalEd.exe" /pdbtype:sept
# SUBTRACT LINK32 /profile /pdb:none
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=copy ..\system\xcore.dll .
# End Special Build Tool

!ENDIF 

# Begin Target

# Name "CannibalEditor - Win32 Release"
# Name "CannibalEditor - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "*.c;*.cpp"
# Begin Group "System"

# PROP Default_Filter "*.c;*.cpp"
# Begin Source File

SOURCE=.\cam_man.cpp
# End Source File
# Begin Source File

SOURCE=.\con_man.cpp
# End Source File
# Begin Source File

SOURCE=.\file_imp.cpp
# End Source File
# Begin Source File

SOURCE=.\in_main.cpp
# End Source File
# Begin Source File

SOURCE=.\in_win.cpp
# End Source File
# Begin Source File

SOURCE=.\math_vec.cpp
# End Source File
# Begin Source File

SOURCE=.\mdx_man.cpp
# End Source File
# Begin Source File

SOURCE=.\ovl_man.cpp
# End Source File
# Begin Source File

SOURCE=.\sys_main.cpp
# End Source File
# Begin Source File

SOURCE=.\sys_win.cpp
# End Source File
# Begin Source File

SOURCE=.\vcr_man.cpp
# End Source File
# Begin Source File

SOURCE=.\vid_main.cpp
# End Source File
# End Group
# Begin Group "Overlays"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\ovl_cc.cpp
# End Source File
# Begin Source File

SOURCE=.\ovl_defs.cpp
# End Source File
# Begin Source File

SOURCE=.\ovl_frm.cpp
# End Source File
# Begin Source File

SOURCE=.\ovl_mdl.cpp
# End Source File
# Begin Source File

SOURCE=.\ovl_seq.cpp
# End Source File
# Begin Source File

SOURCE=.\ovl_skin.cpp
# End Source File
# Begin Source File

SOURCE=.\ovl_work.cpp
# End Source File
# End Group
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "*.h"
# Begin Group "System Headers"

# PROP Default_Filter "*.h"
# Begin Source File

SOURCE=.\cam_man.h
# End Source File
# Begin Source File

SOURCE=.\cbl_defs.h
# End Source File
# Begin Source File

SOURCE=.\con_man.h
# End Source File
# Begin Source File

SOURCE=.\file_imp.h
# End Source File
# Begin Source File

SOURCE=.\in_main.h
# End Source File
# Begin Source File

SOURCE=.\in_win.h
# End Source File
# Begin Source File

SOURCE=.\math_vec.h
# End Source File
# Begin Source File

SOURCE=.\mdx_man.h
# End Source File
# Begin Source File

SOURCE=.\ovl_man.h
# End Source File
# Begin Source File

SOURCE=.\resource.h
# End Source File
# Begin Source File

SOURCE=.\sys_main.h
# End Source File
# Begin Source File

SOURCE=.\sys_win.h
# End Source File
# Begin Source File

SOURCE=.\vcr_man.h
# End Source File
# Begin Source File

SOURCE=.\vid_main.h
# End Source File
# End Group
# Begin Group "Overlay Headers"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\ovl_cc.h
# End Source File
# Begin Source File

SOURCE=.\ovl_defs.h
# End Source File
# Begin Source File

SOURCE=.\ovl_frm.h
# End Source File
# Begin Source File

SOURCE=.\ovl_mdl.h
# End Source File
# Begin Source File

SOURCE=.\ovl_seq.h
# End Source File
# Begin Source File

SOURCE=.\ovl_skin.h
# End Source File
# Begin Source File

SOURCE=.\ovl_work.h
# End Source File
# End Group
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "*.rc;*.ico"
# Begin Source File

SOURCE=.\cannibal.ico
# End Source File
# Begin Source File

SOURCE=.\CannibalEditor.rc
# End Source File
# End Group
# End Target
# End Project
