/*-----------------------------------------------------------------------------
	FreezerCollisionActor
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class FreezerCollisionActor extends ParticleCollisionActor;

var float StartColHeight, EndColHeight;
var float StartColRadius, EndColRadius;
var float DamagePerTouch;

event Locked()
{
	SetCollision( true, false, false );
}

event Unlocked()
{
	SetCollision( false, false, false );
	SetCollisionSize( StartColRadius, StartColHeight );
}

event Update()
{
	local float ColHeight, ColRadius, Alpha;

	Alpha = pLifetimeRemaining / pLifetime;
	ColHeight = Lerp( Alpha, EndColHeight, StartColHeight );
	ColRadius = Lerp( Alpha, EndColRadius, StartColRadius );
	SetCollisionSize( ColRadius, ColHeight );
}

function Touch( Actor Other )
{
	if ( (Other.bIsRenderActor) && (Other != MyParticleSystem.CollisionInstigator) )
	{
		if ( Other.bIsPawn )
			RenderActor( Other ).TakeDamage( DamagePerTouch, MyParticleSystem.CollisionInstigator, Location, vect(0,0,0), class'ColdDamage' );
		else
			RenderActor( Other ).TakeDamage( 0, MyParticleSystem.CollisionInstigator, Location, vect(0,0,0), class'ColdDamage' );
	}
}

defaultproperties
{
	DamagePerTouch=3
	bCollideWorld=false
	StartColHeight=5
	EndColHeight=30
	StartColRadius=5
	EndColRadius=30
	bBurning=true
}