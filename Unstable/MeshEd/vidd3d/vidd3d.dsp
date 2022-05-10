# Microsoft Developer Studio Project File - Name="vidd3d" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=vidd3d - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "vidd3d.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "vidd3d.mak" CFG="vidd3d - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "vidd3d - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE "vidd3d - Win32 Debug" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "vidd3d - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Cmd_Line "NMAKE /f vidd3d.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "vidd3d.exe"
# PROP BASE Bsc_Name "vidd3d.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "obj"
# PROP Intermediate_Dir "obj"
# PROP Cmd_Line "nmake "debug=" /f "makefile""
# PROP Rebuild_Opt "/a"
# PROP Target_File "vidd3d.dll"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "$(CFG)" == "vidd3d - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "vidd3d___Win32_Debug"
# PROP BASE Intermediate_Dir "vidd3d___Win32_Debug"
# PROP BASE Cmd_Line "NMAKE /f vidd3d.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "vidd3d.exe"
# PROP BASE Bsc_Name "vidd3d.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "obj"
# PROP Intermediate_Dir "obj"
# PROP Cmd_Line "nmake "debug=1" /f "makefile""
# PROP Rebuild_Opt "/a"
# PROP Target_File "vidd3d.dll"
# PROP Bsc_Name "obj\vidd3d.bsc"
# PROP Target_Dir ""

!ENDIF 

# Begin Target

# Name "vidd3d - Win32 Release"
# Name "vidd3d - Win32 Debug"

!IF  "$(CFG)" == "vidd3d - Win32 Release"

!ELSEIF  "$(CFG)" == "vidd3d - Win32 Debug"

!ENDIF 

# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\dev.cpp
# End Source File
# Begin Source File

SOURCE=.\font.cpp
# End Source File
# Begin Source File

SOURCE=.\main.cpp
# End Source File
# Begin Source File

SOURCE=.\stdd3d.cpp
# End Source File
# Begin Source File

SOURCE=.\tex.cpp
# End Source File
# Begin Source File

SOURCE=.\vbuffer.cpp
# End Source File
# Begin Source File

SOURCE=.\vidif.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=D:\dx8sdk\include\d3d8.h
# End Source File
# Begin Source File

SOURCE=.\stdd3d.h
# End Source File
# Begin Source File

SOURCE=..\vid_main.h
# End Source File
# Begin Source File

SOURCE=.\vidd3d.h
# End Source File
# Begin Source File

SOURCE=..\..\ximage\ximage.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# Begin Source File

SOURCE=.\makefile
# End Source File
# Begin Source File

SOURCE=.\vidd3d.def
# End Source File
# End Target
# End Project
