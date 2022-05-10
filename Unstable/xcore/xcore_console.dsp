# Microsoft Developer Studio Project File - Name="xcore_console" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=xcore_console - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "xcore_console.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "xcore_console.mak" CFG="xcore_console - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "xcore_console - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE "xcore_console - Win32 Debug" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "xcore_console - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Cmd_Line "NMAKE /f xcore_console.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "xcore_console.exe"
# PROP BASE Bsc_Name "xcore_console.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "obj"
# PROP Intermediate_Dir "obj"
# PROP Cmd_Line "nmake "debug=0" /f "makefile""
# PROP Rebuild_Opt "/a"
# PROP Target_File "xcore_console.lib"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "$(CFG)" == "xcore_console - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "xcore_console___Win32_Debug"
# PROP BASE Intermediate_Dir "xcore_console___Win32_Debug"
# PROP BASE Cmd_Line "NMAKE /f xcore_console.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "xcore_console.exe"
# PROP BASE Bsc_Name "xcore_console.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "obj"
# PROP Intermediate_Dir "obj"
# PROP Cmd_Line "nmake "debug=1" /f "makefile""
# PROP Rebuild_Opt "/a"
# PROP Target_File "xcore_console.lib"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ENDIF 

# Begin Target

# Name "xcore_console - Win32 Release"
# Name "xcore_console - Win32 Debug"

!IF  "$(CFG)" == "xcore_console - Win32 Release"

!ELSEIF  "$(CFG)" == "xcore_console - Win32 Debug"

!ENDIF 

# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\conapp.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\conapp.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
