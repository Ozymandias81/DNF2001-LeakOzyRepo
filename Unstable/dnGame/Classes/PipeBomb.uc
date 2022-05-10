/*-----------------------------------------------------------------------------
	PipeBomb
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class PipeBomb extends dnGrenade;

var bool bCanPickup;
var vector LastWallHitNormal;
var float RollSpeed;

simulated function PostBeginPlay()
{
	Super(Projectile).PostBeginPlay();

	bExplodeEffectSpawned = true;
	if ( Role == ROLE_Authority )
	{
		bCollideWorld = true;
		bCanHitOwner = false;

		if ( Instigator.HeadRegion.Zone.bWaterZone )
		{
			bHitWater = true;
			Velocity = 0.6 * Velocity;
		}

//		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed + 50);// (Proj.Speed + FRand() * 100);
//		Velocity.Z += 200;

		RotationRate.Pitch = 16384;
		DesiredRotation = Rotation;
		DesiredRotation.Pitch += 16384;
	}

	DelayActorCollide();

	LoopAnim('centered');
}
/*
event PostNetInitial()
{
	local vector X, Y, Z;
	GetAxes(Instigator.ViewRotation,X,Y,Z);
	Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed + 50);// (Proj.Speed + FRand() * 100);
	Velocity.Z += 200;
}
*/
simulated function DelayActorCollide()
{
//	SetCallbackTimer( 0.3, true, 'EnableActorCollide' );
//	SetCollision( true, true, false );
}

simulated function EnableActorCollide()
{
//	EndCallbackTimer( 'EnableActorCollide' );
//	SetCollision( true, true, true );
}

//simulated function ProcessTouch( actor Other, vector HitLocation )
simulated singular function Touch( Actor Other )
{
	local Inventory Inv;
	local MultiBombAmmo Bomb;

	// Give the player the pipebomb.
	if ( bCanPickup && Other.IsA('PlayerPawn') )
	{
		if ( class'MultiBombAmmo'.static.CanPickup(Pawn(Other), class'MultiBombAmmo', Inv) )
		{
			if ( Role == ROLE_Authority )
			{
				Bomb = spawn(class'MultiBombAmmo');
				Bomb.Touch( Other );
				Bomb.Destroy();
				Destroy();
			}

			if ( (Pawn(Other).Weapon != None) &&
				 Pawn(Other).Weapon.IsA('MultiBomb') &&
				 (Pawn(Other).Weapon.GetStateName() == 'DetonatorIdle') )
				Pawn(Other).Weapon.GotoState('DetonatorDown');
		}
	}
}

simulated function Tick( float Delta )
{
	Super.Tick( Delta );

	if ( Physics == PHYS_Rolling )
		RotationRate.Pitch = -16384 * (VSize(Velocity) / RollSpeed) * 10;
}

// Special event called on PHYS_Rolling actors when movement delta < 10
simulated event StoppedRolling()
{
	StopMoving();
}

simulated function StopMoving()
{
	bCanPickup = true;
	SetCollision( true, false, false );
	Disable('Tick');
	bBounce = false;
	SetPhysics(PHYS_None);
	RotationRate.Pitch = 0;
	if ( MyFearSpot == None )
		MyFearSpot = Spawn( class'FearSpot', Instigator,, Location );
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	local Actor HitActor;
	local vector HitLoc, HitNorm;
	local float HitTime;

	if ( Physics == PHYS_Rolling )
		return;

	if ( bRollOnGround )
	{
		SetPhysics(PHYS_Rolling);
		RotationRate.Pitch = -20000;
		RollSpeed = VSize( Velocity );
		GroundFriction = -6;
		Enable('Tick');
		return;
	}

	return;

	if ( Wall.IsA('BreakableGlass') )
	{
		BreakableGlass(Wall).ReplicateBreakGlass( Location-(Velocity*2), true, 100.0f );
		return;
	}

	bCanHitOwner = true;
	Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);

	if ( !bHitWater && (HitNormal != LastWallHitNormal) && !bRollOnGround )
		RandSpin(100000);

	if ( (Level.NetMode != NM_DedicatedServer) && (speed > 50) && !bRollOnGround )
	{
		if ( (Wall != None) && Wall.IsA('Pawn') )
			PlayOwnedSound( sound'a_impact.body.ImpactBody15a', SLOT_Misc, FMax(0.5, speed/800) );
		else
			PlayOwnedSound( ImpactSound, SLOT_Misc, FMax(0.5, speed/800) );
	}

	if ( !bRollOnGround )
	{
		speed = VSize(Velocity);
		if ( Velocity.Z > 400 )
			Velocity.Z = 0.5 * (400 + Velocity.Z);	
		else if ( speed < 20 )
			StopMoving();
	}

	LastWallHitNormal = HitNormal;
}

simulated function RandSpin( float spinRate )
{
	DesiredRotation = RotRand();
	RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
}

// Pipebomb explosions are always relevant and not simulated.
function SpawnExplosionEffect( vector HitLocation, optional vector HitNormal )
{
	local actor s;

	bExplodeEffectSpawned = true;
  	s = spawn( ExplosionClass,,,HitLocation + HitNormal*16, rotator(HitNormal) );
	s.RemoteRole = ROLE_SimulatedProxy;
	s.bAlwaysRelevant = true;
}

defaultproperties
{
	Damage=100
	DamageClass=class'PipeBombDamage'
	Mesh=Mesh'c_dnWeapon.w_multipipe'
    bMeshLowerByCollision=false
    CollisionHeight=3.0
    CollisionRadius=7.0
    Health=1
	LodMode=LOD_Disabled
	DrawScale=0.8
	Speed=500
	MaxSpeed=500
    bCollideActors=true
    bCollideWorld=true
    bBlockActors=true
    bBlockPlayers=true
    bProjTarget=true
	bNetTemporary=false
	NetPriority=1.0
	AnimSequence=centered
	ExplosionClass=class'dnMultibombFX_Explosion_Flash'
}