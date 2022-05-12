//=============================================================================
// SuperShockBeam.
//=============================================================================
class SuperShockBeam extends Effects;

#exec MESH IMPORT MESH=SShockbm ANIVFILE=MODELS\asmdeffect_a.3D DATAFILE=MODELS\asmdeffect_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SShockbm X=0 Y=-400 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=SShockbm SEQ=All       STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=SShockbm X=0.09 Y=0.21 Z=0.18 YAW=128
#exec TEXTURE IMPORT NAME=jenergy3 FILE=MODELS\energy3.pcx GROUP=Effects
#exec MESHMAP SETTEXTURE MESHMAP=SShockbm NUM=1 TEXTURE=jenergy3

var vector MoveAmount;
var int NumPuffs;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		MoveAmount, NumPuffs;
}

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode  != NM_DedicatedServer )
	{
		ScaleGlow = (Lifespan/Default.Lifespan)*1.0;
		AmbientGlow = ScaleGlow * 210;
	}
}


simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
		SetTimer(0.05, false);
}

simulated function Timer()
{
	local SuperShockBeam r;
	
	if (NumPuffs>0)
	{
		r = Spawn(class'SuperShockbeam',,,Location+MoveAmount);
		r.RemoteRole = ROLE_None;
		r.NumPuffs = NumPuffs -1;
		r.MoveAmount = MoveAmount;
	}
}

defaultproperties
{
	 bUnlit=true
     Physics=PHYS_Rotating
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.270000
     Rotation=(Roll=20000)
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=Texture'Botpack.Effects.jenergy3'
     Mesh=Mesh'Botpack.SShockbm'
     DrawScale=0.440000
     bParticles=True
     bMeshCurvy=False
     bFixedRotationDir=True
     RotationRate=(Roll=1000000)
     DesiredRotation=(Roll=20000)
}
