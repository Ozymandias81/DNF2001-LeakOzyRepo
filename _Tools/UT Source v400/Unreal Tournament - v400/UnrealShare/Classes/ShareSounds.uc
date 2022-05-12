
class ShareSounds extends Actor
	abstract;

#exec OBJ LOAD FILE=textures\deburst.utx PACKAGE=UnrealShare.DBEffect
#exec OBJ LOAD FILE=..\Textures\Belt_fx.utx PACKAGE=Unrealshare.Belt_fx
#exec  OBJ LOAD FILE=Textures\fireeffect1.utx PACKAGE=UnrealShare.Effect1

#exec AUDIO IMPORT FILE="Sounds\Generic\lsplash.WAV" NAME="LSplash" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\pickups\genwep1.WAV" NAME="WeaponPickup" GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Generic\land1.WAV" NAME="Land1" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Pickups\GENPICK3.WAV" NAME="GenPickSnd"    GROUP="Pickups"

#exec AUDIO IMPORT FILE="Sounds\eightbal\8ALTF1.WAV" NAME="EightAltFire" GROUP="EightBall"
#exec AUDIO IMPORT FILE="Sounds\eightbal\Barrelm1.WAV" NAME="BarrelMove" GROUP="EightBall"
#exec AUDIO IMPORT FILE="Sounds\eightbal\Eload1.WAV" NAME="Loading" GROUP="EightBall"
#exec AUDIO IMPORT FILE="Sounds\eightbal\Lock1.WAV" NAME="SeekLock" GROUP="EightBall"
#exec AUDIO IMPORT FILE="Sounds\eightbal\SeekLost.WAV" NAME="SeekLost" GROUP="EightBall"
#exec AUDIO IMPORT FILE="Sounds\eightbal\Select.WAV" NAME="Selecting" GROUP="EightBall"
#exec AUDIO IMPORT FILE="Sounds\EightBal\Ignite.WAV" NAME="Ignite" GROUP="Eightball"
#exec AUDIO IMPORT FILE="Sounds\EightBal\grenflor.wav" NAME="GrenadeFloor" GROUP="Eightball"
#exec AUDIO IMPORT FILE="Sounds\General\brufly1.WAV" NAME="Brufly1" GROUP="General"

#exec AUDIO IMPORT FILE="Sounds\Tazer\TSHOTA6.WAV" NAME="TazerFire" GROUP="ASMD"
#exec AUDIO IMPORT FILE="Sounds\Tazer\TSHOTB1.WAV" NAME="TazerAltFire" GROUP="ASMD"
#exec AUDIO IMPORT FILE="Sounds\Tazer\TPICKUP3.WAV" NAME="TazerSelect" GROUP="ASMD"

#exec AUDIO IMPORT FILE="Sounds\Gibs\biggib1.WAV" NAME="Gib1" GROUP="Gibs"
#exec AUDIO IMPORT FILE="Sounds\Gibs\biggib2.WAV" NAME="Gib4" GROUP="Gibs"
#exec AUDIO IMPORT FILE="Sounds\Gibs\biggib3.WAV" NAME="Gib5" GROUP="Gibs"
#exec AUDIO IMPORT FILE="Sounds\Gibs\bthump1.WAV" NAME="Thump" GROUP="Gibs"

#exec TEXTURE IMPORT NAME=I_Armor FILE=TEXTURES\HUD\i_armor.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=I_Health FILE=TEXTURES\HUD\i_Health.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=I_ClipAmmo FILE=TEXTURES\HUD\i_clip.PCX GROUP="Icons"
#exec TEXTURE IMPORT NAME=I_Boots FILE=..\unreali\TEXTURES\HUD\i_Boots.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=TeleEffect2 ANIVFILE=MODELS\telepo_a.3D DATAFILE=MODELS\telepo_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TeleEffect2 X=0 Y=0 Z=-200 YAW=0
#exec MESH SEQUENCE MESH=TeleEffect2 SEQ=All  STARTFRAME=0  NUMFRAMES=30
#exec MESH SEQUENCE MESH=TeleEffect2  SEQ=Burst  STARTFRAME=0  NUMFRAMES=30
#exec MESHMAP SCALE MESHMAP=TeleEffect2 X=0.03 Y=0.03 Z=0.06

#exec AUDIO IMPORT FILE="sounds\dispersion\dpexplo4.wav" NAME="DispEX1" GROUP="General"
#exec AUDIO IMPORT FILE="Sounds\General\Expl03.wav" NAME="Expl03" GROUP="General"
#exec AUDIO IMPORT FILE="Sounds\General\Expla02.wav" NAME="Expla02" GROUP="General"
#exec AUDIO IMPORT FILE="Sounds\Pickups\HEALTH2.WAV"  NAME="Health2"     GROUP="Pickups"

#exec MESH IMPORT MESH=PHeartM ANIVFILE=MODELS\heartg_a.3D DATAFILE=MODELS\heartg_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PHeartM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=PHeartM SEQ=All    STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=PHeartM SEQ=Beat  STARTFRAME=0   NUMFRAMES=6
#exec TEXTURE IMPORT NAME=Jmisc1 FILE=MODELS\misc.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=PHeartM X=0.015 Y=0.015 Z=0.03
#exec MESHMAP SETTEXTURE MESHMAP=PHeartM NUM=1 TEXTURE=Jmisc1

#exec MESH IMPORT MESH=LiverM ANIVFILE=MODELS\g_gut1_a.3D DATAFILE=MODELS\g_gut1_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=LiverM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=LiverM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=LiverM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jparts1  FILE=MODELS\g_parts.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=LiverM X=0.02 Y=0.02 Z=0.04
#exec MESHMAP SETTEXTURE MESHMAP=LiverM NUM=1 TEXTURE=Jparts1

#exec MESH IMPORT MESH=stomachM ANIVFILE=MODELS\g_stm_a.3D DATAFILE=MODELS\g_stm_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=stomachM X=0 Y=0 Z=0 YAW=64 PITCH=128
#exec MESH SEQUENCE MESH=stomachM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=stomachM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jparts1  FILE=MODELS\g_parts.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=stomachM X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=stomachM NUM=1 TEXTURE=Jparts1

#exec AUDIO IMPORT FILE="sounds\flak\expl2.wav" NAME="Explo1" GROUP="General"
#exec AUDIO IMPORT FILE="Sounds\automag\shot.WAV" NAME="shot" GROUP="AutoMag"

#exec TEXTURE IMPORT NAME=ExplosionPal FILE=textures\exppal.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=BloodSpot FILE=MODELS\bloods2.PCX GROUP=Skins FLAGS=2

#exec MESH IMPORT MESH=CowBody1 ANIVFILE=MODELS\g_cow2_a.3D DATAFILE=MODELS\g_cow2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CowBody1 X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=CowBody1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=CowBody1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGCow1  FILE=MODELS\Nc_1.PCX GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=CowBody1 X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=CowBody1 NUM=1 TEXTURE=JGCow1

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\Scloak1.WAV" NAME="Invisible" GROUP="Pickups"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\BOOTSA1.WAV" NAME="BootSnd" GROUP="Pickups"

