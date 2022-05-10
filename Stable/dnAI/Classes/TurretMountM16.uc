class TurretMountM16 extends TurretMounts;

// a b c d 
//var() name MFlashMountMeshItem;
var() bool		bCauseDamage;
var() vector	MFlashOrigin;
var() rotator	MFlashMountAngles;
var() bool		bUseMuzzleFlash;
var() float		MFlashScale;
var() float		PauseBetweenShots;
var() name		MountToTag;

function Trigger( actor Other, pawn EventInstigator )
{
	GotoState( 'TriggeredFiring' );
}

function Actor GetActorWithTag( name MatchTag )
{
	local actor A;

	foreach allactors( class'Actor', A, MatchTag )
	{
		return A;
	}
}

simulated function MuzzleFlash()
{
	local actor S;
	local float RandRot;
	local actor MountToActor;

//	MuzzleFlashClass=class'M16Flash';

	S = Spawn(class'M16Flash');
	
	if( MountToTag != '' )
	{
		MountToActor = GetActorWithTag( MountToTag );
	}
	else
		MountToActor = self;

//	S.MountMeshItem = MFlashMountMeshItem;
	S.AttachActorToParent( MountToActor, true, true );
	S.MountType = MOUNT_Actor;
	S.MountOrigin = MFlashOrigin;
	S.MountAngles = MFlashMountAngles;
	if( MFlashScale > 0.0 )
		S.DrawScale = MFlashScale;
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
	if( bUseMuzzleFlash )
		MuzzleFlash();
	if( PauseBetweenShots > 0.0 )
	{
		Sleep( PauseBetweenShots );
	}
	else
		Sleep( 0.12 );
	Goto( 'Begin' );
}

function GetTraceFireSegment( out vector Start, out vector End, out vector BeamStart, optional float HorizError, optional float VertError )
{
	Start = Location;
	End = Location + vector( Rotation ) * TraceDistance;
}

simulated function int GetHitDamage( actor Victim, name BoneName )
{
	if ( bCauseDamage )
		return MinShotDamage + Rand( 2 );
	else
		return 0;
}

DefaultProperties
{
    bCauseDamage=true
	TimeBetweenShots=0.15
	MinShotDamage=2
	TraceDistance=8000
    bDirectional=true
    bUseMuzzleFlash=false
}