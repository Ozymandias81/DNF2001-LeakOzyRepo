/*-----------------------------------------------------------------------------
	MountableDecoration
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class MountableDecoration extends dnDecoration;

var bool					bCanBeShotOff;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( bCanBeShotOff )
	{
		bProjTarget = true;
		bCollideWorld = true;
		SetCollision( true, false, false );
	}
}

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	if ( !bCanBeShotOff )
		return;

	Pawn(Owner).RemoveMountable( Self );
	AttachActorToParent( none, false, false );
	SetPhysics(PHYS_Falling);
	Tossed();
	Velocity.Z += 100;
	bCollideWorld = true;
	LifeSpan = 20.0;
//	bMeshLowerByCollision=true;
}

function ZoneChange( ZoneInfo NewZone ) {}
function BaseChange() {}

defaultproperties
{
	bCollideWorld=false
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false
	bProjTarget=false
	CollisionRadius=0.0
	CollisionHeight=0.0
	Physics=PHYS_MovingBrush
	DestroyOnDismount=true
	LodMode=LOD_Disabled
	bOwnerSeeSpecial=true
	bMeshLowerByCollision=false
	bNotTargetable=true
}