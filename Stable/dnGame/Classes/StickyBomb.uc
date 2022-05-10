/*-----------------------------------------------------------------------------
	StickyBomb
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class StickyBomb extends dnGrenade;

var bool bCanCollideMesh;
var vector ParentLastLocation;
var rotator ParentLastRotation;

var float MountBarysX, MountBarysY, MountBarysZ;

var int WarnCount;
var sound WarnSound;

replication
{
	reliable if ( Role == ROLE_Authority )
		MountBarysX, MountBarysY, MountBarysZ;
}

// Someone set us up the bomb.
simulated function PostBeginPlay()
{
	local vector X,Y,Z;

	// You are on your way to destruction.
	Super(Projectile).PostBeginPlay();
	SetTimer( 4.0, true );

	if ( Role == ROLE_Authority )
	{
		bCollideWorld = true;
		bCanHitOwner = false;
		bCanCollideMesh = true;
		Disable('Tick');
		
		if (Instigator.HeadRegion.Zone.bWaterZone)
		{
			bHitWater = true;
			Velocity=0.6*Velocity;
		}

		RotationRate.Pitch = 16384;
		DesiredRotation = Rotation;
		DesiredRotation.Pitch += 16384;
	}

	AnimSequence = 'centered';
}

// You cannot survive, make your time.
simulated function Timer( optional int TimerNum )
{
	local Actor Found, A;

	if ( WarnCount == 0 )
		PlaySound( WarnSound, SLOT_Interact, 1.0, false, 800 );
	WarnCount++;
	if ( WarnCount > 19 )
		WarnCount = 0;

	if ( Role == ROLE_Authority )
	{
		foreach VisibleActors( class'Actor', A, 150 )
		{
			if ( !A.IsA('Mover') && (VSize(A.Velocity) > 0) )
			{
				Found = A;
				break;
			}
		}

		if ( Found != None )
			Explode( Location );
		else if ( MountParent != None )
		{
			if ( ParentLastLocation != MountParent.Location )
				Explode( Location );
			else if ( ParentLastRotation != MountParent.Rotation )
				Explode( Location );

			ParentLastLocation = MountParent.Location;
			ParentLastRotation = MountParent.Rotation;
		}
	}

	SetTimer(0.10, true);
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	local rotator HitRot;

	if ( Wall != Level )
	{
		if ( bCanCollideMesh )
			Enable('Tick');
		return;
	}

	bAlwaysRelevant = true;
	bCanHitOwner = true;
	bBounce = false;

	if ( MyFearSpot != None )
		MyFearSpot = Spawn( class'FearSpot', Instigator,, Location );

	HitRot = rotator(HitNormal);
	if ( HitNormal != vect(0,0,1) )
		SetRotation( HitRot );
	RotationRate.Pitch = 0;

	if ( Role == ROLE_Authority )
	{
		SetPhysics(PHYS_None);
		Disable('Tick');
	} else
		SetPhysics(PHYS_MovingBrush);

	SetCollision(true,true,false);
	bCanCollideMesh = false;
}

simulated function Landed( vector HitNormal )
{
	Super.Landed( HitNormal );
	if ( Role == ROLE_Authority )
		Disable('Tick');
	bCanCollideMesh = false;
	RotationRate.Pitch = 0;
	bAlwaysRelevant = true;
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if ( bCanCollideMesh )
		Enable('Tick');
}

simulated function Tick( float Delta )
{
	local vector HitLocation, HitNormal, HitMeshBarys, EndTrace, StartTrace, X, Y, Z;
	local name HitMeshBone;
	local int HitMeshTri;
	local Actor Other;
	local MeshInstance minst;

	if ( Role < ROLE_Authority )
	{
		if ( MountParent != None )
		{
			SetPhysics(PHYS_MovingBrush);
			MountMeshSurfaceBarys = vect( MountBarysX, MountBarysY, MountBarysZ );
			bCollideWorld = false;
			SetCollision(false,false,false);
			ParentLastLocation = MountParent.Location;
			ParentLastRotation = MountParent.Rotation;
			bOwnerSeeSpecial = true;
			bAlwaysRelevant = true;
			Disable('Tick');
		}
		return;
	}

	if ( MountParent != None )
		return;

	// See if there is something to attach onto.
	GetAxes(Rotation, X, Y, Z);

	// Trade from middle.
	StartTrace = Location;
	EndTrace = Location + Velocity*Delta;
	Other = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, , true, HitMeshTri, HitMeshBarys, HitMeshBone );
	if ( Other == None )
	{
		// Trace from half left.
		StartTrace = Location - Y*(CollisionRadius/2);
		EndTrace = Location - Y*(CollisionRadius/2) + Velocity*Delta;
		Other = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, , true, HitMeshTri, HitMeshBarys, HitMeshBone );
	}
	if ( Other == None )
	{
		// Trace from left.
		StartTrace = Location - Y*CollisionRadius;
		EndTrace = Location - Y*CollisionRadius + Velocity*Delta;
		Other = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, , true, HitMeshTri, HitMeshBarys, HitMeshBone );
	}
	if ( Other == None )
	{
		// Trace from half right.
		StartTrace = Location + Y*(CollisionRadius/2);
		EndTrace = Location + Y*(CollisionRadius/2) + Velocity*Delta;
		Other = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, , true, HitMeshTri, HitMeshBarys, HitMeshBone );
	}
	if ( Other == None )
	{
		// Trace from right.
		StartTrace = Location + Y*CollisionRadius;
		EndTrace = Location + Y*CollisionRadius + Velocity*Delta;
		Other = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, , true, HitMeshTri, HitMeshBarys, HitMeshBone );
	}

	if ( (Other != None) && (Other != Level) && ((Other != Instigator) || bCanHitOwner) )
	{
		// Zero out some settings.
		bCollideWorld = false;
		SetCollision(false,false,false);
		bFixedRotationDir = false;

		// Mount to the actor.
		SetPhysics(PHYS_MovingBrush);
		MountType			   = MOUNT_MeshSurface;
		MountMeshSurfaceTri    = HitMeshTri;
		MountMeshSurfaceBarys  = HitMeshBarys;
		MountBarysX = HitMeshBarys.X;
		MountBarysY = HitMeshBarys.Y;
		MountBarysZ = HitMeshBarys.Z;
		bMountRotationRelative = true;
		AttachActorToParent( Other, false, false );
		bOwnerSeeSpecial = true;

		SetOwner(Other);

		ParentLastLocation = MountParent.Location;
		ParentLastRotation = MountParent.Rotation;

		bAlwaysRelevant = true;

		// Spawn a fear location.
//		MyFearSpot = Spawn( class'FearSpot', Instigator,, Location );
//		MyFearSpot.AttachActorToParent( Self, false, false );

		bCanCollideMesh = false;
		Disable('Tick');
	}
}

static function BlowUpStickies( StickyBomb Sticky, Actor Other )
{
	foreach Other.AllActors( class'StickyBomb', Sticky )
	{
		if ( Sticky.Owner == Other )
			Sticky.Explode( Sticky.Location );
	}
}

defaultproperties
{
	Damage=100
	DamageRadius=250
	DamageClass=class'StickyBombDamage'
	Mesh=Mesh'c_dnWeapon.w_multistick'
    bMeshLowerByCollision=true
    CollisionHeight=3.0
    CollisionRadius=7.0
    Health=1
	LodMode=LOD_Disabled
	DrawScale=0.8
	Speed=500
	MaxSpeed=500
    bCollideActors=true
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    bProjTarget=true
    Health=1
	bNetTemporary=false
	NetPriority=1.0
	WarnSound=sound'dnsWeapn.Bombs.StickyBombWarn1'
	ExplosionClass=class'dnMultibombFX_Explosion_Flash'
}
