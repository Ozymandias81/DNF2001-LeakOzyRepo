# Microsoft Developer Studio Project File - Name="UTMenu" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=UTMenu - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "UTMenu.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "UTMenu.mak" CFG="UTMenu - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "UTMenu - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "UTMenu - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Unreal/UTMenu/Src", GXLAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "UTMenu - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UTMENU_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UTMENU_EXPORTS" /D "UNICODE" /D "_UNICODE" /D "WIN32" /YX /FD /c
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

!ELSEIF  "$(CFG)" == "UTMenu - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UTMENU_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UTMENU_EXPORTS" /D "UNICODE" /D "_UNICODE" /D "_DEBUG" /D "WIN32" /YX /FD /GZ /c
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

# Name "UTMenu - Win32 Release"
# Name "UTMenu - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter "*.uc"
# Begin Source File

SOURCE=..\Classes\DemoStoryWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DoorArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\EnemyBrowser.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FreeSlotsClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FreeSlotsWindow.uc
# End Source File
# Begin Source File

SOURCE=..\classes\InGameObjectives.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\KillGameQueryClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\KillGameQueryWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\LadderButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ManagerWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ManagerWindowStub.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MatchButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MeshBrowser.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MessageWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\NameEditBox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\NewCharacterWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\NewGameInterimObject.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ngStatsButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ngWorldSecretClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ngWorldSecretWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\NotifyButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\NotifyWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ObjectiveBrowser.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\OrdersChildWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PhysicalChildWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SlotWindow.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpeechBinderCW.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpeechBinderSC.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpeechBinderWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SpeechButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SpeechChildWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SpeechMiniDisplay.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SpeechWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\StaticArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TargetChildWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TeamBrowser.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTAssaultRulesCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTAssaultRulesSC.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTAudioClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTBotConfigClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTBotConfigSClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTBotmatchWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTChallengeHUDConfig.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTConfigIndivBotsCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTConfigIndivBotsWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTConsole.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTCustomizeClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTFadeTextArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTGameMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTIndivBotSetupClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTIndivBotSetupSC.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTInputOptionsCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTLadder.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTLadderAS.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTLadderChal.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTLadderCTF.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTLadderDM.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTLadderDOM.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTLadderStub.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTLMSRulesCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTLMSRulesSC.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTMenu.upkg
# End Source File
# Begin Source File

SOURCE=..\Classes\UTMenuBotmatchCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTMenuStartMatchCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTMenuStartMatchSC.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTMultiplayerMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTOptionsMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTPasswordCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTPasswordWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTPlayerClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTPlayerSetupClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTPlayerSetupScrollClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTPlayerWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTRulesCWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTRulesSClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTServerSetupPage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTServerSetupSC.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTSettingsCWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTSettingsSClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTStartGameCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTStartGameWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTTeamRCWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTTeamRSClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTTeamSCWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTTeamSSClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTWeaponPriorityCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTWeaponPriorityInfoArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTWeaponPriorityList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTWeaponPriorityListArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTWeaponPriorityListBox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UTWeaponPriorityWindow.uc
# End Source File
# End Group
# End Target
# End Project
