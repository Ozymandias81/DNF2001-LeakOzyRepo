/*-----------------------------------------------------------------------------
	dnGrenade
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnGrenade extends dnProjectile;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

var		bool						bCanHitOwner, bHitWater;
var		float						Count;
var()	int							NumExtraGrenades;
var()	class<SoftParticleSystem>	SplashClass;

var		FearSpot					MyFearSpot;

simulated function PostBeginPlay()
{
	local vector X,Y,Z;
	local rotator Rot;
	local actor SmokeTrail;

	Super.PostBeginPlay();
	SetTimer( 2.5+FRand()*0.5, false );

	if ( Role == ROLE_Authority )
	{
		GetAxes( Instigator.ViewRotation, X, Y, Z );	
		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * Speed;
		Velocity.Z += 75;

		SetRotation( Instigator.ViewRotation );
		bRotateToDesired = false;
		bFixedRotationDir = true;
		RotationRate.Pitch = -32768;

		bCanHitOwner = false;
		if ( Instigator.HeadRegion.Zone.bWaterZone )
		{
			bHitWater = true;
			Velocity = 0.6 * Velocity;			
		}
	}	

	SmokeTrail = spawn( class'dnGrenadeFX_GrenadeTrail' );
    SmokeTrail.AttachActorToParent( self, false, false );
    SmokeTrail.MountType = MOUNT_Actor;	
	SmokeTrail.SetPhysics( PHYS_MovingBrush );
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	if ( !NewZone.bWaterZone || bHitWater )
		return;

	bHitWater = true;
	RotationRate.Pitch /= 4;
	RotationRate.Yaw = 0;
	RotationRate.Roll = 0;
	Velocity.X *= 0.8;
	Velocity.Y *= 0.8;
	Velocity.Z *= 1.05;

	if ( SplashClass != None )
		spawn( SplashClass );
}

simulated function Timer( optional int TimerNum )
{
	Explode( Location+Vect(0,0,1)*16 );
}

simulated function Landed( vector HitNormal )
{
	HitWall( HitNormal, None );
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if ( (Other!=instigator) || bCanHitOwner )
		Explode( HitLocation );
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	bCanHitOwner = true;
	Velocity = 0.75*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);
	if ( !bHitWater )
		RandSpin(100000);
	speed = VSize(Velocity);
	if ( (Level.NetMode != NM_DedicatedServer) && (speed > 50) )
		PlayOwnedSound( ImpactSound, SLOT_Misc, FMax(0.5, speed/800) );
	if ( speed < 20 ) 
	{
		bBounce = false;
		SetPhysics( PHYS_None );
		if ( MyFearSpot == None )
			MyFearSpot = Spawn( class'FearSpot', Instigator,, Location );
	}
}

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	Explode( HitLocation );
}

simulated function Destroyed()
{
	Super.Destroyed();

	if ( !bExplodeEffectSpawned )
		SpawnExplosionEffect( Location+Vect(0,0,1)*16 );

 	if ( MyFearSpot != None )
		MyFearSpot.Destroy();
}

defaultproperties
{
	 DamageRadius=200.0
	 DamageClass=class'GrenadeDamage'
	 ExplosionClass=class'dnGrenadeFX_Explosion_Flash'
	 SplashClass=dnParticles.dnWallWaterSplash
     Speed=1000.0
     MaxSpeed=1500.0
     Damage=100.0
     MomentumTransfer=50000
	 mass=300
	 buoyancy=301
     ImpactSound=sound'dnsweapn.m16.m16GrenBounce'
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     AmbientGlow=64
     bBounce=true
     bFixedRotationDir=true
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
     Mesh=Mesh'c_dnWeapon.m16grenade'
 	 LodMode=LOD_Disabled
	 LifeSpan=0
	 bShadowCast=true
	 bShadowReceive=true
}
