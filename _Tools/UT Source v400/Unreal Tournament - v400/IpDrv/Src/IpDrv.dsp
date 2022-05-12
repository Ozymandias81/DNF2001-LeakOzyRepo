# Microsoft Developer Studio Project File - Name="IpDrv" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=IpDrv - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "IpDrv.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "IpDrv.mak" CFG="IpDrv - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "IpDrv - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "IpDrv - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Unreal/IpDrv", FAAAAAAA"
# PROP Scc_LocalPath ".."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "IpDrv - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "..\Lib"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /Zp4 /MD /W4 /WX /vd0 /GX /O2 /Ob2 /I "." /I "..\Inc" /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /D IPDRV_API=__declspec(dllexport) /D "_WINDOWS" /D "NDEBUG" /D "UNICODE" /D "_UNICODE" /D "WIN32" /FR /Yu"IpDrvPrivate.h" /FD /Zm256 /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 wsock32.lib kernel32.lib gdi32.lib user32.lib ..\..\Core\Lib\Core.lib ..\..\Engine\Lib\Engine.lib /nologo /base:"0x10700000" /subsystem:windows /dll /incremental:yes /machine:I386 /out:"..\..\System\IpDrv.dll"

!ELSEIF  "$(CFG)" == "IpDrv - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "..\Lib"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /Zp4 /MDd /W4 /WX /Gm /vd0 /GX /ZI /Od /I "." /I "..\Inc" /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /D "_WINDOWS" /D IPDRV_API=__declspec(dllexport) /D "UNICODE" /D "_UNICODE" /D "_DEBUG" /D "WIN32" /Yu"IpDrvPrivate.h" /FD /Zm256 /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 ..\..\Core\Lib\Core.lib ..\..\Engine\Lib\Engine.lib wsock32.lib kernel32.lib gdi32.lib user32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /out:"..\..\System\IpDrv.dll" /pdbtype:sept

!ENDIF 

# Begin Target

# Name "IpDrv - Win32 Release"
# Name "IpDrv - Win32 Debug"
# Begin Group "Src"

# PROP Default_Filter "*.cpp;*.h"
# Begin Source File

SOURCE=.\InternetLink.cpp
# End Source File
# Begin Source File

SOURCE=.\IpDrv.cpp
# ADD CPP /Yc"IpDrvPrivate.h"
# End Source File
# Begin Source File

SOURCE=.\TcpLink.cpp
# End Source File
# Begin Source File

SOURCE=.\TcpNetDriver.cpp
# End Source File
# Begin Source File

SOURCE=.\UdpLink.cpp
# End Source File
# Begin Source File

SOURCE=.\UMasterServerCommandlet.cpp
# End Source File
# Begin Source File

SOURCE=.\UnSocket.cpp
# End Source File
# Begin Source File

SOURCE=.\UUpdateServerCommandlet.cpp
# End Source File
# End Group
# Begin Group "Classes"

# PROP Default_Filter "*.uc"
# Begin Source File

SOURCE=..\Classes\ClientBeaconReceiver.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\InternetLink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\IpDrv.upkg
# End Source File
# Begin Source File

SOURCE=..\Classes\TcpLink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UdpBeacon.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UdpLink.uc
# End Source File
# End Group
# Begin Group "Inc"

# PROP Default_Filter "*.h"
# Begin Source File

SOURCE=..\Inc\AInternetLink.h
# End Source File
# Begin Source File

SOURCE=..\Inc\ATcpLink.h
# End Source File
# Begin Source File

SOURCE=..\Inc\AUdpLink.h
# End Source File
# Begin Source File

SOURCE=..\Inc\GameSpyClasses.h
# End Source File
# Begin Source File

SOURCE=..\Inc\GameSpyClassesPublic.h
# End Source File
# Begin Source File

SOURCE=..\Inc\IpDrvClasses.h
# End Source File
# Begin Source File

SOURCE=.\IpDrvPrivate.h
# End Source File
# Begin Source File

SOURCE=.\UnSocket.h
# End Source File
# End Group
# Begin Group "Classes (IpServer)"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\IpServer\Classes\IpServer.upkg
# End Source File
# Begin Source File

SOURCE=..\..\IpServer\Classes\UdpServerQuery.uc
# End Source File
# Begin Source File

SOURCE=..\..\IpServer\Classes\UdpServerUplink.uc
# End Source File
# End Group
# End Target
# End Project
