# Microsoft Developer Studio Project File - Name="MeshEd" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=MeshEd - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "MeshEd.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "MeshEd.mak" CFG="MeshEd - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "MeshEd - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "MeshEd - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "MeshEd - Win32 Release"

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
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "../core/inc" /I "../xcore" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /Yu"stdtool.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 ../xcore/xcore_winapp.lib ../xcore/xcore.lib dinput8.lib dxguid.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winmm.lib /nologo /subsystem:windows /machine:I386

!ELSEIF  "$(CFG)" == "MeshEd - Win32 Debug"

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
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /GX /Z7 /Od /I "../core/inc" /I "../xcore" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /FR /Yu"stdtool.h" /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 ../xcore/xcore_winapp.lib ../xcore/xcore.lib dinput8.lib dxguid.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winmm.lib /nologo /subsystem:windows /map /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "MeshEd - Win32 Release"
# Name "MeshEd - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
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

SOURCE=.\meshapp.cpp
# End Source File
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

SOURCE=.\ovl_man.cpp
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
# Begin Source File

SOURCE=.\stdtool.cpp

!IF  "$(CFG)" == "MeshEd - Win32 Release"

!ELSEIF  "$(CFG)" == "MeshEd - Win32 Debug"

# ADD CPP /Yc

!ENDIF 

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
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
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

SOURCE=.\meshapp.h
# End Source File
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

SOURCE=.\ovl_man.h
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
# Begin Source File

SOURCE=.\resource.h
# End Source File
# Begin Source File

SOURCE=.\stdtool.h
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
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\cannibal.ico
# End Source File
# Begin Source File

SOURCE=.\MeshEd.rc
# End Source File
# End Group
# End Target
# End Project
