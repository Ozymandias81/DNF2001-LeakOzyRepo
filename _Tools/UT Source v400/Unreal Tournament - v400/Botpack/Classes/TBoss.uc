//=============================================================================
// TBoss.
//=============================================================================
class TBoss extends TournamentMale;

#exec MESH IMPORT MESH=Boss ANIVFILE=MODELS\Boss_a.3D DATAFILE=MODELS\Boss_d.3D UNMIRROR=1 LODSTYLE=12 
#exec MESH ORIGIN MESH=Boss X=-150 Y=40 Z=0 YAW=64 ROLL=-64

#exec MESH SEQUENCE MESH=Boss SEQ=All       STARTFRAME=0   NUMFRAMES=700 
#exec MESH SEQUENCE MESH=Boss SEQ=GutHit    STARTFRAME=0   NUMFRAMES=1				Group=TakeHit
#exec MESH SEQUENCE MESH=Boss SEQ=AimDnLg   STARTFRAME=1   NUMFRAMES=1				Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=AimDnSm   STARTFRAME=2   NUMFRAMES=1				Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=AimUpLg   STARTFRAME=3   NUMFRAMES=1				Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=AimUpSm   STARTFRAME=4   NUMFRAMES=1				Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=Taunt1    STARTFRAME=5   NUMFRAMES=20 RATE=15		Group=Gesture
#exec MESH SEQUENCE MESH=Boss SEQ=Breath1   STARTFRAME=25  NUMFRAMES=7  RATE=6		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=Breath2   STARTFRAME=32  NUMFRAMES=20 RATE=7		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=CockGun   STARTFRAME=52  NUMFRAMES=8  RATE=6		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=DuckWlkL  STARTFRAME=60  NUMFRAMES=15 RATE=15		Group=Ducking
#exec MESH SEQUENCE MESH=Boss SEQ=DuckWlkS  STARTFRAME=75  NUMFRAMES=15 RATE=15		Group=Ducking
#exec MESH SEQUENCE MESH=Boss SEQ=HeadHit   STARTFRAME=90  NUMFRAMES=1				Group=TakeHit
#exec MESH SEQUENCE MESH=Boss SEQ=JumpLgFr  STARTFRAME=91  NUMFRAMES=1				Group=Jumping
#exec MESH SEQUENCE MESH=Boss SEQ=JumpSmFr  STARTFRAME=92  NUMFRAMES=1				Group=Jumping
#exec MESH SEQUENCE MESH=Boss SEQ=LandLgFr  STARTFRAME=93  NUMFRAMES=1				Group=Landing
#exec MESH SEQUENCE MESH=Boss SEQ=LandSmFr  STARTFRAME=94  NUMFRAMES=1				Group=Landing
#exec MESH SEQUENCE MESH=Boss SEQ=LeftHit   STARTFRAME=95  NUMFRAMES=1				Group=TakeHit
#exec MESH SEQUENCE MESH=Boss SEQ=Look      STARTFRAME=96  NUMFRAMES=40 RATE=15     Group=Waiting 
#exec MESH SEQUENCE MESH=Boss SEQ=RightHit  STARTFRAME=136 NUMFRAMES=1				Group=TakeHit
#exec MESH SEQUENCE MESH=Boss SEQ=RunLg     STARTFRAME=137 NUMFRAMES=10 RATE=17
#exec MESH SEQUENCE MESH=Boss SEQ=RunLgFr   STARTFRAME=147 NUMFRAMES=10 RATE=17    Group=MovingFire
#exec MESH SEQUENCE MESH=Boss SEQ=RunSm     STARTFRAME=157 NUMFRAMES=10 RATE=17
#exec MESH SEQUENCE MESH=Boss SEQ=RunSmFr   STARTFRAME=167 NUMFRAMES=10 RATE=17		Group=MovingFire
#exec MESH SEQUENCE MESH=Boss SEQ=StillFrRp STARTFRAME=177 NUMFRAMES=10 RATE=15		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=StillLgFr STARTFRAME=187 NUMFRAMES=10 RATE=15		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=StillSmFr STARTFRAME=197 NUMFRAMES=8  RATE=15		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=SwimLg    STARTFRAME=205 NUMFRAMES=15 RATE=15
#exec MESH SEQUENCE MESH=Boss SEQ=SwimSm    STARTFRAME=220 NUMFRAMES=15 RATE=15
#exec MESH SEQUENCE MESH=Boss SEQ=TreadLg   STARTFRAME=235 NUMFRAMES=15 RATE=15		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=TreadSm   STARTFRAME=250 NUMFRAMES=15 RATE=15		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=Victory1  STARTFRAME=265 NUMFRAMES=18 RATE=6  	Group=Gesture
#exec MESH SEQUENCE MESH=Boss SEQ=WalkLg    STARTFRAME=283 NUMFRAMES=15 RATE=18
#exec MESH SEQUENCE MESH=Boss SEQ=WalkLgFr  STARTFRAME=298 NUMFRAMES=15 RATE=18		Group=MovingFire
#exec MESH SEQUENCE MESH=Boss SEQ=WalkSm    STARTFRAME=313 NUMFRAMES=15 RATE=18
#exec MESH SEQUENCE MESH=Boss SEQ=WalkSmFr  STARTFRAME=328 NUMFRAMES=15 RATE=18		Group=MovingFire
#exec MESH SEQUENCE MESH=Boss SEQ=Wave      STARTFRAME=343 NUMFRAMES=15 RATE=15		Group=Gesture
#exec MESH SEQUENCE MESH=Boss SEQ=Walk      STARTFRAME=358 NUMFRAMES=15 RATE=18
#exec MESH SEQUENCE MESH=Boss SEQ=TurnLg    STARTFRAME=298 NUMFRAMES=2  RATE=15					// 2 frames of walklgfr
#exec MESH SEQUENCE MESH=Boss SEQ=TurnSm    STARTFRAME=328 NUMFRAMES=2  RATE=15					// 2 frames of walksmfr
#exec MESH SEQUENCE MESH=Boss SEQ=Breath1L  STARTFRAME=373 NUMFRAMES=7  RATE=6		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=Breath2L  STARTFRAME=380 NUMFRAMES=20 RATE=7		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=CockGunL  STARTFRAME=400 NUMFRAMES=8  RATE=6		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=LookL     STARTFRAME=408 NUMFRAMES=40 RATE=15     Group=Waiting 
#exec MESH SEQUENCE MESH=Boss SEQ=WaveL     STARTFRAME=448 NUMFRAMES=15 RATE=15		Group=Gesture
#exec MESH SEQUENCE MESH=Boss SEQ=Chat1     STARTFRAME=463 NUMFRAMES=13 RATE=6		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=Chat2     STARTFRAME=476 NUMFRAMES=10 RATE=6		Group=Waiting
#exec MESH SEQUENCE MESH=Boss SEQ=Thrust    STARTFRAME=486 NUMFRAMES=15 RATE=20		Group=Gesture
#exec MESH SEQUENCE MESH=Boss SEQ=DodgeB    STARTFRAME=501 NUMFRAMES=1				Group=Jumping
#exec MESH SEQUENCE MESH=Boss SEQ=DodgeF    STARTFRAME=502 NUMFRAMES=1				Group=Jumping
#exec MESH SEQUENCE MESH=Boss SEQ=DodgeR    STARTFRAME=503 NUMFRAMES=1				Group=Jumping
#exec MESH SEQUENCE MESH=Boss SEQ=DodgeL    STARTFRAME=504 NUMFRAMES=1				Group=Jumping
#exec MESH SEQUENCE MESH=Boss SEQ=Fighter   STARTFRAME=187 NUMFRAMES=1								// first frame of stilllgfr
#exec MESH SEQUENCE MESH=Boss SEQ=Flip      STARTFRAME=505 NUMFRAMES=20				Group=Jumping
#exec MESH SEQUENCE MESH=Boss SEQ=Dead1     STARTFRAME=525 NUMFRAMES=13 RATE=12		Group=TakeHit
#exec MESH SEQUENCE MESH=Boss SEQ=Dead2     STARTFRAME=538 NUMFRAMES=16 RATE=12		
#exec MESH SEQUENCE MESH=Boss SEQ=Dead3     STARTFRAME=554 NUMFRAMES=13 RATE=12
#exec MESH SEQUENCE MESH=Boss SEQ=Dead4     STARTFRAME=567 NUMFRAMES=16 RATE=12
#exec MESH SEQUENCE MESH=Boss SEQ=Dead7     STARTFRAME=583 NUMFRAMES=21 RATE=15		Group=TakeHit
#exec MESH SEQUENCE MESH=Boss SEQ=Dead8     STARTFRAME=604 NUMFRAMES=18 RATE=15		Group=TakeHit
#exec MESH SEQUENCE MESH=Boss SEQ=Dead9     STARTFRAME=622 NUMFRAMES=20 RATE=30		Group=TakeHit
#exec MESH SEQUENCE MESH=Boss SEQ=Dead9B    STARTFRAME=642 NUMFRAMES=10 RATE=15		
#exec MESH SEQUENCE MESH=Boss SEQ=Dead11    STARTFRAME=652 NUMFRAMES=18 RATE=15
#exec MESH SEQUENCE MESH=Boss SEQ=BackRun   STARTFRAME=670 NUMFRAMES=10 RATE=17		Group=MovingFire
#exec MESH SEQUENCE MESH=Boss SEQ=StrafeL   STARTFRAME=680 NUMFRAMES=10 RATE=17		Group=MovingFire
#exec MESH SEQUENCE MESH=Boss SEQ=StrafeR   STARTFRAME=690 NUMFRAMES=10 RATE=17		Group=MovingFire

#exec MESH SEQUENCE MESH=Boss SEQ=DeathEnd  STARTFRAME=537 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Boss SEQ=DeathEnd2 STARTFRAME=553 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Boss SEQ=DeathEnd3 STARTFRAME=566 NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=Boss X=0.0585 Y=0.0585 Z=0.117

#exec MESH NOTIFY MESH=Boss SEQ=RunLG TIME=0.25 FUNCTION=PlayFootStep
#exec MESH NOTIFY MESH=Boss SEQ=RunLG TIME=0.75 FUNCTION=PlayFootStep
#exec MESH NOTIFY MESH=Boss SEQ=RunLGFR TIME=0.25 FUNCTION=PlayFootStep
#exec MESH NOTIFY MESH=Boss SEQ=RunLGFR TIME=0.75 FUNCTION=PlayFootStep
#exec MESH NOTIFY MESH=Boss SEQ=RunSM TIME=0.25 FUNCTION=PlayFootStep
#exec MESH NOTIFY MESH=Boss SEQ=RunSM TIME=0.75 FUNCTION=PlayFootStep
#exec MESH NOTIFY MESH=Boss SEQ=RunSMFR TIME=0.25 FUNCTION=PlayFootStep
#exec MESH NOTIFY MESH=Boss SEQ=RunSMFR TIME=0.75 FUNCTION=PlayFootStep
#exec MESH NOTIFY MESH=Boss SEQ=Dead1 TIME=0.7 FUNCTION=LandThump
#exec MESH NOTIFY MESH=Boss SEQ=Dead2 TIME=0.9 FUNCTION=LandThump
#exec MESH NOTIFY MESH=Boss SEQ=Dead3 TIME=0.45 FUNCTION=LandThump
#exec MESH NOTIFY MESH=Boss SEQ=Dead4 TIME=0.6 FUNCTION=LandThump
#exec MESH NOTIFY MESH=Boss SEQ=Dead7 TIME=0.7 FUNCTION=LandThump
#exec MESH NOTIFY MESH=Boss SEQ=Dead8 TIME=0.7 FUNCTION=LandThump
#exec MESH NOTIFY MESH=Boss SEQ=Dead9B TIME=0.8 FUNCTION=LandThump
#exec MESH NOTIFY MESH=Boss SEQ=Dead11 TIME=0.57 FUNCTION=LandThump

#exec AUDIO IMPORT FILE="Sounds\BossSounds\Bfootsteps.WAV" NAME="BFootstep" GROUP="Boss"
#exec AUDIO IMPORT FILE="Sounds\BossSounds\Bdeathc1.WAV" NAME="BDeath1" GROUP="Boss"
#exec AUDIO IMPORT FILE="Sounds\BossSounds\Bdeathc3.WAV" NAME="BDeath3" GROUP="Boss"
#exec AUDIO IMPORT FILE="Sounds\BossSounds\Bdeathc4.WAV" NAME="BDeath4" GROUP="Boss"
#exec AUDIO IMPORT FILE="Sounds\BossSounds\BinjurL2.WAV" NAME="BInjur1" GROUP="Boss"
#exec AUDIO IMPORT FILE="Sounds\BossSounds\BinjurL04.WAV" NAME="BInjur2" GROUP="Boss"
#exec AUDIO IMPORT FILE="Sounds\BossSounds\BinjurM04.WAV" NAME="BInjur3" GROUP="Boss"
#exec AUDIO IMPORT FILE="Sounds\BossSounds\BinjurH5.WAV" NAME="BInjur4" GROUP="Boss"
#exec AUDIO IMPORT FILE="Sounds\BossSounds\Bjump2.WAV" NAME="BJump1" GROUP="Boss"
#exec AUDIO IMPORT FILE="Sounds\BossSounds\Bland02.WAV" NAME="Bland01" GROUP="Boss"
#exec AUDIO IMPORT FILE="Sounds\BossSounds\Bgib01.WAV" NAME="BNewGib" GROUP="Boss"

#exec TEXTURE IMPORT NAME=BossDoll FILE=TEXTURES\HUD\IBoss2.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=BossBelt FILE=TEXTURES\HUD\IBossSBelt.PCX GROUP="Icons" MIPS=OFF

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local string MeshName, SkinItem, SkinPackage;

	MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));

	SkinItem = SkinActor.GetItemName(SkinName);
	SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem));

	if(SkinPackage == "")
	{
		SkinPackage="BossSkins.";
		SkinName=SkinPackage$SkinName;
	}

	if( TeamNum != 255 )
	{
		if(!SetSkinElement(SkinActor, 0, SkinName$"1T_"$String(TeamNum), ""))
		{
			if(!SetSkinElement(SkinActor, 0, SkinName$"1", ""))
			{
				SetSkinElement(SkinActor, 0, "BossSkins.boss1T_"$String(TeamNum), "BossSkins.boss1");
				SkinName="BossSkins.boss";
			}
		}
		SetSkinElement(SkinActor, 1, SkinName$"2T_"$String(TeamNum), SkinName$"2");
		SetSkinElement(SkinActor, 2, SkinName$"3T_"$String(TeamNum), SkinName$"3");
		SetSkinElement(SkinActor, 3, SkinName$"4T_"$String(TeamNum), SkinName$"4");
	}
	else
	{
		if(!SetSkinElement(SkinActor, 0, SkinName$"1", "BossSkins.boss1"))
			SkinName="BossSkins.boss";

		SetSkinElement(SkinActor, 1, SkinName$"2", "");
		SetSkinElement(SkinActor, 2, SkinName$"3", "");
		SetSkinElement(SkinActor, 3, SkinName$"4", "");
	}

	if( Pawn(SkinActor) != None ) 
		Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(SkinName$"5Xan", class'Texture'));
}

defaultproperties
{
	Handedness=-1.000000
	Mesh=Mesh'Botpack.Boss'
	SelectionMesh="Botpack.SelectionBoss"
	SpecialMesh="Botpack.TrophyBoss"
	CarcassType=TBossCarcass
	Menuname="Boss"
	VoiceType="BotPack.VoiceBoss"
	FaceSkin=1
     HitSound3=BInjur3
     HitSound4=BInjur4
	 Die=BDeath1
	 Deaths(0)=BDeath1
	 Deaths(1)=BDeath1
	 Deaths(2)=BDeath3
	 Deaths(3)=BDeath4
	 Deaths(4)=BDeath3
	 Deaths(5)=BDeath4
	 JumpSound=BJump1
     HitSound1=BInjur1
     HitSound2=BInjur2
	 LandGrunt=Bland01
	 StatusDoll=texture'Botpack.BossDoll'
	 StatusBelt=texture'Botpack.BossBelt'
	 VoicePackMetaClass="BotPack.VoiceBoss"
}

