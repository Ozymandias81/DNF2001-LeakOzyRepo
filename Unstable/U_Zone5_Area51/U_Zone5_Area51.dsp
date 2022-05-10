# Microsoft Developer Studio Project File - Name="U_Zone5_Area51" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=U_Zone5_Area51 - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "U_Zone5_Area51.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "U_Zone5_Area51.mak" CFG="U_Zone5_Area51 - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "U_Zone5_Area51 - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "U_Zone5_Area51 - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "U_Zone5_Area51 - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_ZONE5_AREA51_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_ZONE5_AREA51_EXPORTS" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386

!ELSEIF  "$(CFG)" == "U_Zone5_Area51 - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_ZONE5_AREA51_EXPORTS" /YX /FD /GZ  /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_ZONE5_AREA51_EXPORTS" /YX /FD /GZ  /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "U_Zone5_Area51 - Win32 Release"
# Name "U_Zone5_Area51 - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter "uc"
# Begin Source File

SOURCE=.\Classes\Z5_agitator.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_analyzer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_c_keyboard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_c_monitor.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_c_tower.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_centrifuge.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_cornstalk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_DNA_black.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_DNA_blue.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_DNA_green.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_DNA_orange.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_DNA_red.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_DNA_yellow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_faucet_lab.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor10.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor11.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor12.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor5.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor6.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor7.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor8.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_FlyingDoor9.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_lab_agitator.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_lab_analyzer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_lab_centrifuge.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_lab_controller.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_lab_laserscan.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_lab_microscope.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_lab_scannister.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_labscrn_2ndarm.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_labscrn_base.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_labscrn_mainarm.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_labscrn_screen.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_petcage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_rollcart.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_rollcart1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_scannister.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_Snowflake.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z5_wallphone.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Zone5_Area51.uc
# End Source File
# End Group
# End Target
# End Project
