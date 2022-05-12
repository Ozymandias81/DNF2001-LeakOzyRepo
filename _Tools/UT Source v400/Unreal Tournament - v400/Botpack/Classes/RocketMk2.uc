//=============================================================================
// rocketmk2.
//=============================================================================
class RocketMk2 extends Projectile;

#exec MESH IMPORT MESH=UTRocket ANIVFILE=MODELS\eightballrocket_a.3D DATAFILE=MODELS\eightballrocket_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=UTRocket X=0 Y=-250 Z=-30 YAW=-64

#exec MESH SEQUENCE MESH=UTRocket SEQ=All       STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=UTRocket SEQ=Still     STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=UTRocket SEQ=Wing     STARTFRAME=1   NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JuRocket1 FILE=MODELS\eightballrocket.PCX LODSET=2
#exec MESHMAP SCALE MESHMAP=UTRocket X=2.2 Y=2.2 Z=4.5 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=UTRocket NUM=1 TEXTURE=Jurocket1

#exec AUDIO IMPORT FILE="Sounds\RocketLauncher\brufly1c.Wav" NAME=RocketFly1 GROUP="RocketLauncher"

var float SmokeRate;
var bool bRing,bHitWater,bWaterStart;
var int NumExtraRockets;
var	rockettrail trail;

simulated function Destroyed()
{
	if ( Trail != None )
		Trail.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	Trail = Spawn(class'RocketTrail',self);
	if ( Level.bHighDetailMode )
	{
		SmokeRate = (200 + (0.5 + 2 * FRand()) * NumExtraRockets * 24)/Speed; 
		if ( Level.bDropDetail )
		{
			SoundRadius = 6;
			LightRadius = 3;
		}
	}
	else 
	{
		SmokeRate = 0.15 + FRand()*(0.02+NumExtraRockets);
		LightRadius = 3;
	}
	SetTimer(SmokeRate, true);
}

simulated function Timer()
{
	local ut_SpriteSmokePuff b;

	if ( Region.Zone.bWaterZone || (Level.NetMode == NM_DedicatedServer) )
		Return;

	if ( Level.bHighDetailMode )
	{
		if ( Level.bDropDetail || ((NumExtraRockets > 0) && (FRand() < 0.5)) )
			Spawn(class'LightSmokeTrail');
		else
			Spawn(class'UTSmokeTrail');
		SmokeRate = 152/Speed; 
	}
	else 
	{
		SmokeRate = 0.15 + FRand()*(0.01+NumExtraRockets);
		b = Spawn(class'ut_SpriteSmokePuff');
		b.RemoteRole = ROLE_None;
	}
	SetTimer(SmokeRate, false);
}

auto state Flying
{

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local waterring w;
		
		if (!NewZone.bWaterZone || bHitWater) Return;

		bHitWater = True;
		if ( Level.NetMode != NM_DedicatedServer )
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = 0.2;
			w.RemoteRole = ROLE_None;
			PlayAnim( 'Still', 3.0 );
		}		
		Velocity=0.6*Velocity;
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( (Other != instigator) && !Other.IsA('Projectile') ) 
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	function BlowUp(vector HitLocation)
	{
		HurtRadius(Damage,220.0, MyDamageType, MomentumTransfer, HitLocation );
		MakeNoise(1.0);
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local UT_SpriteBallExplosion s;

		s = spawn(class'UT_SpriteBallExplosion',,,HitLocation + HitNormal*16);	
 		s.RemoteRole = ROLE_None;

		BlowUp(HitLocation);

 		Destroy();
	}

	function BeginState()
	{
		local vector Dir;

		Dir = vector(Rotation);
		Velocity = speed * Dir;
		Acceleration = Dir * 50;
		PlayAnim( 'Wing', 0.2 );
		if (Region.Zone.bWaterZone)
		{
			bHitWater = True;
			Velocity=0.6*Velocity;
		}
	}
}

defaultproperties
{
	 ExplosionDecal=class'Botpack.BlastMark'
	 MyDamageType=RocketDeath
     speed=900.000000
     MaxSpeed=1600.000000
     Damage=75.000000
     MomentumTransfer=80000
     SpawnSound=Sound'UnrealShare.Eightball.Ignite'
     ImpactSound=Sound'UnrealShare.Eightball.GrenadeFloor'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=6.000000
     AnimSequence=Wing
     Mesh=Mesh'Botpack.UTRocket'
     DrawScale=0.020000
     AmbientGlow=96
     bUnlit=True
     bMeshCurvy=False
     SoundRadius=14
     SoundVolume=255
	 SoundPitch=100
     AmbientSound=Sound'Botpack.RocketLauncher.Rocketfly1'
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=28
     LightSaturation=0
     LightRadius=6
     bBounce=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
}
