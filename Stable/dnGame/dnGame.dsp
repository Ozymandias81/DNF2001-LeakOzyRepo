# Microsoft Developer Studio Project File - Name="dnGame" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=dnGame - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "dnGame.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "dnGame.mak" CFG="dnGame - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "dnGame - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "dnGame - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Duke4_UT400/dnGame", TRLAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "dnGame - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNGAME_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNGAME_EXPORTS" /YX /FD /c
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

!ELSEIF  "$(CFG)" == "dnGame - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNGAME_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "DNGAME_EXPORTS" /YX /FD /GZ /c
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

# Name "dnGame - Win32 Release"
# Name "dnGame - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter ".uc"
# Begin Group "Deathmatch"

# PROP Default_Filter ".uc"
# Begin Group "Team"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\dnTeamGame.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnTeamGame_Bomb.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnTeamGame_LMS.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnTeamInfo.uc
# End Source File
# End Group
# Begin Group "Messages"

# PROP Default_Filter "uc"
# Begin Source File

SOURCE=.\Classes\dnBombMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDeathmatchMessage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnDeathMessage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnFirstBloodMessage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnKillerMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnPrivateMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnSayMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnTeamGameMessage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnVictimMessage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LightShadows.uc
# End Source File
# End Group
# Begin Group "DM HUD"

# PROP Default_Filter "uc"
# Begin Source File

SOURCE=.\classes\dnDeathmatchGameHUD.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnTeamGameHUD.uc
# End Source File
# End Group
# Begin Group "Scoreboards"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\classes\dnDeathmatchGameScoreboard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnTeamGameScoreboard.uc
# End Source File
# End Group
# Begin Group "Bughunt Classes"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\BUG_209_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BUG_AttackDog_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BUG_Captain_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BUG_Flamer_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BUG_Freezer_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BUG_Grunt_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BUG_Octabrain_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BUG_Sapper_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BUG_Sniper_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BUG_Soldier_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EDF_209_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EDF_AttackDog_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EDF_Captain_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EDF_Flamer_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EDF_Freezer_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EDF_Grunt_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EDF_Sapper_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EDF_Sniper_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EDF_Soldier_Player.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\OctaPlayer.uc
# End Source File
# End Group
# Begin Source File

SOURCE=.\classes\dnDeathmatchGame.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnDeathmatchGameReplicationInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnRespawnMarker.uc
# End Source File
# End Group
# Begin Group "HUD"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\Classes\DukeHUD.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HUDIndexItem_ActorHealth.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Air.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_AltAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_AltMultiAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Ammo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Bomb.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Cash.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Chainsaw.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Credits.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HUDIndexItem_DecoHealth.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_DefuseBomb.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_DMFrags.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_EGO.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Energy.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HUDIndexItem_Flamethrower.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HUDIndexItem_FlamethrowerAlt.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HUDIndexItem_Freezer.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HUDIndexItem_FreezerAlt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Hypo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_HypoAlt.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HUDIndexItem_Jetpack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_M16Gun.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_M16GunAlt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_MultiBomb.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_MultiBombAlt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Pistol.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_PistolAlt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Prompt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_RiotShield.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_RPG.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_RPGAlt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Shotgun.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_ShotgunAlt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_ShrinkRay.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_ShrinkRayAlt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_Sniper.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_SniperAlt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_TripMine.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HUDIndexItem_TripMineAlt.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HUDIndexItem_WeaponAltAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HUDIndexItem_WeaponAmmo.uc
# End Source File
# End Group
# Begin Group "Weapons"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\Classes\dnWeapon.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnWeaponNoMesh.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnWeaponNoMesh_Pistol.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DukeChainsaw.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Flamethrower.uc
# End Source File
# Begin Source File

SOURCE=.\classes\Freezer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HypoGun.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\M16.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MeleeWeapon.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MightyFoot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MultiBomb.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\OctaBlaster.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Pistol.uc
# End Source File
# Begin Source File

SOURCE=.\classes\Pistol_Gold.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RPG.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Shotgun.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Shrinkray.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SnatcherFace.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SniperRifle.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TripMine.uc
# End Source File
# End Group
# Begin Group "Decorations"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\Classes\AmmoCase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Barrel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BlueBook.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Book.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Boulder.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnBall.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnBoneRope.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDecoration.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDecorationBigFrag.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDecorationTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDriveableDecoration.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDriveableDecorationTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnLight.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnLight_FlashlightAmbient.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnLight_FlashlightBeam.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnPinBall.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnPinballBumper.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnPinBallTable.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnPoolBall.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnSwitchDecoration.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnThirdPersonShield.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnThirdPersonShieldBroken.uc
# End Source File
# Begin Source File

SOURCE=.\classes\G_Flashlight.uc
# End Source File
# Begin Source File

SOURCE=.\classes\G_FlashlightOff.uc
# End Source File
# Begin Source File

SOURCE=.\classes\JetpackAccessory.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MountableDecoration.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PlantedBomb.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SlotMachineBank.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\StretchCable.uc
# End Source File
# End Group
# Begin Group "InputDecorations"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\classes\AccessPad.uc
# End Source File
# Begin Source File

SOURCE=.\classes\AccessPad_Desk.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnEmailSystem.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnEmailSystemPrefab_Wall.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnKeyboardInput.uc
# End Source File
# Begin Source File

SOURCE=.\classes\ezAbsolv.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EZPhone.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EZPhone_Desk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EZPhoneEvent.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EZPhoneTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EZVendMachine.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EZVendMachine_Dirty.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\InputDecoration.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\InputDecorationTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\InversePuzzle.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\InversePuzzle_Desk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\KeyPad.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PowerPuzzle.uc
# End Source File
# Begin Source File

SOURCE=.\classes\PowerPuzzle_Desk.uc
# End Source File
# End Group
# Begin Group "Effects"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\AnimSpriteEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BoneStretchEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BreakingGlass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Bubble1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletWhiz.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CannonFlash.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CannonFlash2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DecalBomb.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnAlienBloodHit.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnAlienBloodPool.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnAlienBloodSplat.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnBloodHit.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnBloodPool.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnBloodSplat.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnFlameThrowerFX_NozzleFlame.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnFlameThrowerFX_Shrunk_NozzleFlame.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnFragment.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnFreezeRayFX_MainStream.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnFreezeRayFX_NozzleMist.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnFreezeRayFX_NozzleStream.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnFXSpawner.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnLaserBeam.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnLight_ProtonMonitor.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnMeshImmolation.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnOilHit.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnOilPool.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnOilSplat.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnPawnFreeze.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnPawnImmolation.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnPawnImmolation_AlienPig.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnPawnImmolation_EDFDog.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnPawnImmolation_Octabrain.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnPawnImmolation_PodProtector.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnPawnShrink.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWeaponFX.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWeaponFX_EMPSphere.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnWeaponFX_IceNukeSphere.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWeaponFX_NukeFire.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnWeaponFX_NukeSphere.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnWeaponFX_RPGFire.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EMPulse.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ExplodingWall.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ExplosionChain.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EyeBlinkEffect.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FlamethrowerCollisionActor.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FlamethrowerCollisionActorShrunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FlashEffects.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FreezerCollisionActor.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FrozenBlock.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FrozenBlockBody.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FrozenBlockLeftArm.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FrozenBlockLegs.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FrozenBlockRightArm.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HeadBomb.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LipSyncEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\M16Flash.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MimicRotationEffect.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PistolFlash.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Ricochet.uc
# End Source File
# Begin Source File

SOURCE=.\classes\RobotDamageSmokeA.uc
# End Source File
# Begin Source File

SOURCE=.\classes\RobotEye.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShotgunFlash.uc
# End Source File
# Begin Source File

SOURCE=.\classes\ShrinkRayBeamAnchor.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SmokeGenerator.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SniperPoint.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SpriteSmokePuff.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VertexMagnetEffect.uc
# End Source File
# End Group
# Begin Group "Chunks and Carcass"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\Chunk_EyeballA.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Chunk_FleshA.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Chunk_FleshB.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Chunk_FleshC.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Chunk_HandA.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Chunk_Head.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Chunk_OrganA.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Chunk_TorsoA.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CreatureChunks.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CreaturePawnCarcass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnCarcass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DukeMasterChunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DukePlayerCarcass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HumanMeshChunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HumanPawnCarcass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MasterCreatureChunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PlayerChunks.uc
# End Source File
# Begin Source File

SOURCE=.\classes\RobotMasterChunk.uc
# End Source File
# Begin Source File

SOURCE=.\classes\RobotMeshChunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RobotPawnCarcass.uc
# End Source File
# Begin Source File

SOURCE=.\classes\SnatcherMasterChunk.uc
# End Source File
# End Group
# Begin Group "Projectiles"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\Classes\BubbleTrail.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CloakedLaserMine.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnGrenade.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnGrenadeShrunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnHomingRocket.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnHomingTorpedo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnNuke.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnNukeShrunk.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnParachuteBomb.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnProjectile.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnRocket.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnRocket_BrainBlast.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnRocket_ShrinkBlast.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnRocketShrunk.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnTossedGrenade.uc
# End Source File
# Begin Source File

SOURCE=.\classes\EDFRocket.uc
# End Source File
# Begin Source File

SOURCE=.\classes\ExpanderPulse.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FireWallBomb.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FireWallBombShrunk.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FireWallCruiser.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FireWallCruiserShrunk.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FireWallStarter.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FireWallStarterScorch.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FireWallStarterShrunk.uc
# End Source File
# Begin Source File

SOURCE=.\classes\IceNuke.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LaserMine.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PipeBomb.uc
# End Source File
# Begin Source File

SOURCE=.\classes\PipeBombShrunk.uc
# End Source File
# Begin Source File

SOURCE=.\classes\RoamingLaserMine.uc
# End Source File
# Begin Source File

SOURCE=.\classes\ShockWave.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShotgunShell.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\StickyBomb.uc
# End Source File
# Begin Source File

SOURCE=.\classes\StickyBombShrunk.uc
# End Source File
# End Group
# Begin Group "Ammo"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\Classes\ChainsawFuel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ChainsawFuel_Dirty.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FreezerAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HypoAir.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HypoVial_Antidote.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HypoVial_Antidote_Side.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HypoVial_Health.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HypoVial_Health_Side.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HypoVial_Steroids.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HypoVial_Steroids_Side.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\M16Clip.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\M16GAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\classes\MightyFootAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MultiBombAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\NukeCannister.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PistolClip.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PistolClip_Gold.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PistolClipAP.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PistolClipAP_Gold.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PistolClipHP.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PistolClipHP_Gold.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RocketPack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RocketPackB.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShieldedLaserMine.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShotgunAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShotgunAmmo_Open.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShotgunAmmoAcid.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShotgunAmmoAcid_Open.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShrinkAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\classes\SnatcherFaceAmmo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SniperCell.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TripMineAmmo.uc
# End Source File
# End Group
# Begin Group "Triggers"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\classes\AddEmailTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BombPlacementTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DecoDamageTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnBreakableGlassTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DoorMoverTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DOTTrigger_Fire.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Earthquake.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ElevatorTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HealthActor.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LeverControl1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MeshMultiplexer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\NewLocationTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ObjectiveTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PlaneRollDispatch.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PushButtonControl1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RandomSpawn.uc
# End Source File
# Begin Source File

SOURCE=.\classes\SOSTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\StochasticTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriggerCrane.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriggerDamage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriggerDnProjectileSpawn.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriggeredDeath.uc
# End Source File
# Begin Source File

SOURCE=.\classes\TriggerEgo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriggerLight.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriggerPinballBumper.uc
# End Source File
# Begin Source File

SOURCE=.\classes\TriggerPlayer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriggerSlotMachineBank.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriggerUntrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriggerVideoPoker.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TriggerVideoPoker2.uc
# End Source File
# End Group
# Begin Group "Life"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\Classes\Life.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LifeCell.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LifeDetector.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LifeGrid.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LifeGridAssign.uc
# End Source File
# End Group
# Begin Group "Movers"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\Classes\ElevatorMover.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RotatingMover.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\SwayMover.uc
# End Source File
# End Group
# Begin Group "Inventory"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\Classes\Bomb.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DollarSingle.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DollarWad.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DollarWad_Five.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DollarWad_Hundred.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DollarWad_Three.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DollarWad_TwentyFive.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DukeHand.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HoloDuke.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Jetpack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Keycard.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MedKit.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Money.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PowerCell.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Rebreather.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\RiotShield.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Steroids.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ToDoList.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Upgrade_EMP.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Upgrade_HeatVision.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Upgrade_NightVision.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Upgrade_ZoomMode.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VendSnack.uc
# End Source File
# End Group
# Begin Group "Info"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\Classes\CameraManager.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CreatureTasks.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnFontInfo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnSinglePlayer.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnSinglePlayer_NoPistol.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FearSpot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\NPCAlertBeacon.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\TaskInfo.uc
# End Source File
# End Group
# Begin Group "Pawns"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\Classes\DukePlayer.uc
# End Source File
# End Group
# Begin Group "Navigation"

# PROP Default_Filter ".uc"
# Begin Source File

SOURCE=.\Classes\Transporter.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\WaterZone.uc
# End Source File
# End Group
# Begin Group "Turrets"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\ControllableTurret.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ControllableTurret_Cannon.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ControllableTurret_CannonB.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ControllableTurret_CannonBNS.uc
# End Source File
# Begin Source File

SOURCE=.\classes\ControllableTurret_CannonNS.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ControllableTurret_MachineGun.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\CTViewActor.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ModifyTurretTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MoveBetweenLikeTurrets.uc
# End Source File
# End Group
# Begin Group "Rain"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\RainPuddleTrigger.uc
# End Source File
# Begin Source File

SOURCE=.\classes\RainTrigger.uc
# End Source File
# End Group
# Begin Group "DamageTypes"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\BiteDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\CannonDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\ChainsawDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\EMPDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\ExplosionChainDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FirewallDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\FlamethrowerDamage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FreezeDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\GrenadeDamage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HypoGunDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\LaserMineDamage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\M16Damage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\MachinegunTurretDamage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MightyFootDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\PipeBombDamage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PistolDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\RocketDamage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShotgunDamage.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ShrinkDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\SnatcherDeLeggedDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\SnatcherDeLeggedLDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\SnatcherDeLeggedRDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\SnatcherFaceDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\SnatcherRollDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\SniperLaserDamage.uc
# End Source File
# Begin Source File

SOURCE=.\classes\StickyBombDamage.uc
# End Source File
# End Group
# Begin Group "Voice"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Classes\dnVoicePack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\FemalePlayerSounds.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\MalePlayerSounds.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PigcopPlayerSounds.uc
# End Source File
# End Group
# Begin Group "Mutators"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\classes\BiggerHead.uc
# End Source File
# Begin Source File

SOURCE=.\classes\BigHead.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\EMPMutator.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HeatVisionMutator.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Jetpacks.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\LowGrav.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\NightVisionMutator.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\ZoomModeMutator.uc
# End Source File
# End Group
# Begin Group "Dancing Game"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\classes\DDD_Controls.uc
# End Source File
# Begin Source File

SOURCE=.\classes\DDD_DancerControl.uc
# End Source File
# Begin Source File

SOURCE=.\classes\DDD_Dispatcher.uc
# End Source File
# Begin Source File

SOURCE=.\classes\DDD_InputControl.uc
# End Source File
# End Group
# Begin Group "Funny Stuff"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\classes\DisembodiedHeadOfLincoln.uc
# End Source File
# Begin Source File

SOURCE=.\classes\InterplexingBeacon.uc
# End Source File
# End Group
# Begin Group "HitPackages"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\classes\HitPackage_AlienFlesh.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HitPackage_DukeLevel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HitPackage_Flesh.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HitPackage_Shield.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HitPackage_ShieldBig.uc
# End Source File
# Begin Source File

SOURCE=.\classes\HitPackage_ShieldHeld.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HitPackage_Shotgun.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\HitPackage_Steel.uc
# End Source File
# End Group
# Begin Source File

SOURCE=.\Classes\CardGame.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnBreakableGlass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDriveableMotorcycle.uc
# End Source File
# Begin Source File

SOURCE=.\classes\dnGlassFragments.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnVegasJackpotCounter.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DynamicAmbientSound.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PivotJoint.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PuppetMimic.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PuppetReach.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\PuppetStretch.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\VideoPoker.uc
# End Source File
# End Group
# End Target
# End Project
