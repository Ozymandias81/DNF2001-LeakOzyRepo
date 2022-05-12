//=============================================================================
// FlakShell.
//=============================================================================
class FlakShell extends Projectile;

#exec MESH IMPORT MESH=FlakSh ANIVFILE=MODELS\FlakSh_a.3D DATAFILE=MODELS\FlakSh_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=FlakSh STRENGTH=0.3
#exec MESH ORIGIN MESH=FlakSh X=0 Y=0 Z=-0 YAW=-64
#exec MESH SEQUENCE MESH=FlakSh SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=FlakSh SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jflakshel1 FILE=..\unrealshare\MODELS\FlakShel.PCX
#exec MESHMAP SCALE MESHMAP=FlakSh X=0.12 Y=0.12 Z=0.24
#exec MESHMAP SETTEXTURE MESHMAP=FlakSh NUM=1 TEXTURE=Jflakshel1 TLOD=50

	simulated function PostBeginPlay()
	{
		Super.PostBeginPlay();
		Velocity = Vector(Rotation) * Speed;     
		Velocity.z += 200; 
		if (Level.bHighDetailMode) SetTimer(0.05,True);
		else SetTimer(0.25,True);
	}

	function ProcessTouch (Actor Other, vector HitLocation)
	{
		if ((Other != instigator) && (FlakShell(Other) == none)) 
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	function Landed( vector HitNormal )
	{
		Explode(Location,HitNormal);
	}

	simulated function Timer()
	{
		local SpriteSmokePuff s;

		if (Level.NetMode!=NM_DedicatedServer) 
		{
			s = Spawn(class'SpriteSmokePuff');
			s.RemoteRole = ROLE_None;
		}	
	}

	function Explode(vector HitLocation, vector HitNormal)
	{
		local vector start;

		HurtRadius(damage, 150, 'exploded', MomentumTransfer, HitLocation);	
		start = Location + 10 * HitNormal;
 		Spawn( class'FlameExplosion',,,Start);
		Spawn(class 'MasterChunk',,,Start);
		Spawn( class 'Chunk2',, '', Start);
		Spawn( class 'Chunk3',, '', Start);
		Spawn( class 'Chunk4',, '', Start);
		Spawn( class 'Chunk1',, '', Start);
		Spawn( class 'Chunk2',, '', Start);
 		Destroy();
	}

defaultproperties
{
     speed=1200.000000
     Damage=70.000000
     MomentumTransfer=75000
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=6.000000
     Mesh=Mesh'UnrealI.FlakSh'
     AmbientGlow=67
     bUnlit=True
     bMeshCurvy=False
     NetPriority=2.500000
	 bNetTemporary=false
}
