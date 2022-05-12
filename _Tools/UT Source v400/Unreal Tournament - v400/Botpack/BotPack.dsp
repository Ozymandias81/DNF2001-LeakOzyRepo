# Microsoft Developer Studio Project File - Name="BotPack" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=BotPack - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "BotPack.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "BotPack.mak" CFG="BotPack - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "BotPack - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "BotPack - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Unreal/Botpack", KGHAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "BotPack - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_USRDLL" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MTd /W3 /Gm /ZI /Od /D "_WINDOWS" /D "_USRDLL" /D "_DEBUG" /D "WIN32" /D "UNICODE" /D "_UNICODE" /Yu"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# Begin Custom Build - Registering ActiveX Control...
OutDir=.\Debug
TargetPath=.\Debug\BotPack.dll
InputPath=.\Debug\BotPack.dll
SOURCE="$(InputPath)"

"$(OutDir)\regsvr32.trg" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	regsvr32 /s /c "$(TargetPath)" 
	echo regsvr32 exec. time > "$(OutDir)\regsvr32.trg" 
	
# End Custom Build

!ELSEIF  "$(CFG)" == "BotPack - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "BotPack___Win32_Release"
# PROP BASE Intermediate_Dir "BotPack___Win32_Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "BotPack\Lib"
# PROP Intermediate_Dir "BotPack\Src\Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_USRDLL" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MTd /W3 /Gm /ZI /Od /D "_DEBUG" /D "_WINDOWS" /D "_USRDLL" /D "WIN32" /D "UNICODE" /D "_UNICODE" /FR /Yu"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# Begin Custom Build - Registering ActiveX Control...
OutDir=.\BotPack\Lib
TargetPath=.\BotPack\Lib\BotPack.dll
InputPath=.\BotPack\Lib\BotPack.dll
SOURCE="$(InputPath)"

"$(OutDir)\regsvr32.trg" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	regsvr32 /s /c "$(TargetPath)" 
	echo regsvr32 exec. time > "$(OutDir)\regsvr32.trg" 
	
# End Custom Build

!ENDIF 

# Begin Target

# Name "BotPack - Win32 Debug"
# Name "BotPack - Win32 Release"
# Begin Group "Classes"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\AlternatePath.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Arena.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ArenaCam.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Armor2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ArrowStud.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ASDefaultMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ASMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Assault.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\AssaultHUD.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\AssaultInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\AssaultRandomizer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\AssaultScoreboard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\AssaultTrophy.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Barrel1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Barrel2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Barrel3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BigEnergyImpact.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BigSprocket.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Bin2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Bin3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BioAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BioFear.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BioGlob.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\biomark.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BioSplash.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BladeHopper.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BlastMark.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BlockedPath.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BloodSplat.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BlueTapestry.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BoltScorch.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Bot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BotReplicationInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Boulder1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Boulder2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BoulderSpawner.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Brazier.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Brick.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletBox.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletImpact.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CannonMuzzle.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CannonShot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CapitalU.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Car01.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Car02.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Car03.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Carflash.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CatapultRock.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CeilingGunBase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CH_Earthquake.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChainSaw.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChainsawMelee.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Challenge.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChallengeBotInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChallengeCTFHUD.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChallengeDMP.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChallengeDominationHUD.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChallengeHUD.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChallengeIntro.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChallengeTeamHUD.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChallengeVoicePack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CHEOLHUD.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CHNullHUD.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CHSpectator.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CHSpectatorHUD.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChunkTrail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CircleStud.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ClientScriptedTexture.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Commander.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ControlPoint.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ControlPointMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CriticalEventLowPlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CriticalEventPlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CriticalStringPlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Crystal.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CTFDefaultMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CTFFlag.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CTFGame.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CTFMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CTFMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CTFMessage2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CTFReplicationInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CTFTrophy.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CubeGem.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DeathMatchMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DeathMatchPlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DeathMatchTrophy.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DeathMessagePlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DecapitationMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DefensePoint.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Diamond.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DirectionalBlast.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DiscStud.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DistanceViewTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DMMutator.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DOMDefaultMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Domination.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DominationScoreboard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DominationTrophy.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DOMMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Door.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DoubleEnforcer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Earth.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Earth2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EClip.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EndStats.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EnergyImpact.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Enforcer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EnhancedRespawn.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EradicatedDeathMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FadeShadow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FadeViewTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FastSprocket.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FatBoy.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FemaleBotPlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Fighter.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Fighter2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FirstBloodMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FlagBase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FlakAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FlakArena.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\flakslug.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FlatMirror.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FontInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FortStandard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\GoldFlag.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\GoldTapestry.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\GrBase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\GreenBloodSpray.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\GreenFlag.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\GreenTapestry.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\GuidedWarshell.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HealthPack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HealthVial.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HoldSpot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HumanBotPlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ICBM.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ImpactHammer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ImpactHole.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ImpactMark.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\InstaGibDM.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\InstantRockets.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\IntroBoss.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\IntroDude.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ItemMessagePlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\JumpMatch.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\JumpSpot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Kicker.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\KillerMessagePlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\KillingField.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\KillingSpreeMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Ladder.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderAS.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderChal.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderCTF.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderCTFDemo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderDM.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderDMDemo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderDOM.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderDOMDemo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderInventory.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderLoadGame.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderNewGame.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LadderTransition.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LastManStanding.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LightBox.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LightCone.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LightSmokeTrail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LMSOutMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LMSScoreboard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LocalMessagePlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LowGrav.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MaleBotPlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MedBox.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MiniAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Minigun2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MinigunArena.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MinigunCannon.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MiniShellCase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MortarShell.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MortarSpawner.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MTracer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MultiKillMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\NoPowerups.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\NoRedeemer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\NuclearMark.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\OctGem.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\OctStud.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PainPath.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PBolt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PickupMessageHealthPlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PickupMessagePlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Pillar.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Pipe.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PipeBend.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PlainBar.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PlainStud.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PlasmaCap.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PlasmaEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PlasmaHit.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PlasmaSphere.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PlayerShadow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Pock.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Pot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PressureZone.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PulseArena.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PulseGun.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Pylon.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\QuakeCam.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchAS1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchAS2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchAS3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchAS4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchAS5.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchAS6.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchASTUT.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchChal1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchChal2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchChal3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchChal4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchCTF1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchCTF2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchCTF3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchCTF4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchCTF5.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchCTF6.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchCTF7.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchCTF8.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchCTF9.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchCTFDemo1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchCTFTUT.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM10.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM11.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM12.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM13.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM5.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM6.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM7.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM8.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDM9.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDMDemo1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDMDemo2.uc
# End Source File
# Begin Source File

SOURCE=.\classes\RatedMatchDMDemo3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDMDemo4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDMTUT.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOM1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOM10.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOM2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOM3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOM4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOM5.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOM6.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOM7.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOM8.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOM9.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOMDemo1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchDOMTut.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedMatchInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedTeamInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedTeamInfo1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedTeamInfo2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedTeamInfo3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedTeamInfo4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedTeamInfo5.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedTeamInfo6.uc
# End Source File
# Begin Source File

SOURCE=.\classes\RatedTeamInfoDemo1.uc
# End Source File
# Begin Source File

SOURCE=.\classes\RatedTeamInfoDemo2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RatedTeamInfoS.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Razor2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Razor2Alt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RectMirror.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Redeemertrail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RedFlag.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RedSayMessagePlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RedTapestry.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RifleShell.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Rim.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Ripper.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RipperMark.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RipperPulse.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RocketArena.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RocketMk2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RocketPack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RocketTrail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RockingSkyZoneInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SawHit.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SayMessagePlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Scorch.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ScrollingMessageTexture.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SelectionDude.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ServerInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ServerInfoAS.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ServerInfoCTF.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ServerInfoDOM.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ServerInfoTeam.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Shell.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Shieldd.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShockArena.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShockBeam.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShockBeam2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShockCore.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShockExplo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShockProj.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShockRifle.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShockrifleWave.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShockWave.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SkaarjBot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SniperArena.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SniperRifle.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SpectatorCam.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SquareMirror.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SquareStud.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\StarterBolt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\StationaryPawn.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Stealth.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\StringMessagePlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\StudMetal.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Stukka.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\supershockbeam.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SuperShockCore.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SuperShockExplo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SuperShockRifle.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TargetShadow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TBoss.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TBossBot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TBossCarcass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TBossMasterChunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TDarkMatch.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TDKDefaultMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TDKMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TDMDefaultMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TDMLargeMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TDMmaplist.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TDMMediumMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TDMSmallMapList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TeamCannon.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TeamGamePlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TeamSayMessagePlus.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TeamScoreboard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TeamTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TFemale1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TFemale1Bot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TFemale1Carcass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TFemale2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TFemale2Bot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TFemale2Carcass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TFemaleBody.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TFemaleMasterChunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ThighPads.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TimedTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TimeMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TMale1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TMale1Bot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TMale1Carcass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TMale2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TMale2Bot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TMale2Carcass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TMaleBody.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TMaleMasterChunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ToolBox.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TournamentAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TournamentConsole.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TournamentFemale.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TournamentGameInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TournamentGameReplicationInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TournamentHealth.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TournamentMale.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TournamentPickup.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TournamentPlayer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TournamentScoreboard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TournamentWeapon.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TrainingAS.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TrainingCTF.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TrainingDM.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TrainingDOM.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Translocator.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TranslocatorTarget.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TranslocBLue.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TranslocDest.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TranslocGlow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TranslocGold.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TranslocGreen.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TranslocOutEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TranslocStart.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TrapSpringer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriggeredTexture.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriStud.uc
# End Source File
# Begin Source File

SOURCE=.\classes\Trophy.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TrophyDude.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TrophyGame.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TubeLight.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TubeLight2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\U.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UDamage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UnrealCTFScoreboard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_BigBloodHit.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_BioGel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_BioRifle.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_BlackSmoke.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_Blood2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_BloodBurst.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_BloodDrop.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_BloodHit.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_BloodPuff.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_BloodTrail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ut_bossarm.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ut_bosshead.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ut_bossthigh.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_ComboRing.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_Decoration.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_Eightball.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_FemaleArm.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_FemaleFoot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_FemaleTorso.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_FlakCannon.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_FlameExplosion.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_GreenBlob.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_GreenBloodPuff.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_GreenGelPuff.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_GreenSmokePuff.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_Grenade.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_HeadFemale.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_HeadMale.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_HeavyWallHitEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_invisibility.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_Jumpboots.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_LightWallHitEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_MaleArm.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_MaleFoot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_MaleTorso.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_RingExplosion.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_RingExplosion3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_RingExplosion4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_RingExplosion5.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_SeekingRocket.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_ShellCase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_ShieldBelt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_ShieldBeltEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_ShortSmokeGen.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_Spark.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_Sparks.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_SpriteBallChild.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_SpriteBallExplosion.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_SpriteSmokePuff.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_Stealth.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ut_superring.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_Superring2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_Thigh.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UT_WallHit.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTBanner.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTBloodPool.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTBloodPool2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTChunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTChunk1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTChunk2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTChunk3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTChunk4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTCreatureChunks.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTFlakShell.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTFlare.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTHeads.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTHeart.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTHumanCarcass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTIntro.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTLiver.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTMasterCreatureChunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTPlayerChunks.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTSmokeTrail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTStatLogFile.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTStomach.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTTeleEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\UTTeleportEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VacuumZone.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VictimMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VisibleTeleporter.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VoiceBoss.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VoiceBotBoss.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VoiceFemale.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VoiceFemaleOne.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VoiceFemaleTwo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VoiceMale.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VoiceMaleOne.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VoiceMaleTwo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\WallCrack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\WarExplosion.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\WarExplosion2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\WarHeadAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\WarheadLauncher.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\WarShell.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Wreck1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Wreck2.uc
# End Source File
# End Group
# End Target
# End Project
