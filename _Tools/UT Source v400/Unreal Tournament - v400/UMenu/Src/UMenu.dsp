# Microsoft Developer Studio Project File - Name="UMenu" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=UMenu - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "UMenu.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "UMenu.mak" CFG="UMenu - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "UMenu - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "UMenu - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Unreal/UMenu/Src", EALAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "UMenu - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UMENU_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UMENU_EXPORTS" /D "UNICODE" /D "_UNICODE" /D "WIN32" /YX /FD /c
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

!ELSEIF  "$(CFG)" == "UMenu - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UMENU_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UMENU_EXPORTS" /D "_REALLY_WANT_DEBUG" /D "UNICODE" /D "_UNICODE" /D "_DEBUG" /D "WIN32" /YX /FD /GZ /c
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

# Name "UMenu - Win32 Release"
# Name "UMenu - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter "*.uc"
# Begin Source File

SOURCE=..\Classes\MeshActor.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenu.upkg
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuAudioClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuAudioScrollClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuBlueLookAndFeel.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuBotConfigBase.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuBotConfigClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuBotConfigSClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuBotmatchClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuBotmatchWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuBotSetupBase.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuBotSetupClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuBotSetupSC.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuConfigCoopGameClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuConfigIndivBotsCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuConfigIndivBotsWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuConsoleWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuCustomizeClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuCustomizeScrollClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuDialogClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuFramedWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuGameMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuGameOptionsClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuGameOptionsScrollClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuGameRulesBase.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuGameRulesCWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuGameRulesSClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuGameSettingsBase.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuGameSettingsCWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuGameSettingsSClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuGoldLookAndFeel.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuHelpClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuHelpMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuHelpTextArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuHelpWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuHUDConfigCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuHUDConfigScrollClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuInputOptionsClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuInputOptionsScrollClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuLabelControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuLoadGameClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuLoadGameScrollClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuLoadGameWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMapList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMapListBox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMapListCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMapListExclude.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMapListFrameCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMapListInclude.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMapListWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMenuBar.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMetalLookAndFeel.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuModMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuModMenuItem.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMultiplayerMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMutatorCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMutatorExclude.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMutatorFrameCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMutatorInclude.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMutatorList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMutatorListBox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuMutatorWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuNetworkClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuNetworkScrollClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuNewGameClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuNewGameWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuOptionsClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuOptionsMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuOptionsWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuPageControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuPageWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuPlayerClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuPlayerMeshClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuPlayerSetupClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuPlayerSetupScrollClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuPlayerWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuRaisedButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuRootWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuSaveGameClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuSaveGameScrollClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuSaveGameWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuScreenshotCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuScreenshotWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuServerSetupPage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuServerSetupSC.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuSlotClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuStartGameClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuStartGameWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuStartMatchClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuStartMatchScrollClient.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UMenuStatsMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuStatusBar.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuTeamGameRulesCWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuTeamGameRulesSClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuToolBar.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuToolsMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuVideoClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuVideoScrollclient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuWeaponPriorityCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuWeaponPriorityList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuWeaponPriorityListArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuWeaponPriorityListBox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuWeaponPriorityMesh.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UMenuWeaponPriorityWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UnrealConsole.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTCreditsCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTCreditsWindow.uc
# End Source File
# End Group
# End Target
# End Project
