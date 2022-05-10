# Microsoft Developer Studio Project File - Name="dnParticles" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=dnParticles - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "dnParticles.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "dnParticles.mak" CFG="dnParticles - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "dnParticles - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "dnParticles - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "dnParticles - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNPARTICLES_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNPARTICLES_EXPORTS" /YX /FD /c
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

!ELSEIF  "$(CFG)" == "dnParticles - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNPARTICLES_EXPORTS" /YX /FD /GZ  /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNPARTICLES_EXPORTS" /YX /FD /GZ  /c
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

# Name "dnParticles - Win32 Release"
# Name "dnParticles - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat;uc"
# Begin Source File

SOURCE=.\Classes\dnBlood_Spurt1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnComputerFX.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDroneJet_ConTrail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDroneJet_GibFire.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDroneJet_GibFire2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDroneJet_GibSmoke.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDroneJet_WingLight1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDroneJet_WingLight2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnEDFGameExplosion.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnEDFGExplosion_Effect1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion1_Effect1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion1_Effect2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion1_Effect3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion1_Effect4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion1_Spawner1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion1_Spawner2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion1_Spawner3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion2_Effect1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion2_Effect2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion2_Effect3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion2_Effect4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion2_Spawner1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosion2_Spawner2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnExplosiveBarrelFire.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnFireEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnHRocket2trail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnJetski_Splash1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnJetski_Trail1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnLensFlares.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnM16GrenadeTrail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMissileTrail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMuzzleFX.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMuzzleM16.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMuzzleM16Angle.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMuzzleM16Smoke.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMuzzlePistol.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMuzzlePistolSmoke.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMuzzlePistolSmoke2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMuzzleShotgun.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMuzzleShotgunSmoke.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnMuzzleShotgunSmoke2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnParachuteBombExplosion.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnPBomb_Effect1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnPBomb_Effect3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnShellCaseMaster.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnShrinkFluff.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnShrinkLightning.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnShrinkStream.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnShrinkWave.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnSmokeEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnSparkEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnSparkEffect_Effect1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnSparkEffect_Effect2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnSparkEffect_Effect3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnSparkEffect_Effect4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnSparkEffect_Spawner1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnSparkEffect_Spawner2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWall_Ice.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallConcrete.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallConcreteSpark.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallDirt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallDust.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallFabric.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallFreezeRay.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallFX.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallGlass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallGravel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallLeaves.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallOil.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallOilDrip.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallPopcorn.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallShrinkRay.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallSmoke.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallSpark.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallSteam.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallSteam2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallWater.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallWaterSplash.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWallWood.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWater1_Splash.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWater1_Spray.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWaterSplash_Effect1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWaterSpray_Effect1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWaterSpray_Effect2.uc
# End Source File
# End Group
# End Target
# End Project
