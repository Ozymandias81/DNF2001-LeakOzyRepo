# Microsoft Developer Studio Project File - Name="UnrealShare" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=UnrealShare - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "UnrealShare.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "UnrealShare.mak" CFG="UnrealShare - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "UnrealShare - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "UnrealShare - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Unreal/UnrealShare/Src", ODIAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "UnrealShare - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /ZI /Od /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "UNICODE" /D "_UNICODE" /D "_DEBUG" /D "WIN32" /Yu"stdafx.h" /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# Begin Custom Build - Performing registration
OutDir=.\Debug
TargetPath=.\Debug\UnrealShare.dll
InputPath=.\Debug\UnrealShare.dll
SOURCE="$(InputPath)"

"$(OutDir)\regsvr32.trg" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	regsvr32 /s /c "$(TargetPath)" 
	echo regsvr32 exec. time > "$(OutDir)\regsvr32.trg" 
	
# End Custom Build

!ELSEIF  "$(CFG)" == "UnrealShare - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "UnrealShare___Win32_Release"
# PROP BASE Intermediate_Dir "UnrealShare___Win32_Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "UnrealShare___Win32_Release"
# PROP Intermediate_Dir "UnrealShare___Win32_Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /ZI /Od /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "WIN32" /D "_DEBUG" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /ZI /Od /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "_DEBUG" /D "UNICODE" /D "_UNICODE" /D "WIN32" /Yu"stdafx.h" /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# Begin Custom Build - Performing registration
OutDir=.\UnrealShare___Win32_Release
TargetPath=.\UnrealShare___Win32_Release\UnrealShare.dll
InputPath=.\UnrealShare___Win32_Release\UnrealShare.dll
SOURCE="$(InputPath)"

"$(OutDir)\regsvr32.trg" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	regsvr32 /s /c "$(TargetPath)" 
	echo regsvr32 exec. time > "$(OutDir)\regsvr32.trg" 
	
# End Custom Build

!ENDIF 

# Begin Target

# Name "UnrealShare - Win32 Debug"
# Name "UnrealShare - Win32 Release"
# Begin Group "Classes"

# PROP Default_Filter "*.uc"
# Begin Source File

SOURCE=..\classes\AlarmPoint.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Amplifier.uc
# End Source File
# Begin Source File

SOURCE=..\classes\AnimSpriteEffect.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Arc.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Arm1.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Armor.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Arrow.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ArrowSpawner.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ASMD.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ASMDAmmo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\AssertMover.uc
# End Source File
# Begin Source File

SOURCE=..\classes\AttachMover.uc
# End Source File
# Begin Source File

SOURCE=..\classes\AutoMag.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BabyCow.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BabyCowCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BallExplosion.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Bandages.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Barrel.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BarrelSludge.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BigBiogel.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BigBlackSmoke.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Biodrop.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Biogel.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Bird1.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BiterFish.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BiterFishSchool.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BlackSmoke.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Blood2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BloodBurst.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BloodPool.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BloodPuff.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BloodSpray.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BloodSpurt.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BloodTrail.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BlueBook.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Book.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BotInfo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Bots.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Boulder.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BreakingGlass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Brute.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BruteCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BruteProjectile.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Bubble.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Bubble1.uc
# End Source File
# Begin Source File

SOURCE=..\classes\BubbleGenerator.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Candle.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Candle2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\CaveManta.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ChargeLight.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Chest.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Chip.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Clip.uc
# End Source File
# Begin Source File

SOURCE=..\classes\CoopGame.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Cow.uc
# End Source File
# Begin Source File

SOURCE=..\classes\CowCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\CreatureCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\CreatureChunks.uc
# End Source File
# Begin Source File

SOURCE=..\classes\CreatureFactory.uc
# End Source File
# Begin Source File

SOURCE=..\classes\CrucifiedNali.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DAmmo2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DAmmo3.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DAmmo4.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DAmmo5.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DeadBodySwarm.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DeadChairMale.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DeadMales.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DeathMatchGame.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DefaultAmmo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DefaultBurst.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DefaultBurstAlt.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Devilfish.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DevilfishCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DExplosion.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DispersionAmmo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DispersionPistol.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DMmaplist.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Drip.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DripGenerator.uc
# End Source File
# Begin Source File

SOURCE=..\classes\DynamicAmbientSound.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Earthquake.uc
# End Source File
# Begin Source File

SOURCE=..\classes\EffectLight.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Eightball.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Electricity.uc
# End Source File
# Begin Source File

SOURCE=..\classes\EnergyBurst.uc
# End Source File
# Begin Source File

SOURCE=..\classes\EntryGameInfo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ExplodingWall.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ExplosionChain.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Fan2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FatRing.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FavoritesTeleporter.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FearSpot.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Female.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Female2Body.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FemaleBody.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FemaleBot.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FemaleHead.uc
# End Source File
# Begin Source File

SOURCE=..\classes\femalemasterchunk.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FemaleOne.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FemaleOneBot.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FemaleOneCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FemaleTorso.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Flame.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FlameBall.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FlameExplosion.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Flare.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Flashlight.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FlashLightBeam.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FlockMasterPawn.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FlockPawn.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Fly.uc
# End Source File
# Begin Source File

SOURCE=..\classes\FlyCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Fragment1.uc
# End Source File
# Begin Source File

SOURCE=..\classes\GlassFragments.uc
# End Source File
# Begin Source File

SOURCE=..\classes\GreenBlob.uc
# End Source File
# Begin Source File

SOURCE=..\classes\GreenBloodPuff.uc
# End Source File
# Begin Source File

SOURCE=..\classes\GreenBook.uc
# End Source File
# Begin Source File

SOURCE=..\classes\GreenGelPuff.uc
# End Source File
# Begin Source File

SOURCE=..\classes\GreenSmokePuff.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Grenade.uc
# End Source File
# Begin Source File

SOURCE=..\classes\GuardPoint.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Health.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HeavyWallHitEffect.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HorseFly.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HorseFlySwarm.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Human.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HumanBot.uc
# End Source File
# Begin Source File

SOURCE=..\classes\HumanCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\InfoMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\InterpolatingObject.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Jumper.uc
# End Source File
# Begin Source File

SOURCE=..\classes\KevlarSuit.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Knife.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Lantern.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Lantern2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\LavaZone.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Leg1.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Leg2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\LesserBrute.uc
# End Source File
# Begin Source File

SOURCE=..\classes\LesserBruteCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\LightWallHitEffect.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Liver.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MakeNaliFriendly.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Male.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MaleBody.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MaleBodyThree.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MaleBodyTwo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MaleBot.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MaleHead.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MaleMasterChunk.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MaleThree.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MaleThreeBot.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MaleThreeCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Manta.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MantaCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MasterCreatureChunk.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MedWoodBox.uc
# End Source File
# Begin Source File

SOURCE=..\classes\MonkStatue.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Nali.uc
# End Source File
# Begin Source File

SOURCE=..\classes\NaliCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\NaliFruit.uc
# End Source File
# Begin Source File

SOURCE=..\classes\NaliMasterChunk.uc
# End Source File
# Begin Source File

SOURCE=..\classes\NaliPriest.uc
# End Source File
# Begin Source File

SOURCE=..\classes\NaliRabbit.uc
# End Source File
# Begin Source File

SOURCE=..\classes\NaliStatue.uc
# End Source File
# Begin Source File

SOURCE=..\classes\NullAmmo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ObjectPath.uc
# End Source File
# Begin Source File

SOURCE=..\classes\OKMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Panel.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ParticleBurst.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ParticleBurst2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\PathPoint.uc
# End Source File
# Begin Source File

SOURCE=..\classes\PawnTeleportEffect.uc
# End Source File
# Begin Source File

SOURCE=..\classes\PHeart.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Plant1.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Plant2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Plant3.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Plant4.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Plant5.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Plant6.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Plant7.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Plasma.uc
# End Source File
# Begin Source File

SOURCE=..\classes\PlayerChunks.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Pottery0.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Pottery1.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Pottery2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\PurpleLight.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ReSpawn.uc
# End Source File
# Begin Source File

SOURCE=..\classes\RingExplosion.uc
# End Source File
# Begin Source File

SOURCE=..\classes\RingExplosion2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\RingExplosion3.uc
# End Source File
# Begin Source File

SOURCE=..\classes\RingExplosion4.uc
# End Source File
# Begin Source File

SOURCE=..\classes\RisingSpriteSmokePuff.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Rocket.uc
# End Source File
# Begin Source File

SOURCE=..\classes\RocketCan.uc
# End Source File
# Begin Source File

SOURCE=..\classes\RotatingMover.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Sconce.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ScriptedPawn.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SCUBAGear.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SeaWeed.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SeekingRocket.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Shellbox.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ShellCase.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Shells.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Shield.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ShieldBelt.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ShieldBeltEffect.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ShortSmokeGen.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SightLight.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Sign1.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SilentBallExplosion.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SinglePlayer.Uc
# End Source File
# Begin Source File

SOURCE=..\classes\Skaarj.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SkaarjCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SkaarjMasterChunk.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SkaarjProjectile.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SkaarjScout.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SkaarjWarrior.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SlimeZone.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Slith.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SlithCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SlithProjectile.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmallSpark.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmallSpark2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmallSteelBox.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmallWire.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmallWoodBox.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmokeColumn.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmokeExplo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmokeGenerator.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmokeHose.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmokeHoseDest.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmokePuff.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SmokeTrail.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Spark3.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Spark32.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Spark33.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Spark34.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Spark35.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SparkBit.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Sparks.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Spawnpoint.uc
# End Source File
# Begin Source File

SOURCE=..\classes\spectatorhud.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpikeExplosion.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Splash.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpriteBallChild.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpriteBallExplosion.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpriteBlueExplo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpriteExplosion.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpriteGreenE.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpriteLightning.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpriteOrangeE.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpriteRedE.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpriteSmokePuff.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SpriteYellowE.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SteelBarrel.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SteelBox.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Stinger.uc
# End Source File
# Begin Source File

SOURCE=..\classes\StingerAmmo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\StingerProjectile.uc
# End Source File
# Begin Source File

SOURCE=..\classes\StochasticTrigger.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Stomach.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Suits.uc
# End Source File
# Begin Source File

SOURCE=..\classes\SuperHealth.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TarydiumBarrel.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tazerexplosion.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TazerProj.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TeamGame.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TeamInfo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TeleporterZone.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tentacle.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TentacleCarcass.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TentacleProjectile.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Thigh.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ThingFactory.uc
# End Source File
# Begin Source File

SOURCE=..\classes\thrownbody.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ThrowStuff.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TinyBurst.uc
# End Source File
# Begin Source File

SOURCE=..\classes\ToggleZoneInfo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TorchFlame.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Translator.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TranslatorEvent.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Transporter.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree1.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree10.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree11.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree12.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree2.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree3.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree4.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree5.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree6.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree7.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree8.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Tree9.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TriggeredAmbientSound.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TriggeredDeath.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TriggerLight.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TriggerLightRad.uc
# End Source File
# Begin Source File

SOURCE=..\classes\TSmoke.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealBotConfigMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealChooseGameMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealCoopGameOptions.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealDMGameOptionsMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealFavoritesMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealGameInfo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealGameMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealGameOptionsMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealHelpMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealHUD.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealIndivBotMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealInfoMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealIPlayer.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealJoinGameMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealKeyboardMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealListenMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealListMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealLoadMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealLongMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealMainMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealMeshMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealMultiPlayerMenu.uc
# End Source File
# Begin Source File

SOURCE=..\Classes\UnrealMultiplayerMeshMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealNewGameMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealOptionsMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealPlayerMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealQuitMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealSaveMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealScoreBoard.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealServerMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealShortMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealSlotMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealSpectator.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealTeamGameOptionsMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealTeamHUD.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealTeamScoreBoard.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealTestInfo.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealVideoMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UnrealWeaponMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\UpgradeMenu.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Urn.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Vase.uc
# End Source File
# Begin Source File

SOURCE=..\classes\VoiceBox.uc
# End Source File
# Begin Source File

SOURCE=..\classes\VRikersGame.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WallFragments.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WallHitEffect.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WaterImpact.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WaterRing.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WaterZone.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WeaponLight.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WeaponPowerUp.uc
# End Source File
# Begin Source File

SOURCE=..\classes\Wire.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WoodenBox.uc
# End Source File
# Begin Source File

SOURCE=..\classes\WoodFragments.uc
# End Source File
# Begin Source File

SOURCE=..\classes\YellowBook.uc
# End Source File
# Begin Source File

SOURCE=..\classes\YesNoMenu.uc
# End Source File
# End Group
# End Target
# End Project
