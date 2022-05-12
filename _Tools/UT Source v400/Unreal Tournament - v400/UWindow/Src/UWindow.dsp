# Microsoft Developer Studio Project File - Name="UWindow" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=UWindow - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "UWindow.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "UWindow.mak" CFG="UWindow - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "UWindow - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "UWindow - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Unreal/UWindow/Src", HVKAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "UWindow - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UWINDOW_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "_MBCS" /D "_USRDLL" /D "UWINDOW_EXPORTS" /D "NDEBUG" /D "_WINDOWS" /D "UNICODE" /D "_UNICODE" /D "WIN32" /YX /FD /c
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
# Begin Special Build Tool
SOURCE="$(InputPath)"
PreLink_Cmds=nmake /f UWindow.mak
PostBuild_Cmds=nmake /f UWindow.mak
# End Special Build Tool

!ELSEIF  "$(CFG)" == "UWindow - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UWINDOW_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UWINDOW_EXPORTS" /D "UNICODE" /D "_UNICODE" /D "_DEBUG" /D "WIN32" /YX /FD /GZ /c
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

# Name "UWindow - Win32 Release"
# Name "UWindow - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter "*.uc"
# Begin Source File

SOURCE=..\Classes\UWindow.upkg
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowBase.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowBitmap.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowCheckbox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowComboButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowComboControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowComboLeftButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowComboList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowComboListItem.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowComboRightButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowConsoleClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowConsoleTextAreaControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowConsoleWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowControlFrame.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowDialogClientWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowDialogControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowDynamicTextArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowDynamicTextRow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowEditBox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowEditBoxHistory.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowEditControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowFrameCloseBox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowFramedWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowGrid.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowGridClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowGridColumn.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowHotkeyWindowList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowHScrollbar.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowHSliderControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowHSplitter.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowHTMLTextArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowHTMLTextRow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowLabelControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowLayoutBase.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowLayoutCell.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowLayoutControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowLayoutRow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowList.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowListBox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowListBoxItem.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowListControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowLookAndFeel.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowMenuBar.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowMenuBarItem.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowMessageBox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowMessageBoxArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowMessageBoxCW.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowPageControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowPageControlPage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowPageWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowProgressBar.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowPulldownMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowPulldownMenuItem.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowRightClickMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowRootWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowSBDownButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowSBLeftButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowSBRightButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowSBUpButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowScrollingDialogClient.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowSmallButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowSmallCancelButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowSmallCloseButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowSmallOKButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowTabControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowTabControlItem.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowTabControlLeftButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowTabControlRightButton.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowTabControlTabArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowTextAreaControl.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowURLTextArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowVScrollbar.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowVSplitter.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowWin95LookAndFeel.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowWindow.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UWindowWrappedTextArea.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\WindowConsole.uc
# End Source File
# End Group
# End Target
# End Project
