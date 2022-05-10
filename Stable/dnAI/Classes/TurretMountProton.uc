class TurretMountProton extends TurretMounts;

// a b c d 
var() name MFlashMountMeshItem;
var Pawn NewEnemy;

function Trigger( actor Other, pawn EventInstigator )
{
	GotoState( 'TriggeredFiring' );
}

simulated function MuzzleFlash()
{
	local actor S;
	local float RandRot;

//	MuzzleFlashClass=class'M16Flash';

	S = Spawn(class'ShotgunFlash');
	S.MountMeshItem = 'MuzzleMount';
	S.AttachActorToParent( Self, true, true );
	S.MountType = MOUNT_MeshSurface;
	S.bOwnerSeeSpecial = true;
	S.SetOwner( Owner );
	S.SetPhysics( PHYS_MovingBrush );
	RandRot = FRand();
	if (RandRot < 0.3)
		S.SetRotation(rot(S.Rotation.Pitch,S.Rotation.Yaw,S.Rotation.Roll+16384));
	else if (RandRot < 0.6)
		S.SetRotation(rot(S.Rotation.Pitch,S.Rotation.Yaw,S.Rotation.Roll+32768));
}

state TriggeredFiring
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		GotoState( '' );
	}

Begin:
	TraceFire( None );
	//MuzzleFlash();
	Sleep( 0.12 );
	Goto( 'Begin' );
}

simulated function GetTraceFireSegment( out vector Start, out vector End, out vector BeamStart, optional float HorizError, optional float VertError )
{
	local rotator Offset;

	/*Offset = Rotation;
	Offset.Pitch += Rand( 4000 );
	Offset.Yaw += Rand( 4000 );
	Offset.Roll += Rand( 1200 );
	Start += Location + vector( Rotation ) * 72;
	BeamStart = Start+vector(rotation)*30;
	End = Location + vector( Offset ) * TraceDistance;*/
	Start = Location;
	End = Location + vector( Rotation ) * TraceDistance;

	BeamStart = Start+vector(rotation)*30;
}

defaultproperties
{
	TimeBetweenShots=0.15
	MinShotDamage=2
	TraceDistance=8000
    bHidden=true
	bBeamTraceHit=true
	HitPackageLevelClass=class'HitPackage_DukeLevel'
}