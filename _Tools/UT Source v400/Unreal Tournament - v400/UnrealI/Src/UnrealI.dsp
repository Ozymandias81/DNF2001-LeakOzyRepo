# Microsoft Developer Studio Project File - Name="UnrealI" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=UnrealI - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "UnrealI.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "UnrealI.mak" CFG="UnrealI - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "UnrealI - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "UnrealI - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Unreal", QBCAAAAA"
# PROP Scc_LocalPath "..\.."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "UnrealI - Win32 Release"

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
# ADD CPP /nologo /Zp4 /MD /W4 /WX /vd0 /GX /O2 /Ob2 /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /I "..\Inc" /D "NDEBUG" /D "_WINDOWS" /D "UNICODE" /D "_UNICODE" /D "WIN32" /YX /FD /D /Zm256 PACKAGE="\"UnrealI"\" /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 ..\..\Core\Lib\Core.lib ..\..\Engine\Lib\Engine.lib /nologo /base:"0x10700000" /subsystem:windows /dll /machine:I386
# SUBTRACT LINK32 /incremental:yes

!ELSEIF  "$(CFG)" == "UnrealI - Win32 Debug"

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
# ADD CPP /nologo /Zp4 /MDd /W4 /WX /Gm /vd0 /GX /ZI /Od /I "..\..\Core\Inc" /I "..\..\Engine\Inc" /I "..\Inc" /D "_WINDOWS" /D "UNICODE" /D "_UNICODE" /D "_DEBUG" /D "WIN32" /YX /FD /D /Zm256 PACKAGE="\"UnrealI"\" /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 ..\..\Core\Lib\Core.lib ..\..\Engine\Lib\Engine.lib /nologo /base:"0x10900000" /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "UnrealI - Win32 Release"
# Name "UnrealI - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter "*.uc"
# Begin Source File

SOURCE=..\Classes\AsbestosSuit.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Behemoth.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\BigRock.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Bloblet.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Boulder1.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\BulletHit.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Burned.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Cannon.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\CannonBolt.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Chair.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Chunk.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Chunk1.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Chunk2.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Chunk3.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Chunk4.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\CloudZone.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\CodeMaster.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\CodeTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Corroded.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Cryopod.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Dampener.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DarkMatch.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Decapitated.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Dice.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DistanceLightning.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\DKmaplist.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Drowned.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ElevatorMover.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ElevatorTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\EliteKrallBolt.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\EndGame.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\EndgameHud.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\EnergyBolt.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\EscapePod.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FatnessTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Fell.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FemaleTwo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FemaleTwoBot.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FemaleTwoCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Flag1.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Flag2.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Flag3.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Flagb.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FlakBox.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FlakCannon.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FlakShell.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\FlakShellAmmo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ForceField.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ForceFieldProj.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Gasbag.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\GasBagBelch.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\GassiusCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\GESBioRifle.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\GiantGasbag.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\GiantManta.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\GradualMover.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\HugeCannon.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\IceSkaarj.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Intro.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\IntroNullHud.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\IntroShip.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\invisibility.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\JumpBoots.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\KingOfTheHill.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\KraalBolt.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Krall.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\KrallCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\KrallElite.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Lamp1.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Lamp4.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\LeglessKrall.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\LoopMover.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Magma.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MagmaBurst.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MaleOne.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MaleOneBot.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MaleOneCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MaleTwo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MaleTwoBot.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MaleTwoCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MasterChunk.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MercCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Mercenary.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MercenaryElite.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MercFlare.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MercRocket.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Minigun.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\MixMover.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Moon.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Moon2.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Moon3.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\naliplayer.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\NitrogenZone.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\OverHeatLight.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\parentBlob.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PeaceRocket.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PowerShield.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Pupae.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\PupaeCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\QuadShot.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Queen.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\QueenCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\QueenDest.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\QueenProjectile.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\QueenShield.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\QueenTeleportEffect.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\QueenTeleportLight.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RazorAmmo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RazorBlade.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RazorBladeAlt.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RazorJack.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Rifle.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RifleAmmo.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RifleRound.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Robot.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\RockSlide.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SearchLight.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Seeds.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\skaarjassassin.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SkaarjBerserker.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SkaarjGunner.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SkaarjInfantry.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SkaarjLord.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SkaarjOfficer.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\skaarjplayer.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SkaarjPlayerBot.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SkaarjSniper.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SkaarjTrooper.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Sludge.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SludgeBarrel.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Squid.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\SquidCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\StoneTitan.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Table.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Tapestry1.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TarZone.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Titan.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\TitanCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\ToxinSuit.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Tracer.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\troopercarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UnrealDamageType.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\Warlord.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\WarlordCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\WarlordRocket.uc
# End Source File
# End Group
# Begin Group "Int"

# PROP Default_Filter "*.int"
# Begin Source File

SOURCE=..\..\System\UnrealI.int
# End Source File
# End Group
# End Target
# End Project
