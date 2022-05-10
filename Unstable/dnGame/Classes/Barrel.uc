/*-----------------------------------------------------------------------------
	Barrel
	Author: From Unreal, in here for Level Desginers dependent on old stuff.
-----------------------------------------------------------------------------*/
class Barrel extends Decoration;

var() int Health;

auto state Animate
{
	function HitWall ( vector HitNormal, actor Wall )
	{
		if ( Velocity.Z < -200 )
			TakeDamage( 100, Pawn(Owner), HitNormal, HitNormal*10000, class'ExplosionDamage' );
		bBounce = False;
		Velocity = vect(0,0,0);
	}

	function TakeDamage( int NDamage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType )
	{
		Instigator = InstigatedBy;
		bBobbing = false;
		if ( Health < 0 ) return;
		if ( Instigator != None )
			MakeNoise( 1.0 );
		Health -= NDamage;
	}
}

defaultproperties
{
     Health=10
     bPushable=true
     bStatic=false
     DrawType=DT_Sprite
     CollisionRadius=24.000000
     CollisionHeight=29.000000
     bCollideActors=true
     bCollideWorld=true
     bBlockActors=true
     bBlockPlayers=true
     Mass=50.000000
     Buoyancy=60.000000
}
