# Microsoft Developer Studio Project File - Name="Cannibal" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=Cannibal - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Cannibal.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Cannibal.mak" CFG="Cannibal - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Cannibal - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "Cannibal - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Duke4_UT400/Cannibal", QDPAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Cannibal - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CANNIBAL_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /Zi /O2 /Ob2 /I "../core/inc" /I "../xcore" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "KRN_EXPORTS" /D "KRN_DLL" /U "XCORE_PURE" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 ../xcore/xcore.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib comctl32.lib /nologo /dll /map /debug /debugtype:both /machine:I386 /out:"..\System\Cannibal.dll"

!ELSEIF  "$(CFG)" == "Cannibal - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CANNIBAL_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /I "../xcore" /I "../core/inc" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "KRN_EXPORTS" /D "KRN_DLL" /U "XCORE_PURE" /FR /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 ../xcore/xcore.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib comctl32.lib /nologo /dll /map /debug /machine:I386 /out:"..\System\Cannibal.dll" /pdbtype:sept

!ENDIF 

# Begin Target

# Name "Cannibal - Win32 Release"
# Name "Cannibal - Win32 Debug"
# Begin Group "Kernel"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\CorMain.cpp
# End Source File
# Begin Source File

SOURCE=.\CorMain.h
# End Source File
# Begin Source File

SOURCE=.\Kernel.cpp
# End Source File
# Begin Source File

SOURCE=.\Kernel.h
# End Source File
# Begin Source File

SOURCE=.\KrnBuild.h
# End Source File
# Begin Source File

SOURCE=.\KrnDefs.h
# End Source File
# Begin Source File

SOURCE=.\KrnInc.h
# End Source File
# Begin Source File

SOURCE=.\KrnTypes.h
# End Source File
# Begin Source File

SOURCE=.\msg.asm

!IF  "$(CFG)" == "Cannibal - Win32 Release"

# Begin Custom Build
IntDir=.\Release
InputPath=.\msg.asm

"$(IntDir)\msg.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\msg.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "Cannibal - Win32 Debug"

# Begin Custom Build
IntDir=.\Debug
InputPath=.\msg.asm

"$(IntDir)\msg.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\msg.obj /c /coff /Cp /Cx -Zd -Zi -Zf $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\StrMain.cpp
# End Source File
# Begin Source File

SOURCE=.\StrMain.h
# End Source File
# End Group
# Begin Group "Mathematics"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\MathFlt.h
# End Source File
# Begin Source File

SOURCE=.\VecMain.h
# End Source File
# Begin Source File

SOURCE=.\VecPrim.h
# End Source File
# End Group
# Begin Group "Logging"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\LogMain.cpp
# End Source File
# Begin Source File

SOURCE=.\LogMain.h
# End Source File
# End Group
# Begin Group "Timing"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\TimeMain.cpp
# End Source File
# Begin Source File

SOURCE=.\TimeMain.h
# End Source File
# End Group
# Begin Group "Memory"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\MemMain.cpp
# End Source File
# Begin Source File

SOURCE=.\MemMain.h
# End Source File
# End Group
# Begin Group "Files"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\FileBox.cpp
# End Source File
# Begin Source File

SOURCE=.\FileBox.h
# End Source File
# Begin Source File

SOURCE=.\FileMain.cpp
# End Source File
# Begin Source File

SOURCE=.\FileMain.h
# End Source File
# End Group
# Begin Group "Parsing"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\LexMain.cpp
# End Source File
# Begin Source File

SOURCE=.\LexMain.h
# End Source File
# Begin Source File

SOURCE=.\PrsMain.cpp
# End Source File
# Begin Source File

SOURCE=.\PrsMain.h
# End Source File
# End Group
# Begin Group "Objects"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\MsgMain.cpp
# End Source File
# Begin Source File

SOURCE=.\MsgMain.h
# End Source File
# Begin Source File

SOURCE=.\ObjMain.cpp
# End Source File
# Begin Source File

SOURCE=.\ObjMain.h
# End Source File
# End Group
# Begin Group "Input"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\InDefs.h
# End Source File
# Begin Source File

SOURCE=.\InMain.cpp
# End Source File
# Begin Source File

SOURCE=.\InMain.h
# End Source File
# Begin Source File

SOURCE=.\InWin.cpp
# End Source File
# Begin Source File

SOURCE=.\InWin.h
# End Source File
# End Group
# Begin Group "Models"

# PROP Default_Filter ""
# Begin Group "Project Files"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\CpjFmt.h
# End Source File
# Begin Source File

SOURCE=.\CpjFrm.cpp
# End Source File
# Begin Source File

SOURCE=.\CpjFrm.h
# End Source File
# Begin Source File

SOURCE=.\CpjGeo.cpp
# End Source File
# Begin Source File

SOURCE=.\CpjGeo.h
# End Source File
# Begin Source File

SOURCE=.\CpjLod.cpp
# End Source File
# Begin Source File

SOURCE=.\CpjLod.h
# End Source File
# Begin Source File

SOURCE=.\CpjMac.cpp
# End Source File
# Begin Source File

SOURCE=.\CpjMac.h
# End Source File
# Begin Source File

SOURCE=.\CpjMain.cpp
# End Source File
# Begin Source File

SOURCE=.\CpjMain.h
# End Source File
# Begin Source File

SOURCE=.\CpjProj.cpp
# End Source File
# Begin Source File

SOURCE=.\CpjProj.h
# End Source File
# Begin Source File

SOURCE=.\CpjSeq.cpp
# End Source File
# Begin Source File

SOURCE=.\CpjSeq.h
# End Source File
# Begin Source File

SOURCE=.\CpjSkl.cpp
# End Source File
# Begin Source File

SOURCE=.\CpjSkl.h
# End Source File
# Begin Source File

SOURCE=.\CpjSrf.cpp
# End Source File
# Begin Source File

SOURCE=.\CpjSrf.h
# End Source File
# End Group
# Begin Group "Model Actors"

# PROP Default_Filter ""
# Begin Group "Res"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Res\CpjCpj.bmp
# End Source File
# Begin Source File

SOURCE=.\Res\CpjFrm.bmp
# End Source File
# Begin Source File

SOURCE=.\Res\CpjGeo.bmp
# End Source File
# Begin Source File

SOURCE=.\Res\CpjLod.bmp
# End Source File
# Begin Source File

SOURCE=.\Res\CpjMac.bmp
# End Source File
# Begin Source File

SOURCE=.\Res\CpjSeq.bmp
# End Source File
# Begin Source File

SOURCE=.\Res\CpjSkl.bmp
# End Source File
# Begin Source File

SOURCE=.\Res\CpjSrf.bmp
# End Source File
# Begin Source File

SOURCE=.\Res\FileClosed.bmp
# End Source File
# Begin Source File

SOURCE=.\Res\FileOpen.bmp
# End Source File
# Begin Source File

SOURCE=.\Res\MacEdit.rc
# End Source File
# Begin Source File

SOURCE=.\Res\resource.h
# End Source File
# End Group
# Begin Source File

SOURCE=.\MacEdit.cpp
# End Source File
# Begin Source File

SOURCE=.\MacEdit.h
# End Source File
# Begin Source File

SOURCE=.\MacMain.cpp

!IF  "$(CFG)" == "Cannibal - Win32 Release"

# ADD CPP /FAs

!ELSEIF  "$(CFG)" == "Cannibal - Win32 Debug"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\MacMain.h
# End Source File
# End Group
# End Group
# Begin Group "Plugins"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\PlgMain.cpp
# End Source File
# Begin Source File

SOURCE=.\PlgMain.h
# End Source File
# End Group
# Begin Group "Platform"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\IpcMain.cpp
# End Source File
# Begin Source File

SOURCE=.\IpcMain.h
# End Source File
# Begin Source File

SOURCE=.\WinCtrl.cpp
# End Source File
# Begin Source File

SOURCE=.\WinCtrl.h
# End Source File
# End Group
# Begin Source File

SOURCE=.\Cannibal.h
# End Source File
# End Target
# End Project
