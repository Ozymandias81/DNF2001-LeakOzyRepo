# Microsoft Developer Studio Project File - Name="xcore" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=xcore - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "xcore.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "xcore.mak" CFG="xcore - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "xcore - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE "xcore - Win32 Debug" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "xcore - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "xcore___Win32_Release"
# PROP BASE Intermediate_Dir "xcore___Win32_Release"
# PROP BASE Cmd_Line "NMAKE /f xcore.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "xcore.exe"
# PROP BASE Bsc_Name "xcore.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "obj"
# PROP Intermediate_Dir "obj"
# PROP Cmd_Line "nmake "debug=" /f "makefile""
# PROP Rebuild_Opt "/a"
# PROP Target_File "xcore.dll"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "$(CFG)" == "xcore - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "xcore___Win32_Debug"
# PROP BASE Intermediate_Dir "xcore___Win32_Debug"
# PROP BASE Cmd_Line "NMAKE /f xcore.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "xcore.exe"
# PROP BASE Bsc_Name "xcore.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "obj"
# PROP Intermediate_Dir "obj"
# PROP Cmd_Line "nmake "debug=1" /f "makefile""
# PROP Rebuild_Opt "/a"
# PROP Target_File "xcore.dll"
# PROP Bsc_Name "xcore.bsc"
# PROP Target_Dir ""

!ENDIF 

# Begin Target

# Name "xcore - Win32 Release"
# Name "xcore - Win32 Debug"

!IF  "$(CFG)" == "xcore - Win32 Release"

!ELSEIF  "$(CFG)" == "xcore - Win32 Debug"

!ENDIF 

# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\dll.cpp
# End Source File
# Begin Source File

SOURCE=.\error.cpp
# End Source File
# Begin Source File

SOURCE=.\file.cpp
# End Source File
# Begin Source File

SOURCE=.\find.cpp
# End Source File
# Begin Source File

SOURCE=.\gendata.cpp
# End Source File
# Begin Source File

SOURCE=.\genmem.cpp
# End Source File
# Begin Source File

SOURCE=.\global.cpp
# End Source File
# Begin Source File

SOURCE=.\ipc.cpp
# End Source File
# Begin Source File

SOURCE=.\list.cpp
# End Source File
# Begin Source File

SOURCE=.\malloc.asm
# End Source File
# Begin Source File

SOURCE=.\printf.cpp
# End Source File
# Begin Source File

SOURCE=.\stat.cpp
# End Source File
# Begin Source File

SOURCE=.\stdcore.cpp
# End Source File
# Begin Source File

SOURCE=.\stream.cpp
# End Source File
# Begin Source File

SOURCE=.\string.cpp
# End Source File
# Begin Source File

SOURCE=.\stuff.asm
# End Source File
# Begin Source File

SOURCE=.\win.cpp
# End Source File
# Begin Source File

SOURCE=.\winalloc.cpp
# End Source File
# Begin Source File

SOURCE=.\winfile.cpp
# End Source File
# Begin Source File

SOURCE=.\winmem.cpp
# End Source File
# Begin Source File

SOURCE=.\xmisc.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\filex.h
# End Source File
# Begin Source File

SOURCE=.\winalloc.h
# End Source File
# Begin Source File

SOURCE=.\xclass.h
# End Source File
# Begin Source File

SOURCE=.\xcore.h
# End Source File
# Begin Source File

SOURCE=.\xipc.h
# End Source File
# Begin Source File

SOURCE=.\xstream.h
# End Source File
# Begin Source File

SOURCE=.\xstring.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# Begin Source File

SOURCE=.\makefile
# End Source File
# Begin Source File

SOURCE=.\xcore.def
# End Source File
# End Target
# End Project
