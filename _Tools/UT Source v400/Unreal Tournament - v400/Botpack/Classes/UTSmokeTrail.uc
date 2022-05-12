//=============================================================================
// UTSmokeTrail.
//=============================================================================
class UTSmokeTrail extends Effects;

#exec MESH IMPORT MESH=Smokebm ANIVFILE=MODELS\strail_a.3D DATAFILE=MODELS\strail_d.3D
#exec MESH ORIGIN MESH=Smokebm X=-600 Y=0 Z=0 YAW=128
#exec MESH SEQUENCE MESH=Smokebm SEQ=All       STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Smokebm X=0.1 Y=0.001 Z=0.001

var int Curr;
var bool bRandomize, bEven;
var int Vert[8];

function PostBeginPlay()
{
	local int i;
	Super.PostBeginPlay();
	SetTimer(1.4, false);
	if ( bRandomize && (FRand() < 0.4) )
		MultiSkins[5 + Rand(2)] = Texture'Botpack.utsmoke.us3_a00';
	
}

function Timer()
{
	if ( Curr >= 0 )
	{
		MultiSkins[Vert[Curr]] = None;
		Curr--;
		if ( Curr >= 0 )
			SetTimer(0.025, false);
	}
}

defaultproperties
{
	 bRandomize=true
	 Curr=7
	 Physics=PHYS_Projectile
     RemoteRole=ROLE_None
     LifeSpan=1.60000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=Texture'Botpack.utsmoke.us1_a00'
     Mesh=Mesh'Botpack.Smokebm'
     DrawScale=2.000000
     ScaleGlow=0.800000
     bParticles=True
	 bRandomFrame=true
     bMeshCurvy=False
	 bUnlit=true
	 Velocity=(x=0,y=0,z=50)
	MultiSkins(0)=Texture'Botpack.utsmoke.us8_a00'
	MultiSkins(1)=Texture'Botpack.utsmoke.us3_a00'
	MultiSkins(2)=Texture'Botpack.utsmoke.us8_a00'
	MultiSkins(3)=Texture'Botpack.utsmoke.us2_a00'
	MultiSkins(4)=Texture'Botpack.utsmoke.us1_a00'
	MultiSkins(5)=Texture'Botpack.utsmoke.us2_a00'
	MultiSkins(6)=Texture'Botpack.utsmoke.us1_a00'
	MultiSkins(7)=Texture'Botpack.utsmoke.us8_a00'
	Vert(0)=1
	Vert(1)=7
	Vert(2)=3
	Vert(3)=6
	Vert(4)=2
	Vert(5)=5
	Vert(6)=0
	Vert(7)=4
}
