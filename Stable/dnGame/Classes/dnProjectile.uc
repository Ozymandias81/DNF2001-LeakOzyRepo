/*-----------------------------------------------------------------------------
	dnProjectile
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnProjectile extends Projectile;

var() bool				ApplyGravity;
var() vector			TargetOffset;
var() class<Actor>		ExplosionClass;
var() float				DamageRadius;
var() class<DamageType> DamageClass;

var() float				VibrationIntensity, VibrationElasticity, VibrationPeriod;
var() bool				bExplodeEffectSpawned;

var   bool				bRollOnGround;

replication
{
	unreliable if ( Role == ROLE_Authority )
		bRollOnGround;
}

simulated function DelayActorCollide()
{
}

simulated function Explode( vector HitLocation, optional vector HitNormal, optional bool bNoDestroy )
{
	DoDamage( HitLocation );
	SpawnExplosionEffect( HitLocation, HitNormal );
	VibrateArea();
	if ( !bNoDestroy )
		Destroy();
}

function DoDamage( vector HitLocation )
{
	HurtRadius( Damage, DamageRadius, DamageClass, MomentumTransfer, HitLocation );
	MakeNoise( 1.0 );
}

simulated function SpawnExplosionEffect( vector HitLocation, optional vector HitNormal )
{
	local actor s;

	bExplodeEffectSpawned = true;
  	s = spawn( ExplosionClass,,,HitLocation + HitNormal*16, rotator(HitNormal) );
	s.RemoteRole = ROLE_None;
}

simulated function VibrateArea()
{
	local Pawn P;

	P = Level.PawnList;
	while ( P != None )
	{
		if ( P.bIsPlayerPawn && (VSize(Location-P.Location)<DamageRadius+150) )
		{
			PlayerPawn(P).AddVibration( VibrationIntensity, 1.0, VibrationElasticity, VibrationPeriod );
		}
		P = P.nextPawn;
	}
}

defaultproperties
{
	TraceHitCategory=TH_Projectile
	VibrationElasticity=0.9
	VibrationPeriod=0.003
	VibrationIntensity=20.0
}