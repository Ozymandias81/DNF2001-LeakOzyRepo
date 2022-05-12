//=============================================================================
// pbolt.
//=============================================================================
class PBolt extends projectile;

#exec TEXTURE IMPORT NAME=PalGreen FILE=..\unrealshare\textures\expgreen.pcx GROUP=Effects
#exec OBJ LOAD FILE=textures\BoltCap.utx PACKAGE=Botpack.BoltCap
#exec OBJ LOAD FILE=textures\BoltHit.utx PACKAGE=Botpack.BoltHit

#exec MESH IMPORT MESH=pbolt ANIVFILE=MODELS\pbolt_a.3d DATAFILE=MODELS\pbolt_d.3d
#exec MESH ORIGIN MESH=pbolt X=0 Y=-400 Z=0 YAW=192

#exec MESH SEQUENCE MESH=pbolt SEQ=All                      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=pbolt SEQ=still                    STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=pbolt MESH=pbolt
#exec MESHMAP SCALE MESHMAP=pbolt X=0.10125 Y=0.10125 Z=0.2025

#exec TEXTURE IMPORT NAME=pbolt0 FILE=Textures\Bolta_00.bmp GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=pbolt1 FILE=Textures\Bolta_01.bmp GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=pbolt2 FILE=Textures\Bolta_02.bmp GROUP=Skins	LODSET=2
#exec TEXTURE IMPORT NAME=pbolt3 FILE=Textures\Bolta_03.bmp GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=pbolt4 FILE=Textures\Bolta_04.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=pbolt NUM=0 TEXTURE=pbolt0

var() texture SpriteAnim[5];
var int SpriteFrame;
var PBolt PlasmaBeam;
var PlasmaCap WallEffect;
var int Position;
var vector FireOffset;
var float BeamSize;
var bool bRight, bCenter;
var float AccumulatedDamage, LastHitTime;
var Actor DamagedActor;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		bRight, bCenter;
}

simulated function Destroyed()
{
	Super.Destroyed();
	if ( PlasmaBeam != None )
		PlasmaBeam.Destroy();
	if ( WallEffect != None )
		WallEffect.Destroy();
}

simulated function CheckBeam(vector X, float DeltaTime)
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	// check to see if hits something, else spawn or orient child

	HitActor = Trace(HitLocation, HitNormal, Location + BeamSize * X, Location, true);
	if ( (HitActor != None)	&& (HitActor != Instigator)
		&& (HitActor.bProjTarget || (HitActor == Level) || (HitActor.bBlockActors && HitActor.bBlockPlayers)) 
		&& ((Pawn(HitActor) == None) || Pawn(HitActor).AdjustHitLocation(HitLocation, Velocity)) )
	{
		if ( Level.Netmode != NM_Client )
		{
			if ( DamagedActor == None )
			{
				AccumulatedDamage = FMin(0.5 * (Level.TimeSeconds - LastHitTime), 0.1);
				HitActor.TakeDamage(damage * AccumulatedDamage, instigator,HitLocation,
					(MomentumTransfer * X * AccumulatedDamage), MyDamageType);
				AccumulatedDamage = 0;
			}				
			else if ( DamagedActor != HitActor )
			{
				DamagedActor.TakeDamage(damage * AccumulatedDamage, instigator,HitLocation,
					(MomentumTransfer * X * AccumulatedDamage), MyDamageType);
				AccumulatedDamage = 0;
			}				
			LastHitTime = Level.TimeSeconds;
			DamagedActor = HitActor;
			AccumulatedDamage += DeltaTime;
			if ( AccumulatedDamage > 0.22 )
			{
				if ( DamagedActor.IsA('Carcass') && (FRand() < 0.09) )
					AccumulatedDamage = 35/damage;
				DamagedActor.TakeDamage(damage * AccumulatedDamage, instigator,HitLocation,
					(MomentumTransfer * X * AccumulatedDamage), MyDamageType);
				AccumulatedDamage = 0;
			}
		}
		if ( HitActor.bIsPawn && Pawn(HitActor).bIsPlayer )
		{
			if ( WallEffect != None )
				WallEffect.Destroy();
		}
		else if ( (WallEffect == None) || WallEffect.bDeleteMe )
			WallEffect = Spawn(class'PlasmaHit',,, HitLocation - 5 * X);
		else if ( !WallEffect.IsA('PlasmaHit') )
		{
			WallEffect.Destroy();	
			WallEffect = Spawn(class'PlasmaHit',,, HitLocation - 5 * X);
		}
		else
			WallEffect.SetLocation(HitLocation - 5 * X);

		if ( WallEffect != None )
			Spawn(ExplosionDecal,,,HitLocation,rotator(HitNormal));

		if ( PlasmaBeam != None )
		{
			AccumulatedDamage += PlasmaBeam.AccumulatedDamage;
			PlasmaBeam.Destroy();
			PlasmaBeam = None;
		}

		return;
	}
	else if ( (Level.Netmode != NM_Client) && (DamagedActor != None) )
	{
		DamagedActor.TakeDamage(damage * AccumulatedDamage, instigator, DamagedActor.Location - X * 1.2 * DamagedActor.CollisionRadius,
			(MomentumTransfer * X * AccumulatedDamage), MyDamageType);
		AccumulatedDamage = 0;
		DamagedActor = None;
	}			


	if ( Position >= 9 )
	{	
		if ( (WallEffect == None) || WallEffect.bDeleteMe )
			WallEffect = Spawn(class'PlasmaCap',,, Location + (BeamSize - 4) * X);
		else if ( WallEffect.IsA('PlasmaHit') )
		{
			WallEffect.Destroy();	
			WallEffect = Spawn(class'PlasmaCap',,, Location + (BeamSize - 4) * X);
		}
		else
			WallEffect.SetLocation(Location + (BeamSize - 4) * X);
	}
	else
	{
		if ( WallEffect != None )
		{
			WallEffect.Destroy();
			WallEffect = None;
		}
		if ( PlasmaBeam == None )
		{
			PlasmaBeam = Spawn(class'PBolt',,, Location + BeamSize * X); 
			PlasmaBeam.Position = Position + 1;
		}
		else
			PlasmaBeam.UpdateBeam(self, X, DeltaTime);
	}
}

simulated function UpdateBeam(PBolt ParentBolt, vector Dir, float DeltaTime)
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	SpriteFrame = ParentBolt.SpriteFrame;
	Skin = SpriteAnim[SpriteFrame];
	SetLocation(ParentBolt.Location + BeamSize * Dir);
	SetRotation(ParentBolt.Rotation);
	CheckBeam(Dir, DeltaTime);
}

defaultproperties
{
    ExplosionDecal=class'Botpack.BoltScorch'
	MyDamageType=zapped
	SpriteAnim(0)=Texture'pbolt0'
	SpriteAnim(1)=Texture'pbolt1'
	SpriteAnim(2)=Texture'pbolt2'
	SpriteAnim(3)=Texture'pbolt3'
	SpriteAnim(4)=Texture'pbolt4'
	Skin=Texture'pbolt0'
	Texture=Texture'pbolt0'
	BeamSize=81.00
	bUnlit=true
    FireOffset=(X=16.000000,Y=-14.000000,Z=-8.00000)
	DrawType=DT_Mesh
	Mesh=pbolt
	Style=STY_Translucent
     RemoteRole=ROLE_None
     MaxSpeed=+00000.000000
     SoundVolume=0
     CollisionRadius=+00000.000000
     CollisionHeight=+00000.000000
     bCollideActors=False
     bCollideWorld=False
	 bNetTemporary=False
	 bGameRelevant=true
     Physics=PHYS_None
     LifeSpan=+60.000000
	 Damage=+72.000
     MomentumTransfer=8500
	 bRight=True
	 AmbientSound=Sound'PulseBolt'
     SoundRadius=12
     SoundVolume=255
}

