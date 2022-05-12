//=============================================================================
// Pylon.
//=============================================================================
class Pylon extends Decoration;

#exec MESH IMPORT MESH=PylonM ANIVFILE=MODELS\Pylon_a.3D DATAFILE=MODELS\Pylon_d.3D X=0 Y=0 Z=0 MLOD=0
#exec MESH ORIGIN MESH=PylonM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=PylonM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=PylonM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JPylon1 FILE=MODELS\Pylon.PCX GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=PylonM X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=PylonM NUM=0 TEXTURE=JPylon1

var bool bFirstHit;

function Attach( Actor Other )
{
	Velocity.X = 0;
	Velocity.Y = 0;
	Velocity.Z = FMin(0, Velocity.Z);
}

function Timer()
{
	SetCollision(true,true,true);
}

function Bump( actor Other )
{
	if( Other.Mass >= 40 )
	{
		bBobbing = false;
		Velocity += 1.5 * VSize(Other.Velocity) * Normal(Location - Other.Location);
		if ( Physics == PHYS_None ) 
			Velocity.Z = FMax(Velocity.Z,250);
		SetPhysics(PHYS_Falling);
		SetTimer(0.3,False);
		Instigator = Pawn(Other);
		SetCollision(true,false,false);
		StartRotating();
	}
}

function StartRotating()
{
	RotationRate.Yaw = 250000*FRand() - 125000;
	RotationRate.Pitch = 250000*FRand() - 125000;
	RotationRate.Roll = 250000*FRand() - 125000;	
	DesiredRotation = RotRand();
	bRotateToDesired=False;
	bFixedRotationDir=True;
	bFirstHit=True;
}

function Landed(vector HitNormal)
{
	local Rotator NewRot;
	Super.Landed(HitNormal);
	NewRot = Rotation;
	NewRot.Pitch = 18768;
	SetRotation(NewRot);
}

Auto State Animate
{
	function HitWall (vector HitNormal, actor Wall)
	{
		local float speed;

		Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
		speed = VSize(Velocity);
		if (bFirstHit && speed<400) 
		{
			bFirstHit=False;
			bRotatetoDesired=True;
			bFixedRotationDir=False;
			DesiredRotation.Yaw=Rand(65535);
			DesiredRotation.Pitch=Rand(65535);
			DesiredRotation.Roll=0;
		}
		RotationRate.Yaw = RotationRate.Yaw*0.75;
		RotationRate.Roll = RotationRate.Roll*0.75;
		RotationRate.Pitch = RotationRate.Pitch*0.75;	
		If (speed < 50) 
		{
			bBounce = False;
			DesiredRotation.Yaw = Rotation.Yaw;
			DesiredRotation.Roll = Rotation.Roll;
			DesiredRotation.Pitch=18768;
			SetRotation(DesiredRotation);
		}
	}	

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		if ( StandingCount > 0 )
			return;
		SetPhysics(PHYS_Falling);
		bBounce = True;
		Velocity += Momentum/Mass;
		Velocity.Z = FMax(Momentum.Z, 200);
		StartRotating();
	}
}

defaultproperties
{
	 RemoteRole=ROLE_None
	 bNetTemporary=true
     bPushable=True
     bStatic=False
	 bNet=false
	 bProjTarget=true
     DrawType=DT_Mesh
     Mesh=Mesh'Botpack.PylonM'
     CollisionRadius=12.000000
     CollisionHeight=8.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     Mass=+35.000000
	 Buoyancy=+40.0
}
