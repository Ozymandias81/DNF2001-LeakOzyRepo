# Microsoft Developer Studio Project File - Name="UBrowser" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=UBrowser - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "UBrowser.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "UBrowser.mak" CFG="UBrowser - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "UBrowser - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "UBrowser - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Unreal/UBrowser/Src", FVKAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "UBrowser - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UBROWSER_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "_MBCS" /D "_USRDLL" /D "UBROWSER_EXPORTS" /D "NDEBUG" /D "_WINDOWS" /D "WIN32" /D "UNICODE" /D "_UNICODE" /YX /FD /c
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

!ELSEIF  "$(CFG)" == "UBrowser - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UBROWSER_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UBROWSER_EXPORTS" /D "UNICODE" /D "_UNICODE" /D "_DEBUG" /D "WIN32" /YX /FD /GZ /c
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

# Name "UBrowser - Win32 Release"
# Name "UBrowser - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter "*.uc"
# Begin Source File

SOURCE=..\Classes\UBrowser.upkg
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserBannerAd.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserBannerBar.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserBrowserButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserBufferedTCPLink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserColorIRCTextArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserConsole.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserEditFavoriteCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserEditFavoriteWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserFavoriteServers.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserFavoritesFact.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserFavoritesMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserGSpyFact.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserGSpyLink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserHTTPClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserHTTPFact.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserHTTPLink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserInfoClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserInfoMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserInfoWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCChannelMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCChannelPage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCJoinMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCLink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCPageBase.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCPrivateMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCPrivPage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCSetupClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCSystemMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCSystemPage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCTextArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCUserList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCUserListBox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserIRCWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserLocalFact.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserLocalLink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserMainClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserMainWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserNewFavoriteCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserNewFavoriteWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserOpenCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserOpenWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserPlayerGrid.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserPlayerList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserRightClickMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserRootWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserRulesGrid.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserRulesList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserScreenshotCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserServerGrid.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserServerList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserServerListFactory.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserServerListWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserServerPing.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserSubsetFact.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserSubsetList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserSupersetList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserUpdateServerLink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserUpdateServerTextArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UBrowserUpdateServerWindow.uc
# End Source File
# End Group
# End Target
# End Project
