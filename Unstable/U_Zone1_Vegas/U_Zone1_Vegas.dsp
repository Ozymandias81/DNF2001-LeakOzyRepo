# Microsoft Developer Studio Project File - Name="U_Zone1_Vegas" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=U_Zone1_Vegas - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "U_Zone1_Vegas.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "U_Zone1_Vegas.mak" CFG="U_Zone1_Vegas - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "U_Zone1_Vegas - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "U_Zone1_Vegas - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "U_Zone1_Vegas - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_ZONE1_VEGAS_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_ZONE1_VEGAS_EXPORTS" /YX /FD /c
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

!ELSEIF  "$(CFG)" == "U_Zone1_Vegas - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_ZONE1_VEGAS_EXPORTS" /YX /FD /GZ  /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_ZONE1_VEGAS_EXPORTS" /YX /FD /GZ  /c
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

# Name "U_Zone1_Vegas - Win32 Release"
# Name "U_Zone1_Vegas - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter "uc"
# Begin Source File

SOURCE=.\Classes\CoinCup_Z1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnHRocketStreetMap.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_AquariumSeaweed.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_AquariumSharkTooth.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_BeachBall.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_BilliardBridge.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_BilliardCueRack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_CasinoStool.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Chair1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Chair2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Chandalier1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_ClockGrandfather.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_ClockGrandfatherHourHand.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_ClockGrandfatherMinHand.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_CoinCup.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Curtain_Still.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_DiscoBall.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_DukC_Bandolier.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_DukC_Boot1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_DukC_Coatrack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_DukC_Hat.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_DukC_SunGrack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Hanginglight.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_HotelChair.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_HotelRack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_HotelTable1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_HotelTable2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_HotelTable3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_HumidorHygrometer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_LampFloor1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_LampFloorPenthouse.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_LampHanging.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_LampShade2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_LampTable.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_LampWall1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_LampWall2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_LampWoman.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_LKSignBase1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_MountCrawler.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_MountFishHead.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_MountPigCop.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_MountTrex.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Palmtree.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_PoolToy1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Ps_Anchor.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Ps_Cannon.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Ps_CannonBall.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Ps_CannonBarrel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Ps_Ramrod.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_ps_Sail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Sharktooth.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Shower_Head.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Shower_Knob.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Shower_Soap.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_SignValet.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_SinkBathroom.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Slotarm.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_SlotWheel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_StatueFountainWoman.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_StatueGriffon1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_StatueMermaid1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_StatueStuffedBoss.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_StratosfearBall.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_StratosfearFlag.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_StuffedBossEye.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_TennisShooter.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_ToiletHeadBase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_ToiletHeadLid.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Trophy1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_TunaCut.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_TunaFrozen.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Vines.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Weights1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Weights2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Z1_Weights3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Zone1_Vegas.uc
# End Source File
# End Group
# End Target
# End Project
