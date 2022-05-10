# Microsoft Developer Studio Project File - Name="dnMaterial" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=dnMaterial - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "dnMaterial.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "dnMaterial.mak" CFG="dnMaterial - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "dnMaterial - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "dnMaterial - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "dnMaterial - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNMATERIAL_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNMATERIAL_EXPORTS" /YX /FD /c
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

!ELSEIF  "$(CFG)" == "dnMaterial - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNMATERIAL_EXPORTS" /YX /FD /GZ  /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNMATERIAL_EXPORTS" /YX /FD /GZ  /c
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

# Name "dnMaterial - Win32 Release"
# Name "dnMaterial - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\Classes\Airvents.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\AnnouncerMaterial.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BBall_Court.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Cardboard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Carpet.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Cement_Clean.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Cement_Gritty.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ConveyorBelt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ConveyorNegX.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ConveyorNegY.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ConveyorPosX.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ConveyorPosY.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Dirt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Fabric.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Forcefields.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Generic_Floor.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Generic_Wall.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Glass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Grass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Gravel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Ice.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Ladder_Metal1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Ladder_Metal2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Ladder_Rope.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Ladder_Wood1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Ladder_Wood2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Ladder_Wood3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Leaves.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\lights.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Metal_1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Metal_2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Mud_Squishy.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Pipe_Oil.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Pipe_Steam.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Pipe_Water.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Popcorn.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Rocks.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SlotMachineRotor.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Snow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SteamPipe.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Water_kneedeep.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Water_Puddles.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Wood_Hard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Wood_Parquet.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Wood_Soft.uc
# End Source File
# End Group
# End Target
# End Project
