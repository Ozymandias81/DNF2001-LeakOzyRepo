# Microsoft Developer Studio Project File - Name="Engine" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=Engine - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Engine.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Engine.mak" CFG="Engine - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Engine - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "Engine - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Duke4_UT400/Engine", KGJAAAAA"
# PROP Scc_LocalPath ".."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Engine - Win32 Release"

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
# ADD CPP /nologo /G6 /Zp4 /MD /W4 /WX /vd0 /GX /Zi /O2 /Ob2 /I "..\..\DirectX8\Inc" /I "..\..\xcore" /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /I "..\..\Render\Inc" /I "..\..\WinDrv\Inc" /I "..\..\Window\Inc" /I "..\..\IpDrv\Inc" /I "..\..\IpDrv\Src" /D CORE_API=__declspec(dllexport) /D ENGINE_API=__declspec(dllexport) /D WINDOW_API=__declspec(dllexport) /D WINDRV_API=__declspec(dllexport) /D IPDRV_API=__declspec(dllexport) /D "_WINDOWS" /D "NDEBUG" /D "UNICODE" /D "_UNICODE" /D "WIN32" /D _WIN32_IE=0x0200 /Fr /Yu"EnginePrivate.h" /FD /Zm256 /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 /libpath:"..\..\DirectX8\Lib" ..\..\xcore\xcore.lib ..\lib\spchwrap.lib comdlg32.lib comctl32.lib dinput8.lib dxguid.lib gdi32.lib user32.lib kernel32.lib winmm.lib shell32.lib ole32.lib advapi32.lib ..\Lib\s3tc.lib /nologo /base:"0x10300000" /subsystem:windows /dll /pdb:"..\..\system\engine.pdb" /debug /machine:I386 /nodefaultlib:"LIBC" /out:"..\..\System\Engine.dll"
# SUBTRACT LINK32 /pdb:none /incremental:yes

!ELSEIF  "$(CFG)" == "Engine - Win32 Debug"

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
# ADD CPP /nologo /G6 /Zp4 /MDd /W4 /WX /vd0 /GX /Zi /Od /I "..\..\DirectX8\Inc" /I "..\..\xcore" /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /I "..\..\Render\Inc" /I "..\..\WinDrv\Inc" /I "..\..\Window\Inc" /I "..\..\IpDrv\Inc" /I "..\..\IpDrv\Src" /D CORE_API=__declspec(dllexport) /D ENGINE_API=__declspec(dllexport) /D WINDOW_API=__declspec(dllexport) /D WINDRV_API=__declspec(dllexport) /D IPDRV_API=__declspec(dllexport) /D "_WINDOWS" /D "UNICODE" /D "_UNICODE" /D "_DEBUG" /D "WIN32" /D _WIN32_IE=0x0200 /Yu"EnginePrivate.h" /FD /D /Zm256 /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 /libpath:"..\..\DirectX8\Lib" ..\..\xcore\xcore.lib ..\lib\spchwrap.lib comdlg32.lib comctl32.lib dinput8.lib dxguid.lib gdi32.lib user32.lib kernel32.lib winmm.lib shell32.lib ole32.lib advapi32.lib ..\Lib\s3tc.lib /nologo /base:"0x10300000" /subsystem:windows /dll /pdb:"..\..\system\engine.pdb" /debug /machine:I386 /nodefaultlib:"LIBC" /out:"..\..\System\Engine.dll" /pdbtype:sept
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "Engine - Win32 Release"
# Name "Engine - Win32 Debug"
# Begin Group "Core Src"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\Core\Src\DnExec.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\mail.cpp

!IF  "$(CFG)" == "Engine - Win32 Release"

# SUBTRACT CPP /YX /Yc /Yu

!ELSEIF  "$(CFG)" == "Engine - Win32 Debug"

# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UExporter.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UFactory.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnAnsi.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnBits.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnCache.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnClass.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnCoreNet.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnCorSc.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnLinker.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnMath.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnMem.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnMisc.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnName.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnObj.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnProp.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Core\Src\UnVcWin32.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# End Group
# Begin Group "Core Inc"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\Core\Inc\Core.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\DnExec.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FCodec.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FConfigCacheIni.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FFeedbackContextAnsi.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FFeedbackContextWindows.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FFileManagerAnsi.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FFileManagerGeneric.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FFileManagerLinux.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FFileManagerWindows.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FMallocAnsi.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FMallocDebug.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FMallocWindows.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FOutputDeviceAnsiError.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FOutputDeviceFile.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FOutputDeviceNull.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FOutputDeviceStdout.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FOutputDeviceWindowsError.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\FRiffChunk.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\mail.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UExporter.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UFactory.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnArc.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnBits.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnBuild.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnCache.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnCId.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnClass.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnCoreNet.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnCorObj.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnFile.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnGnuG.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnLinker.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnMath.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnMem.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnMsg.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnName.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnNames.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnObjBas.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnObjVer.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnScript.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnStack.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnTemplate.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnType.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnUnix.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnVcWin32.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\UnVcWn32SSE.h
# End Source File
# Begin Source File

SOURCE=..\..\Core\Inc\xtypes.h
# End Source File
# End Group
# Begin Group "Engine Src"

# PROP Default_Filter "*.cpp"
# Begin Source File

SOURCE=.\ABeamSystem.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\ABreakableGlass.cpp
# End Source File
# Begin Source File

SOURCE=.\ADukeNet.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\AFocalPoint.cpp
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\Amd3d.h
# End Source File
# Begin Source File

SOURCE=.\ASoftParticleSystem.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\BoneWarp.cpp
# End Source File
# Begin Source File

SOURCE=.\DnCinematic.cpp

!IF  "$(CFG)" == "Engine - Win32 Release"

# ADD CPP /Yu

!ELSEIF  "$(CFG)" == "Engine - Win32 Debug"

# SUBTRACT CPP /YX /Yc /Yu

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\dnclient.c
# ADD CPP /G6 /W3
# SUBTRACT CPP /YX /Yc /Yu
# End Source File
# Begin Source File

SOURCE=.\DnMesh.cpp
# ADD CPP /G6 /Yu
# End Source File
# Begin Source File

SOURCE=.\dnParentalLock.cpp
# End Source File
# Begin Source File

SOURCE=.\dnPlayerProfile.cpp
# End Source File
# Begin Source File

SOURCE=.\dnSaveLoad.cpp
# End Source File
# Begin Source File

SOURCE=.\dnScreenshot.cpp
# End Source File
# Begin Source File

SOURCE=.\DnTextureCanvas.cpp
# ADD CPP /G6 /Yu
# End Source File
# Begin Source File

SOURCE=.\Engine.cpp
# ADD CPP /G6 /Yc"EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=.\EnginePrivate.h
# End Source File
# Begin Source File

SOURCE=..\Inc\Flic.h
# End Source File
# Begin Source File

SOURCE=.\network.c
# ADD CPP /G6 /W3
# SUBTRACT CPP /YX /Yc /Yu
# End Source File
# Begin Source File

SOURCE=.\palette.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\Render.cpp
# ADD CPP /G6 /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\RenderPrivate.h
# End Source File
# Begin Source File

SOURCE=.\Rope.cpp
# End Source File
# Begin Source File

SOURCE=.\ULodMesh.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnActCol.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnActor.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnAudio.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnCamera.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnCamMgr.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnCanvas.cpp
# ADD CPP /G6 /Yu
# End Source File
# Begin Source File

SOURCE=.\UnCon.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnDynBsp.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnEngine.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnFont.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnFPoly.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnGame.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnIn.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnLevAct.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnLevel.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnLevTic.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\UnLight.cpp
# ADD CPP /G6 /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=.\UnMain.cpp

!IF  "$(CFG)" == "Engine - Win32 Release"

# ADD CPP /Yu

!ELSEIF  "$(CFG)" == "Engine - Win32 Debug"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\UnMesh.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\UnMeshRn.cpp

!IF  "$(CFG)" == "Engine - Win32 Release"

# ADD CPP /G6 /Yu

!ELSEIF  "$(CFG)" == "Engine - Win32 Debug"

# ADD CPP /G6 /Yu"EnginePrivate.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\UnModel.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnMover.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnObjEngine.cpp
# End Source File
# Begin Source File

SOURCE=.\UnParams.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnPath.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnPath.h
# End Source File
# Begin Source File

SOURCE=.\UnPawn.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnPhysic.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnPlayer.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnPrim.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\UnRandom.cpp
# ADD CPP /G6 /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=.\UnReach.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\UnRender.cpp

!IF  "$(CFG)" == "Engine - Win32 Release"

# ADD CPP /G6 /FAs /Yu"..\..\Engine\Src\EnginePrivate.h"

!ELSEIF  "$(CFG)" == "Engine - Win32 Debug"

# ADD CPP /G6 /Yu"..\..\Engine\Src\EnginePrivate.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\UnRenderIterator.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnRoute.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnScript.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnScrTex.cpp
# ADD CPP /G6 /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\UnSoftLn.cpp
# ADD CPP /G6 /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\UnSpan.cpp
# ADD CPP /G6 /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\UnSpan.h
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\UnSprite.cpp
# ADD CPP /G6 /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\Render\Src\UnTest.cpp
# ADD CPP /G6 /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=.\UnTex.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnTrace.cpp
# ADD CPP /G6
# End Source File
# Begin Source File

SOURCE=.\UnURL.cpp
# ADD CPP /G6
# End Source File
# End Group
# Begin Group "Engine Inc"

# PROP Default_Filter "*.h"
# Begin Source File

SOURCE=..\Inc\AActor.h
# End Source File
# Begin Source File

SOURCE=..\Inc\ABeamSystem.h
# End Source File
# Begin Source File

SOURCE=..\Inc\ABoneRope.h
# End Source File
# Begin Source File

SOURCE=..\Inc\ABrush.h
# End Source File
# Begin Source File

SOURCE=..\Inc\ACamera.h
# End Source File
# Begin Source File

SOURCE=..\Inc\ACarcass.h
# End Source File
# Begin Source File

SOURCE=..\Inc\ADoorMover.h
# End Source File
# Begin Source File

SOURCE=..\Inc\ADukeNet.h
# End Source File
# Begin Source File

SOURCE=..\Inc\AFocalPoint.h
# End Source File
# Begin Source File

SOURCE=..\Inc\AGameReplicationInfo.h
# End Source File
# Begin Source File

SOURCE=..\Inc\AInventory.h
# End Source File
# Begin Source File

SOURCE=.\Amd3d.h
# End Source File
# Begin Source File

SOURCE=..\Inc\AMover.h
# End Source File
# Begin Source File

SOURCE=..\Inc\APawn.h
# End Source File
# Begin Source File

SOURCE=..\Inc\APlayerPawn.h
# End Source File
# Begin Source File

SOURCE=..\Inc\APlayerReplicationInfo.h
# End Source File
# Begin Source File

SOURCE=..\Inc\ARenderActor.h
# End Source File
# Begin Source File

SOURCE=..\Inc\ASoftParticleSystem.h
# End Source File
# Begin Source File

SOURCE=..\Inc\AZoneInfo.h
# End Source File
# Begin Source File

SOURCE=..\Inc\DnCinematic.h
# End Source File
# Begin Source File

SOURCE=..\Inc\dnclient.h
# End Source File
# Begin Source File

SOURCE=..\Inc\DnMesh.h
# End Source File
# Begin Source File

SOURCE=..\Inc\DnMeshPrivate.h
# End Source File
# Begin Source File

SOURCE=..\Inc\DnTextureCanvas.h
# End Source File
# Begin Source File

SOURCE=..\Inc\Engine.h
# End Source File
# Begin Source File

SOURCE=..\Inc\EngineClasses.h
# End Source File
# Begin Source File

SOURCE=.\flic.cpp
# End Source File
# Begin Source File

SOURCE=..\Inc\MeshBase.h
# End Source File
# Begin Source File

SOURCE=..\Inc\network.h
# End Source File
# Begin Source File

SOURCE=..\Inc\Palette.h
# End Source File
# Begin Source File

SOURCE=.\res\resource.h
# End Source File
# Begin Source File

SOURCE=..\Inc\Rope.h
# End Source File
# Begin Source File

SOURCE=..\Inc\S3tc.h
# End Source File
# Begin Source File

SOURCE=..\Inc\ULevelSummary.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnActor.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnAudio.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnCamera.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnCon.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnDDraw.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnDynBsp.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnEngine.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnEngineGnuG.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnEngineWin.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnGame.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnIn.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnLevel.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnMesh.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnMeshPrivate.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnModel.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnNetStuff.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnObj.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnPlayer.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnPrim.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnReach.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnRender.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnRenderIterator.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnRenDev.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnScrTex.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnTex.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnURL.h
# End Source File
# End Group
# Begin Group "Engine Classes"

# PROP Default_Filter "*.uc"
# Begin Source File

SOURCE=..\Classes\Actor.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ActorDamageEffect.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ActorFreeze.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ActorImmolation.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\AlternatePath.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\AlwaysTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\AmbientSound.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Ambushpoint.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Ammo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\AnalogClockDispatcher.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\AnimPlayer.uc
# End Source File
# Begin Source File

SOURCE=..\classes\AnyDamage.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BeamAnchor.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\BeamSystem.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BiochemicalDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Bitmap.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\BlockAll.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\BlockedPath.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\BlockMonsters.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\BlockPlayer.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BoneRope.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BootSmashDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\BotPawn.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BreakableGlass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Brush.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\BulletDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ButtonMarker.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Camera.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Canvas.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Carcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ClientBeaconReceiver.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ClipMarker.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ColdDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Commandlet.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Console.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ConstraintJoint.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ControlRemapper.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Coordaxis.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Counter.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\CriticalEventMessage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\CriticalString.uc
# End Source File
# Begin Source File

SOURCE=..\classes\CrushingDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DamageType.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DebugAnimView.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DebugView.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Decal.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DecapitationDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Decoration.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DefensePoint.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\deleteme.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DigitalClockDispatcher.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Dispatcher.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Dispatchers.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\dnDecal.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\dnDecal_Delayed.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DoorHandle.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DoorMover.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DOTAffector.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DOTTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DrawActorMount.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DrowningDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DukeNet.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DukeVoice.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Effects.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ElectricalDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Engine.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Engine.upkg
# End Source File
# Begin Source File

SOURCE=..\classes\ExplosionDamage.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FallingDamage.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FireDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FlareLight.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FlicTexture.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FocalPoint.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FocusPoint.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FogMorphDispatcher.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FontBaseBlargo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Fragment.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\GameInfo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\GameReplicationInfo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\GlassMover.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\GlassShatterEffect.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HelloWorldCommandlet.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HitPackage.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HitPackage_Decoration.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HitPackage_Glass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HitPackage_GlassDir.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HitPackage_Inventory.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HitPackage_Level.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\HoldSpot.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\HomeBase.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\HUD.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Info.uc
# End Source File
# Begin Source File

SOURCE=..\classes\InfoActor.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Inpatcher.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\InternalTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\InternetInfo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\InternetLink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\InterpolationPoint.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\InterpolationStation.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Inventory.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\InventorySpot.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Item.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\KeyframeDispatch.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\KeyframeDispatchDispatcher.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Keypoint.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\KillTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\classes\KungFuDamage.uc
# End Source File
# Begin Source File

SOURCE=..\classes\LaserBeam.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\LevelInfo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\LevelSummary.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\LiftCenter.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\LiftExit.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Light.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Locale.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\LocalMessage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\locationid.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\LogicGate.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\LookAtDispatch.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MapList.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MapLocations.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Material.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MeshDecal.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MeshEffect.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MeshImmolation.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MeshInstance.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Mover.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MusicEvent.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MusicTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Mutator.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\NavigationPoint.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Object.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Palette.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ParticleCollisionActor.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ParticleSystem.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PathAttach.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PathNode.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PatrolPoint.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Pawn.uc
# End Source File
# Begin Source File

SOURCE=..\classes\PawnImmolation.uc
# End Source File
# Begin Source File

SOURCE=..\classes\PawnShrink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PawnTrackingInfo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PeriodicTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Player.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PlayerCanSeeMe.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PlayerPawn.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PlayerReplicationInfo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PlayerStart.uc
# End Source File
# Begin Source File

SOURCE=..\classes\PoisonDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PolyMarker.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Primitive.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ProceduralTexture.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Projectile.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Puppet.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PuppetIterator.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PuppetIteratorGlobal.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PuppetIteratorRadius.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PuppetWorker.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\QuestItem.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\QuestTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\classes\RadiationDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RandomDispatcher.uc
# End Source File
# Begin Source File

SOURCE=..\classes\RenderActor.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ReplicationInfo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RespawnMarker.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RotaryTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RouletteWheelDispatcher.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RoundRobin.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SavedMove.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ScaledSprite.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ScoreBoard.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Scout.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ScriptedTexture.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ShrinkerDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SkyZoneInfo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmackerTexture.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SoftParticleAffector.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SoftParticleSystem.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SoftParticleSystemAssign.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SOSMessage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SpawnNotify.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SpecialEvent.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Spotlight.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SpriteManager.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\StaticTexture.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SteroidBurnoutDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\StringMessage.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Subsystem.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SuicideDamage.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TcpLink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Teleporter.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TentacleDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TestMeshEffect.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Texture.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TextureCanvas.uc
# End Source File
# Begin Source File

SOURCE=..\classes\thirdpersondecoration.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Time.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Trigger.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerAnim.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerArrangeActors.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerAssign.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerDestroy.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerEtherial.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerExternalForce.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerFlic.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerForward.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerFOV.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerLight.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerLightStyle.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerMarker.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerMaterial.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerMeshChannel.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerMount.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerPortal.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerRelay.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Triggers.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerSelfForward.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerSetPhysics.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerSlomo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerSmacker.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerSpawn.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerTextureCanvas.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerTimeWarp.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerToggleExistance.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerToggleHidden.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerTransmission.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TriggerZoneAssign.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UdpBeacon.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UdpLink.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UniqueTextureBank.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Variable.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\VariableModify.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\VoicePack.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\WarpZoneInfo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\WarpZoneMarker.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\WayBeacon.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Weapon.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WhippedDownDamage.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WhippedLeftDamage.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WhippedRightDamage.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ZoneInfo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ZoneTrigger.uc
# End Source File
# End Group
# Begin Group "Net"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\UnBunch.cpp
# End Source File
# Begin Source File

SOURCE=..\Inc\UnBunch.h
# End Source File
# Begin Source File

SOURCE=.\UnChan.cpp
# ADD CPP /Yu
# End Source File
# Begin Source File

SOURCE=..\Inc\UnChan.h
# End Source File
# Begin Source File

SOURCE=.\UnConn.cpp
# ADD CPP /Yu
# End Source File
# Begin Source File

SOURCE=..\Inc\UnConn.h
# End Source File
# Begin Source File

SOURCE=.\UnDemoPenLev.cpp
# End Source File
# Begin Source File

SOURCE=..\Inc\UnDemoPenLev.h
# End Source File
# Begin Source File

SOURCE=.\UnDemoRec.cpp
# End Source File
# Begin Source File

SOURCE=..\Inc\UnDemoRec.h
# End Source File
# Begin Source File

SOURCE=..\Inc\UnNet.h
# End Source File
# Begin Source File

SOURCE=.\UnNetDrv.cpp
# End Source File
# Begin Source File

SOURCE=..\Inc\UnNetDrv.h
# End Source File
# Begin Source File

SOURCE=.\UnPenLev.cpp
# End Source File
# Begin Source File

SOURCE=..\Inc\UnPenLev.h
# End Source File
# End Group
# Begin Group "Bink"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\Inc\BINK.H
# End Source File
# Begin Source File

SOURCE=..\Lib\binkw32.lib
# End Source File
# End Group
# Begin Group "Smacker"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\Inc\rad.h
# End Source File
# Begin Source File

SOURCE=..\Inc\smack.h
# End Source File
# Begin Source File

SOURCE=..\Lib\smackw32.lib
# End Source File
# End Group
# Begin Group "SapiSDK"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Buildnum.h
# End Source File
# Begin Source File

SOURCE=.\Spchtel.h
# End Source File
# Begin Source File

SOURCE=.\Spchwrap.h
# End Source File
# Begin Source File

SOURCE=.\Speech.h
# End Source File
# Begin Source File

SOURCE=..\Lib\Spchwrap.lib
# End Source File
# End Group
# Begin Group "Int"

# PROP Default_Filter "*.int"
# Begin Source File

SOURCE=..\..\System\Engine.int
# End Source File
# End Group
# Begin Group "Window Src"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\Window\Src\Window.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# End Group
# Begin Group "Window Inc"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\Window\Inc\Window.h
# End Source File
# End Group
# Begin Group "WinDrv Src"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\WinDrv\Src\WinClient.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\WinDrv\Src\WinDrv.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\WinDrv\Src\WinViewport.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# End Group
# Begin Group "WinDrv Inc"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\WinDrv\inc\WinDrv.h
# End Source File
# End Group
# Begin Group "IpDrv Src"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\IpDrv\Src\InternetLink.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Src\TcpLink.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Src\TcpNetDriver.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Src\UdpLink.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Src\UMasterServerCommandlet.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Src\UnSocket.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Src\UnSocket.h
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Src\UUpdateServerCommandlet.cpp
# ADD CPP /Yu"..\..\Engine\Src\EnginePrivate.h"
# End Source File
# End Group
# Begin Group "IpDrv Inc"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\IpDrv\Inc\AInternetLink.h
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Inc\ATcpLink.h
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Inc\AUdpLink.h
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Inc\GameSpyClasses.h
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Inc\GameSpyClassesPublic.h
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Inc\IpDrvClasses.h
# End Source File
# End Group
# Begin Group "IPDrv Classes"

# PROP Default_Filter "uc"
# Begin Source File

SOURCE=..\..\IpDrv\Classes\ClientBeaconReceiver.uc
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Classes\InternetLink.uc
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Classes\TcpLink.uc
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Classes\UdpBeacon.uc
# End Source File
# Begin Source File

SOURCE=..\..\IpDrv\Classes\UdpLink.uc
# End Source File
# End Group
# Begin Group "IPServer Classes"

# PROP Default_Filter "uc"
# Begin Source File

SOURCE=..\..\IpServer\Classes\UdpServerQuery.uc
# End Source File
# Begin Source File

SOURCE=..\..\IpServer\Classes\UdpServerUplink.uc
# End Source File
# End Group
# Begin Source File

SOURCE=.\res\EngineRes.rc
# End Source File
# Begin Source File

SOURCE=..\Lib\s3tc.lib
# End Source File
# End Target
# End Project
