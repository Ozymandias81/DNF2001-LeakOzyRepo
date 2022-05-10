# Microsoft Developer Studio Project File - Name="DukeEd" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=DukeEd - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "DukeEd.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "DukeEd.mak" CFG="DukeEd - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "DukeEd - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "DukeEd - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Duke4_UT400/DukeEd", SSNAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "DukeEd - Win32 Release"

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
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /Zp4 /MD /W4 /WX /vd0 /GX /Zi /O2 /Ob2 /I "..\xcore" /I "..\Core\Inc" /I "..\Engine\Inc" /I "..\Window\Inc" /I "..\Editor\Inc" /I "Inc" /I "Inc\Bugslayer" /I "..\Engine\Src" /D "NDEBUG" /D "_WINDOWS" /D "UNICODE" /D "_UNICODE" /D "WIN32" /D _WIN32_IE=0x0200 /FR /FD /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 comctl32.lib comdlg32.lib ..\Engine\Lib\Engine.lib ..\Editor\Lib\Editor.lib user32.lib kernel32.lib gdi32.lib advapi32.lib shell32.lib BugslayerUtil.lib winmm.lib ..\Cannibal\Release\Cannibal.lib /nologo /base:"0x10E00000" /subsystem:windows /pdb:"..\system\DukeEd.pdb" /debug /machine:I386 /out:"..\System\DukeEd.exe"
# SUBTRACT LINK32 /pdb:none /incremental:yes

!ELSEIF  "$(CFG)" == "DukeEd - Win32 Debug"

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
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /Zp4 /MDd /W3 /WX /vd0 /GX /Zi /Od /I "..\xcore" /I "..\Core\Inc" /I "..\Engine\Inc" /I "..\Window\Inc" /I "..\Editor\Inc" /I "Inc" /I "Inc\Bugslayer" /I "..\Engine\Src" /D "_DEBUG" /D "_WINDOWS" /D "UNICODE" /D "_UNICODE" /D "WIN32" /D _WIN32_IE=0x0200 /FR /FD /GZ /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 comctl32.lib comdlg32.lib ..\Engine\Lib\Engine.lib ..\Editor\Lib\Editor.lib user32.lib kernel32.lib gdi32.lib advapi32.lib shell32.lib BugslayerUtil.lib winmm.lib ..\Cannibal\Release\Cannibal.lib /nologo /base:"0x10E00000" /subsystem:windows /pdb:"..\system\DukeEd.pdb" /debug /machine:I386 /out:"..\System\DukeEd.exe" /pdbtype:sept
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "DukeEd - Win32 Release"
# Name "DukeEd - Win32 Debug"
# Begin Group "Src"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\Src\Res\DukeEd.rc
# End Source File
# Begin Source File

SOURCE=.\Src\Main.cpp
# End Source File
# End Group
# Begin Group "Inc"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\Inc\BottomBar.h
# End Source File
# Begin Source File

SOURCE=.\Inc\Browser.h
# End Source File
# Begin Source File

SOURCE=.\Inc\BrowserActor.h
# End Source File
# Begin Source File

SOURCE=.\Inc\BrowserGroup.h
# End Source File
# Begin Source File

SOURCE=.\Inc\BrowserMaster.h
# End Source File
# Begin Source File

SOURCE=.\Inc\BrowserMesh.h
# End Source File
# Begin Source File

SOURCE=.\Inc\BrowserMusic.h
# End Source File
# Begin Source File

SOURCE=.\Inc\BrowserSound.h
# End Source File
# Begin Source File

SOURCE=.\Inc\BrowserTexture.h
# End Source File
# Begin Source File

SOURCE=.\Inc\BuildPropSheet.h
# End Source File
# Begin Source File

SOURCE=.\Inc\ButtonBar.h
# End Source File
# Begin Source File

SOURCE=.\Inc\CodeFrame.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgAddSpecial.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgBevel.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgBrushBuilder.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgBrushImport.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgBuildOptions.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgDepth.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgGeneric.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgMapError.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgMapImport.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgProgress.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgRename.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgScaleLights.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgSearchActors.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgTexProp.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgTexReplace.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgTexUsage.h
# End Source File
# Begin Source File

SOURCE=.\Inc\DlgViewportConfig.h
# End Source File
# Begin Source File

SOURCE=.\Inc\Extern.h
# End Source File
# Begin Source File

SOURCE=.\Inc\MRUList.h
# End Source File
# Begin Source File

SOURCE=.\Src\Res\resource.h
# End Source File
# Begin Source File

SOURCE=.\Inc\SurfacePropSheet.h
# End Source File
# Begin Source File

SOURCE=.\Inc\TerrainEditSheet.h
# End Source File
# Begin Source File

SOURCE=.\Inc\TopBar.h
# End Source File
# Begin Source File

SOURCE=.\Inc\TwoDeeShapeEditor.h
# End Source File
# Begin Source File

SOURCE=.\Inc\ViewportFrame.h
# End Source File
# End Group
# Begin Group "Res"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\Src\Res\bb_grid1.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bb_lock1.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bb_log_w.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bb_rotat.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bb_vtx_s.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bb_zoomc.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00001.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00002.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00003.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00004.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00005.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00006.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00007.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00008.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00009.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00010.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00011.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00012.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00013.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00014.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00015.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00016.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00017.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00018.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00019.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00020.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00021.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00022.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00023.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00024.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00025.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00026.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00027.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\bmp00028.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\browsers.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\browsert.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\cf_toolb.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\Duke.ico
# End Source File
# Begin Source File

SOURCE=.\Src\Res\Icon.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\icon1.ico
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_2ds.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_add.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_bui.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_buildall.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_cam.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_che.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_del.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_dow.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_edi.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_fil.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_mes.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\Idbm_mus.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_new.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_pla.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_sur.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_tex.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_unr.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\idbm_vie.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\Logo.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\Toolbar.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\toolbar1.bmp
# End Source File
# Begin Source File

SOURCE=.\Src\Res\Unreal.ico
# End Source File
# Begin Source File

SOURCE=.\Src\Res\UnrealEd.ico
# End Source File
# End Group
# Begin Group "Bugslayer"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Inc\Bugslayer\BugslayerUtil.h
# End Source File
# Begin Source File

SOURCE=.\Inc\Bugslayer\CrashHandler.h
# End Source File
# Begin Source File

SOURCE=.\Inc\Bugslayer\CriticalSection.h
# End Source File
# Begin Source File

SOURCE=.\Inc\Bugslayer\DiagAssert.h
# End Source File
# Begin Source File

SOURCE=.\Inc\Bugslayer\MemDumperValidator.h
# End Source File
# Begin Source File

SOURCE=.\Inc\Bugslayer\MemStress.h
# End Source File
# Begin Source File

SOURCE=.\Inc\Bugslayer\MSJDBG.h
# End Source File
# Begin Source File

SOURCE=.\Inc\Bugslayer\PSAPI.H
# End Source File
# Begin Source File

SOURCE=.\Inc\Bugslayer\SymbolEngine.h
# End Source File
# Begin Source File

SOURCE=.\Inc\Bugslayer\WarningsOff.h
# End Source File
# Begin Source File

SOURCE=.\Inc\Bugslayer\WarningsOn.h
# End Source File
# End Group
# End Target
# End Project
