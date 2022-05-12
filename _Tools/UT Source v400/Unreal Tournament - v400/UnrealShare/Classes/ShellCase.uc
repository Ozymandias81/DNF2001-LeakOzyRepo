//=============================================================================
// ShellCase.
//=============================================================================
class ShellCase extends Projectile;

#exec MESH IMPORT MESH=Shell ANIVFILE=MODELS\shell_a.3D DATAFILE=MODELS\shell_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Shell X=0 Y=0 Z=0 YAW=64 ROLL=128
#exec MESH SEQUENCE MESH=Shell SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Autom1 FILE=MODELS\automag.PCX
#exec MESHMAP SCALE MESHMAP=Shell X=0.011 Y=0.011 Z=0.022
#exec MESHMAP SETTEXTURE MESHMAP=Shell NUM=1 TEXTURE=Autom1 TLOD=30

#exec AUDIO IMPORT FILE="Sounds\automag\shell2.WAV" NAME="Shell2" GROUP="AutoMag"
#exec AUDIO IMPORT FILE="Sounds\General\Drip.WAV" NAME="Drip1" GROUP="General"

var bool bHasBounced;
var int numBounces;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.1, false);
}

simulated function Timer()
{
	LightType = LT_None;
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	local vector RealHitNormal;

	if ( bHasBounced && ((numBounces > 3) || (FRand() < 0.85) || (Velocity.Z > -50)) )
		bBounce = false;
	numBounces++;
	if ( !Region.Zone.bWaterZone )
		PlaySound(sound 'shell2');
	RealHitNormal = HitNormal;
	HitNormal = Normal(HitNormal + 0.4 * VRand());
	if ( (HitNormal Dot RealHitNormal) < 0 )
		HitNormal *= -0.5; 
	Velocity = 0.5 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	RandSpin(100000);
	bHasBounced = True;
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	if (NewZone.bWaterZone && !Region.Zone.bWaterZone) 
	{
		Velocity=0.2*Velocity;	
		PlaySound(sound 'Drip1');			
		bHasBounced=True;
	}
}


simulated function Landed( vector HitNormal )
{
	local rotator RandRot;

	if ( !Region.Zone.bWaterZone )
		PlaySound(sound 'shell2');	
	SetPhysics(PHYS_None);
	RandRot = Rotation;
	RandRot.Pitch = 0;
	RandRot.Roll = 0;
	SetRotation(RandRot);
}

function Eject(Vector Vel)
{
	Velocity = Vel + 0.8 * Instigator.Velocity;
	RandSpin(100000);
	if (Instigator.HeadRegion.Zone.bWaterZone) 
	{
		Velocity = Velocity * (0.2+FRand()*0.2);
		bHasBounced=True;
	}
}

defaultproperties
{
     MaxSpeed=1000.000000
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=3.000000
     Mesh=Mesh'UnrealShare.Shell'
     bUnlit=True
     bNoSmooth=False
     bMeshCurvy=False
     bCollideActors=False
     bBounce=True
     bFixedRotationDir=True
	 bReplicateInstigator=false
     NetPriority=1.500000
     bNetOptional=True
	 bNetTemporary=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=250
     LightHue=28
     LightSaturation=128
     LightRadius=7
}
