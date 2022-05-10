# Microsoft Developer Studio Project File - Name="dnWindow" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=dnWindow - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "dnWindow.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "dnWindow.mak" CFG="dnWindow - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "dnWindow - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "dnWindow - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Duke4_UT400/dnWindow", IDMAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "dnWindow - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNWINDOW_EXPORTS" /YX /FD /c
# ADD CPP /nologo /G6 /MT /W3 /GX /Zi /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNWINDOW_EXPORTS" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386

!ELSEIF  "$(CFG)" == "dnWindow - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNWINDOW_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNWINDOW_EXPORTS" /YX /FD /GZ /c
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

# Name "dnWindow - Win32 Release"
# Name "dnWindow - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter "uc"
# Begin Group "Multiplayer"

# PROP Default_Filter "uc"
# Begin Group "Join Game"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeJoinMultiCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeJoinMultiSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeJoinMultiWindow.uc
# End Source File
# End Group
# Begin Group "Create Game"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeCreateMultiCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeCreateMultiSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeCreateMultiWindow.uc
# End Source File
# End Group
# Begin Group "Player Setup"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\MeshActor.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukePlayerMeshCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukePlayerSetupCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukePlayerSetupSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukePlayerSetupTopCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukePlayerSetupTopSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukePlayerSetupWindow.uc
# End Source File
# End Group
# Begin Group "MutatorList"

# PROP Default_Filter "uc"
# Begin Source File

SOURCE=.\Classes\dnMutatorList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMutatorListBox.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMutatorListCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMutatorListExclude.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMutatorListInclude.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMutatorListSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMutatorListWindow.uc
# End Source File
# End Group
# Begin Group "MapList"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\dnMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMapListBox.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMapListCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMapListExclude.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMapListInclude.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMapListSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMapListWindow.uc
# End Source File
# End Group
# Begin Group "Rules"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeMultiRulesBase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeMultiRulesCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeMultiRulesSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeStartMatchCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeStartMatchSC.uc
# End Source File
# End Group
# Begin Group "ServerBrowser"

# PROP Default_Filter ""
# Begin Group "Grids"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukePlayerGrid.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukePlayerList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeRulesGrid.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeRulesList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeServerGrid.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeServerList.uc
# End Source File
# End Group
# Begin Group "Factories"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeGSpyFact.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeGSpyLink.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeLocalFact.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeLocalLink.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeServerListFactory.uc
# End Source File
# End Group
# Begin Group "Filters"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeBuddyList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeBuddyListBox.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeRightClickBuddyMenu.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeServerFilterCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeServerFilterSC.uc
# End Source File
# End Group
# Begin Source File

SOURCE=.\Classes\UDukeInfoCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeRightClickMenu.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeScreenshotCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeServerBrowserControlsCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeServerBrowserCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeServerBrowserSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeServerPing.uc
# End Source File
# End Group
# Begin Group "DukeNet NOT USED"

# PROP Default_Filter ""
# Begin Group "ChatClient"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeNetChannelItem.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNetChannelListBox.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNetTabWindowChat.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNetTextArea.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNetUserItem.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNetUserListBox.uc
# End Source File
# End Group
# Begin Source File

SOURCE=.\Classes\DukeNetLink.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeBannerAd.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeDukeNetWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNetCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNetSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNetTabWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNetTabWindowCreate.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNetTabWindowNews.uc
# End Source File
# End Group
# Begin Group "Password"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukePasswordCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukePasswordWindow.uc
# End Source File
# End Group
# Begin Group "Scoreboard"

# PROP Default_Filter "uc"
# Begin Source File

SOURCE=.\Classes\UDukeScoreboard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeScoreboardCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeScoreboardGrid.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeScoreboardList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeScoreboardMenu.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeScoreboardSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeScoreboardTauntMenu.uc
# End Source File
# End Group
# End Group
# Begin Group "Key Binder"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeControlsBinder.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeControlsCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeControlsSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeControlsWindow.uc
# End Source File
# End Group
# Begin Group "LookandFeel"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeLookAndFeel.uc
# End Source File
# End Group
# Begin Group "InGameWindow"

# PROP Default_Filter "uc"
# Begin Group "Pulldown Menu Version"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeInGamePulldownClassesMenu.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeInGamePulldownMenu.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeInGamePulldownSpectatorMenu.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeInGamePulldownTauntMenu.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeInGamePulldownTeamsMenu.uc
# End Source File
# End Group
# Begin Source File

SOURCE=.\Classes\NotifyButton.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\NotifyWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeInGameButton.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeInGameWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeInGameWindowClasses.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeInGameWindowSpectator.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeInGameWindowSpeech.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeInGameWindowTeams.uc
# End Source File
# End Group
# Begin Group "Video"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeVideoCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeVideoSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeVideoWindow.uc
# End Source File
# End Group
# Begin Group "Audio"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeAudioCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeAudioSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeAudioWindow.uc
# End Source File
# End Group
# Begin Group "Game"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeGameOptionsCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeGameOptionsSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeGameWindow.uc
# End Source File
# End Group
# Begin Group "SOS"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeSOSCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeSOSSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeSOSWindow.uc
# End Source File
# End Group
# Begin Group "Parent Lock"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeParentLockWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeParentLockWindowCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeParentLockWindowSC.uc
# End Source File
# End Group
# Begin Group "New Game"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeNewGameWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNewGameWindowCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeNewGameWindowSC.uc
# End Source File
# End Group
# Begin Group "Load Game"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeLoadGameWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeLoadGameWindowCW.uc
# End Source File
# End Group
# Begin Group "Save Game"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeSaveEditBox.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeSaveGameWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeSaveGameWindowCW.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeSaveGameWindowSC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeSaveLoadGrid.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeSaveLoadList.uc
# End Source File
# End Group
# Begin Group "Profile"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeProfileWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeProfileWindowCW.uc
# End Source File
# End Group
# Begin Group "Custom Controls"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeArrowButton.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeColoredDynamicTextRow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeConsoleWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeDialogClientWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeEmbeddedClient.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeFrameButton.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeFramedWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeHTMLTextHandler.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeHTTPClient.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeLabelControl.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeMissionOverButton.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukePageWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeRaisedButton.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeTabControl.uc
# End Source File
# End Group
# Begin Group "Desktop"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\UDukeButton.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeDesktopWindow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeDesktopWindowBase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeFakeIcon.uc
# End Source File
# End Group
# Begin Source File

SOURCE=.\Classes\DukeConsole.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DukeIntro.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDukeRootWindow.uc
# End Source File
# End Group
# Begin Source File

SOURCE=.\Readme.txt
# End Source File
# End Target
# End Project
